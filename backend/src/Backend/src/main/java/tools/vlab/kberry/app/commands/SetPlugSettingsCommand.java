package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.settings.Plug;
import tools.vlab.kberry.app.settings.PlugSettingsVerticle;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.logic.AutoPresenceOffLogic;
import tools.vlab.kberry.server.logic.AutoUsageOffLogic;
import tools.vlab.kberry.server.settings.Settings;

import java.util.Optional;

public class SetPlugSettingsCommand extends Command {

    private final PlugSettingsVerticle settings;
    private final Settings<String> autoOffLogic = new LogicIdStore();
    private final Settings<String> usageOffLogic = new LogicIdStore();

    public SetPlugSettingsCommand(PlugSettingsVerticle settings) {
        this.settings = settings;
    }

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        Haus positionPath = Haus.positionPath(message.getString("positionPath"));
        var plug = Plug.fromSettings(message.getJsonArray("settings").stream().map(o -> ((JsonObject) o)).toList());
        setPlugOffLogic(positionPath, plug);
        return this.settings
                .setSettingAsync(positionPath, plug)
                .map(none -> Optional.empty());
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_PLUG_SETTINGS;
    }

    @Override
    public void init() {
        this.getKnxDevices().getKNXDevices(tools.vlab.kberry.core.devices.actor.Plug.class)
                .forEach(device -> settings.getSetting(device.getPositionPath())
                        .filter(Plug::isPresenceOff)
                        .ifPresent(settings-> setPlugOffLogic(device.getPositionPath(), settings)));
    }

    private void setPlugOffLogic(PositionPath positionPath, tools.vlab.kberry.app.settings.Plug settings) {
        autoOffLogic.getSetting(positionPath).ifPresent(logicId -> this.getLogics().unregister(logicId));
        usageOffLogic.getSetting(positionPath).ifPresent(logicId -> this.getLogics().unregister(logicId));
        if (settings.isUsageTime()) {
            // USAGE OFF
            var logic = AutoUsageOffLogic.at(settings.getMaxUsageTimeMinutes(), positionPath);
            usageOffLogic.getSetting(positionPath);
            this.getLogics().register(logic);
        } else if (settings.isPresenceOff()) {
            // PRESENCE OFF
            var logic = AutoPresenceOffLogic.at(settings.getHoldTimeMinute() * 60, positionPath);
            autoOffLogic.setSettingAsync(positionPath, logic.getId());
            this.getLogics().register(logic);
        }
    }

}
