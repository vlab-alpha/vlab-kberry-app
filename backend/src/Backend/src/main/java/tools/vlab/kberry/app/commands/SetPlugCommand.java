package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.knx.devices.actor.Plug;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class SetPlugCommand extends Command {


    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        var positionPath = Haus.positionPath(message.getString("positionPath"));
        var status = message.getBoolean("status");
        this.getKnxDevices().getKNXDevice(Plug.class, positionPath).ifPresent(device -> {
            if (status) device.on();
            else device.off();
        });
        this.getShellyDevices().getDevice(tools.vlab.kberry.core.mqtt.shelly.devices.device.Plug.class, positionPath).ifPresent(device -> {
            if (status) device.on();
            else device.off();
        });
        return Future.succeededFuture(Optional.of(new JsonObject().put("status", status)));
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_PLUG_STATUS;
    }

    @Override
    public void init() {

    }

}
