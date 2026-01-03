package tools.vlab.kberry.app.dashboard;

import io.netty.handler.codec.mqtt.MqttQoS;
import io.vertx.core.AbstractVerticle;
import io.vertx.core.Future;
import io.vertx.core.Promise;
import io.vertx.mqtt.MqttClient;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.devices.KNXDevice;
import tools.vlab.kberry.core.devices.KNXDevices;
import tools.vlab.kberry.core.devices.Scene;
import tools.vlab.kberry.core.devices.actor.*;
import tools.vlab.kberry.core.devices.sensor.*;

import java.util.Set;

public class DashboardUpdate extends AbstractVerticle {

    private final KNXDevices knxDevices;
    private final String mqttAddress;
    private final int port;
    private final String password;
    private final Set<PositionPath> passwordRequired;
    private long timerId;
    private MqttClient client;

    public DashboardUpdate(KNXDevices knxDevices, String mqttAddress, int port, String password, Set<PositionPath> passwordRequired) {
        this.knxDevices = knxDevices;
        this.mqttAddress = mqttAddress;
        this.port = port;
        this.password = password;
        this.passwordRequired = passwordRequired;
    }

    @Override
    public void start(Promise<Void> startPromise) throws Exception {
        client = MqttClient.create(vertx);
        client.connect(port, mqttAddress)
                .compose(none -> {
                    timerId = vertx.setPeriodic(1000, l -> {
                        publishRoomSpecificData();
                        publishSpecificPositionData();
                    });
                    return Future.succeededFuture();
                }).onComplete(res -> startPromise.complete())
                .onFailure(startPromise::fail);
    }

    private void publish(Information information) {
        this.client.publish(information.getTopic(), information.toPayload(), MqttQoS.AT_MOST_ONCE, false, true);
    }

    private void publishRoomSpecificData() {
        knxDevices.getAllRooms().forEach(room -> {

            // Light
            var light = knxDevices.getKNXDeviceByRoom(Light.class, room);
            var lux = knxDevices.getKNXDeviceByRoom(LuxSensor.class, room);
            if (light.isPresent()) {
                publish(Information.light(room,
                        light.get().isOn(),
                        lux.map(LuxSensor::getCurrentLux).orElse(0.0f),
                        getPassword(light.get())));
            } else lux.ifPresent(sensor -> publish(Information.lux(room,
                    sensor.getCurrentLux(),
                    getPassword(sensor))));

            // FloorHeater
            var temperatur = knxDevices.getKNXDeviceByRoom(TemperatureSensor.class, room);
            var floorHeater = knxDevices.getKNXDeviceByRoom(FloorHeater.class, room);
            if (floorHeater.isPresent() && temperatur.isPresent()) {
                publish(Information.floorHeater(room,
                        floorHeater.get().getCurrentActuatorPosition(),
                        temperatur.get().getCurrentTemp(),
                        getPassword(floorHeater.get())));
            } else {
                temperatur.ifPresent(temperatureSensor -> publish(Information.temperature(room,
                        temperatureSensor.getCurrentTemp(),
                        getPassword(temperatureSensor))));
            }

            // TODO: Humidity and Voc Sensor combine with Fan

        });
    }


    private void publishSpecificPositionData() {
        knxDevices.getAllPositionPaths().forEach(path -> {
            knxDevices.getKNXDevice(Plug.class, path).ifPresent(plug -> publish(Information.plug(
                    plug.getPositionPath(),
                    plug.isOn(),
                    getPassword(plug))));

            knxDevices.getKNXDevice(PresenceSensor.class, path).ifPresent(sensor -> publish(Information.presence(
                    sensor.getPositionPath(),
                    sensor.getLastPresentSecond(),
                    sensor.isPresent(),
                    getPassword(sensor))));

            knxDevices.getKNXDevice(VOCSensor.class, path).ifPresent(sensor -> publish(Information.voc(
                    sensor.getPositionPath(),
                    sensor.getCurrentPPM(),
                    getPassword(sensor))));

            knxDevices.getKNXDevice(Dimmer.class, path).ifPresent(sensor -> publish(Information.dimmer(
                    sensor.getPositionPath(),
                    sensor.getCurrentBrightness(),
                    getPassword(sensor))));

            knxDevices.getKNXDevice(HumiditySensor.class, path).ifPresent(sensor -> publish(Information.humidity(
                    sensor.getPositionPath(),
                    sensor.getCurrentHumidity(),
                    getPassword(sensor))));

            knxDevices.getKNXDevice(ElectricitySensor.class, path).ifPresent(sensor -> publish(Information.electricity(
                    sensor.getPositionPath(),
                    sensor.getCurrentKWH(),
                    getPassword(sensor))));

            knxDevices.getKNXDevice(Jalousie.class, path).ifPresent(sensor -> publish(Information.jalousie(
                    sensor.getPositionPath(),
                    sensor.currentPosition(),
                    getPassword(sensor))));

            knxDevices.getKNXDevice(Led.class, path).ifPresent(sensor -> publish(Information.led(
                    sensor.getPositionPath(),
                    sensor.getRGB(),
                    getPassword(sensor))));

            knxDevices.getKNXDevice(Scene.class, path).ifPresent(sensor -> publish(Information.scene(
                    sensor.getPositionPath(),
                    sensor.getLastExecution(),
                    getPassword(sensor))));
        });
    }

    private String getPassword(KNXDevice device) {
        return passwordRequired.contains(device.getPositionPath()) ? password : null;
    }


    public void stop() {
        vertx.cancelTimer(timerId);
    }

}
