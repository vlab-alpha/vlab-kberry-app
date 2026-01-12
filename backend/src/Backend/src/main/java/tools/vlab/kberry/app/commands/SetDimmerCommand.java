package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.devices.actor.Dimmer;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class SetDimmerCommand extends Command {


    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        var positionPath = Haus.positionPath(message.getString("positionPath"));
        var percent = message.getInteger("percent");
        var device = this.getKnxDevices().getKNXDevice(Dimmer.class, positionPath);
        device.ifPresent(dimmer -> dimmer.setBrightness(percent));
        return Future.succeededFuture(Optional.of(new JsonObject().put("percent", percent)));
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_DIMMER_STATUS;
    }

    @Override
    public void init() {

    }
}
