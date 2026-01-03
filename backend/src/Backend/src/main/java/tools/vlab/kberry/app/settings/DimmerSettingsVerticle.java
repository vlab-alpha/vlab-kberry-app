package tools.vlab.kberry.app.settings;

import io.vertx.core.buffer.Buffer;
import tools.vlab.kberry.server.settings.SettingsVerticle;

public class DimmerSettingsVerticle extends SettingsVerticle<Dimmer> {

    public DimmerSettingsVerticle(String basePath) {
        super(basePath, "dimmer");
    }

    @Override
    public Dimmer defaultSetting() {
        return Dimmer.first();
    }

    @Override
    public Dimmer toJson(Buffer buffer) {
        return buffer.toJsonObject().mapTo(Dimmer.class);
    }

    @Override
    public Buffer toBuffer(Dimmer setting) {
        return setting.toJson().toBuffer();
    }
}
