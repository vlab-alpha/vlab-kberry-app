package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.actor.Jalousie;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class SetJalousieCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));
        int position = message.getInteger("position");
        var jalousie = getKnxDevices().getKNXDevice(Jalousie.class, positionPath);
        if (position == 0) {
            jalousie.ifPresent(Jalousie::up);
        } else if (position == 100) {
            jalousie.ifPresent(Jalousie::down);
        } else {
            jalousie.ifPresent(v -> v.setPosition(position));
        }
        return Future.succeededFuture(Optional.empty());
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_JALOUSIE_POSITION;
    }

    @Override
    public void init() {

    }
}
