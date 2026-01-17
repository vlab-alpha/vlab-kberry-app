package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.PushButton;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;

import java.util.Optional;

public class SetJalousieLock extends Command {
    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));
        var enable = message.getBoolean("status");
        this.getKnxDevices().getKNXDevice(PushButton.class, positionPath).ifPresent(pushButton -> {
            if (enable) {
                pushButton.enable();
            } else {
                pushButton.disable();
            }
        });
        return Future.succeededFuture(Optional.of(new JsonObject().put("status", enable)));
    }

    @Override
    public CommandTopic topic() {
        return Commands.LOCK_JALOUSIE;
    }

    @Override
    public void init() {

    }
}
