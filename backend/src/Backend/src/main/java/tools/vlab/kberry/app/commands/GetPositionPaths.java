package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class GetPositionPaths extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        var paths = new JsonArray(this.getKnxDevices().getAllPositionPaths().stream().map(PositionPath::toString).toList());
        return Future.succeededFuture(Optional.of(new JsonObject().put("paths", paths)));
    }

    @Override
    public CommandTopic topic() {
        return Commands.GET_POSITION_PATHS;
    }

    @Override
    public void init() {

    }
}
