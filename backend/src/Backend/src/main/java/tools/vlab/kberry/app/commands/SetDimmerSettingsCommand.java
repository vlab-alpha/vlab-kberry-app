package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.app.settings.Dimmer;
import tools.vlab.kberry.app.settings.DimmerSettingsVerticle;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.server.commands.Command;
import tools.vlab.kberry.server.commands.CommandTopic;
import tools.vlab.kberry.server.logic.DimmerByLuxLogic;
import tools.vlab.kberry.server.logic.TargetLux;
import tools.vlab.kberry.server.settings.Settings;

import java.util.Map;
import java.util.Optional;

public class SetDimmerSettingsCommand extends Command {

    private final Settings<String> dimmLogic = new LogicIdStore();
    private final DimmerSettingsVerticle settings;
    private final static Map<String, TargetLux> LUX_MAP = Map.of(
            "Wohnzimmer", TargetLux.LIVING_ROOM,
            "Küche", TargetLux.WORKING_PLACE,
            "Büro", TargetLux.OFFICE
    );

    public SetDimmerSettingsCommand(DimmerSettingsVerticle settings) {
        this.settings = settings;
    }

    @Override
    public Future<Optional<JsonObject>> execute(JsonObject message) {
        Haus positionPath = Haus.positionPath(message.getString("positionPath"));
        var dimmer = Dimmer.fromSettings(message.getJsonArray("settings").stream().map(o -> ((JsonObject) o)).toList());
        setDimmLogic(positionPath, dimmer);
        return this.settings
                .setSettingAsync(positionPath, dimmer)
                .map(none -> Optional.empty());
    }

    @Override
    public CommandTopic topic() {
        return Commands.SET_DIMMER_SETTINGS;
    }

    @Override
    public void init() {
        this.getKnxDevices()
                .getKNXDevices(tools.vlab.kberry.core.devices.actor.Dimmer.class)
                .forEach(device -> settings.getSetting(device.getPositionPath())
                        .filter(Dimmer::isDimmerByLux)
                        .ifPresent(setting -> setDimmLogic(device.getPositionPath(), setting)
        ));
    }

    private void setDimmLogic(PositionPath positionPath, Dimmer settings) {
        dimmLogic.getSetting(positionPath).ifPresent(logicId -> this.getLogics().unregister(logicId));
        if (settings.isDimmerByLux()) {
            var target = LUX_MAP.get(positionPath.getRoom());
            var logic = DimmerByLuxLogic.at(target, positionPath);
            dimmLogic.setSettingAsync(positionPath, logic.getId());
            this.getLogics().register(logic);
        }
    }
}
