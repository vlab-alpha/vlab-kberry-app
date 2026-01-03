import 'package:flutter/material.dart';
import '../model/data.dart';
import '../card/jalousie_card.dart';
import '../card/switch_card.dart';
import '../card/temperatur_card.dart';
import '../card/weather_card.dart';
import '../card/co2_card.dart';
import '../card/fan_card.dart';
import '../dialog/dialog_manager.dart';
import '../card/energy_card.dart';
import '../card/led_card.dart';
import '../model/data.dart';
import '../widgets/combobox.dart';
import '../card/app_launcher_card.dart';
import '../card/light_dimmer_card.dart';
import '../card/scene_card.dart';
import '../card/reolink_card.dart';
import 'package:SmartHome/card/light_card.dart';
import 'package:SmartHome/card/stream_card.dart';
import 'package:SmartHome/card/usage_card.dart';
import 'package:SmartHome/model/Position.dart';

Widget buildCard(Information item, Future<void> Function(String positionPath, String title) executeScene) {
  switch (item.type) {
    case InformationType.temperature:
      return TemperatureCard(
        room: item.room(),
        title: item.title,
        value: item.value,
      );
    case InformationType.light:
      return LightsCard(
        room: item.room(),
        title: item.title,
        value: item.value == "true",
      );
    case InformationType.jalousie:
      return JalousieCard(
        room: item.room(),
        position: double.parse(item.value),
        title: item.title,
      );
    case InformationType.humidity:
      return HumidityCard(
        information: item,
      );
    case InformationType.usage:
      return UsageCard(
        information: item,
      );
    case InformationType.plug:
      return SwitchCard(information: item);
    case InformationType.weather:
      return WeatherCard(
        condition: item.value,
        temperature: double.parse(item.extraValue!),
        title: item.title,
      );
    case InformationType.dimmer:
      return LightDimmerCard(
        room: item.room(),
        title: item.title,
        brightness: double.parse(item.value),
      );
    case InformationType.fan:
      return FanCard(
        room: item.room(),
        title: item.title,
        isOn: item.value == "true",
      );
    case InformationType.led:
      return LedCard(information: item);
    case InformationType.scene:
      return SceneCard(information: item, executeScene: executeScene);
    case InformationType.camera:
      return ReolinkCard(title: item.title, rtspUrl: item.value);
    case InformationType.launcher:
      return AppLaunchCard(
        title: item.title,
        methodName: item.value,
        icon: item.icon!,
      );
    case InformationType.co2:
      return Co2Card(information: item);
    case InformationType.energy:
      return EnergyCard(information:item);
    default:
      return const SizedBox();
  }
}
