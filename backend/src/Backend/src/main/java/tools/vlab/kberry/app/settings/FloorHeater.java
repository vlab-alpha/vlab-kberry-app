package tools.vlab.kberry.app.settings;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.vertx.core.json.JsonObject;
import lombok.Getter;
import lombok.Setter;
import tools.vlab.kberry.app.dashboard.Setting;

import java.time.LocalTime;
import java.util.List;

@Setter
@Getter
public class FloorHeater {

    private boolean nightSetback;
    private String start;
    private String end;

    public FloorHeater() {

    }

    public FloorHeater(boolean nightSetback, String start, String end) {
        this.nightSetback = nightSetback;
        this.start = start;
        this.end = end;
    }

    @JsonIgnore
    public static FloorHeater first() {
        return new FloorHeater(false, "11:00", "6:00");
    }

    @JsonIgnore
    public JsonObject toJson() {
        return JsonObject.mapFrom(this);
    }

    @JsonIgnore
    public static FloorHeater fromJson(JsonObject json) {
        return json.mapTo(FloorHeater.class);
    }

    @JsonIgnore
    public static FloorHeater fromSettings(List<JsonObject> settings) {
        FloorHeater light = new FloorHeater();

        for (JsonObject setting : settings) {
            String title = setting.getString("title");
            if (title == null) continue;
            String value = setting.getJsonObject("value").getString("value");
            switch (title) {
                case "Nachtabsenkung" -> light.setNightSetback(Boolean.parseBoolean(value));
                case "Startpunkt" -> light.setStart(value);
                case "Endpunkt" -> light.setEnd(value);
                default -> {
                    // Unbekanntes Setting -> ignoriere
                }
            }
        }

        return light;
    }

    @JsonIgnore
    public List<JsonObject> toSettings() {
        return List.of(
                Setting.checkbox("Nachtabsenkung", isNightSetback(), "person_pin_circle_outlined").toJson(),
                Setting.time("Startpunkt", getStart(),"mode_night").toJson(),
                Setting.time("Endpunkt", getEnd(),"light_time_on").toJson()
        );
    }

    @JsonIgnore
    public LocalTime getStartTime() {
        return Time.of(start).toLocalTime();
    }

    @JsonIgnore
    public LocalTime getEndTime() {
        return Time.of(end).toLocalTime();
    }

}

