package tools.vlab.kberry.app.logics;

import io.vertx.core.AbstractVerticle;
import io.vertx.core.Promise;
import io.vertx.ext.mail.MailClient;
import io.vertx.ext.mail.MailConfig;
import io.vertx.ext.mail.MailMessage;
import io.vertx.ext.mail.StartTLSOptions;

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
        // Mail-Server konfigurieren
        MailConfig config = new MailConfig();
        config.setHostname(this.host);  // SMTP-Server
        config.setPort(this.port);                    // SMTP-Port (z.B. 587 für TLS)
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
    public void sendMail(String subject, String body) {
        MailMessage message = new MailMessage();
        message.setFrom("Kberry SmartHome <your_user@example.com>");
        message.setTo(this.mailTo);
        message.setSubject(subject);
        message.setText(body);

        mailClient.sendMail(message).onSuccess(to -> System.out.println("Mail erfolgreich gesendet an: " + to.getRecipients()))
                .onFailure(failure -> System.err.println("Fehler beim Senden der Mail: " + failure.getMessage()));
    }
}