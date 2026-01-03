package tools.vlab.kberry.app;

import io.vertx.core.Vertx;

public class ConfigLoader {

    public static AppSettings loadSettings(Vertx vertx) {
        var file = vertx.fileSystem().readFileBlocking("config.settings");
        return file.toJsonObject().mapTo(AppSettings.class);
    }

}
