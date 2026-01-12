package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.actor.Jalousie;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class SetJalousieReferenceCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));
        var jalousie = this.getKnxDevices().getKNXDevice(Jalousie.class, positionPath);
        jalousie.ifPresent(Jalousie::referenceDriving);
        return Future.succeededFuture(Optional.empty());
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_JALOUSIE_REFERENCE;
    }

    @Override
    public void init() {

    }

}
