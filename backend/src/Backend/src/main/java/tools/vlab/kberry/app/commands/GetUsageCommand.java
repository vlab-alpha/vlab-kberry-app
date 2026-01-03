package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.devices.sensor.PresenceSensor;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class GetUsageCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        var positionPath = Haus.positionPath(message.getString("positionPath"));
        var dayUsage = getStatistics().getPresent().getUsageLastDay(positionPath.getPath());
        var monthUsage = getStatistics().getPresent().getUsageLastMonth(positionPath.getPath());
        var current = getKnxDevices().getKNXDevice(PresenceSensor.class, positionPath);
        var isUsed = current
                .map(PresenceSensor::isPresent)
                .map(result -> result ? "Ja" : "Nein")
                .orElse("Unknown");
        long lastUsedMinutes = current
                .map(PresenceSensor::getLastPresentSecond)
                .map(seconds -> seconds / 60)
                .orElse((long)0);
        return Future.succeededFuture(Optional.of(new JsonObject()
                .put("usedLastMinutes", (int)lastUsedMinutes)
                .put("daily", (int)dayUsage)
                .put("monthly", (int)monthUsage)
                .put("used", isUsed)
        ));
    }

    @Override
    public CommandTopic topic() {
        return Commands.GET_USAGE;
    }

    @Override
    public void init() {

    }

}
