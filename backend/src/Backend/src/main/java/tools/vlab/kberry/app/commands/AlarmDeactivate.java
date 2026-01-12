package tools.vlab.kberry.app.commands;

import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.core.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.commands.Scene;
import tools.vlab.kberry.server.settings.Settings;

public class AlarmDeactivate extends Scene {

    private final Settings<String> alarmLogic;

    public AlarmDeactivate(Settings<String> alarmLogic) {
        this.alarmLogic = alarmLogic;
    }

    @Override
    public void executeScene(JsonObject message) {
        this.getKnxDevices().getAllPositionPaths().forEach(positionPath -> alarmLogic.getSetting(positionPath).ifPresent(logicId -> this.getLogics().unregister(logicId)));
    }

    @Override
    public PositionPath getPositionPath() {
        return Haus.HallwayWall;
    }

    @Override
    public String getIcon() {
        return "access_alarm";
    }

    @Override
    public String getName() {
        return "Alarm Aus";
    }

    @Override
    public CommandTopic topic() {
        return Commands.ALARM_OFF;
    }

    @Override
    public void init() {

    }
}
