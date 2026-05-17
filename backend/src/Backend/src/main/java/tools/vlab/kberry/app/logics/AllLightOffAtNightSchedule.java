package tools.vlab.kberry.app.logics;

import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.knx.devices.KNXDevices;
import tools.vlab.kberry.core.knx.devices.actor.Led;
import tools.vlab.kberry.core.knx.devices.actor.Light;
import tools.vlab.kberry.core.mqtt.custom.devices.CustomMqttDevices;
import tools.vlab.kberry.core.mqtt.shelly.devices.ShellyDevices;
import tools.vlab.kberry.server.scheduler.Scheduler;
import tools.vlab.kberry.server.scheduler.trigger.Daily;
import tools.vlab.kberry.server.scheduler.trigger.Trigger;
import tools.vlab.kberry.server.serviceProvider.ServiceProviders;

import java.time.LocalTime;

public class AllLightOffAtNightSchedule extends Scheduler {

    private final PositionPath positionPath;

    public AllLightOffAtNightSchedule(PositionPath positionPath) {
        this.positionPath = positionPath;
    }

    @Override
    public Trigger getTrigger() {
        return Daily.trigger(LocalTime.of(2, 0));
    }

    @Override
    public void executed(KNXDevices knxDevices, CustomMqttDevices mqttDevices, ShellyDevices shellyDevices, ServiceProviders serviceProviders) {
        knxDevices.getKNXDevices(Light.class).forEach(Light::off);
        knxDevices.getKNXDevices(Led.class).forEach(Led::off);
        shellyDevices.getDevices(tools.vlab.kberry.core.mqtt.shelly.devices.device.Led.class).forEach(tools.vlab.kberry.core.mqtt.shelly.devices.device.Led::off);
    }

    @Override
    public String getTaskId() {
        return "all-lights-off-at-night";
    }

    @Override
    public PositionPath getPositionPath() {
        return this.positionPath;
    }
}
