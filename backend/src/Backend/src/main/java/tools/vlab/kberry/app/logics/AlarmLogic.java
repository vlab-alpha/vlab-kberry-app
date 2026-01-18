package tools.vlab.kberry.app.logics;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.sensor.PresenceSensor;
import tools.vlab.kberry.core.devices.sensor.PresenceStatus;
import tools.vlab.kberry.server.logic.Logic;

import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;

public class AlarmLogic extends Logic implements PresenceStatus {

    private final static long BREAK_ONE_HOUR_MS = 1000 * 60 * 60;
    private final static Logger Log = LoggerFactory.getLogger(AlarmLogic.class);
    private final MailService mailService;
    private final AtomicBoolean mailSendActive = new AtomicBoolean(true);
    private final AtomicLong mailSendEveryOneHour = new AtomicLong();

    private AlarmLogic(PositionPath path, MailService mailService) {
        super(path);
        this.mailService = mailService;
    }

    public static AlarmLogic at(MailService mailService, PositionPath path) {
        return new AlarmLogic(path, mailService);
    }

    @Override
    public void stop() {

    }

    @Override
    public void start() {
        mailSendActive.set(true);
    }

    @Override
    public void presenceChanged(PresenceSensor sensor, boolean available) {
        if (mailSendActive.get() && mailSendEveryOneHour.get() < (System.currentTimeMillis() - BREAK_ONE_HOUR_MS)) {
            mailService.sendMail("Person detected", String.format("Person detected in room %s", sensor.getPositionPath().getRoom()))
                    .onFailure(failure -> {
                        Log.error("Mail couldn't send!", failure);
                        mailSendActive.set(false);
                    })
                    .onSuccess(mailResult -> {
                        Log.info("Mail send successfully!");
                        mailSendEveryOneHour.set(System.currentTimeMillis());
                    });
        }
    }
}
