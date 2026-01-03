package tools.vlab.kberry.app;

import io.vertx.core.Vertx;
import tools.vlab.kberry.app.commands.*;
import tools.vlab.kberry.app.dashboard.DashboardUpdate;
import tools.vlab.kberry.app.logics.MailService;
import tools.vlab.kberry.app.settings.DimmerSettingsVerticle;
import tools.vlab.kberry.app.settings.JalousieSettingsVerticle;
import tools.vlab.kberry.app.settings.LightSettingsVerticle;
import tools.vlab.kberry.app.settings.PlugSettingsVerticle;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.core.baos.TimeoutException;
import tools.vlab.kberry.core.devices.PushButton;
import tools.vlab.kberry.core.devices.Scene;
import tools.vlab.kberry.core.devices.actor.*;
import tools.vlab.kberry.core.devices.sensor.*;
import tools.vlab.kberry.server.KBerryServer;
import tools.vlab.kberry.server.logic.AutoLightOnLogic;
import tools.vlab.kberry.server.logic.AutoPresenceOffLogic;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

public class Main {

    public static void main(String[] args) throws IOException, TimeoutException {
        Vertx vertx = Vertx.vertx();
        var settings = ConfigLoader.loadSettings(vertx);

        // Mail
        var alarmLogic = new LogicIdStore();
        var mailService = new MailService(settings.getToMail(), settings.getMailHost(), settings.getMailPort(), settings.getMailUserName(), settings.getMailPassword().toCharArray());

        // Settings
        var plugSettings = new PlugSettingsVerticle("storage");
        vertx.deployVerticle(plugSettings);
        var jalousieSettings = new JalousieSettingsVerticle("storage");
        vertx.deployVerticle(jalousieSettings);
        var lightSettings = new LightSettingsVerticle("storage");
        vertx.deployVerticle(lightSettings);
        var dimmerSettings = new DimmerSettingsVerticle("storage");
        vertx.deployVerticle(dimmerSettings);

        HashSet<PositionPath> passwordRequired = new HashSet<>(Set.of(
                Haus.LivingRoomTV,
                Haus.KidsRoomYellowPC
        ));

        var server = KBerryServer.Builder.create("/dev/ttyAMA0", settings.getMqttHost(), settings.getMqttPort(), 2000, 10)
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
                // Dimmer
                .register(Dimmer.at(Haus.KitchenTop))
                .register(Dimmer.at(Haus.LivingRoomTop))
                // LED
                .register(Led.at(Haus.LivingRoomTop))
                //Plug
                .register(Plug.at(Haus.LivingRoomTV))
                .register(Plug.at(Haus.LivingRoomPlugin))
                .register(Plug.at(Haus.KidsRoomYellowPC))
                // Presence
                .register(PresenceSensor.at(Haus.KidsRoomYellowTop))
                .register(PresenceSensor.at(Haus.KidsRoomBlueTop))
                .register(PresenceSensor.at(Haus.OfficeTop))
                .register(PresenceSensor.at(Haus.SleepingRoomTop))
                .register(PresenceSensor.at(Haus.UpperHallwayTop))
                .register(PresenceSensor.at(Haus.LivingRoomTop))
                .register(PresenceSensor.at(Haus.DiningRoomTop))
                .register(PresenceSensor.at(Haus.KitchenTop))
                .register(PresenceSensor.at(Haus.HallwayTop))
                .register(PresenceSensor.at(Haus.GuestWC_Wall))
                // VOC
                .register(VOCSensor.at(Haus.KitchenTop))
                .register(VOCSensor.at(Haus.BathTop))
                // Humidity
                .register(HumiditySensor.at(Haus.OfficeTop))
                .register(HumiditySensor.at(Haus.SleepingRoomTop))
                .register(HumiditySensor.at(Haus.DiningRoomTop))
                .register(HumiditySensor.at(Haus.BathTop))
                .register(HumiditySensor.at(Haus.KitchenTop))
                // Lux
                .register(LuxSensor.at(Haus.KitchenTop))
                .register(LuxSensor.at(Haus.BathTop))
                .register(LuxSensor.at(Haus.SleepingRoomTop))
                .register(LuxSensor.at(Haus.GuestWC_Wall))
                .register(LuxSensor.at(Haus.DiningRoomTop))
                // Electricity
                .register(ElectricitySensor.at(Haus.KidsRoomYellowPC))
                .register(ElectricitySensor.at(Haus.KidsRoomYellowTop))
                .register(ElectricitySensor.at(Haus.OfficeTop))
                .register(ElectricitySensor.at(Haus.HallwayTop))
                .register(ElectricitySensor.at(Haus.UpperHallwayTop))
                // Temperature
                .register(TemperatureSensor.at(Haus.OfficeTop))
                .register(TemperatureSensor.at(Haus.KidsRoomYellowTop))
                .register(TemperatureSensor.at(Haus.KidsRoomBlueTop))
                .register(TemperatureSensor.at(Haus.SleepingRoomTop))
                .register(TemperatureSensor.at(Haus.UpperHallwayWall))
                .register(TemperatureSensor.at(Haus.BathTop))
                .register(TemperatureSensor.at(Haus.LivingRoomTop))
                .register(TemperatureSensor.at(Haus.DiningRoomTop))
                .register(TemperatureSensor.at(Haus.HallwayWall))
                .register(TemperatureSensor.at(Haus.KitchenTop))
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
                // Default Logic
                .logic(AutoLightOnLogic.at(Haus.BathTop))
                .logic(AutoPresenceOffLogic.at(10 * 60, Haus.BathTop))
                .logic(AutoLightOnLogic.at(Haus.GuestWC_Top))
                .logic(AutoPresenceOffLogic.at(5 * 60, Haus.GuestWC_Top))
                // Service Provider
                .setICloudCalender(settings.getUsername(), settings.getPassword(), settings.getCalendarUrl())
                // Commands
                .command(new SetPlugSettingsCommand(plugSettings))
                .command(new SetPlugCommand())
                .command(new SetJalousieSettingsCommand(jalousieSettings))
                .command(new SetJalousieReferenceCommand())
                .command(new SetLightCommand())
                .command(new SetLightSettingsCommand(lightSettings))
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
                .command(new GetSettingsCommand(dimmerSettings, jalousieSettings, lightSettings, plugSettings))
                .command(new GetPositionPaths())
                .command(new GetPlugCommand())
                .command(new GetLightCommand())
                .command(new GetLEDCommand())
                .command(new GetJalousieCommand())
                .command(new SetTemperatureModeCommand())
                .command(new AlarmActivate(mailService, alarmLogic))
                .command(new AlarmDeactivate(alarmLogic))
                .command(new AllJalousieUp())
                .command(new AllJalousieDown())
                .command(new AllLightOff())
                .command(new HolidayStart())
                .command(new HolidayEnd())
                .command(new StartMovie())
                .build();

        vertx.deployVerticle(new DashboardUpdate(server.getDevices(), settings.getMqttHost(), settings.getMqttPort(), settings.getPassword(), passwordRequired));
        try {
            System.out.println("Server Started...");
            server.startListening();
        } catch (Exception e) {
            System.err.println("Server Stopped...");
            server.shutdown();
        }
    }
}
