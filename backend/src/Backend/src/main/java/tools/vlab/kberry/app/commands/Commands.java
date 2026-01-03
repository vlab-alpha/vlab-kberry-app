package tools.vlab.kberry.app.commands;

import tools.vlab.kberry.server.commands.CommandTopic;

public enum Commands implements CommandTopic {
    SET_TEMPERATURE("set", "send", "temperature"),
    SET_PLUG("set", "send", "plug"),
    SET_PLUG_SETTINGS("set", "setting", "plug"),
    SET_TEMPERATURE_SETTINGS("set", "send", "temperature"),
    SET_LIGHT_SETTINGS("set","setting","light"),
    SET_LIGHT("set","send","light"),
    SET_LED("set","send","led"),
    SET_JALOUSIE_SETTINGS("set","setting","jalousie"),
    SET_JALOUSIE_STOP("set","stop","jalousie"),
    SET_JALOUSIE_REFERENCE("set","reference","jalousie"),
    SET_JALOUSIE_POSITION("set","position","jalousie"),
    SET_DIMMER_SETTINGS("set","setting","dimmer"),
    SET_DIMMER_PERCENT("set","percent","dimmer"),
    SET_DIMMER_STATUS("set","status","dimmer"),
    GET_DIMMER("get", "get", "dimmer"),
    GET_USAGE("get", "get", "usage"),
    GET_TEMPERATURE_STATISTICS("get", "statistics", "temperature"),
    GET_TEMPERATURE("get", "get", "temperature"),
    GET_SETTINGS_ALL("get", "settings", "all"),
    GET_POSITION_PATHS("get", "position", "paths"),
    GET_PLUG("get", "plugin", "plug"),
    GET_LIGHT("get", "light", "light"),
    GET_LED("get", "led", "led"),
    GET_JALOUSIE("get", "jalousie", "jalousie"),
    SET_TEMPERATURE_MODE("set", "mode", "temperature"),
    ALARM_ON("scene", "alarm", "on"),
    ALARM_OFF("scene", "alarm", "off"),
    JALOUSIE_ALL_UP("scene", "jalousie", "up"),
    JALOUSIE_ALL_DOWN("scene", "jalousie", "down"),
    ALL_LIGHT_OFF("scene", "off", "light"),
    HOLIDAY_START("scene", "holiday", "start"),
    HOLIDAY_END("scene", "holiday", "end"),
    START_MOVIE("scene", "start", "movie"),;

    private final String[] path;

    Commands(String... path) {
        this.path = path;
    }

    @Override
    public String[] getTopicPath() {
        return path;
    }
}
