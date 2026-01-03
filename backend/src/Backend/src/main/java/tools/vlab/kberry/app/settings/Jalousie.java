package tools.vlab.kberry.app.settings;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.vertx.core.json.JsonObject;
import lombok.Getter;
import lombok.Setter;
import tools.vlab.kberry.app.dashboard.Setting;

import java.util.List;
import java.util.Optional;

@Getter
@Setter
public class Jalousie {

    private boolean isAutoTime;
    private boolean kindersicherung;
    private String weekdayDownTime;
    private String weekendDownTime;
    private String weekdayUpTime;
    private String weekendUpTime;
    private String wakeUpTime;
    private boolean wakeUp;
    private int wakeUpPostion;

    public Jalousie() {
    }

    public Jalousie(boolean kindersicherung, String weekdayDownTime, String weekdayUpTime, String weekendDownTime, String weekendUpTime, boolean wakeUp, String wakeUpTime, int wakeUpPostion) {
        this.kindersicherung = kindersicherung;
        this.weekdayDownTime = weekdayDownTime;
        this.weekdayUpTime = weekdayUpTime;
        this.weekendDownTime = weekendDownTime;
        this.weekendUpTime = weekendUpTime;
        this.wakeUp = wakeUp;
        this.wakeUpTime = wakeUpTime;
        this.wakeUpPostion = wakeUpPostion;
    }

    @JsonIgnore
    public static Jalousie first() {
        return new Jalousie(false, "18:00", "07:00", "18:00", "07:00", false, "8:00", 20);
    }

    @JsonIgnore
    public JsonObject toJson() {
        return JsonObject.mapFrom(this);
    }

    @JsonIgnore
    public static Jalousie fromJson(JsonObject json) {
        return json.mapTo(Jalousie.class);
    }

    @JsonIgnore
    public List<JsonObject> toSettingsList() {
        return List.of(
                Setting.checkbox("Kindersicherung", isKindersicherung(), "child_care").toJson(),
                Setting.checkbox("Auto via Time", isAutoTime(), "timelapse_outlined").toJson(),
                Setting.time("Zeit runter", this.getWeekdayDownTime(), "arrow_downward").toJson(),
                Setting.time("Zeit hoch", this.getWeekdayUpTime(), "arrow_upward").toJson(),
                Setting.time("Zeit runter WE", this.getWeekdayDownTime(), "arrow_downward").toJson(),
                Setting.time("Zeit hoch WE", this.getWeekdayUpTime(), "arrow_upward").toJson(),
                Setting.checkbox("Aufwecken", isWakeUp(), "access_alarm").toJson(),
                Setting.time("Aufwecken Um", this.getWakeUpTime(), "access_alarm").toJson(),
                Setting.numberSpan("Aufwecken Position", 0, 100, getWakeUpPostion(), "access_alarm").toJson()
        );
    }

    @JsonIgnore
    public static Jalousie fromSettings(List<JsonObject> settings) {
        Jalousie jalousie = new Jalousie();

        for (JsonObject setting : settings) {
            String title = setting.getString("title");
            if (title == null) continue;
            String value = setting.getJsonObject("value").getString("value");
            switch (title) {
                case "Kindersicherung" -> jalousie.setKindersicherung(Boolean.parseBoolean(value));
                case "Auto via Time" -> jalousie.setAutoTime(Boolean.parseBoolean(value));
                case "Zeit runter" -> jalousie.setWeekdayDownTime(value);
                case "Zeit hoch" -> jalousie.setWeekdayUpTime(value);
                case "Zeit runter WE" -> jalousie.setWeekendDownTime(value);
                case "Zeit hoch WE" -> jalousie.setWeekendUpTime(value);
                case "Aufwecken" -> jalousie.setWakeUp(Boolean.parseBoolean(value));
                case "Aufwecken Um" -> jalousie.setWakeUpTime(value);
                case "Aufwecken Position" ->  jalousie.setWakeUpPostion((int) Math.floor(Double.parseDouble(value)));
                default -> {
                    // Unbekanntes Setting ignorieren
                }
            }
        }
        return jalousie;
    }

    @JsonIgnore
    public Optional<Time> getWakeUpTimeOpt() {
        if (isWakeUp()) {
            return Optional.of(Time.of(this.wakeUpTime));
        }
        return Optional.empty();
    }

    @JsonIgnore
    public Optional<Time> getUpTimeOpt() {
        if (isAutoTime()) {
            return Optional.of(Time.of(this.weekdayUpTime));
        }
        return Optional.empty();
    }

    @JsonIgnore
    public Optional<Time> getDownTimeOpt() {
        if (isAutoTime()) {
            return Optional.of(Time.of(this.weekdayDownTime));
        }
        return Optional.empty();
    }

    @JsonIgnore
    public Optional<Time> getWeekendUpTimeOpt() {
        if (isAutoTime()) {
            return Optional.of(Time.of(this.weekdayUpTime));
        }
        return Optional.empty();
    }

    @JsonIgnore
    public Optional<Time> getWeekendDownTimeOpt() {
        if (isAutoTime()) {
            return Optional.of(Time.of(this.weekdayDownTime));
        }
        return Optional.empty();
    }

}
