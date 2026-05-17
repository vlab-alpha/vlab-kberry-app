package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.statistics.values.BooleanValue;

import java.util.Optional;

public class GetPresenceStatisticsCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));
        return this.getStatistics().getPresent().getToday(BooleanValue.class, positionPath).compose(stat -> {
            var result = new JsonArray();
            stat.forEach(value -> result.add(value.toJson()));
            return Future.succeededFuture(Optional.of(new JsonObject()
                    .put("statistics", result)
            ));
        });
    }

    @Override
    public CommandTopic topic() {
        return Commands.GET_PRESENCE_STATISTICS;
    }

    @Override
    public void init() {

    }
}
