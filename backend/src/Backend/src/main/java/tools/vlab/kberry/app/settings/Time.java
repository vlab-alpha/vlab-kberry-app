package tools.vlab.kberry.app.settings;

import lombok.Getter;

import java.time.LocalTime;

@Getter
public class Time {

    private final int hour;
    private final int minute;

    private Time(int hour, int minute) {
        this.hour = hour;
        this.minute = minute;
    }

    public static Time of(String time) {
        return new Time(Integer.parseInt(time.split(":")[0]), Integer.parseInt(time.split(":")[1]));
    }

    public LocalTime toLocalTime() {
        return LocalTime.of(hour, minute);
    }
}
