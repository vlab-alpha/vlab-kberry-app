package tools.vlab.kberry.app.dashboard;

import io.netty.handler.codec.mqtt.MqttQoS;
import io.vertx.core.AbstractVerticle;
import io.vertx.core.Future;
import io.vertx.core.Promise;
import io.vertx.core.buffer.Buffer;
import io.vertx.mqtt.MqttClient;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.knx.devices.KNXDevice;
import tools.vlab.kberry.core.knx.devices.KNXDevices;
import tools.vlab.kberry.core.knx.devices.actor.*;
import tools.vlab.kberry.core.knx.devices.sensor.*;
import tools.vlab.kberry.core.mqtt.custom.devices.CustomMqttDevice;
import tools.vlab.kberry.core.mqtt.custom.devices.CustomMqttDevices;
import tools.vlab.kberry.core.mqtt.custom.devices.actor.Fan;
import tools.vlab.kberry.core.mqtt.shelly.devices.ShellyDevice;
import tools.vlab.kberry.core.mqtt.shelly.devices.ShellyDevices;
import tools.vlab.kberry.server.commands.Scene;
import tools.vlab.kberry.server.log.Logger;
import tools.vlab.kberry.server.serviceProvider.ServiceProviders;
import tools.vlab.kberry.server.statistics.Statistics;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Slf4j
public class DashboardUpdate extends AbstractVerticle {

    Map<String, String> lastPayloads = new ConcurrentHashMap<>();
    private final KNXDevices knxDevices;
    private final CustomMqttDevices mqttDevices;
    private final ShellyDevices shellyDevices;
    @Getter
    private final Statistics statistics;
    private final String mqttAddress;
    private final int port;
    private final String password;
    private final Set<PositionPath> passwordRequired;
    private final List<Scene> scenes;
    private final ServiceProviders serviceProviders;
    private long timerId;
    private long calendarTimerId;
    private long weatherTimerId;
    private MqttClient client;

