package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.settings.JalousieSettingsVerticle;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.PushButton;
import tools.vlab.kberry.core.devices.actor.Jalousie;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.scheduler.trigger.Daily;
import tools.vlab.kberry.server.scheduler.trigger.Weekday;
import tools.vlab.kberry.server.scheduler.trigger.Weekend;

import java.util.Optional;

public class SetJalousieSettingsCommand extends Command {

    private final JalousieSettingsVerticle settings;

    public SetJalousieSettingsCommand(JalousieSettingsVerticle settings) {
        this.settings = settings;
    }

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        Haus positionPath = Haus.positionPath(message.getString("positionPath"));
        var setting = tools.vlab.kberry.app.settings.Jalousie.fromSettings(message.getJsonArray("settings").stream().map(o -> ((JsonObject) o)).toList());
        initSettings(positionPath, setting);
        return this.settings
                .setSettingAsync(positionPath, setting)
                .map(none -> Optional.empty());
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_JALOUSIE_SETTINGS;
    }

    @Override
    public void init() {
        this.getKnxDevices().getKNXDevices(Jalousie.class).forEach(jalousie -> {
            var setting = this.settings.getSetting(jalousie.getPositionPath());
            setting.ifPresent(value -> initSettings(jalousie.getPositionPath(), value));
        });
    }

    public void initSettings(PositionPath positionPath, tools.vlab.kberry.app.settings.Jalousie setting) {
        var jalousie = this.getKnxDevices().getKNXDevice(Jalousie.class, positionPath);
        var pushButton = this.getKnxDevices().getKNXDevice(PushButton.class, positionPath);

        // Weekday Up
        if (setting.getUpTimeOpt().isPresent() && jalousie.isPresent()) {
            this.register(positionPath, "weekday_up", Weekday.trigger(setting.getUpTimeOpt().get().toLocalTime()), () -> {
                jalousie.get().up();
                if (setting.isKindersicherung() && pushButton.isPresent()) {
                    pushButton.get().enable();
                }
            });
        } else {
            this.unregister(positionPath, "weekday_up");
        }

        // Weekday Down
        if (setting.getDownTimeOpt().isPresent() && jalousie.isPresent()) {
            this.register(
                    positionPath, "weekday_down",
                    Weekday.trigger(setting.getDownTimeOpt().get().toLocalTime()),
                    () -> {
                        jalousie.get().down();
                        if (setting.isKindersicherung() && pushButton.isPresent()) {
                            pushButton.get().disable();
                        }
                    });
        } else {
            this.unregister(positionPath, "weekday_down");
        }

        // Weekend Up
        if (setting.getWeekendUpTimeOpt().isPresent() && jalousie.isPresent()) {
            this.register(
                    positionPath, "weekend_up",
                    Weekend.trigger(setting.getWeekendUpTimeOpt().get().toLocalTime()),
                    () -> {
                        jalousie.get().up();
                        if (setting.isKindersicherung() && pushButton.isPresent()) {
                            pushButton.get().enable();
                        }
                    });
        } else {
            this.unregister(positionPath, "weekend_up");
        }

        // Weekend Down
        if (setting.getWeekendDownTimeOpt().isPresent() && jalousie.isPresent()) {
            this.register(
                    positionPath, "weekend_down",
                    Weekend.trigger(setting.getWeekendDownTimeOpt().get().toLocalTime()),
                    () -> {
                        jalousie.get().down();
                        if (setting.isKindersicherung() && pushButton.isPresent()) {
                            pushButton.get().disable();
                        }
                    });
        } else {
            this.unregister(positionPath, "weekend_down");
        }

        // Wakeup
        if (setting.getWakeUpTimeOpt().isPresent() && jalousie.isPresent()) {
            this.register(
                    positionPath, "wakeup",
                    Daily.trigger(setting.getWakeUpTimeOpt().get().toLocalTime()),
                    () -> jalousie.get().setPositionPercent(setting.getWakeUpPosition()));
        } else {
            this.unregister(positionPath, "wakeup");
        }

        if (!setting.isKindersicherung() && pushButton.isPresent()) {
            pushButton.get().enable();
        }


    }

}
