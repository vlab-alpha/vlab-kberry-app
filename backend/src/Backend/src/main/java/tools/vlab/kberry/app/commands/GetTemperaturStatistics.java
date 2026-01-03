package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Map;
import java.util.Optional;

public class GetTemperaturStatistics extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));
        Map<Long, Double> t = this.getStatistics().getTemperatur().getValuesLastDay(positionPath);
        var result = new JsonArray();
        t.forEach((time, temperature) -> result.add(new JsonObject()
                .put("time", time)
                .put("temp", temperature)
        ));
        return Future.succeededFuture(Optional.of(new JsonObject()
                .put("statistics", result)
        ));
    }

    @Override
    public CommandTopic topic() {
        return Commands.GET_TEMPERATURE_STATISTICS;
    }

    @Override
    public void init() {

    }
}
