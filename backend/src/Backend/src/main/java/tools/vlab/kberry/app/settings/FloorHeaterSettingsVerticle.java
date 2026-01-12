package tools.vlab.kberry.app.settings;

import io.vertx.core.buffer.Buffer;
import tools.vlab.kberry.server.settings.SettingsVerticle;

public class FloorHeaterSettingsVerticle extends SettingsVerticle<FloorHeater> {

    public FloorHeaterSettingsVerticle(String basePath) {
        super(basePath, "dimmer");
    }

    @Override
    public FloorHeater defaultSetting() {
        return FloorHeater.first();
    }

    @Override
    public FloorHeater toJson(Buffer buffer) {
        return buffer.toJsonObject().mapTo(FloorHeater.class);
    }

    @Override
    public Buffer toBuffer(FloorHeater setting) {
        return setting.toJson().toBuffer();
    }
}
