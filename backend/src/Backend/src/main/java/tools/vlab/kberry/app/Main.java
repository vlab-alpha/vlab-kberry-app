package tools.vlab.kberry.app;

import io.vertx.core.Vertx;
import org.eclipse.paho.client.mqttv3.MqttException;
import tools.vlab.kberry.app.commands.*;
import tools.vlab.kberry.app.dashboard.DashboardUpdate;
import tools.vlab.kberry.app.logics.AllLightOffAtNightSchedule;
import tools.vlab.kberry.app.logics.BathSceneLogic;
import tools.vlab.kberry.app.logics.LivingRoomSceneLogic;
import tools.vlab.kberry.app.logics.MailService;
import tools.vlab.kberry.app.settings.*;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.knx.baos.TimeoutException;
import tools.vlab.kberry.core.knx.devices.PushButton;
import tools.vlab.kberry.core.knx.devices.Scene;
import tools.vlab.kberry.core.knx.devices.actor.*;
import tools.vlab.kberry.core.knx.devices.actor.Dimmer;
import tools.vlab.kberry.core.knx.devices.actor.FloorHeater;
import tools.vlab.kberry.core.knx.devices.actor.Jalousie;
import tools.vlab.kberry.core.knx.devices.actor.Light;
import tools.vlab.kberry.core.knx.devices.actor.Plug;
import tools.vlab.kberry.core.knx.devices.sensor.*;
import tools.vlab.kberry.core.mqtt.custom.devices.actor.Fan;
import tools.vlab.kberry.server.KBerryServer;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;


// FIXME: Es fehlt Urlaub Logic, zufällig, Jalousie und Lichter an, aber realistisch!! Sowie alarm bei bewegung!
public class Main {

