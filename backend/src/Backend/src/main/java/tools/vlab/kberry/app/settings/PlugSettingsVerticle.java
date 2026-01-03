package tools.vlab.kberry.app.settings;

import io.vertx.core.buffer.Buffer;
import tools.vlab.kberry.server.settings.SettingsVerticle;

public class PlugSettingsVerticle extends SettingsVerticle<Plug> {

    public PlugSettingsVerticle(String basePath) {
        super(basePath, "Plug");
    }

    @Override
    public Plug defaultSetting() {
        return Plug.first();
    }

    @Override
    public Plug toJson(Buffer buffer) {
        return Plug.fromJson(buffer.toJsonObject());
    }

    @Override
    public Buffer toBuffer(Plug setting) {
        return setting.toJson().toBuffer();
    }
}
