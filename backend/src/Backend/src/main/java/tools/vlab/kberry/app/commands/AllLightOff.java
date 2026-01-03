package tools.vlab.kberry.app.commands;

import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.core.devices.actor.Light;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.commands.Scene;

public class AllLightOff extends Scene {


    @Override
    public void executeScene(JsonObject message) {
        this.getKnxDevices().getKNXDevices(Light.class).forEach(Light::off);
    }

    @Override
    public CommandTopic topic() {
        return Commands.ALL_LIGHT_OFF;
    }

    @Override
    public void init() {

    }
}
