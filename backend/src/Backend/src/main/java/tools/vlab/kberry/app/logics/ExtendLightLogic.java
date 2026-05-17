package tools.vlab.kberry.app.logics;

import tools.vlab.kberry.app.settings.LightSettingsVerticle;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.knx.devices.actor.Light;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.log.Logger;
import tools.vlab.kberry.server.logic.AutoLightOnLogic;
import tools.vlab.kberry.server.logic.AutoPresenceKnxOffLogic;
import tools.vlab.kberry.server.scheduler.trigger.Daily;

import java.time.LocalTime;

public class ExtendLightLogic {


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
            Logger.info(positionPath,"Add Auto Light On in the specific time!");
            command.register(positionPath, "presence_on_light_start", Daily.trigger(settings.getStartAutoOnTime()),
                    () -> registerLightLogic(positionPath, settings));
            command.register(positionPath, "presence_on_light_end", Daily.trigger(settings.getEndStartAutoOnTime()),
                    () -> command.getLogicEngine().unregister(positionPath, AutoLightOnLogic.LOGIC_NAME));
            // Init after start
            if (LocalTime.now().isAfter(settings.getStartAutoOnTime()) && LocalTime.now().isBefore(settings.getEndStartAutoOnTime())) {
                Logger.info(positionPath, "Init Auto Light On for room!");
                registerLightLogic(positionPath, settings);
            } else {
                command.getLogicEngine().unregister(positionPath, AutoLightOnLogic.LOGIC_NAME);
            }
        } else if (settings.isPresenceOn()) {
            Logger.info(positionPath,"Add Auto Light On");
            command.unregister(positionPath, "presence_on_light_start");
            command.unregister(positionPath, "presence_on_light_end");
            registerLightLogic(positionPath, settings);
        } else {
            Logger.info(positionPath,"Remove Auto Light On [Logic: {}]", command.getLogicEngine().getLogicNames(positionPath));
            command.unregister(positionPath, "presence_on_light_start");
            command.unregister(positionPath, "presence_on_light_end");
            command.getLogicEngine().unregister(positionPath, AutoLightOnLogic.LOGIC_NAME);
        }

        // OFF
        if (settings.isPresenceOff()) {
            var logic = AutoPresenceKnxOffLogic.at(Light.class, settings.getHoldTimeMinute() * 60, positionPath);
            command.getLogicEngine().register(logic);
        } else {
            command.getLogicEngine().unregister(positionPath, AutoPresenceKnxOffLogic.LOGIC_NAME);
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
