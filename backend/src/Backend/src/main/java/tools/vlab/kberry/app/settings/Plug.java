package tools.vlab.kberry.app.settings;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.vertx.core.json.JsonObject;
import lombok.Getter;
import lombok.Setter;
import tools.vlab.kberry.app.dashboard.Setting;

import java.util.List;

@Getter
@Setter
public class Plug {

    private boolean presenceOff;
    private boolean usageTime;
    private int maxUsageTimeMinutes;
    private int holdTimeMinute;

    public Plug() {
    }

    public Plug(boolean presenceOff, boolean usageTime, int maxUsageTimeMinutes, int holdTimeMinute) {
        this.presenceOff = presenceOff;
        this.usageTime = usageTime;
        this.maxUsageTimeMinutes = maxUsageTimeMinutes;
        this.holdTimeMinute = holdTimeMinute;
    }

    @JsonIgnore
    public static Plug first() {
        return new Plug(false, false, 2, 30);
    }

    @JsonIgnore
    public JsonObject toJson() {
        return JsonObject.mapFrom(this);
    }

    @JsonIgnore
    public static Plug fromJson(JsonObject json) {
        return json.mapTo(Plug.class);
    }

    @JsonIgnore
    public List<JsonObject> toSettings() {
        return List.of(
                Setting.checkbox("Nur Anwesend", isPresenceOff(), "timelapse").toJson(),
                Setting.minutes("Nachlaufzeit (min)", getHoldTimeMinute(), "timelapse_outlined").toJson(),
                Setting.checkbox("Benutzung Begrenzen", isUsageTime(),"person_pin_circle_outlined").toJson(),
                Setting.minutes("Maximal Benutzung (min)", getMaxUsageTimeMinutes(), "offline_bolt_outlined").toJson()
        );
    }

    @JsonIgnore
    public static Plug fromSettings(List<JsonObject> settings) {
        Plug plug = new Plug();
        for (JsonObject setting : settings) {
            String title = setting.getString("title");
            if (title == null) continue;
            String value = setting.getJsonObject("value").getString("value", "40");
            switch (title) {
                case "Nur Anwesend" ->
                        plug.setPresenceOff(Boolean.parseBoolean(value));
                case "Nachlaufzeit (min)" ->
                        plug.setHoldTimeMinute(Integer.parseInt(value));
                case "Benutzung Begrenzen" ->
                        plug.setUsageTime(Boolean.parseBoolean(value));
                case "Maximal Benutzung (min)" ->
                        plug.setMaxUsageTimeMinutes(Integer.parseInt(value));
                default -> {
                    // Unbekannte Settings ignorieren
                }
            }
        }
        return plug;
    }
}
