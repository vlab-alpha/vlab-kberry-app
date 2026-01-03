package tools.vlab.kberry.app.settings;

import io.vertx.core.buffer.Buffer;
import tools.vlab.kberry.server.settings.SettingsVerticle;

public class JalousieSettingsVerticle extends SettingsVerticle<Jalousie> {

    public JalousieSettingsVerticle(String basePath) {
        super(basePath, "Jalousie");
    }

    @Override
    public Jalousie defaultSetting() {
        return Jalousie.first();
    }

    @Override
    public Jalousie toJson(Buffer buffer) {
        return Jalousie.fromJson(buffer.toJsonObject());
    }

    @Override
    public Buffer toBuffer(Jalousie setting) {
        return setting.toJson().toBuffer();
    }
}
