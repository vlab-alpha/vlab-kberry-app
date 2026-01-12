import 'package:flutter/material.dart';
import 'package:SmartHome/card/jalousie_card.dart';
import 'package:SmartHome/dialog/humidity_dialog.dart';
import 'package:SmartHome/dialog/jalousie_dialog.dart';
import 'package:SmartHome/dialog/plug_dialog.dart';
import 'package:SmartHome/dialog/temperature_dialog.dart';
import 'package:SmartHome/dialog/usage_dialog.dart';
import 'package:SmartHome/dialog/weather_dialog.dart';
import '../model/data.dart';
import 'info_dialog.dart';
import 'energy_dialog.dart';
import 'co2_dialog.dart';
import 'light_dialog.dart';
import 'dimmer_dialog.dart';
import 'led_dialog.dart';
import 'fan_dialog.dart';
import 'pin_dialog.dart';
import 'weather_dialog.dart';
import 'package:async/async.dart';
import 'temperature_dialog.dart';
import 'jalousie_dialog.dart';
import 'plug_dialog.dart';
import 'humidity_dialog.dart';
import 'usage_dialog.dart';

Future<void> showInfoPopup(BuildContext context, Information info) async {
  if (info.password != null && info.password!.isNotEmpty) {
    final ok = await showPinDialog(context, info.password!);
    if (!ok) return; // Abbrechen oder falsche PIN -> Dialog nicht öffnen
  }

  Widget dialog;

  switch (info.type) {
    case InformationType.light:
      dialog = LightDialog(information: info);
      break;
    case InformationType.floorHeater:
      dialog = TemperatureDialog(information: info);
      break;
    case InformationType.jalousie:
      dialog = JalousieDialog(information: info);
      break;
    case InformationType.plug:
      dialog = PlugDialog(information: info);
      break;
    case InformationType.humidity:
      dialog = HumidityDialog(information: info);
      break;
    case InformationType.presence:
      dialog = UsageDialog(information: info);
      break;
    case InformationType.weather:
      dialog = WeatherDialog(information: info);
      break;
    case InformationType.dimmer:
      dialog = LightDimmerDialog(information: info);
      break;
    case InformationType.fan:
      dialog = FanDialog(information: info);
      break;
    case InformationType.voc:
      dialog = Co2Dialog(information: info);
      break;
    case InformationType.energy:
      dialog = EnergyDialog(information: info);
      break;
    case InformationType.led:
      dialog = LedControlDialog(information: info);
      break;
    default:
      dialog = InfoDialog(information: info);
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => dialog,
  );
}