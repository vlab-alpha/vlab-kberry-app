package tools.vlab.kberry.app.settings;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.vertx.core.json.JsonObject;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import tools.vlab.kberry.app.dashboard.Setting;

import java.time.LocalTime;
import java.util.List;
import java.util.stream.Stream;

@Getter
@Setter
@AllArgsConstructor
public class Jalousie {
    private boolean kindersicherung;
    private int maxPosition = 100;

    private boolean isWeekDayAutoTime;
    private String weekdayUpTime;
    private String weekdayDownTime;
    private boolean weekdayWakeUp;
    private int weekdayWakeUpMinutes;
    private int weekdayWakeWakeUpPosition;

    private boolean isWeekendAutoTime;
    private String weekendDownTime;
    private String weekendUpTime;
    private boolean weekendWakeUp;
    private int weekendWakeUpMinutes;
    private int weekendWakeWakeUpPosition;


    public Jalousie() {
    }


    @JsonIgnore
    public static Jalousie first() {
        return new Jalousie(false, 100,
                true, "07:00", "21:00", true, 30, 20,
                false, "09:00", "21:00", false, 30, 20
        );
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
    public List<JsonObject> toSettings() {
        return Stream.of(
                Setting.checkbox("Kindersicherung", this.kindersicherung, "child_care"),
                Setting.numberSpan("Max Position", 0, 100, this.maxPosition, "arrow_upward"),

                Setting.seperator("Wochentag", "arrow_upward"),
                Setting.checkbox("Auto (Wochentag)", this.isWeekDayAutoTime, "timelapse_outlined"),
                Setting.time("Wochentag (Hoch)", this.weekdayUpTime, "arrow_upward"),
                Setting.time("Wochentag (Runter)", this.weekdayDownTime, "arrow_downward"),
                Setting.checkbox("Wochentag Aufwecken", this.weekdayWakeUp, "access_alarm"),
                Setting.minutes("Wochentag Aufwecken (Min)", this.weekdayWakeUpMinutes, "access_alarm"),
                Setting.numberSpan("Wochentag Aufwecken (Pos)", 0, 100, this.weekdayWakeWakeUpPosition, "access_alarm"),

                Setting.seperator("Wochenende", "arrow_upward"),
                Setting.checkbox("Auto (Wochenende)", this.isWeekendAutoTime, "timelapse_outlined"),
                Setting.time("Wochenende (Hoch)", this.weekendUpTime, "arrow_upward"),
                Setting.time("Wochenende (Runter)", this.weekendDownTime, "arrow_downward"),
                Setting.checkbox("Wochenende Aufwecken", this.weekendWakeUp, "access_alarm"),
                Setting.minutes("Wochenende Aufwecken (Min)", this.weekendWakeUpMinutes, "access_alarm"),
                Setting.numberSpan("Wochenende Aufwecken (Pos)", 0, 100, this.weekendWakeWakeUpPosition, "access_alarm")

        ).map(Setting::toJson).toList();
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
                case "Max Position" -> jalousie.setMaxPosition((int) Math.floor(Double.parseDouble(value)));

                case "Auto (Wochentag)" -> jalousie.setWeekDayAutoTime(Boolean.parseBoolean(value));
                case "Wochentag (Hoch)"-> jalousie.setWeekdayUpTime(value);
                case "Wochentag (Runter)"-> jalousie.setWeekdayDownTime(value);
                case "Wochentag Aufwecken"-> jalousie.setWeekdayWakeUp(Boolean.parseBoolean(value));
                case "Wochentag Aufwecken (Min)"-> jalousie.setWeekdayWakeUpMinutes(Integer.parseInt(value));
                case "Wochentag Aufwecken (Pos)"-> jalousie.setWeekdayWakeWakeUpPosition((int) Math.floor(Double.parseDouble(value)));

                case "Auto (Wochenende)" -> jalousie.setWeekendAutoTime(Boolean.parseBoolean(value));
                case "Wochenende (Hoch)"-> jalousie.setWeekendUpTime(value);
                case "Wochenende (Runter)"-> jalousie.setWeekendDownTime(value);
                case "Wochenende Aufwecken"-> jalousie.setWeekendWakeUp(Boolean.parseBoolean(value));
                case "Wochenende Aufwecken (Min)"-> jalousie.setWeekendWakeUpMinutes(Integer.parseInt(value));
                case "Wochenende Aufwecken (Pos)"-> jalousie.setWeekendWakeWakeUpPosition((int) Math.floor(Double.parseDouble(value)));

                default -> {
                    // Unbekanntes Setting ignorieren
                }
            }
        }
        return jalousie;
    }


    @JsonIgnore
    public LocalTime getWeekdayDownTime() {
        return LocalTime.parse(this.weekdayDownTime);
    }

    @JsonIgnore
    public LocalTime getWeekdayUpTime() {
        return LocalTime.parse(this.weekdayUpTime);
    }

    @JsonIgnore
    public LocalTime getWeekendDownTime() {
        return LocalTime.parse(this.weekendDownTime);
    }

    @JsonIgnore
    public LocalTime getWeekendUpTime() {
        return LocalTime.parse(this.weekendUpTime);
    }

    @JsonIgnore
    public LocalTime getWeekdayWakeupTime() {
        return this.getWeekdayUpTime().minusMinutes(this.weekdayWakeUpMinutes);
    }

    @JsonIgnore
    public LocalTime getWeekendWakeupTime() {
        return this.getWeekendUpTime().minusMinutes(this.weekendWakeUpMinutes);
    }

}
