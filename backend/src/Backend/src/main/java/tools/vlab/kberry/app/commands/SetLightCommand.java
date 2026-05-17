package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.knx.devices.actor.Led;
import tools.vlab.kberry.core.knx.devices.actor.Light;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class SetLightCommand extends Command {


    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        var positionPath = Haus.positionPath(message.getString("positionPath"));
        var status = message.getBoolean("status");
        var lightDevice = getKnxDevices().getKNXDevice(Light.class, positionPath);
        if (lightDevice.isPresent()) {
            if (status) {
                lightDevice.get().on();
            } else {
                lightDevice.get().off();
            }
        }
        var ledDevice = getKnxDevices().getKNXDevice(Led.class, positionPath);
        if (ledDevice.isPresent()) {
            if (status) {
                ledDevice.get().on();
            } else {
                ledDevice.get().off();
            }
        }

        var shellyDevice = getShellyDevices().getDevice(tools.vlab.kberry.core.mqtt.shelly.devices.device.Led.class, positionPath);
        if (shellyDevice.isPresent()) {
            if (status) {
                shellyDevice.get().on();
            } else {
                shellyDevice.get().off();
            }
        }

        return Future.succeededFuture(Optional.of(new JsonObject().put("status", status)));
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_LIGHT_STATUS;
    }

    @Override
    public void init() {

    }
}
