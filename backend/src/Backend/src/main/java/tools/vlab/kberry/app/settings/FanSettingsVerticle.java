package tools.vlab.kberry.app.settings;

import io.vertx.core.buffer.Buffer;
import tools.vlab.kberry.server.settings.SettingsVerticle;

public class FanSettingsVerticle extends SettingsVerticle<Fan> {

    public FanSettingsVerticle(String basePath) {
        super(basePath, "fan");
    }

    @Override
    public Fan defaultSetting() {
        return Fan.first();
    }

    @Override
    public Fan toJson(Buffer buffer) {
        return buffer.toJsonObject().mapTo(Fan.class);
    }

    @Override
    public Buffer toBuffer(Fan setting) {
        return setting.toJson().toBuffer();
    }
}
