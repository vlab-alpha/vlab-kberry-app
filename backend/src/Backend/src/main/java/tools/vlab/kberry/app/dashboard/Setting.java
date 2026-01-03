package tools.vlab.kberry.app.dashboard;

import io.vertx.core.json.JsonObject;

public class Setting {

    SettingType type;
    String title;
    Value value;
    String icon;

    public Setting(SettingType type, String title, Value value, String icon) {
        this.title = title;
        this.value = value;
        this.icon = icon;
        this.type = type;
    }

    public static Setting number(String title, Float v, String icon) {
        var value = new Value(ValueType.Double, null, null, v.toString());
        return new Setting(SettingType.NumberSpan, title, value, icon);
    }

    public static Setting range(String title, Double from, Double to, Double current, String icon) {
        var value = new Value(ValueType.Double, from.toString(), to.toString(), current.toString());
        return new Setting(SettingType.NumberSpan, title, value, icon);
    }

    public static Setting range(String title, Integer from, Integer to, Integer current, String icon) {
        var value = new Value(ValueType.Double, from.toString(), to.toString(), current.toString());
        return new Setting(SettingType.NumberSpan, title, value, icon);
    }

    public static Setting checkbox(String title, Boolean check, String icon) {
        var value = new Value(ValueType.Boolean, null, null, check.toString());
        return new Setting(SettingType.Checkbox, title, value, icon);
    }

    public static Setting time(String title, String time, String icon) {
        var value = new Value(ValueType.Time, null, null, time);
        return new Setting(SettingType.Time, title, value, icon);
    }

    public static Setting number(String title, Integer number, String icon) {
        var value = new Value(ValueType.Integer, null, null, number.toString());
        return new Setting(SettingType.Number, title, value, icon);
    }

    public static Setting timeSpan(String title, Integer timeFrom, Integer timeTo, Integer currentValue, String icon) {
        var value = new Value(ValueType.Time, timeFrom.toString(), timeTo.toString(), currentValue.toString());
        return new Setting(SettingType.TimeSpan, title, value, icon);
    }

    public static Setting rgbw(String title, String colorHex, String icon) {
        var value = new Value(ValueType.Time, null, null, colorHex);
        return new Setting(SettingType.TimeSpan, title, value, icon);
    }

    public Setting() {
    }

    public static Setting minutes(String title, Integer minutes, String icon) {
        var value = new Value(ValueType.Integer, null, null, minutes.toString());
        return new Setting(SettingType.Minutes, title, value, icon);
    }

    public static Setting numberSpan(String title, Integer from, Integer to, Integer currentValue, String icon) {
        var value = new Value(ValueType.Integer, from.toString(), to.toString(), currentValue.toString());
        return new Setting(SettingType.NumberSpan, title, value, icon);
    }

    public SettingType getType() {
        return type;
    }

    public void setType(SettingType type) {
        this.type = type;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Value getValue() {
        return value;
    }

    public void setValue(Value value) {
        this.value = value;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public JsonObject toJson() {
        return JsonObject.mapFrom(this);
    }


}
