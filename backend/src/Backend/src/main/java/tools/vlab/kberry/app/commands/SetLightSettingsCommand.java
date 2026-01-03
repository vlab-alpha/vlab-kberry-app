package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.settings.LightSettingsVerticle;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.actor.Light;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.logic.AutoLightOnLogic;
import tools.vlab.kberry.server.logic.AutoPresenceOffLogic;
import tools.vlab.kberry.server.settings.Settings;

import java.util.Optional;

public class SetLightSettingsCommand extends Command {

    private final LightSettingsVerticle settings;
    private final Settings<String> autoOffLogic = new LogicIdStore();
    private final Settings<String> autoOnLogic = new LogicIdStore();

    public SetLightSettingsCommand(LightSettingsVerticle settings) {
        this.settings = settings;
    }

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));
        var light = tools.vlab.kberry.app.settings.Light.fromSettings(message.getJsonArray("settings").stream().map(o -> ((JsonObject) o)).toList());
        this.setLightLogic(positionPath, light);
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
                        .ifPresent(setting -> setLightLogic(device.getPositionPath(), setting)));
    }


    private void setLightLogic(PositionPath positionPath, tools.vlab.kberry.app.settings.Light settings) {
        autoOffLogic.getSetting(positionPath).ifPresent(logicId -> this.getLogics().unregister(logicId));
        autoOnLogic.getSetting(positionPath).ifPresent(logicId -> this.getLogics().unregister(logicId));
        // ON
        if (settings.isOnlyDark() && settings.isPresenceOn()) {
            var logic = AutoLightOnLogic.at(settings.getMinLux(), positionPath);
            autoOnLogic.setSettingAsync(positionPath, logic.getId());
            this.getLogics().register(logic);
        } else if (settings.isPresenceOn()) {
            var logic = AutoLightOnLogic.at(positionPath);
            autoOnLogic.setSettingAsync(positionPath, logic.getId());
            this.getLogics().register(logic);
        }
        // OFF
        if (settings.isPresenceOff()) {
            var logic = AutoPresenceOffLogic.at(settings.getHoldTimeMinute(), positionPath);
            autoOffLogic.setSettingAsync(positionPath, logic.getId());
            this.getLogics().register(logic);
        }
    }


}
