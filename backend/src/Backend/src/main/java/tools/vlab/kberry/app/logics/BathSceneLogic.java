package tools.vlab.kberry.app.logics;

import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.SceneStatus;
import tools.vlab.kberry.core.devices.actor.Light;
import tools.vlab.kberry.server.logic.Logic;

public class BathSceneLogic extends Logic implements SceneStatus {

    private final static int COMFORT = 1;
    private final static int NORMAL = 2;

    private final ExtendLightLogic logic;

    private BathSceneLogic(ExtendLightLogic logic, PositionPath path) {
        super(path);
        this.logic = logic;
    }

    public static BathSceneLogic at(ExtendLightLogic logic, PositionPath positionPath) {
        return new BathSceneLogic(logic, positionPath);
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
            this.getKnxDevices().getKNXDevice(Light.class, Haus.BathTop).ifPresent(Light::off);
            this.getKnxDevices().getKNXDevice(Light.class, Haus.BathWall).ifPresent(Light::on);
        } else if(sceneNumber == NORMAL) {
            logic.enable(positionPath);
            this.getKnxDevices().getKNXDevice(Light.class, Haus.BathTop).ifPresent(Light::on);
            this.getKnxDevices().getKNXDevice(Light.class, Haus.BathWall).ifPresent(Light::off);
        }
    }
}
