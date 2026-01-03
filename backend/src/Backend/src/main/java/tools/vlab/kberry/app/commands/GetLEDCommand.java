package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.actor.Led;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class GetLEDCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));
        var device = getKnxDevices().getKNXDevice(Led.class, positionPath);
        if (device.isPresent()) {
            var currentHex = device.get().getRGB().toHex();
            return Future.succeededFuture(Optional.of(new JsonObject()
                    .put("hex", currentHex)));
        }
        return  Future.succeededFuture(Optional.empty());
    }

    @Override
    public CommandTopic topic() {
        return Commands.GET_LED;
    }

    @Override
    public void init() {

    }


}
