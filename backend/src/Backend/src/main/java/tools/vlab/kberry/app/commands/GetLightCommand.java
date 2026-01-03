package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.devices.actor.Light;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class GetLightCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        var positionPath = Haus.positionPath(message.getString("positionPath"));
        var device = this.getKnxDevices().getKNXDevice(Light.class, positionPath);
        if (device.isPresent()) {
            var isON = device.get().isOn();
            return Future.succeededFuture(Optional.of(new JsonObject().put("status", isON)));
        }
        return Future.succeededFuture(Optional.of(new JsonObject().put("status", false)));
    }

    @Override
    public CommandTopic topic() {
        return Commands.GET_LIGHT;
    }

    @Override
    public void init() {

    }

}
