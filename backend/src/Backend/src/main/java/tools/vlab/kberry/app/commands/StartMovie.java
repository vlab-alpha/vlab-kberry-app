package tools.vlab.kberry.app.commands;

import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.devices.RGB;
import tools.vlab.kberry.core.devices.actor.Dimmer;
import tools.vlab.kberry.core.devices.actor.Led;
import tools.vlab.kberry.core.devices.actor.Plug;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.commands.Scene;

public class StartMovie extends Scene {


    @Override
    public void executeScene(JsonObject message) {
        getKnxDevices().getKNXDevice(Dimmer.class, Haus.KitchenTop).ifPresent(Dimmer::turnOff);
        getKnxDevices().getKNXDevice(Dimmer.class, Haus.LivingRoomTop).ifPresent(dimmer -> dimmer.setBrightness(5));
        getKnxDevices().getKNXDevice(Led.class, Haus.LivingRoomTop).ifPresent(led -> led.setRGB(new RGB(50, 100, 200)));
        getKnxDevices().getKNXDevice(Plug.class, Haus.LivingRoomTV).ifPresent(Plug::on);
    }

    @Override
    public CommandTopic topic() {
        return Commands.START_MOVIE;
    }

    @Override
    public void init() {

    }
}
