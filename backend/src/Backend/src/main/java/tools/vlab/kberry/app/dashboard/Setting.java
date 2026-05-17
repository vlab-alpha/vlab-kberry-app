package tools.vlab.kberry.app.dashboard;

import io.vertx.core.json.JsonObject;

public class Setting {

    SettingType type;
    String title;
    Value value;
    String icon;
    boolean disable;

    public Setting(SettingType type, String title, Value value, String icon, boolean disable) {
        this.title = title;
        this.value = value;
        this.icon = icon;
        this.type = type;
        this.disable = disable;
    }

    public static Setting number(String title, Float v, String icon) {
        var value = new Value(ValueType.Double, null, null, v.toString());
        return new Setting(SettingType.Number, title, value, icon, false);
    }

    public static Setting seperator(String title, String icon) {
        return new Setting(SettingType.Seperator, title, Value.empty(), icon, false);
    }

    public static Setting range(String title, Double from, Double to, Double current, String icon) {
        var value = new Value(ValueType.Double, from.toString(), to.toString(), current.toString());
        return new Setting(SettingType.NumberSpan, title, value, icon, false);
    }

    public static Setting range(String title, Integer from, Integer to, Integer current, String icon) {
        var value = new Value(ValueType.Double, from.toString(), to.toString(), current.toString());
        return new Setting(SettingType.NumberSpan, title, value, icon, false);
    }

    public static Setting checkbox(String title, Boolean check, String icon) {
        return checkbox(title, check, icon, false);
    }

    public static Setting checkbox(String title, Boolean check, String icon, boolean disable) {
        var value = new Value(ValueType.Boolean, null, null, check.toString());
        return new Setting(SettingType.Checkbox, title, value, icon, disable);
    }

    public static Setting time(String title, String time, String icon, boolean disable) {
        var value = new Value(ValueType.Time, null, null, time);
        return new Setting(SettingType.Time, title, value, icon, disable);
    }

    public static Setting time(String title, String time, String icon) {
        return time(title, time, icon, false);
    }

    public static Setting number(String title, Integer number, String icon) {
        var value = new Value(ValueType.Integer, null, null, number.toString());
        return new Setting(SettingType.Number, title, value, icon, false);
    }

    public static Setting timeSpan(String title, Integer timeFrom, Integer timeTo, Integer currentValue, String icon) {
        var value = new Value(ValueType.Time, timeFrom.toString(), timeTo.toString(), currentValue.toString());
        return new Setting(SettingType.TimeSpan, title, value, icon, false);
    }

    public static Setting rgbw(String title, String colorHex, String icon) {
        var value = new Value(ValueType.Time, null, null, colorHex);
        return new Setting(SettingType.TimeSpan, title, value, icon, false);
    }

    public Setting() {
    }

    public static Setting minutes(String title, Integer minutes, String icon) {
        var value = new Value(ValueType.Integer, null, null, minutes.toString());
        return new Setting(SettingType.Minutes, title, value, icon, false);
    }

    public static Setting numberSpan(String title, Integer from, Integer to, Integer currentValue, String icon) {
        var value = new Value(ValueType.Integer, from.toString(), to.toString(), currentValue.toString());
        return new Setting(SettingType.NumberSpan, title, value, icon, false);
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

    public boolean isDisable() {
        return disable;
    }

    public void setDisable(boolean disable) {
        this.disable = disable;
    }

    public JsonObject toJson() {
        return JsonObject.mapFrom(this);
    }


}
