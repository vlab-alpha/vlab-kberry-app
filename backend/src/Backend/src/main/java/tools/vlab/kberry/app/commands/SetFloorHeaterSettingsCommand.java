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
        initSettings(positionPath, heater);
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
        this.getKnxDevices().getKNXDevices(tools.vlab.kberry.core.devices.actor.FloorHeater.class).forEach(jalousie -> {
            var setting = this.settings.getSetting(jalousie.getPositionPath());
            setting.ifPresent(value -> initSettings(jalousie.getPositionPath(), value));
        });
    }

    private void initSettings(PositionPath positionPath, FloorHeater setting) {
        var device = this.getKnxDevices().getKNXDeviceByRoom(tools.vlab.kberry.core.devices.actor.FloorHeater.class, positionPath);
        if (setting.isNightSetback() && device.isPresent()) {
            this.register(
                    positionPath, "night_setback_start",
                    Daily.trigger(setting.getStartTime()),
                    () -> device.get().setMode(HeaterMode.COMFORT));
            this.register(
                    positionPath, "night_setback_end",
                    Daily.trigger(setting.getStartTime()),
                    () -> device.get().setMode(HeaterMode.NIGHT));
        } else {
            this.unregister(positionPath, "night_setback_start");
            this.unregister(positionPath, "night_setback_end");
        }
    }
}
