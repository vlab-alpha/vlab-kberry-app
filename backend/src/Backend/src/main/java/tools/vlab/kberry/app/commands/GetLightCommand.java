package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.knx.devices.actor.Light;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class GetLightCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        var positionPath = Haus.positionPath(message.getString("positionPath"));
        var knxDevice = this.getKnxDevices().getKNXDevice(Light.class, positionPath);
        if (knxDevice.isPresent()) {
            var isON = knxDevice.get().isOn();
            return Future.succeededFuture(Optional.of(new JsonObject().put("status", isON)));
        }
        var shellyDevice = this.getShellyDevices().getDevice(tools.vlab.kberry.core.mqtt.shelly.devices.device.Plug.class, positionPath);
        if (shellyDevice.isPresent()) {
            var isON = shellyDevice.get().isOn();
            return Future.succeededFuture(Optional.of(new JsonObject().put("status", isON)));
        }
        return Future.succeededFuture(Optional.of(new JsonObject().put("status", false)));
    }

    @Override
    public CommandTopic topic() {
        return Commands.GET_LIGHT_STATUS;
    }

    @Override
    public void init() {

    }

}
