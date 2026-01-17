package tools.vlab.kberry.app.dashboard;

import io.netty.handler.codec.mqtt.MqttQoS;
import io.vertx.core.AbstractVerticle;
import io.vertx.core.Future;
import io.vertx.core.Promise;
import io.vertx.mqtt.MqttClient;
import lombok.Getter;
import tools.vlab.kberry.app.Haus;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.KNXDevice;
import tools.vlab.kberry.core.devices.KNXDevices;
import tools.vlab.kberry.core.devices.actor.*;
import tools.vlab.kberry.core.devices.sensor.*;
import tools.vlab.kberry.server.commands.Scene;
import tools.vlab.kberry.server.statistics.Statistics;

import java.util.List;
import java.util.Set;

public class DashboardUpdate extends AbstractVerticle {

    private final KNXDevices knxDevices;
    @Getter
    private final Statistics statistics;
    private final String mqttAddress;
    private final int port;
    private final String password;
    private final Set<PositionPath> passwordRequired;
    private final List<Scene> scenes;
    private long timerId;
    private MqttClient client;

    public DashboardUpdate(KNXDevices knxDevices, Statistics statistics, String mqttAddress, int port, String password, Set<PositionPath> passwordRequired, List<Scene> scenes) {
        this.knxDevices = knxDevices;
        this.statistics = statistics;
        this.mqttAddress = mqttAddress;
        this.port = port;
        this.password = password;
        this.passwordRequired = passwordRequired;
        this.scenes = scenes;
    }

    @Override
    public void start(Promise<Void> startPromise) {
        client = MqttClient.create(vertx);
        client.connect(port, mqttAddress)
                .compose(none -> {
                    publishAllScene();
                    return Future.succeededFuture();
                })
                .compose(none -> {
                    timerId = vertx.setPeriodic(5000, l -> {
                        this.publishHumidity();
                        this.publishElectricity();
                        this.publishJalousie();
                        this.publishLight();
                        this.publishUsage();
                        this.publishVOC();
                        this.publishPlugs();
                        this.publishLED();
                        this.publishHeater();
                        this.publishDimmer();
                    });
                    return Future.succeededFuture();
                }).onComplete(res -> startPromise.complete())
                .onFailure(startPromise::fail);
    }

    private void publish(Information information) {
        this.client.publish("DASHBOARD/" + information.getTopic(), information.toPayload(), MqttQoS.AT_MOST_ONCE, false, true);
    }

    private void publishLight() {
        this.knxDevices.getKNXDevices(Light.class).forEach(device -> {
            var lux = this.knxDevices.getKNXDeviceByRoom(LuxSensor.class, device.getPositionPath());
            publish(Information.light(device.getPositionPath(),
                    device.isOn(),
                    lux.map(LuxSensor::getSmoothedLux).orElse(0.0f),
                    getPassword(device)));
        });
    }

    private void publishHeater() {
        this.knxDevices.getKNXDevices(FloorHeater.class).forEach(floorHeater -> {
            var temperatur = knxDevices.getKNXDeviceByRoom(TemperatureSensor.class, floorHeater.getPositionPath());
            publish(Information.floorHeater(floorHeater.getPositionPath(),
                    floorHeater.getActuatorPositionPercent(),
                    temperatur.map(TemperatureSensor::getCurrentTemp).orElse(0f),
                    floorHeater.getCurrentMode(),
                    getPassword(floorHeater)));
        });
    }

    private void publishPlugs() {
        this.knxDevices.getKNXDevices(Plug.class).forEach(plug -> publish(Information.plug(
                plug.getPositionPath(),
                plug.isOn(),
                getPassword(plug))));
    }

    private void publishUsage() {
        this.knxDevices.getKNXDevices(PresenceSensor.class).forEach(sensor -> publish(Information.presence(
                sensor.getPositionPath(),
                sensor.getLastPresentSecond(),
                sensor.isPresent(),
                getPassword(sensor))));
    }

    private void publishVOC() {
        this.knxDevices.getKNXDevices(VOCSensor.class).forEach(sensor -> publish(Information.voc(
                sensor.getPositionPath(),
                sensor.getCurrentPPM(),
                getPassword(sensor))));
    }

    private void publishHumidity() {
        this.knxDevices.getKNXDevices(HumiditySensor.class).forEach(sensor -> publish(Information.humidity(
                sensor.getPositionPath(),
                sensor.getCurrentHumidity(),
                getPassword(sensor))));
    }

    private void publishElectricity() {
        this.knxDevices.getKNXDevices(ElectricitySensor.class).forEach(sensor -> publish(Information.electricity(
                sensor.getPositionPath(),
                sensor.getCurrentKWH(),
                getPassword(sensor))));
    }

    private void publishJalousie() {
        this.knxDevices.getKNXDevices(Jalousie.class).forEach(jalousie -> publish(Information.jalousie(
                jalousie.getPositionPath(),
                jalousie.getCurrentPositionPercent(),
                getPassword(jalousie))));
    }

    private void publishLED() {
        this.knxDevices.getKNXDevices(Led.class).forEach(jalousie -> publish(Information.led(
                jalousie.getPositionPath(),
                jalousie.getRGB(),
                getPassword(jalousie))));
    }

    private void publishDimmer() {
        this.knxDevices.getKNXDevices(Dimmer.class).forEach(dimmer -> publish(Information.dimmer(
                dimmer.getPositionPath(),
                dimmer.getBrightnessPercent(),
                getPassword(dimmer))));
    }

    private void publishAllScene() {
        this.scenes.forEach(scene -> publish(Information.scene(scene.getPositionPath(), scene.getName(), scene.getIcon(), getPassword(scene))));
    }


    private String getPassword(KNXDevice device) {
        return passwordRequired.contains(device.getPositionPath()) ? password : null;
    }

    private String getPassword(Scene scene) {
        return passwordRequired.contains(scene.getPositionPath()) ? password : null;
    }


    public void stop() {
        vertx.cancelTimer(timerId);
    }

}
