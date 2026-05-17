package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.RGB;
import tools.vlab.kberry.core.knx.devices.actor.Led;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;


public class SetLEDCommand extends Command {


    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        Haus positionPath = Haus.positionPath(message.getString("positionPath"));
        String hex = message.getString("hex");
        getKnxDevices().getKNXDevice(Led.class, positionPath)
                .ifPresent(device -> device.setRGB(RGB.fromHex(hex)));
        getShellyDevices().getDevice(tools.vlab.kberry.core.mqtt.shelly.devices.device.Led.class, positionPath)
                .ifPresent(device -> device.setColor(RGB.fromHex(hex)));
        return Future.succeededFuture(Optional.of(new JsonObject()
                .put("hex", hex)));
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_LED_COLOR;
    }

    @Override
    public void init() {

    }
}
