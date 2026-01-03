package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.devices.actor.Light;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class SetLightCommand extends Command {


    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        var positionPath = Haus.positionPath(message.getString("positionPath"));
        var status = message.getBoolean("status");
        var device = getKnxDevices().getKNXDevice(Light.class, positionPath);
        if (device.isPresent()) {
            if (status) {
                device.get().on();
            } else {
                device.get().off();
            }
        }
        return Future.succeededFuture(Optional.of(new JsonObject().put("status", status)));
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_LIGHT;
    }

    @Override
    public void init() {

    }
}
