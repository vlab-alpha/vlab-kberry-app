package tools.vlab.kberry.app.commands;

import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.core.devices.actor.Jalousie;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.commands.Scene;

public class AllJalousieDown extends Scene {


    @Override
    public void executeScene(JsonObject message) {
        this.getKnxDevices().getKNXDevices(Jalousie.class).forEach(Jalousie::down);
    }

    @Override
    public CommandTopic topic() {
        return Commands.JALOUSIE_ALL_DOWN;
    }

    @Override
    public void init() {

    }
}
