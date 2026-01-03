package tools.vlab.kberry.app.settings;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.vertx.core.json.JsonObject;
import lombok.Getter;
import lombok.Setter;
import tools.vlab.kberry.app.dashboard.Setting;

import java.util.List;

@Setter
@Getter
public class Dimmer {

    int minDimValue;
    int maxDimValue;
    boolean dimmerByLux;

    public Dimmer() {
    }

    public Dimmer(int maxDimValue, int minDimValue, boolean dimmerByLux) {
        this.maxDimValue = maxDimValue;
        this.minDimValue = minDimValue;
        this.dimmerByLux = dimmerByLux;
    }

    @JsonIgnore
    public static Dimmer first() {
        return new Dimmer(100, 0, false);
    }

    @JsonIgnore
    public JsonObject toJson() {
        return JsonObject.mapFrom(this);
    }

    @JsonIgnore
    public static Dimmer fromJson(JsonObject json) {
        return json.mapTo(Dimmer.class);
    }

    @JsonIgnore
    public List<JsonObject> toSettings() {
        return List.of(
                Setting.number("Maximalwert", getMaxDimValue(), "nightlight_round").toJson(),
                Setting.number("Minimalwert", getMinDimValue(), "brightness_low").toJson(),
                Setting.checkbox("Dimmen Via Lux", isDimmerByLux(), "brightness_low").toJson()
        );
    }

    public static Dimmer fromSettings(List<JsonObject> settings) {
        Dimmer dimmer = new Dimmer();
        for (JsonObject setting : settings) {
            String title = setting.getString("title");
            String value = setting.getJsonObject("value").getString("value", "40");
            switch (title) {
                case "Maximalwert" -> dimmer.setMaxDimValue(Integer.parseInt(value));
                case "Minimalwert" -> dimmer.setMinDimValue(Integer.parseInt(value));
                case "Dimmen Via Lux" -> dimmer.setDimmerByLux(Boolean.parseBoolean(value));
                default -> {
                    // Unbekannte Einstellung ignorieren
                }
            }
        }
        return dimmer;
    }
}
