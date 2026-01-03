package tools.vlab.kberry.app.commands;

import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.core.devices.HeaterMode;
import tools.vlab.kberry.core.devices.actor.FloorHeater;
import tools.vlab.kberry.core.devices.actor.Jalousie;
import tools.vlab.kberry.core.devices.actor.Light;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.commands.Scene;

public class HolidayStart extends Scene {

    @Override
    public void executeScene(JsonObject message) {
        getKnxDevices().getKNXDevices(FloorHeater.class).forEach(floorHeater -> floorHeater.setMode(HeaterMode.FROST_PROTECTION));
        getKnxDevices().getKNXDevices(Light.class).forEach(Light::off);
        getKnxDevices().getKNXDevices(Jalousie.class).forEach(Jalousie::down);
    }

    @Override
    public CommandTopic topic() {
        return Commands.HOLIDAY_START;
    }

    @Override
    public void init() {

    }
}
