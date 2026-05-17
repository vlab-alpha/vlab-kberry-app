package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.schedule.JalousieScheduler;
import tools.vlab.kberry.app.settings.JalousieSettingsVerticle;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.knx.devices.PushButton;
import tools.vlab.kberry.core.knx.devices.actor.Jalousie;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.*;

public class SetJalousieSettingsCommand extends Command {

    private final JalousieSettingsVerticle settings;

    public SetJalousieSettingsCommand(JalousieSettingsVerticle settings) {
        this.settings = settings;
    }

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        var setting = tools.vlab.kberry.app.settings.Jalousie.fromSettings(message.getJsonArray("settings").stream().map(o -> ((JsonObject) o)).toList());
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
        unregister(positionPath, "weekend_down");
        unregister(positionPath, "weekend_up");
        unregister(positionPath, "weekday_down");
        unregister(positionPath, "weekday_up");
        unregister(positionPath,"weekend_wakeup");
        unregister(positionPath,"weekday_wakeup");

        if (setting.isWeekDayAutoTime()) {
            register(JalousieScheduler.downWeekday("weekday_down", positionPath, setting.getWeekdayDownTime(), setting.isKindersicherung()));
            register(JalousieScheduler.upWeekday("weekday_up", positionPath, setting.getWeekdayUpTime(), setting.getMaxPosition()));
        } else {
            unregister(positionPath, "weekday_down");
            unregister(positionPath, "weekday_up");
        }

        if (setting.isWeekendAutoTime()) {
            register(JalousieScheduler.downWeekend("weekend_down", positionPath, setting.getWeekendDownTime(), setting.isKindersicherung()));
            register(JalousieScheduler.upWeekend("weekend_up", positionPath, setting.getWeekendUpTime(), setting.getMaxPosition()));
        } else {
            unregister(positionPath, "weekend_down");
            unregister(positionPath, "weekend_up");
        }

        if (setting.isWeekdayWakeUp()) {
            register(JalousieScheduler.upWeekday("weekday_wakeup", positionPath, setting.getWeekdayWakeupTime(), setting.getMaxPosition()));
        } else {
            unregister(positionPath,"weekday_wakeup");
        }

        if (setting.isWeekendWakeUp()) {
            register(JalousieScheduler.upWeekend("weekend_wakeup", positionPath, setting.getWeekendWakeupTime(), setting.getMaxPosition()));
        } else {
            unregister(positionPath,"weekend_wakeup");
        }

        if (!setting.isKindersicherung()) {
            this.getKnxDevices().getKNXDeviceByRoom(PushButton.class, positionPath).ifPresent(PushButton::enable);
        }
    }

}
