package tools.vlab.kberry.app.dashboard;

import io.vertx.core.buffer.Buffer;
import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import lombok.Getter;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.RGB;

import java.util.List;

@Getter
public class Information {
    PositionPath positionPath;
    InformationType type;
    String password;
    String[] values;

    public static Information led(PositionPath positionPath, RGB rgbw, String password) {
        return new Information(positionPath, InformationType.led, password, rgbw.toHex());
    }

    public static Information light(PositionPath positionPath, Boolean isOn, Float lux, String password) {
        return new Information(positionPath, InformationType.light, password, isOn.toString(), lux.toString());
    }

    public static Information plug(PositionPath positionPath, Boolean isOn, String password) {
        return new Information(positionPath, InformationType.plug, password, isOn.toString());
    }

    public static Information scene(PositionPath positionPath, Long lastExecution, String password) {
        return new Information(positionPath, InformationType.scene, password, lastExecution.toString());
    }

    public static Information jalousie(PositionPath positionPath, Integer position, String password) {
        return new Information(positionPath, InformationType.jalousie, password, position.toString());
    }

    public static Information dimmer(PositionPath positionPath, Integer brightness, String password) {
        return new Information(positionPath, InformationType.dimmer, password, brightness.toString());
    }

    public static Information temperature(PositionPath positionPath, Float currentTemperature, String password) {
        double rounded = Math.round(currentTemperature * 100.0) / 100.0;
        return new Information(positionPath, InformationType.temperature, password, Double.toString(rounded));
    }

    public static Information floorHeater(PositionPath positionPath, Integer actuatorPosition, Float currentTemperature, String password) {
        double rounded = Math.round(currentTemperature * 100.0) / 100.0;
        return new Information(positionPath, InformationType.floorHeater, password, actuatorPosition.toString(), Double.toString(rounded));
    }

    public static Information humidity(PositionPath positionPath, Float humidity, String password) {
        return new Information(positionPath, InformationType.humidity, password, humidity.toString());
    }

    public static Information presence(PositionPath positionPath, Long lastPresentSecond, Boolean isUsed, String password) {
        return new Information(positionPath, InformationType.presence, password, lastPresentSecond.toString(), isUsed.toString());
    }

    public static Information electricity(PositionPath positionPath, Integer kwh, String password) {
        return new Information(positionPath, InformationType.energy, password, kwh.toString());
    }

    public static Information voc(PositionPath positionPath, Float ppm, String password) {
        return new Information(positionPath, InformationType.voc, password, ppm.toString());
    }

    public static Information lux(PositionPath positionPath, Float currentLux, String password) {
        return new Information(positionPath, InformationType.voc, password, currentLux.toString());
    }

    public Information(PositionPath positionPath, InformationType type, String password, String... values) {
        this.positionPath = positionPath;
        this.type = type;
        this.password = password;
        this.values = values;
    }

    public String getTopic() {
        return this.positionPath.getPath();
    }

    public Buffer toPayload() {
        return toJson().toBuffer();
    }

    public JsonObject toJson() {
        JsonObject json = new JsonObject();
        json.put("positionPath", this.positionPath.getPath());
        json.put("type", type);
        if (this.password != null) {
            json.put("password", this.password);
        } else {
            json.putNull("password");
        }
        json.put("values", new JsonArray(List.of(values)));
        return json;
    }

}
