package tools.vlab.kberry.app.logics;

import tools.vlab.kberry.core.devices.KNXDevices;
import tools.vlab.kberry.core.devices.actor.Light;
import tools.vlab.kberry.server.scheduler.Scheduler;
import tools.vlab.kberry.server.scheduler.trigger.Daily;
import tools.vlab.kberry.server.scheduler.trigger.Trigger;

import java.time.LocalTime;

public class AllLightOffAtNightSchedule extends Scheduler {

    @Override
    public Trigger getTrigger() {
        return Daily.trigger(LocalTime.of(2, 0));
    }

    @Override
    public void executed(KNXDevices knxDevices) {
        knxDevices.getKNXDevices(Light.class).forEach(Light::off);
    }
}
