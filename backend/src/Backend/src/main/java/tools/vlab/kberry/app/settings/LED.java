package tools.vlab.kberry.app.settings;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.dashboard.Setting;

import java.util.List;

public class LED {

    private String hex;

    public LED() {
    }

    public LED(String hex) {
        this.hex = hex;
    }

    public String getHex() {
        return hex;
    }

    public void setHex(String hex) {
        this.hex = hex;
    }

    @JsonIgnore
    public static LED first() {
        return new LED("#004433");
    }

    @JsonIgnore
    public JsonObject toJson() {
        return JsonObject.mapFrom(this);
    }

    @JsonIgnore
    public static LED fromJson(JsonObject json) {
        return json.mapTo(LED.class);
    }


    @JsonIgnore
    public List<JsonObject> toSettings() {
        return List.of(
                Setting.rgbw("hex", getHex(), "color_lens").toJson()
        );
    }

    @JsonIgnore
    public static LED fromSettings(List<JsonObject> settings) {
        LED led = new LED();
        for (JsonObject setting : settings) {
            String title = setting.getString("title");
            String value = setting.getJsonObject("value").getString("value", "40");
            switch (title) {
                case "hex" -> led.setHex(value);
                default -> {
                    // Unbekannte Einstellung ignorieren
                }
            }
        }
        return led;
    }
}
