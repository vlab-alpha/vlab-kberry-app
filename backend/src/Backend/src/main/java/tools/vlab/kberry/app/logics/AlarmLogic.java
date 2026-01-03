package tools.vlab.kberry.app.logics;

import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.sensor.PresenceSensor;
import tools.vlab.kberry.core.devices.sensor.PresenceStatus;
import tools.vlab.kberry.server.logic.Logic;

import java.util.List;
import java.util.Vector;

public class AlarmLogic extends Logic implements PresenceStatus {

    private final MailService mailService;

    private AlarmLogic(Vector<PositionPath> paths, MailService mailService) {
        super(paths);
        this.mailService = mailService;
    }

    public static AlarmLogic at(MailService mailService, PositionPath... path) {
        return new AlarmLogic(new Vector<>(List.of(path)), mailService);
    }


    public static AlarmLogic at(MailService mailService, List<PositionPath> path) {
        return new AlarmLogic(new Vector<>(path), mailService);
    }

    @Override
    public void stop() {

    }

    @Override
    public void start() {

    }

    @Override
    public void presenceChanged(PresenceSensor sensor, boolean available) {
        mailService.sendMail("Person detected", String.format("Person detected in room %s", sensor.getPositionPath().getRoom()));
    }
}
