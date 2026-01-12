package tools.vlab.kberry.app.commands;

import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.HeaterMode;
import tools.vlab.kberry.core.devices.actor.FloorHeater;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.commands.Scene;

public class HolidayEnd extends Scene {

    @Override
    public void executeScene(JsonObject message) {
        getKnxDevices().getKNXDevices(FloorHeater.class).forEach(floorHeater -> floorHeater.setMode(HeaterMode.COMFORT));
    }

    @Override
    public PositionPath getPositionPath() {
        return Haus.HallwayWall;
    }

    @Override
    public String getIcon() {
        return "beach_access_outlined";
    }

    @Override
    public String getName() {
        return "Beende Urlaub";
    }

    @Override
    public CommandTopic topic() {
        return Commands.HOLIDAY_END;
    }

    @Override
    public void init() {

    }
}
