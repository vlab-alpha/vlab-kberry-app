package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.settings.FloorHeater;
import tools.vlab.kberry.app.settings.FloorHeaterSettingsVerticle;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.HeaterMode;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.scheduler.trigger.Daily;

import java.util.Optional;

public class SetFloorHeaterSettingsCommand extends Command {

    private final FloorHeaterSettingsVerticle settings;

    public SetFloorHeaterSettingsCommand(FloorHeaterSettingsVerticle settings) {
        this.settings = settings;
    }

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        Haus positionPath = Haus.positionPath(message.getString("positionPath"));
        var heater = FloorHeater.fromSettings(message.getJsonArray("settings").stream().map(o -> ((JsonObject) o)).toList());
        setHeaterSchedule(heater, positionPath);
        return this.settings
                .setSettingAsync(positionPath, heater)
                .map(none -> Optional.empty());
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_HEATER_SETTINGS;
    }

    @Override
    public void init() {

    }

    private void setHeaterSchedule(FloorHeater heater, PositionPath positionPath) {
        var device = this.getKnxDevices().getKNXDeviceByRoom(tools.vlab.kberry.core.devices.actor.FloorHeater.class, positionPath);
        if (heater.isNightSetback() && device.isPresent()) {
            this.start(
                    positionPath.getPath() + "_night_setback_start",
                    Daily.trigger(heater.getStartTime()),
                    () -> device.get().setMode(HeaterMode.COMFORT));
            this.start(
                    positionPath.getPath() + "_night_setback_end",
                    Daily.trigger(heater.getStartTime()),
                    () -> device.get().setMode(HeaterMode.NIGHT));
        } else {
            this.stop(positionPath.getPath() + "_night_setback_start");
            this.stop(positionPath.getPath() + "_night_setback_end");
        }
    }
}
