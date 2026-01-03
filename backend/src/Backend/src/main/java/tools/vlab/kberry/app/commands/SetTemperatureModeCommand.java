package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.HeaterMode;
import tools.vlab.kberry.core.devices.actor.FloorHeater;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class SetTemperatureModeCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));
        var mode = HeaterMode.valueOf(message.getString("betriebsart"));
        var heizung = this.getKnxDevices().getKNXDevice(FloorHeater.class, positionPath);
        heizung.ifPresent(v -> v.setMode(mode));
        return Future.succeededFuture();
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_TEMPERATURE_MODE;
    }

    @Override
    public void init() {

    }
}
