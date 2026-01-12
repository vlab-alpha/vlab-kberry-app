package tools.vlab.kberry.app.logics;

import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.RGB;
import tools.vlab.kberry.core.devices.SceneStatus;
import tools.vlab.kberry.core.devices.actor.Dimmer;
import tools.vlab.kberry.core.devices.actor.Led;
import tools.vlab.kberry.core.devices.actor.Light;
import tools.vlab.kberry.core.devices.actor.OnOffDevice;
import tools.vlab.kberry.server.logic.Logic;

public class LivingRoomSceneLogic extends Logic implements SceneStatus {

    private final static int COMFORT = 1;
    private final static int NORMAL = 2;

    private final ExtendLightLogic logic;

    protected LivingRoomSceneLogic(PositionPath path, ExtendLightLogic logic) {
        super(path);
        this.logic = logic;
    }

    public static LivingRoomSceneLogic at(ExtendLightLogic logic, PositionPath positionPath) {
        return new LivingRoomSceneLogic(positionPath, logic);
    }

    @Override
    public void stop() {

    }

    @Override
    public void start() {

    }

    @Override
    public void onChangedScene(PositionPath positionPath, int sceneNumber) {
        if (sceneNumber == COMFORT) {
            logic.disable(positionPath);
            getKnxDevices().getKNXDevice(Led.class, Haus.LivingRoomTop).ifPresent(led -> led.setRGB(RGB.fromHex("#20AADB")));
            getKnxDevices().getKNXDevice(Dimmer.class, Haus.LivingRoomTop).ifPresent(dimmer -> dimmer.setBrightness(10));
            getKnxDevices().getKNXDevice(Light.class, Haus.KitchenTop).ifPresent(OnOffDevice::off);
        } else if (sceneNumber == NORMAL) {
            logic.enable(positionPath);
            getKnxDevices().getKNXDevice(Led.class, Haus.LivingRoomTop).ifPresent(Led::off);
            getKnxDevices().getKNXDevice(Dimmer.class, Haus.LivingRoomTop).ifPresent(dimmer -> dimmer.setBrightness(80));
        }
    }
}
