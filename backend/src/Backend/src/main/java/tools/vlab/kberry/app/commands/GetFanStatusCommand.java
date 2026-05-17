package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.mqtt.custom.devices.actor.Fan;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class GetFanStatusCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));
        var device = getMqttDevices().getDevice(Fan.class, positionPath);
        return device.map(fan -> Future.succeededFuture(Optional.of(new JsonObject()
                        .put("speed", fan.getSpeed())
                        .put("status", fan.isOn()))))
                .orElse(Future.succeededFuture(Optional.of(new JsonObject().put("speed", 0).put("status", false))));
    }

    @Override
    public CommandTopic topic() {
        return Commands.GET_FAN_STATUS;
    }

    @Override
    public void init() {

    }
}