    public DashboardUpdate(KNXDevices knxDevices, CustomMqttDevices mqttDevices, ShellyDevices shellyDevices, Statistics statistics, String mqttAddress, int port, String password, Set<PositionPath> passwordRequired, List<Scene> scenes, ServiceProviders serviceProviders) {
        this.knxDevices = knxDevices;
        this.mqttDevices = mqttDevices;
        this.shellyDevices = shellyDevices;
        this.statistics = statistics;
        this.mqttAddress = mqttAddress;
        this.port = port;
        this.password = password;
        this.passwordRequired = passwordRequired;
        this.scenes = scenes;
        this.serviceProviders = serviceProviders;
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
                    scheduleNextBatch();
                    calendarTimerId = vertx.setPeriodic(60000, l -> publishCalendar());
                    weatherTimerId = vertx.setPeriodic(60000, l -> publishWeather());
                    return Future.succeededFuture();
                }).onComplete(res -> startPromise.complete())
                .onFailure(startPromise::fail);
        client.closeHandler(v -> {
            Logger.info("MQTT connection closed, reconnecting...");
            reconnect();
        });
    }

    private void scheduleNextBatch() {
        timerId = vertx.setTimer(5000, id -> {
            publishBatch();
            scheduleNextBatch();
        });
    }

    void publishBatch() {
        List<Runnable> tasks = List.of(
                this::publishHumidity,
                this::publishFan,
                this::publishElectricity,
                this::publishJalousie,
                this::publishLight,
                this::publishUsage,
                this::publishVOC,
                this::publishPlugs,
                this::publishLED,
                this::publishHeater,
                this::publishDimmer
        );
        int delay = 0;
        for (Runnable task : tasks) {
            vertx.setTimer(delay, id -> task.run());
            delay += 200;
        }
    }

    private void reconnect() {
        if (client != null) {
            client.disconnect();
        }

        client = MqttClient.create(vertx);
        client.connect(port, mqttAddress)
                .onSuccess(res -> {
                    Logger.info("MQTT reconnected");
                })
                .onFailure(err -> {
                    vertx.setTimer(2000, id -> reconnect());
                });
    }

    private void publish(Information information) {
        Buffer payloadBuffer = information.toPayload();
        String payload = payloadBuffer.toString();
        String topic = "DASHBOARD/" + information.getTopic();
        lastPayloads.compute(topic, (k, last) -> {
            if (last == null || !last.equals(payload)) {
                client.publish(topic, payloadBuffer, MqttQoS.AT_MOST_ONCE, false, true);
                return payload;
            }
            return last;
        });
    }

    private void publishFan() {
        this.mqttDevices.getDevices(Fan.class).forEach(device -> {
            publish(Information.fan(device.getPositionPath(),
                    device.isOn(),
                    device.getSpeed(),
                    getPassword(device)));
        });
    }


    private void publishLight() {
        this.knxDevices.getKNXDevices(Light.class).forEach(device -> {
            var lux = this.knxDevices.getKNXDeviceByRoom(LuxSensor.class, device.getPositionPath());
            publish(Information.light(device.getPositionPath(),
                    device.isOn(),
                    lux.map(LuxSensor::getSmoothedLux).orElse(0.0f),
                    getPassword(device)));
        });
        this.shellyDevices.getDevices(tools.vlab.kberry.core.mqtt.shelly.devices.device.Led.class).forEach(device -> {
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
        this.shellyDevices.getDevices(tools.vlab.kberry.core.mqtt.shelly.devices.device.Plug.class).forEach(plug -> publish(Information.plug(
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
        this.knxDevices.getKNXDevices(Led.class).forEach(led -> publish(Information.led(
                led.getPositionPath(),
                led.getRGB(),
                getPassword(led))));
        this.shellyDevices.getDevices(tools.vlab.kberry.core.mqtt.shelly.devices.device.Led.class).forEach(led -> publish(Information.led(
                led.getPositionPath(),
                led.getColor().toRGB(),
                getPassword(led))));
    }

    private void publishDimmer() {
        this.knxDevices.getKNXDevices(Dimmer.class).forEach(dimmer -> publish(Information.dimmer(
                dimmer.getPositionPath(),
                dimmer.getBrightnessPercent(),
                getPassword(dimmer))));
    }

    private void publishWeather() {
        this.serviceProviders.temperaturServiceProvider().getTemperatureToday("morning")
                .ifPresent(temp -> publish(Information.weather("Morgen", temp)));
        this.serviceProviders.temperaturServiceProvider().getTemperatureToday("afternoon")
                .ifPresent(temp -> publish(Information.weather("Nachmittag", temp)));
        this.serviceProviders.temperaturServiceProvider().getTemperatureToday("evening")
                .ifPresent(temp -> publish(Information.weather("Abend", temp)));
    }

    private void publishCalendar() {
        this.serviceProviders.calendarServiceProvider().get("garbage").getToday()
                .onSuccess(entries -> {
                    var text = entries.stream().map(entry -> String.format("(%s-%s) %s",
                            entry.eventTime().start().format(DateTimeFormatter.ISO_TIME),
                            entry.eventTime().end().format(DateTimeFormatter.ISO_TIME),
                            entry.title()
                    )).collect(Collectors.joining("\n"));
                    publish(Information.calendar("Heute", text));
                })
                .onFailure(throwable -> Logger.error(throwable, "Calendar fetch failed"));
        this.serviceProviders.calendarServiceProvider().get("garbage").getTomorrow()
                .onSuccess(entries -> {
                    var text = entries.stream().map(entry -> String.format("(%s-%s) %s",
                            entry.eventTime().start().format(DateTimeFormatter.ISO_TIME),
                            entry.eventTime().end().format(DateTimeFormatter.ISO_TIME),
                            entry.title()
                    )).collect(Collectors.joining("\n"));
                    publish(Information.calendar("Morgen", text));
                })
                .onFailure(throwable -> Logger.error(throwable, "Calendar fetch failed"));
    }

    private void publishAllScene() {
        this.scenes.forEach(scene -> publish(Information.scene(scene.getPositionPath(), scene.getName(), scene.getIcon(), getPassword(scene))));
    }

    private String getPassword(KNXDevice device) {
        return passwordRequired.contains(device.getPositionPath()) ? password : null;
    }

    private String getPassword(CustomMqttDevice device) {
        return passwordRequired.contains(device.getPositionPath()) ? password : null;
    }

    private String getPassword(ShellyDevice device) {
        return passwordRequired.contains(device.getPositionPath()) ? password : null;
    }

    private String getPassword(Scene scene) {
        return passwordRequired.contains(scene.getPositionPath()) ? password : null;
    }



    public void stop() {
        if (timerId != 0) vertx.cancelTimer(timerId);
        if (calendarTimerId != 0) vertx.cancelTimer(calendarTimerId);
        if (weatherTimerId != 0) vertx.cancelTimer(weatherTimerId);

        if (client != null) {
            client.disconnect();
        }
    }

}
