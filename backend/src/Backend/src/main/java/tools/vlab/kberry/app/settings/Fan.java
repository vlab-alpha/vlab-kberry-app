package tools.vlab.kberry.app.settings;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.vertx.core.json.JsonObject;
import lombok.Getter;
import lombok.Setter;
import tools.vlab.kberry.app.dashboard.Setting;

import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@Setter
@Getter
public class Fan {

    private boolean sleepOn;
    private String sleepStart;
    private String sleepStop;
    private boolean isAutoOn;
    private float humidityMax;
    private float vocMax;

    public Fan(boolean sleepOn, String sleepStart, String sleepStop, boolean isAutoOn, float humidityMax, float vocMax) {
        this.sleepOn = sleepOn;
        this.sleepStart = sleepStart;
        this.sleepStop = sleepStop;
        this.isAutoOn = isAutoOn;
        this.humidityMax = humidityMax;
        this.vocMax = vocMax;
    }

    public Fan() {
    }

    @JsonIgnore
    public static Fan first() {
        return new Fan(true, "24:00", "9:00", true, 65f, 800f);
    }

    @JsonIgnore
    public JsonObject toJson() {
        return JsonObject.mapFrom(this);
    }

    @JsonIgnore
    public static Fan fromJson(JsonObject json) {
        return json.mapTo(Fan.class);
    }

    @JsonIgnore
    public List<JsonObject> toSettings() {
        return List.of(
                Setting.checkbox("Auto An", isAutoOn(), "timelapse_outlined").toJson(),
                Setting.number("Luftfeuchtigkeit", getHumidityMax(),"humidity").toJson(),
                Setting.number("Co2", getVocMax(),"co2").toJson(),
                Setting.checkbox("Sleep Mode", isSleepOn(), "timelapse_outlined").toJson(),
                Setting.time("Sleep An", this.getSleepStart(), "arrow_downward").toJson(),
                Setting.time("Sleep Aus", this.getSleepStop(), "arrow_upward").toJson()
        );
    }

    public static Fan fromSettings(List<JsonObject> settings) {
        Fan fan = new Fan();
        for (JsonObject setting : settings) {
            String title = setting.getString("title");
            String value = setting.getJsonObject("value").getString("value", "40");
            switch (title) {
                case "Auto An" -> fan.setAutoOn(Boolean.parseBoolean(value));
                case "Luftfeuchtigkeit" -> fan.setHumidityMax(Float.parseFloat(value));
                case "Co2" -> fan.setVocMax(Float.parseFloat(value));
                case "Sleep Mode" -> fan.setSleepOn(Boolean.parseBoolean(value));
                case "Sleep An" -> fan.setSleepStart(value);
                case "Sleep Aus" -> fan.setSleepStop(value);
                default -> {
                    // Unbekannte Einstellung ignorieren
                }
            }
        }
        return fan;
    }

    @JsonIgnore
    public Optional<LocalTime> getSleepStartOpt() {
        if (isSleepOn()) {
            var split = this.sleepStart.split(":");
            return Optional.of(LocalTime.of(Integer.parseInt(split[0]), Integer.parseInt(split[1])));
        }
        return Optional.empty();
    }

    @JsonIgnore
    public Optional<LocalTime> getSleepStopOpt() {
        if (isSleepOn()) {
            var split = this.sleepStop.split(":");
            return Optional.of(LocalTime.of(Integer.parseInt(split[0]), Integer.parseInt(split[1])));
        }
        return Optional.empty();
    }
}
