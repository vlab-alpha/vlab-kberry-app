package tools.vlab.kberry.app.settings;

import io.vertx.core.buffer.Buffer;
import tools.vlab.kberry.server.settings.SettingsVerticle;

public class LightSettingsVerticle extends SettingsVerticle<Light> {

    public LightSettingsVerticle(String basePath) {
        super(basePath, "Light");
    }

    @Override
    public Light defaultSetting() {
        return Light.first();
    }

    @Override
    public Light toJson(Buffer buffer) {
        return Light.fromJson(buffer.toJsonObject());
    }

    @Override
    public Buffer toBuffer(Light setting) {
        return setting.toJson().toBuffer();
    }
}
