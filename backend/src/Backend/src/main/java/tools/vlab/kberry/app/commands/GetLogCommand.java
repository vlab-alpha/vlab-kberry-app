package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.log.Logger;

import java.util.Optional;

public class GetLogCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));
        var logs = Logger.getLastLogs(positionPath).stream()
                .map(entry -> new JsonObject()
                        .put("timestamp", entry.timestamp().toString())
                        .put("message", entry.message()))
                .toList();
        return Future.succeededFuture(Optional.of(new JsonObject()
                .put("logs", new JsonArray(logs))
        ));
    }

    @Override
    public CommandTopic topic() {
        return Commands.GET_LOG;
    }

    @Override
    public void init() {

    }

}
