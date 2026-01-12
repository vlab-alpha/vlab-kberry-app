package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.settings.JalousieSettingsVerticle;
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
        var jalousie = this.getKnxDevices().getKNXDevice(Jalousie.class, positionPath);
        var pushButton = this.getKnxDevices().getKNXDevice(PushButton.class, positionPath);

        if (jalousie.isPresent()) {
            if (!setting.isKindersicherung() && pushButton.isPresent()) {
                pushButton.get().enable();
            }

            if (setting.getUpTimeOpt().isPresent()) {
                this.start(
                        positionPath.getPath() + "_weekday_up",
                        Weekday.trigger(setting.getUpTimeOpt().get().toLocalTime()),
                        () -> {
                            jalousie.get().up();
                            if (setting.isKindersicherung() && pushButton.isPresent()) {
                                pushButton.get().enable();
                            }
                        });
            } else {
                this.stop(positionPath.getPath() + "_weekday_up");
            }

            if (setting.getDownTimeOpt().isPresent()) {
                this.start(
                        positionPath.getPath() + "_weekday_down",
                        Weekday.trigger(setting.getDownTimeOpt().get().toLocalTime()),
                        () -> {
                            jalousie.get().down();
                            if (setting.isKindersicherung() && pushButton.isPresent()) {
                                pushButton.get().disable();
                            }
                        });
            } else {
                this.stop(positionPath.getPath() + "_weekday_down");
            }

            if (setting.getWeekendUpTimeOpt().isPresent()) {
                this.start(
                        positionPath.getPath() + "_weekend_up",
                        Weekend.trigger(setting.getWeekendUpTimeOpt().get().toLocalTime()),
                        () -> {
                            jalousie.get().up();
                            if (setting.isKindersicherung() && pushButton.isPresent()) {
                                pushButton.get().enable();
                            }
                        });
            } else {
                this.stop(positionPath.getPath() + "_weekend_up");
            }

            if (setting.getWeekendDownTimeOpt().isPresent()) {
                this.start(
                        positionPath.getPath() + "_weekend_down",
                        Weekend.trigger(setting.getWeekendDownTimeOpt().get().toLocalTime()),
                        () -> {
                            jalousie.get().down();
                            if (setting.isKindersicherung() && pushButton.isPresent()) {
                                pushButton.get().disable();
                            }
                        });
            } else {
                this.stop(positionPath.getPath() + "_weekend_down");
            }

            if (setting.getWakeUpTimeOpt().isPresent()) {
                this.start(
                        positionPath.getPath() + "_wakeup",
                        Daily.trigger(setting.getWakeUpTimeOpt().get().toLocalTime()),
                        () -> jalousie.get().setPositionPercent(setting.getWakeUpPostion()));
            } else {
                this.stop(positionPath.getPath() + "_wakeup");
            }
        }
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

    }

}
