package tools.vlab.kberry.app.logics;

import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.knx.devices.sensor.HumiditySensor;
import tools.vlab.kberry.core.knx.devices.sensor.HumidityStatus;
import tools.vlab.kberry.core.knx.devices.sensor.VOCSensor;
import tools.vlab.kberry.core.knx.devices.sensor.VOCStatus;
import tools.vlab.kberry.core.mqtt.custom.devices.actor.Fan;
import tools.vlab.kberry.server.logic.Logic;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class FanLogic extends Logic implements HumidityStatus, VOCStatus {

    public final static String LOGIC_NAME = "FAN";

    private static final float HUMIDITY_HYSTERESIS = 5f;
    private static final float VOC_HYSTERESIS = 100f;

    private final float humidity;
    private final float voc;
    private final int minTimeRunning;

    private final Map<String, Integer> currentIntensity = new ConcurrentHashMap<>();
    private final Map<String, LocalDateTime> lastStartTime = new ConcurrentHashMap<>();

    private FanLogic(PositionPath path, float humidity, float voc, int minTimeRunning) {
        super(LOGIC_NAME, path);
        this.humidity = humidity;
        this.voc = voc;
        this.minTimeRunning = minTimeRunning;
    }

    public static FanLogic at(PositionPath path, float humidity, float voc) {
        return new FanLogic(path, humidity, voc, 30);
    }

    public static FanLogic at(PositionPath path, float humidity, float voc, int minTimeRunning) {
        return new FanLogic(path, humidity, voc, minTimeRunning);
    }

    @Override
    public void stop() {
    }

    @Override
    public void start() {
    }

    @Override
    public void humidityChanged(HumiditySensor sensor, float humidity) {
        var floor = sensor.getPositionPath().getFloor();
        float voc = this.getKnxDevices()
                .getKNXDevicesByFloor(VOCSensor.class, sensor.getPositionPath())
                .stream()
                .max(Comparator.comparing(VOCSensor::getCurrentPPM))
                .map(VOCSensor::getCurrentPPM)
                .orElse(0f);
        updateFan(floor, voc, humidity);
    }

    @Override
    public void vocChanged(VOCSensor sensor, float voc) {
        var floor = sensor.getPositionPath().getFloor();
        float humidity = this.getKnxDevices()
                .getKNXDevicesByFloor(HumiditySensor.class, sensor.getPositionPath())
                .stream()
                .max(Comparator.comparing(HumiditySensor::getCurrentHumidity))
                .map(HumiditySensor::getCurrentHumidity)
                .orElse(0f);
        updateFan(floor, voc, humidity);
    }

    private void updateFan(String floor,
                           float voc,
                           float humidity) {
        int oldIntensity = currentIntensity.getOrDefault(floor, 0);
        int newIntensity = calculateIntensity(
                oldIntensity,
                voc,
                humidity
        );

        // Mindestlaufzeit
        if (oldIntensity > 0 && newIntensity == 0) {
            LocalDateTime started = lastStartTime.get(floor);
            if (started != null) {
                long runningMinutes = ChronoUnit.MINUTES.between(started, LocalDateTime.now());
                if (runningMinutes < minTimeRunning) {
                    return;
                }
            }
        }

        // Nur bei Änderungen
        if (oldIntensity != newIntensity) {
            currentIntensity.put(floor, newIntensity);
            if (oldIntensity == 0 && newIntensity > 0) {
                lastStartTime.put(floor, LocalDateTime.now());
            }
            applyFanSpeed(floor, newIntensity);
        }
    }

    private int calculateIntensity(int currentIntensity,
                                   float voc,
                                   float humidity) {
        int vocScore = calculateVocScore(currentIntensity, voc);
        int humidityScore = calculateHumidityScore(currentIntensity, humidity);
        return Math.max(vocScore, humidityScore);
    }

    private int calculateVocScore(int currentIntensity, float voc) {
        if (voc >= this.voc) {
            return 2;
        }
        if (currentIntensity > 0 && voc >= (this.voc - VOC_HYSTERESIS)) {
            return 1;
        }
        return 0;
    }

    private int calculateHumidityScore(int currentIntensity, float humidity) {
        if (humidity >= this.humidity) {
            return 2;
        }
        if (currentIntensity > 0 && humidity >= (this.humidity - HUMIDITY_HYSTERESIS)) {
            return 1;
        }
        return 0;
    }

    private void applyFanSpeed(String floor,int intensity) {
        this.getMqttDevices()
                .getDeviceByFloor(Fan.class, floor)
                .ifPresent(fan -> {
                    switch (intensity) {
                        case 0 -> fan.setOn(false);
                        case 1 -> fan.setSpeed(1);
                        case 2 -> fan.setSpeed(2);
                        case 3 -> fan.setSpeed(3);
                    }
                });
    }
}