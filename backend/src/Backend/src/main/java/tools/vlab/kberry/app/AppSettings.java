package tools.vlab.kberry.app;

import lombok.Data;

@Data
public class AppSettings {
    private String username;
    private String password;
    private String mqttHost;
    private int mqttPort;
    private String calendarUrl;
    private String mailUserName;
    private String mailPassword;
    private String mailHost;
    private int mailPort;
    private String toMail;
}