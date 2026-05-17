package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.logics.FanLogic;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.mqtt.custom.devices.actor.Fan;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.scheduler.trigger.Time;

import java.time.LocalTime;
import java.util.Optional;

public class SetFanBreakCommand extends Command {

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        PositionPath positionPath = Haus.positionPath(message.getString("positionPath"));
        int breakTimeMinutes = message.getInteger("breakTime");
        var fan = getMqttDevices().getDevice(Fan.class, positionPath);
        var logic = getLogicEngine().getLogic(positionPath, FanLogic.LOGIC_NAME);
        if (fan.isPresent() && logic.isPresent()) {
            getLogicEngine().unregister(logic.get());
            getSchedule().registerSchedule(positionPath, "break", Time.trigger(LocalTime.now().plusMinutes(breakTimeMinutes)), () -> getLogicEngine().register(logic.get()));
        }

        return Future.succeededFuture(Optional.of(new JsonObject()));
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_FAN_BREAK;
    }

    @Override
    public void init() {

    }
}
