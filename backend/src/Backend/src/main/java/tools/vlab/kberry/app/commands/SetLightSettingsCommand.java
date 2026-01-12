package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import lombok.Getter;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.logics.ExtendLightLogic;
import tools.vlab.kberry.app.settings.LightSettingsVerticle;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.actor.Light;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class SetLightSettingsCommand extends Command {

    private final LightSettingsVerticle settings;
    @Getter
    private final ExtendLightLogic logic;

    public SetLightSettingsCommand(LightSettingsVerticle settings) {
        this.settings = settings;
        this.logic = new ExtendLightLogic(this, settings);
    }

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));
        var light = tools.vlab.kberry.app.settings.Light.fromSettings(message.getJsonArray("settings").stream().map(o -> ((JsonObject) o)).toList());
        this.logic.setLightLogic(positionPath, light);
        return this.settings
                .setSettingAsync(positionPath, light)
                .map(none -> Optional.empty());
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_LIGHT_SETTINGS;
    }

    @Override
    public void init() {
        this.getKnxDevices()
                .getKNXDevices(Light.class)
                .forEach(device -> settings.getSetting(device.getPositionPath())
                        .ifPresent(setting -> this.logic.setLightLogic(device.getPositionPath(), setting)));
    }

}
