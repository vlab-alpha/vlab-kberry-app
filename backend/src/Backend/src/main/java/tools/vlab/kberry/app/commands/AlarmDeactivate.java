package tools.vlab.kberry.app.commands;

import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.logics.AlarmLogic;
import tools.vlab.kberry.core.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.commands.Scene;

public class AlarmDeactivate extends Scene {

    public AlarmDeactivate() {
    }

    @Override
    public void executeScene(JsonObject message) {
        this.getKnxDevices().getAllPositionPaths().forEach(positionPath -> this.getLogicEngine().unregister(positionPath, AlarmLogic.LOGIC_NAME));
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
        return Commands.ALARM_OFF;
    }

    @Override
    public void init() {

    }
}
