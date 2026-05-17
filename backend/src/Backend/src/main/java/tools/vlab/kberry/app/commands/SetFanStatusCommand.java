package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.mqtt.custom.devices.actor.Fan;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class SetFanStatusCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));
        var status = message.getBoolean("status", null);
        var device = getMqttDevices().getDevice(Fan.class, positionPath);
        var isChanged = status != null && device.isPresent();
        var speed = device.map(Fan::getSpeed).orElse(0);
        if (isChanged) {
            device.get().setOn(status);
        }
        return Future.succeededFuture(Optional.of(new JsonObject()
                .put("status", status)
                .put("changed", isChanged)
                .put("speed", speed)));
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_FAN;
    }

    @Override
    public void init() {

    }
}
