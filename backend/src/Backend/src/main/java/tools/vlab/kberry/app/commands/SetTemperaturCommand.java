package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.devices.actor.FloorHeater;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class SetTemperaturCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        Haus positionPath = Haus.positionPath(message.getString("positionPath"));
        var temperature = message.getFloat("temperature");
        var heizung = this.getKnxDevices().getKNXDevice(FloorHeater.class, positionPath);
        heizung.ifPresent(v -> v.setSetpoint(temperature));
        return Future.succeededFuture(Optional.empty());
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_TEMPERATURE;
    }

    @Override
    public void init() {

    }

}
