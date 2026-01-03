package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.dashboard.InformationType;
import tools.vlab.kberry.app.settings.DimmerSettingsVerticle;
import tools.vlab.kberry.app.settings.JalousieSettingsVerticle;
import tools.vlab.kberry.app.settings.LightSettingsVerticle;
import tools.vlab.kberry.app.settings.PlugSettingsVerticle;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class GetSettingsCommand extends Command {

    private final DimmerSettingsVerticle dimmerSettingsVerticle;
    private final JalousieSettingsVerticle jalousieSettingsVerticle;
    private final LightSettingsVerticle lightSettingsVerticle;
    private final PlugSettingsVerticle plugSettingsVerticle;

    public GetSettingsCommand(DimmerSettingsVerticle dimmerSettingsVerticle, JalousieSettingsVerticle jalousieSettingsVerticle, LightSettingsVerticle lightSettingsVerticle, PlugSettingsVerticle plugSettingsVerticle) {
        this.dimmerSettingsVerticle = dimmerSettingsVerticle;
        this.jalousieSettingsVerticle = jalousieSettingsVerticle;
        this.lightSettingsVerticle = lightSettingsVerticle;
        this.plugSettingsVerticle = plugSettingsVerticle;
    }

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        var positionPath = Haus.positionPath(message.getString("positionPath"));
        var type = InformationType.valueOf(message.getString("type"));
        if (type == InformationType.dimmer) {
            return dimmerSettingsVerticle.getSettingAsync(positionPath)
                    .map(currentSetting -> Optional.of(new JsonObject().put("settings", new JsonArray(currentSetting.toSettings()))));
        }
        if (type == InformationType.jalousie) {
            return this.jalousieSettingsVerticle.getSettingAsync(positionPath)
                    .map(currentSetting -> Optional.of(new JsonObject().put("settings", new JsonArray(currentSetting.toSettingsList()))));
        }
        if (type == InformationType.light) {
            return this.lightSettingsVerticle.getSettingAsync(positionPath)
                    .map(currentSetting -> Optional.of(new JsonObject().put("settings", new JsonArray(currentSetting.toSettings()))));
        }
        if (type == InformationType.plug) {
            return this.plugSettingsVerticle.getSettingAsync(positionPath)
                    .map(currentSetting -> Optional.of(new JsonObject().put("settings", new JsonArray(currentSetting.toSettings()))));
        }
        return Future.succeededFuture(Optional.of(new JsonObject().put("settings", new JsonArray())));
    }

    @Override
    public CommandTopic topic() {
        return Commands.GET_SETTINGS_ALL;
    }

    @Override
    public void init() {

    }
}
