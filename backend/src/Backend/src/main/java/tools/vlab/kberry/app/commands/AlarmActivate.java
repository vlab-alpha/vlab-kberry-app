package tools.vlab.kberry.app.commands;

import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.logics.AlarmLogic;
import tools.vlab.kberry.app.logics.MailService;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.commands.Scene;
import tools.vlab.kberry.server.settings.Settings;

public class AlarmActivate extends Scene {

    private final MailService mailService;
    private final Settings<String> alarmLogic;

    public AlarmActivate(MailService mailService, Settings<String> alarmLogic) {
        this.mailService = mailService;
        this.alarmLogic = alarmLogic;
    }

    @Override
    public void executeScene(JsonObject message) {
        this.getKnxDevices().getAllPositionPaths().forEach(positionPath -> {
            alarmLogic.getSetting(positionPath).ifPresent(logicId -> this.getLogics().unregister(logicId));
            var logic = AlarmLogic.at(mailService, positionPath);
            alarmLogic.setSettingAsync(positionPath, logic.getId());
            this.getLogics().register(logic);
        });
    }

    @Override
    public PositionPath getPositionPath() {
        return Haus.HallwayWall;
    }

    @Override
    public String getIcon() {
        return "alarm_off";
    }

    @Override
    public String getName() {
        return "Alarm Aus";
    }

    @Override
    public CommandTopic topic() {
        return Commands.ALARM_ON;
    }

    @Override
    public void init() {

    }
}
