package tools.vlab.kberry.app.commands;

import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.actor.Jalousie;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.commands.Scene;

public class AllJalousieUp extends Scene {


    @Override
    public void executeScene(JsonObject message) {
        this.getKnxDevices().getKNXDevices(Jalousie.class).forEach(Jalousie::up);
    }

    @Override
    public PositionPath getPositionPath() {
        return Haus.HallwayWall;
    }

    @Override
    public String getIcon() {
        return "keyboard_arrow_up";
    }

    @Override
    public String getName() {
        return "Rollladen Hoch";
    }

    @Override
    public CommandTopic topic() {
        return Commands.JALOUSIE_ALL_UP;
    }

    @Override
    public void init() {

    }
}
