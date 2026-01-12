package tools.vlab.kberry.app.commands;

import tools.vlab.kberry.server.commands.CommandTopic;

public enum Commands implements CommandTopic {
    SET_TEMPERATURE_POINT("set", "temperature", "point"),
    SET_TEMPERATURE_SETTINGS("set", "settings", "temperature"),
    GET_TEMPERATURE_STATISTICS("get", "temperature", "statistics"),
    GET_TEMPERATURE_DATA("get", "temperature", "data"),
    SET_TEMPERATURE_MODE("set", "temperature", "mode"),
    SET_PLUG_STATUS("set", "plug", "status"),
    GET_PLUG_STATUS("get", "plug", "satus"),
    SET_PLUG_SETTINGS("set", "settings", "plug"),
    SET_LIGHT_SETTINGS("set","settings","light"),
    SET_LIGHT_STATUS("set","light","status"),
    GET_LIGHT_STATUS("get", "light", "status"),
    SET_LED_COLOR("set","led","color"),
    GET_LED_COLOR("get", "led", "color"),
    SET_JALOUSIE_SETTINGS("set","settings","jalousie"),
    SET_JALOUSIE_STOP("set","jalousie","stop"),
    SET_JALOUSIE_REFERENCE("set","jalousie","reference"),
    SET_JALOUSIE_POSITION("set","jalousie","position"),
    GET_JALOUSIE_POSITION("get", "jalousie", "position"),
    SET_DIMMER_SETTINGS("set","settings","dimmer"),
    SET_DIMMER_STATUS("set","dimmer","status"),
    GET_DIMMER_STATUS("get", "dimmer", "status"),
    GET_USAGE_DATA("get", "usage", "data"),
    GET_SETTINGS_ALL("get", "settings", "all"),
    GET_POSITION_PATHS("get", "position", "paths"),
    ALARM_ON("scene", "alarm", "on"),
    ALARM_OFF("scene", "alarm", "off"),
    JALOUSIE_ALL_UP("scene", "jalousie", "up"),
    JALOUSIE_ALL_DOWN("scene", "jalousie", "down"),
    ALL_LIGHT_OFF("scene", "off", "light"),
    HOLIDAY_START("scene", "holiday", "start"),
    HOLIDAY_END("scene", "holiday", "end"),
    START_MOVIE("scene", "start", "movie"),
    SET_HEATER_SETTINGS("set", "settings", "heater"),;

    private final String[] path;

    Commands(String... path) {
        this.path = path;
    }

    @Override
    public String[] getTopicPath() {
        return path;
    }
}
