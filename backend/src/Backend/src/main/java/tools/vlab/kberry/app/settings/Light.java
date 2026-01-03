package tools.vlab.kberry.app.settings;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.vertx.core.json.JsonObject;
import lombok.Getter;
import lombok.Setter;
import tools.vlab.kberry.app.dashboard.Setting;

import java.util.List;

@Getter
@Setter
public class Light {

    private boolean presenceOff;
    private boolean presenceOn;
    private int holdTimeMinute;
    private boolean onlyDark;
    private float minLux;

    public Light() {
    }

    public Light(boolean presenceOff, boolean presenceOn, int holdTimeMinute, boolean onlyDark, float minLux) {
        this.presenceOff = presenceOff;
        this.presenceOn = presenceOn;
        this.holdTimeMinute = holdTimeMinute;
        this.onlyDark = onlyDark;
        this.minLux = minLux;
    }

    @JsonIgnore
    public static Light first() {
        return new Light(false, false, 5, false, 0.0f);
    }

    @JsonIgnore
    public JsonObject toJson() {
        return JsonObject.mapFrom(this);
    }

    @JsonIgnore
    public static Light fromJson(JsonObject json) {
        return json.mapTo(Light.class);
    }


    @JsonIgnore
    public static Light fromSettings(List<JsonObject> settings) {
        Light light = new Light();

        for (JsonObject setting : settings) {
            String title = setting.getString("title");
            if (title == null) continue;
            String value = setting.getJsonObject("value").getString("value");
            switch (title) {
                case "Auto Ausschalten" ->
                        light.setPresenceOff(Boolean.parseBoolean(value));
                case "Auto Einschalten" ->
                        light.setPresenceOn(Boolean.parseBoolean(value));
                case "Nachlaufzeit (min)" ->
                    light.setHoldTimeMinute(Integer.parseInt(value));
                case "Bei Dunkelheit" ->
                        light.setOnlyDark(Boolean.parseBoolean(value));
                case "Min Lux" ->
                        light.setMinLux(Float.parseFloat(value));
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
                Setting.checkbox("Auto Ausschalten", isPresenceOff(), "person_pin_circle_outlined").toJson(),
                Setting.minutes("Nachlaufzeit (min)", getHoldTimeMinute(), "timelapse_outlined").toJson(),
                Setting.checkbox("Auto Einschalten", isPresenceOn(), "person_pin_circle").toJson(),
                Setting.checkbox("Bei Dunkelheit", isOnlyDark(), "person_pin_circle").toJson(),
                Setting.number("Min Lux", getMinLux(), "person_pin_circle").toJson()
        );
    }
}
