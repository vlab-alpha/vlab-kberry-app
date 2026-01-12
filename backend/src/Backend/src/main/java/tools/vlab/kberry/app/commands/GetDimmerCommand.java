package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.settings.DimmerSettingsVerticle;
import tools.vlab.kberry.core.devices.actor.Dimmer;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class GetDimmerCommand extends Command {

    private final DimmerSettingsVerticle settings;

    public GetDimmerCommand(DimmerSettingsVerticle settings) {
        this.settings = settings;
    }

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        var positionPath = Haus.positionPath(message.getString("positionPath"));
        return this.settings.getSettingAsync(positionPath)
                .compose(setting -> {
                    var device = this.getKnxDevices().getKNXDevice(Dimmer.class, positionPath);
                    if (device.isPresent()) {
                        int percent = device.get().getCurrentBrightness();
                        return Future.succeededFuture(Optional.of(new JsonObject()
                                .put("value", percent)
                                .put("min", setting.getMinDimValue())
                                .put("max", setting.getMaxDimValue())
                        ));
                    }
                    return Future.failedFuture("No Dimmer Found!");
                });
    }

    @Override
    public CommandTopic topic() {
        return Commands.GET_DIMMER_STATUS;
    }

    @Override
    public void init() {

    }
}
