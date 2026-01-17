package tools.vlab.kberry.app.logics;

import tools.vlab.kberry.app.commands.LogicIdStore;
import tools.vlab.kberry.app.settings.LightSettingsVerticle;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.logic.AutoLightOnLogic;
import tools.vlab.kberry.server.logic.AutoPresenceOffLogic;
import tools.vlab.kberry.server.scheduler.trigger.Daily;
import tools.vlab.kberry.server.settings.Settings;

public class ExtendLightLogic {

    private final Settings<String> autoOffLogic = new LogicIdStore();
    private final Settings<String> autoOnLogic = new LogicIdStore();
    private final Command command;
    private final LightSettingsVerticle settingsVerticle;

    public ExtendLightLogic(Command command, LightSettingsVerticle settingsVerticle) {
        this.command = command;
        this.settingsVerticle = settingsVerticle;
    }

    public void disable(PositionPath positionPath) {
        autoOnLogic.getSetting(positionPath).ifPresent(logicId -> command.getLogics().unregister(logicId));
    }

    public void enable(PositionPath positionPath) {
        settingsVerticle.getSetting(positionPath).ifPresent(settings -> setLightLogic(positionPath, settings));
    }

    public void setLightLogic(PositionPath positionPath, tools.vlab.kberry.app.settings.Light settings) {
        autoOffLogic.getSetting(positionPath).ifPresent(logicId -> command.getLogics().unregister(logicId));

        // ON
        if (settings.isPresenceOnDuringTime() && settings.isPresenceOn()) {
            command.register(positionPath, "presence_on_light_start", Daily.trigger(settings.getStartAutoOnTime()),
                    () -> registerLightLogic(positionPath, settings));
            command.register(positionPath, "presence_on_light_end", Daily.trigger(settings.getEndStartAutoOnTime()),
                    () -> autoOnLogic.getSetting(positionPath).ifPresent(logicId -> command.getLogics().unregister(logicId)));
        } else if (settings.isPresenceOn()) {
            command.unregister(positionPath, "presence_on_light_start");
            command.unregister(positionPath, "presence_on_light_end");
            autoOnLogic.getSetting(positionPath).ifPresent(logicId -> command.getLogics().unregister(logicId));
            registerLightLogic(positionPath, settings);
        } else {
            command.unregister(positionPath, "presence_on_light_start");
            command.unregister(positionPath, "presence_on_light_end");
            autoOnLogic.getSetting(positionPath).ifPresent(logicId -> command.getLogics().unregister(logicId));
        }

        // OFF
        if (settings.isPresenceOff()) {
            var logic = AutoPresenceOffLogic.at(settings.getHoldTimeMinute() * 60, positionPath);
            autoOffLogic.setSettingAsync(positionPath, logic.getId());
            command.getLogics().register(logic);
        }
    }

    public void registerLightLogic(PositionPath positionPath, tools.vlab.kberry.app.settings.Light settings) {
        if (settings.isOnlyDark() && settings.isPresenceOn()) {
            var logic = AutoLightOnLogic.at(settings.getMinLux(), positionPath);
            autoOnLogic.setSettingAsync(positionPath, logic.getId());
            command.getLogics().register(logic);
        } else if (settings.isPresenceOn()) {
            var logic = AutoLightOnLogic.at(positionPath);
            autoOnLogic.setSettingAsync(positionPath, logic.getId());
            command.getLogics().register(logic);
        }
    }

}
