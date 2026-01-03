package tools.vlab.kberry.app.settings;

import io.vertx.core.buffer.Buffer;
import tools.vlab.kberry.server.settings.SettingsVerticle;

public class LEDSettingsVerticle extends SettingsVerticle<LED> {

    public LEDSettingsVerticle(String basePath) {
        super(basePath, "LED");
    }

    @Override
    public LED defaultSetting() {
        return LED.first();
    }

    @Override
    public LED toJson(Buffer buffer) {
        return LED.fromJson(buffer.toJsonObject());
    }

    @Override
    public Buffer toBuffer(LED setting) {
        return setting.toJson().toBuffer();
    }
}