    public static void main(String[] args) throws IOException, TimeoutException, MqttException {
        System.out.println("SLF4J Logger: " + org.slf4j.LoggerFactory.getILoggerFactory().getClass().getName());
        Vertx vertx = Vertx.vertx();
        var settings = ConfigLoader.loadSettings(vertx);

        // Mail
        var alarmLogic = new LogicIdStore();
        var mailService = new MailService(settings.getToMail(), settings.getMailHost(), settings.getMailPort(), settings.getMailUserName(), settings.getMailPassword().toCharArray());
        vertx.deployVerticle(mailService);

        // Settings
        var plugSettings = new PlugSettingsVerticle("storage");
        vertx.deployVerticle(plugSettings);
        var jalousieSettings = new JalousieSettingsVerticle("storage");
        vertx.deployVerticle(jalousieSettings);
        var lightSettings = new LightSettingsVerticle("storage");
        vertx.deployVerticle(lightSettings);
        var dimmerSettings = new DimmerSettingsVerticle("storage");
        vertx.deployVerticle(dimmerSettings);
        var floorHeaterSettings = new FloorHeaterSettingsVerticle("storage");
        vertx.deployVerticle(floorHeaterSettings);
        var fanSettings = new FanSettingsVerticle("storage");
        vertx.deployVerticle(fanSettings);

        HashSet<PositionPath> passwordRequired = new HashSet<>(Set.of(
                Haus.LivingRoomTV,
                Haus.KidsRoomYellowPC,
                Haus.KidsRoomYellowWindow
        ));

        int intervalUpdateMs = 10000;

        // Extend Light Function
        var lightSettingsCommand = new SetLightSettingsCommand(lightSettings);

        var server = KBerryServer.Builder.create("/dev/ttyAMA0", settings.getMqttHost(), settings.getMqttPort())
                // Push Taster
                .register(PushButton.at(Haus.KidsRoomYellowWall))
                .register(PushButton.at(Haus.KidsRoomBlueWall))
                // Light
                .register(Light.at(Haus.BathTop))
                .register(Light.at(Haus.BathWall))
                .register(Light.at(Haus.KidsRoomBlueTop))
                .register(Light.at(Haus.KidsRoomYellowTop))
                .register(Light.at(Haus.OfficeTop))
                .register(Light.at(Haus.SleepingRoomTop))
                .register(Light.at(Haus.UpperHallwayTop))
                .register(Light.at(Haus.HallwayTop))
                .register(Light.at(Haus.GuestWC_Top))
                .register(Light.at(Haus.ChangingRoomTop))
                .register(Light.at(Haus.DiningRoomTop))
                .register(Light.at(Haus.LivingRoomTop))
                .register(Light.at(Haus.KitchenTop))
                .register(Light.at(Haus.StairsLight))
                .register(Light.at(Haus.FloorUndergroundTop))
                .register(Light.at(Haus.MusicRoomTop))
                .register(Light.at(Haus.WashingRoomTop))
                // Dimmer
                .register(Dimmer.at(Haus.KitchenTop))
                .register(Dimmer.at(Haus.LivingRoomTop))
                // LED
                .register(Led.at(Haus.LivingRoomTop))
                .register(Led.at(Haus.MusicRoomLed))
                //Plug
                .register(Plug.at(Haus.LivingRoomTV))
                .register(Plug.at(Haus.LivingRoomPlugin))
                .register(Plug.at(Haus.KidsRoomYellowWall))
                // Presence
                .register(PresenceSensor.at(Haus.KidsRoomYellowTop))
                .register(PresenceSensor.at(Haus.KidsRoomBlueTop))
                .register(PresenceSensor.at(Haus.OfficeTop))
                .register(PresenceSensor.at(Haus.BathTop))
                .register(PresenceSensor.at(Haus.SleepingRoomTop))
                .register(PresenceSensor.at(Haus.UpperHallwayTop))
                .register(PresenceSensor.at(Haus.LivingRoomTop))
                .register(PresenceSensor.at(Haus.DiningRoomTop))
                .register(PresenceSensor.at(Haus.KitchenTop))
                .register(PresenceSensor.at(Haus.HallwayTop))
                .register(PresenceSensor.at(Haus.GuestWC_Wall))

                .register(PresenceSensor.at(Haus.FloorUndergroundStair))
                .register(PresenceSensor.at(Haus.FloorUndergroundTop))
                .register(PresenceSensor.at(Haus.MusicRoomTop))
                .register(PresenceSensor.at(Haus.WashingRoomTop))

                // VOC
                .register(VOCSensor.at(Haus.KitchenTop, intervalUpdateMs))
                .register(VOCSensor.at(Haus.BathTop, intervalUpdateMs))
                // Humidity
                .register(HumiditySensor.at(Haus.OfficeTop, intervalUpdateMs))
                .register(HumiditySensor.at(Haus.SleepingRoomTop, intervalUpdateMs))
                .register(HumiditySensor.at(Haus.DiningRoomTop, intervalUpdateMs))
                .register(HumiditySensor.at(Haus.BathTop, intervalUpdateMs))
                .register(HumiditySensor.at(Haus.KitchenTop, intervalUpdateMs))
                .register(HumiditySensor.at(Haus.WashingRoomTop))
                .register(HumiditySensor.at(Haus.MusicRoomTop))
                // Lux
                .register(LuxSensor.at(Haus.KitchenTop, intervalUpdateMs))
                .register(LuxSensor.at(Haus.BathTop, intervalUpdateMs))
                .register(LuxSensor.at(Haus.SleepingRoomTop, intervalUpdateMs))
                .register(LuxSensor.at(Haus.GuestWC_Wall, intervalUpdateMs))
                .register(LuxSensor.at(Haus.DiningRoomTop, intervalUpdateMs))
                .register(LuxSensor.at(Haus.KidsRoomBlueTop, intervalUpdateMs))
                .register(LuxSensor.at(Haus.OfficeTop, intervalUpdateMs))
                .register(LuxSensor.at(Haus.KidsRoomBlueTop, intervalUpdateMs))
                .register(LuxSensor.at(Haus.SleepingRoomTop, intervalUpdateMs))
                .register(LuxSensor.at(Haus.KitchenTop, intervalUpdateMs))
                .register(LuxSensor.at(Haus.DiningRoomTop, intervalUpdateMs))
                // Electricity
                .register(ElectricitySensor.at(Haus.KidsRoomYellowPC, intervalUpdateMs))
                .register(ElectricitySensor.at(Haus.KidsRoomYellowTop, intervalUpdateMs))
                .register(ElectricitySensor.at(Haus.OfficeTop, intervalUpdateMs))
                .register(ElectricitySensor.at(Haus.HallwayTop, intervalUpdateMs))
                .register(ElectricitySensor.at(Haus.KidsRoomBlueTop, intervalUpdateMs))
                .register(ElectricitySensor.at(Haus.LivingRoomTV, intervalUpdateMs))
                .register(ElectricitySensor.at(Haus.LivingRoomPlugin, intervalUpdateMs))
                // Temperature
                .register(TemperatureSensor.at(Haus.OfficeTop, intervalUpdateMs))
                .register(TemperatureSensor.at(Haus.KidsRoomYellowTop, intervalUpdateMs))
                .register(TemperatureSensor.at(Haus.KidsRoomBlueTop, intervalUpdateMs))
                .register(TemperatureSensor.at(Haus.SleepingRoomTop, intervalUpdateMs))
                .register(TemperatureSensor.at(Haus.UpperHallwayWall, intervalUpdateMs))
                .register(TemperatureSensor.at(Haus.BathTop, intervalUpdateMs))
                .register(TemperatureSensor.at(Haus.LivingRoomTop, intervalUpdateMs))
                .register(TemperatureSensor.at(Haus.DiningRoomTop, intervalUpdateMs))
                .register(TemperatureSensor.at(Haus.HallwayWall, intervalUpdateMs))
                .register(TemperatureSensor.at(Haus.KitchenTop, intervalUpdateMs))
                .register(TemperatureSensor.at(Haus.ChangingRoomFloor, intervalUpdateMs))
                .register(TemperatureSensor.at(Haus.FloorUndergroundTop, intervalUpdateMs))
                .register(TemperatureSensor.at(Haus.MusicRoomTop, intervalUpdateMs))
                .register(TemperatureSensor.at(Haus.WashingRoomTop, intervalUpdateMs))
                // FloorHeater
                .register(FloorHeater.at(Haus.OfficeFloor))
                .register(FloorHeater.at(Haus.KidsRoomBlueFloor))
                .register(FloorHeater.at(Haus.KidsRoomYellowFloor))
                .register(FloorHeater.at(Haus.SleepingRoomFloor))
                .register(FloorHeater.at(Haus.UpperHallwayFloor))
                .register(FloorHeater.at(Haus.BathFloor))
                .register(FloorHeater.at(Haus.LivingRoomFloor))
                .register(FloorHeater.at(Haus.KitchenFloor))
                .register(FloorHeater.at(Haus.HallwayFloor))
                .register(FloorHeater.at(Haus.ChangingRoomFloor))
                .register(FloorHeater.at(Haus.DiningRoomFloor))

                // Scene
                .register(Scene.at(Haus.BathWall))
                .logic(BathSceneLogic.at(lightSettingsCommand.getLogic(), Haus.BathWall))
                .register(Scene.at(Haus.LivingRoomWall))
                .logic(LivingRoomSceneLogic.at(lightSettingsCommand.getLogic(), Haus.LivingRoomWall))

                // Jalousie
                .register(Jalousie.at(Haus.OfficeWall))
                .register(Jalousie.at(Haus.SleepingRoomWall))
                .register(Jalousie.at(Haus.KidsRoomBlueWall))
                .register(Jalousie.at(Haus.KidsRoomYellowWindow))
                .register(Jalousie.at(Haus.KitchenWall))
                .register(Jalousie.at(Haus.LivingRoomWall))
                .register(Jalousie.at(Haus.DiningRoomWall))

                // FAN
                .register(Fan.at(Haus.KitchenWall)) // fan-sleeping-room
                .register(Fan.at(Haus.SleepingRoomWall)) // fan-kitchen-room

                // Shelly
                .register(tools.vlab.kberry.core.mqtt.shelly.devices.device.Plug.at(Haus.SleepingRoomWall))
                .register(tools.vlab.kberry.core.mqtt.shelly.devices.device.Plug.at(Haus.KidsRoomYellowPC))
                .register(tools.vlab.kberry.core.mqtt.shelly.devices.device.ElectricitySensor.at(Haus.KidsRoomYellowPC))
                .register(tools.vlab.kberry.core.mqtt.shelly.devices.device.Plug.at(Haus.OfficePrinter))

                .register(tools.vlab.kberry.core.mqtt.shelly.devices.device.Led.at(Haus.SleepingRoomTop))
                .register(tools.vlab.kberry.core.mqtt.shelly.devices.device.Led.at(Haus.BathTop))

                .scheduler(new AllLightOffAtNightSchedule(Haus.BathFloor))
                // Service Provider
//                .setICloudCalender(settings.getICloudUsername(), settings.getICloudPassword(), settings.getCalendarUrl())
                // Commands
                .command(new SetPlugSettingsCommand(plugSettings))
                .command(new SetPlugCommand())
                .command(new SetJalousieSettingsCommand(jalousieSettings))
                .command(new SetJalousieReferenceCommand())
                .command(new SetLightCommand())
                .command(lightSettingsCommand)
                .command(new SetTemperaturCommand())
                .command(new SetDimmerCommand())
                .command(new SetDimmerSettingsCommand(dimmerSettings))
                .command(new SetJalousieCommand())
                .command(new SetLEDCommand())
                .command(new SetJalousieStoppCommand())
                .command(new GetDimmerCommand(dimmerSettings))
                .command(new GetUsageCommand())
                .command(new GetTemperaturStatistics())
                .command(new GetTemperatureCommand())
                .command(new GetSettingsCommand(dimmerSettings, jalousieSettings, lightSettings, plugSettings, floorHeaterSettings, fanSettings))
                .command(new GetPositionPaths())
                .command(new GetPlugCommand())
                .command(new GetLightCommand())
                .command(new GetLEDCommand())
                .command(new GetLogCommand())
                .command(new GetJalousieCommand())
                .command(new SetTemperatureModeCommand())
                .command(new AlarmActivate(mailService))
                .command(new AlarmDeactivate())
                .command(new AllJalousieUp())
                .command(new AllJalousieDown())
                .command(new AllLightOff())
                .command(new HolidayStart())
                .command(new HolidayEnd())
                .command(new StartMovie())
                .command(new SetJalousieLock())
                .command(new GetHumidityStatisticsCommand())
                .command(new GetPresenceStatisticsCommand())
                .command(new SetFanStatusCommand())
                .command(new SetFloorHeaterSettingsCommand(floorHeaterSettings))
                .command(new SetFanSettingsCommand(fanSettings))
                .command(new SetFanBreakCommand())
                .command(new GetFanStatusCommand())
                .addCalendar("smarthome", settings.getSmarthomeCalendarUrl())
                .addCalendar("garbage", settings.getGarbageCalendarUrl())
                .build("noreply@vlab.tools", settings.getMailPassword(), settings.getToMail());

        vertx.deployVerticle(new DashboardUpdate(server.getKnxDevices(), server.getMqttDevices(), server.getShellyDevices(), server.getStatistics(), settings.getMqttHost(), settings.getMqttPort(), settings.getPassword(), passwordRequired, server.getScenes(), server.getServiceProviders()));
        try {
            System.out.println("Server Started...");
            server.startListening();
        } catch (Exception e) {
            System.err.println("Server Stopped...");
            server.shutdown();
        }
    }
}
