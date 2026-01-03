package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.HeaterMode;
import tools.vlab.kberry.core.devices.actor.FloorHeater;
import tools.vlab.kberry.core.devices.sensor.TemperatureSensor;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class GetTemperatureCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));

        var heizung = this.getKnxDevices().getKNXDevice(FloorHeater.class, positionPath);
        var temperaturSensor = getKnxDevices().getKNXDevice(TemperatureSensor.class, positionPath);
        if (heizung.isPresent() && temperaturSensor.isPresent()) {
            var position = heizung.get().getCurrentActuatorPosition();
            var temperatur = temperaturSensor.get().getCurrentTemp();
            var sollwert = heizung.get().getCurrentSetpoint();
            var betriebsart = heizung.get().getCurrentMode();
            return Future.succeededFuture(Optional.of(new JsonObject()
                    .put("temperatur", temperatur)
                    .put("sollwert", sollwert)
                    .put("betriebsart", betriebsart.name())
                    .put("position", position)
            ));
        }
        return Future.succeededFuture(Optional.of(new JsonObject()
                .put("temperatur", 0)
                .put("sollwert", 0)
                .put("error", 0)
                .put("betriebsart", HeaterMode.STANDBY.name())
                .put("position", 0)
        ));
    }

    @Override
    public CommandTopic topic() {
        return Commands.GET_TEMPERATURE;
    }

    @Override
    public void init() {

    }

}
