package tools.vlab.kberry.app.logics;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import tools.vlab.kberry.app.settings.LightSettingsVerticle;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.logic.AutoLightOnLogic;
import tools.vlab.kberry.server.logic.AutoPresenceLightOffLogic;
import tools.vlab.kberry.server.scheduler.trigger.Daily;

public class ExtendLightLogic {

    private final static Logger Log = LoggerFactory.getLogger(ExtendLightLogic.class);

    private final Command command;
    private final LightSettingsVerticle settingsVerticle;

    public ExtendLightLogic(Command command, LightSettingsVerticle settingsVerticle) {
        this.command = command;
        this.settingsVerticle = settingsVerticle;
    }

    public void disable(PositionPath positionPath) {
        command.getLogicEngine().unregister(positionPath, AutoLightOnLogic.LOGIC_NAME);
    }

    public void enable(PositionPath positionPath) {
        settingsVerticle.getSetting(positionPath).ifPresent(settings -> setLightLogic(positionPath, settings));
    }

    public void setLightLogic(PositionPath positionPath, tools.vlab.kberry.app.settings.Light settings) {

        // ON
        if (settings.isPresenceOnDuringTime() && settings.isPresenceOn()) {
            Log.info("Add Auto Light On for room {} in the specific time!", positionPath.getRoom());
            command.register(positionPath, "presence_on_light_start", Daily.trigger(settings.getStartAutoOnTime()),
                    () -> registerLightLogic(positionPath, settings));
            command.register(positionPath, "presence_on_light_end", Daily.trigger(settings.getEndStartAutoOnTime()),
                    () -> command.getLogicEngine().unregister(positionPath, AutoLightOnLogic.LOGIC_NAME));
        } else if (settings.isPresenceOn()) {
            Log.info("Add Auto Light On for room {}", positionPath.getRoom());
            command.unregister(positionPath, "presence_on_light_start");
            command.unregister(positionPath, "presence_on_light_end");
            registerLightLogic(positionPath, settings);
        } else {
            Log.info("Remove Auto Light On for room {} [Logic: {}]", positionPath.getRoom(), command.getLogicEngine().getLogicNames(positionPath));
            command.unregister(positionPath, "presence_on_light_start");
            command.unregister(positionPath, "presence_on_light_end");
            command.getLogicEngine().unregister(positionPath, AutoLightOnLogic.LOGIC_NAME);
        }

        // OFF
        if (settings.isPresenceOff()) {
            var logic = AutoPresenceLightOffLogic.at(settings.getHoldTimeMinute() * 60, positionPath);
            command.getLogicEngine().register(logic);
        } else {
            command.getLogicEngine().unregister(positionPath, AutoPresenceLightOffLogic.LOGIC_NAME);
        }
    }

    public void registerLightLogic(PositionPath positionPath, tools.vlab.kberry.app.settings.Light settings) {
        if (settings.isOnlyDark() && settings.isPresenceOn()) {
            var logic = AutoLightOnLogic.at(settings.getMinLux(), positionPath);
            command.getLogicEngine().register(logic);
        } else if (settings.isPresenceOn()) {
            var logic = AutoLightOnLogic.at(positionPath);
            command.getLogicEngine().register(logic);
        }
    }

}
