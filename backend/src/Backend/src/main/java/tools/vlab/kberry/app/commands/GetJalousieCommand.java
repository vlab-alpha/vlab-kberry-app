package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.devices.actor.Jalousie;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class GetJalousieCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        var positionPath = Haus.positionPath(message.getString("positionPath"));
        var device = this.getKnxDevices().getKNXDevice(Jalousie.class, positionPath);
        var position = 0;
        if (device.isPresent()) {
            position = device.get().getCurrentPositionPercent();
        }
        return Future.succeededFuture(Optional.of(new JsonObject()
                .put("position", position)
        ));
    }

    @Override
    public CommandTopic topic() {
        return Commands.GET_JALOUSIE_POSITION;
    }

    @Override
    public void init() {

    }
}
