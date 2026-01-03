package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.devices.RGB;
import tools.vlab.kberry.core.devices.actor.Led;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;


public class SetLEDCommand extends Command {


    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        Haus positionPath = Haus.valueOf(message.getString("positionPath"));
        String hex =  message.getString("hex");
        var device = getKnxDevices().getKNXDevice(Led.class, positionPath);
        if (device.isPresent()) {
            device.get().setRGB(RGB.fromHex(hex));
            return Future.succeededFuture(Optional.of(new JsonObject()
                    .put("hex", hex)));
        }
        return Future.succeededFuture(Optional.empty());
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_LED;
    }

    @Override
    public void init() {

    }
}
