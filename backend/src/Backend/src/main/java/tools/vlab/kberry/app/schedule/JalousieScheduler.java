package tools.vlab.kberry.app.schedule;

import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.knx.devices.KNXDevices;
import tools.vlab.kberry.core.knx.devices.PushButton;
import tools.vlab.kberry.core.knx.devices.actor.Jalousie;
import tools.vlab.kberry.core.mqtt.custom.devices.CustomMqttDevices;
import tools.vlab.kberry.core.mqtt.shelly.devices.ShellyDevices;
import tools.vlab.kberry.server.scheduler.Scheduler;
import tools.vlab.kberry.server.scheduler.trigger.Daily;
import tools.vlab.kberry.server.scheduler.trigger.Trigger;
import tools.vlab.kberry.server.scheduler.trigger.Weekday;
import tools.vlab.kberry.server.scheduler.trigger.Weekend;
import tools.vlab.kberry.server.serviceProvider.ServiceProviders;

import java.time.LocalTime;

public class JalousieScheduler extends Scheduler {

    private final static int RETRY = 3;
    private final String taskId;
    private final PositionPath positionPath;
    private final Trigger trigger;
    private final boolean isUp;
    private final boolean isKindersicherung;
    private final int position;

    private JalousieScheduler(String taskId, PositionPath positionPath, Trigger trigger, boolean isUp, boolean isKindersicherung, int position) {
        this.taskId = taskId;
        this.positionPath = positionPath;
        this.trigger = trigger;
        this.isUp = isUp;
        this.isKindersicherung = isKindersicherung;
        this.position = position;
    }

    public static JalousieScheduler upDaily(String taskId, PositionPath positionPath, LocalTime time, int position) {
        return new JalousieScheduler(taskId, positionPath, Daily.trigger(time), true, false, position);
    }

    public static JalousieScheduler upWeekend(String taskId, PositionPath positionPath, LocalTime time) {
        return new JalousieScheduler(taskId, positionPath, Weekend.trigger(time), true, false, 100);
    }

    public static JalousieScheduler downWeekend(String taskId, PositionPath positionPath, LocalTime time, boolean kindersicherung) {
        return new JalousieScheduler(taskId, positionPath, Weekend.trigger(time), false, kindersicherung, 0);
    }

    public static JalousieScheduler downWeekday(String taskId, PositionPath positionPath, LocalTime time, boolean kindersicherung) {
        return new JalousieScheduler(taskId, positionPath, Weekday.trigger(time), false, kindersicherung, 0);
    }

    public static JalousieScheduler upWeekday(String taskId, PositionPath positionPath, LocalTime time) {
        return new JalousieScheduler(taskId, positionPath, Weekday.trigger(time), true, false, 100);
    }

    public static JalousieScheduler upWeekday(String taskId, PositionPath positionPath, LocalTime time, int position) {
        return new JalousieScheduler(taskId, positionPath, Weekday.trigger(time), true, false, position);
    }

    public static JalousieScheduler upWeekend(String taskId, PositionPath positionPath, LocalTime time, int position) {
        return new JalousieScheduler(taskId, positionPath, Weekend.trigger(time), true, false, position);
    }

    @Override
    public Trigger getTrigger() {
        return this.trigger;
    }

    private boolean isDown() {
        return !this.isUp;
    }

    private boolean isUp() {
        return this.isUp;
    }

    private boolean isKindersicherung() {
        return this.isKindersicherung;
    }

    @Override
    public void executed(KNXDevices devices, CustomMqttDevices mqttDevices, ShellyDevices shellyDevices, ServiceProviders serviceProviders) {
        if (this.isDown() && this.isKindersicherung()) {
            devices.getKNXDeviceByRoom(PushButton.class, this.positionPath)
                    .ifPresent(PushButton::disable);
        } else {
            devices.getKNXDeviceByRoom(PushButton.class, this.positionPath)
                    .ifPresent(PushButton::enable);
        }
        if (this.isDown()) {
            devices.getKNXDeviceByRoom(Jalousie.class, this.positionPath).ifPresent(Jalousie::down);
        } else {
            devices.getKNXDeviceByRoom(Jalousie.class, this.positionPath).ifPresent(jalousie -> jalousie.setPositionPercent(position));
        }
    }

    @Override
    public String getTaskId() {
        return this.taskId;
    }

    @Override
    public PositionPath getPositionPath() {
        return this.positionPath;
    }

    @Override
    public int getRetry() {
        return RETRY;
    }

    @Override
    public Boolean checkStatus(Integer retry, KNXDevices devices, CustomMqttDevices mqttDevices, ShellyDevices shellyDevices, ServiceProviders serviceProviders) {
        return devices.getKNXDeviceByRoom(Jalousie.class, this.positionPath)
                .map(jalousie -> isDown() ? jalousie.isDown() : jalousie.getCurrentPositionPercent() == position)
                .orElse(true);
    }
}
