package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.settings.Plug;
import tools.vlab.kberry.app.settings.PlugSettingsVerticle;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.logic.AutoPresenceKnxOffLogic;
import tools.vlab.kberry.server.logic.AutoPresenceShellyOffLogic;
import tools.vlab.kberry.server.logic.AutoUsageKnxOffLogic;
import tools.vlab.kberry.server.logic.AutoUsageShellyOffLogic;

import java.util.Optional;

public class SetPlugSettingsCommand extends Command {

    private final PlugSettingsVerticle settings;

    public SetPlugSettingsCommand(PlugSettingsVerticle settings) {
        this.settings = settings;
    }

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        Haus positionPath = Haus.positionPath(message.getString("positionPath"));
        var plug = Plug.fromSettings(message.getJsonArray("settings").stream().map(o -> ((JsonObject) o)).toList());
        setPlugKnxOffLogic(positionPath, plug);
        setShellyPlugOffLogic(positionPath, plug);
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
        this.getKnxDevices().getKNXDevices(tools.vlab.kberry.core.knx.devices.actor.Plug.class)
                .forEach(device -> settings.getSetting(device.getPositionPath())
                        .filter(Plug::isPresenceOff)
                        .ifPresent(settings-> setPlugKnxOffLogic(device.getPositionPath(), settings)));
        this.getShellyDevices().getDevices(tools.vlab.kberry.core.mqtt.shelly.devices.device.Plug.class)
                .forEach(device-> settings.getSetting(device.getPositionPath())
                        .filter(Plug::isPresenceOff)
                        .ifPresent(settings-> setShellyPlugOffLogic(device.getPositionPath(), settings)));
    }

    private void setPlugKnxOffLogic(PositionPath positionPath, tools.vlab.kberry.app.settings.Plug settings) {
        if (settings.isUsageTime()) {
            // USAGE OFF
            this.getLogicEngine().unregister(positionPath, AutoPresenceKnxOffLogic.LOGIC_NAME);
            this.getLogicEngine().register(AutoUsageKnxOffLogic.at(settings.getMaxUsageTimeMinutes(), positionPath));
        } else if (settings.isPresenceOff()) {
            // PRESENCE OFF
            this.getLogicEngine().unregister(positionPath, AutoUsageKnxOffLogic.LOGIC_NAME);
            this.getLogicEngine().register(AutoPresenceKnxOffLogic.at(tools.vlab.kberry.core.knx.devices.actor.Plug.class, settings.getHoldTimeMinute() * 60, positionPath));
        } else {
            this.getLogicEngine().unregister(positionPath, AutoPresenceKnxOffLogic.LOGIC_NAME);
            this.getLogicEngine().unregister(positionPath, AutoUsageKnxOffLogic.LOGIC_NAME);
        }
    }

    private void setShellyPlugOffLogic(PositionPath positionPath, tools.vlab.kberry.app.settings.Plug settings) {
        if (settings.isUsageTime()) {
            // USAGE OFF
            this.getLogicEngine().unregister(positionPath, AutoPresenceShellyOffLogic.LOGIC_NAME);
            this.getLogicEngine().register(AutoUsageShellyOffLogic.at(settings.getMaxUsageTimeMinutes(), positionPath));
        } else if (settings.isPresenceOff()) {
            // PRESENCE OFF
            this.getLogicEngine().unregister(positionPath, AutoUsageShellyOffLogic.LOGIC_NAME);
            this.getLogicEngine().register(AutoUsageShellyOffLogic.at(settings.getHoldTimeMinute() * 60, positionPath));
        } else {
            this.getLogicEngine().unregister(positionPath, AutoPresenceShellyOffLogic.LOGIC_NAME);
            this.getLogicEngine().unregister(positionPath, AutoUsageShellyOffLogic.LOGIC_NAME);
        }
    }

}
