package tools.vlab.kberry.app.logics;

import io.vertx.core.AbstractVerticle;
import io.vertx.core.Future;
import io.vertx.core.Promise;
import io.vertx.ext.mail.*;

public class MailService extends AbstractVerticle {

    private MailClient mailClient;

    private final String mailTo;
    private final String host;
    private final int port;
    private final String userName;
    private final char[] password;

    public MailService(String mailTo, String host, int port, String userName, char[] password) {
        this.mailTo = mailTo;
        this.host = host;
        this.port = port;
        this.userName = userName;
        this.password = password;
    }

    @Override
    public void start(Promise<Void> startPromise) {
        MailConfig config = new MailConfig();
        config.setHostname(this.host);
        config.setPort(this.port);
        config.setStarttls(StartTLSOptions.REQUIRED);
        config.setUsername(this.userName);
        config.setPassword(new String(this.password));

        mailClient = MailClient.create(vertx, config);

        startPromise.complete();
    }

    @Override
    public void stop() {
        if (mailClient != null) {
            mailClient.close();
        }
    }

    /**
     * Sendet eine Mail.
     *
     * @param subject Betreff
     * @param body    Inhalt der Mail
     */
    public Future<MailResult> sendMail(String subject, String body) {
        MailMessage message = new MailMessage();
        message.setFrom("Kberry SmartHome Alarm");
        message.setTo(this.mailTo);
        message.setSubject(subject);
        message.setText(body);
        return mailClient.sendMail(message);
    }

}