package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.logics.FanLogic;
import tools.vlab.kberry.app.settings.FanSettingsVerticle;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.mqtt.custom.devices.actor.Fan;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.scheduler.trigger.Daily;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class SetFanSettingsCommand extends Command {

    private final FanSettingsVerticle settings;

    public SetFanSettingsCommand(FanSettingsVerticle settings) {
        this.settings = settings;
    }

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        var setting = tools.vlab.kberry.app.settings.Fan.fromSettings(message.getJsonArray("settings").stream().map(o -> ((JsonObject) o)).toList());
        if (message.containsKey("positionPath")) {
            Haus positionPath = Haus.positionPath(message.getString("positionPath"));
            initSettings(positionPath, setting);
            return this.settings
                    .setSettingAsync(positionPath, setting)
                    .map(none -> Optional.empty());
        } else {
            // setting all
            List<Future<Void>> futureList = new ArrayList<>();
            for (var positionPath : Haus.values()) {
                initSettings(positionPath, setting);
                futureList.add(this.settings.setSettingAsync(positionPath, setting));
            }
            return Future.all(futureList).map(none -> Optional.empty());
        }
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_FAN_SETTINGS;
    }

    @Override
    public void init() {
        this.getMqttDevices().getDevices(Fan.class).forEach(fan -> {
            var setting = this.settings.getSetting(fan.getPositionPath());
            setting.ifPresent(value -> initSettings(fan.getPositionPath(), value));
        });
    }

    private void initSettings(PositionPath positionPath, tools.vlab.kberry.app.settings.Fan settings) {
        var fan = this.getMqttDevices().getDevice(Fan.class, positionPath);
        if (fan.isPresent()) {
            if (settings.isAutoOn() && settings.isSleepOn() && settings.getSleepStartOpt().isPresent() && settings.getSleepStopOpt().isPresent()) {
                var logic = FanLogic.at(positionPath, settings.getHumidityMax(), settings.getVocMax());

                register(positionPath,
                        "fan_logig_start",
                        Daily.trigger(settings.getSleepStopOpt().get()),
                        () -> getLogicEngine().register(logic));
                register(positionPath,
                        "fan_logig_stop",
                        Daily.trigger(settings.getSleepStartOpt().get()),
                        () -> getLogicEngine().unregister(logic));

            } else if (settings.isAutoOn()) {
                getLogicEngine().register(FanLogic.at(positionPath, settings.getHumidityMax(), settings.getVocMax()));
            } else {
                getLogicEngine().unregister(positionPath, FanLogic.LOGIC_NAME);
            }
        }
    }


}
