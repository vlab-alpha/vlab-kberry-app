import 'dart:convert';
import '../model/data.dart';
import 'package:logger/logger.dart';
import '../config.dart';

import '../model/Position.dart';
import 'mqtt_client.dart';

final log = Logger();

class SmartHomeService {
  static final SmartHomeService _instance = SmartHomeService._internal(
    broker: brokerIp,
    port: brokerPort,
  );

  factory SmartHomeService.instance() => _instance;

  final String broker;
  final int port;
  Mqtt5Client? _client = null;

  SmartHomeService._internal({required this.broker, required this.port});

  Future<bool> connect() async {
    if (_client == null) {
      print("setzte MQTT Client!");
      _client = Mqtt5Client(brokerIp: this.broker, port: this.port);
      return await _client!.connect();
    }
    return true;
  }

  void getSettings(
    String positionPath,
    InformationType type,
    void Function(List<Setting> settings) onMessage,
  ) {
    _client?.request(
      "get/settings/all",
      jsonEncode({"positionPath": positionPath, "type": type.name}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final settingsJsonArray = body["settings"];
        if (settingsJsonArray is List) {
          final settings = settingsJsonArray
              .map((e) => Setting.fromJson(e))
              .toList();
          onMessage(settings);
        } else {
          onMessage([]);
        }
      },
    );
  }

  void saveSettings(
    String positionPath,
    InformationType type,
    List<Setting> updates,
  ) {
    final updatesJson = updates.map((s) => s.toJson()).toList();
    _client?.publish(
      "request/set/settings/${type.name}",
      jsonEncode({"positionPath": positionPath, "settings": updatesJson}),
    );
  }

  void subscribeToInformation(
    void Function(Information info, String topic) onMessage,
  ) {
    _client?.subscribeAll("DASHBOARD", (jsonString, topic) {
      final body = jsonDecode(jsonString);
      final info = Information(
        positionPath: body["positionPath"] ?? "",
        value: body["value"] ?? "",
        title: body["title"] ?? "",
        type: InformationType.values.firstWhere(
          (e) =>
              e.name.toLowerCase() == (body["type"] as String?)?.toLowerCase(),
          orElse: () => InformationType.alle,
        ),
        password: body["password"],
        extraValue: body["extraValue"] ?? "",
        icon: body["icon"],
      );
      onMessage(info, topic);
    });
  }

  void getPositionPaths(void Function(List<String> positionPaths) onMessage) {
    _client?.request("get/all/positionPaths", "", (bodyString, topic) {
      final body = jsonDecode(bodyString);
      final paths = (body["paths"] as List).cast<String>();
      onMessage(paths);
    });
  }

  void setFanStatus(
    String positionPath,
    bool fanStatus,
    void Function(bool status) onMessage,
  ) {
    _client?.request(
      "set/fan/status",
      jsonEncode({"positionPath": positionPath, "status": fanStatus}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final status = body["status"] as bool? ?? false;
        onMessage(status);
      },
    );
  }

  void setLightStatus(
    String positionPath,
    String title,
    bool lightOn,
    void Function(bool status) onMessage,
  ) {
    _client?.request(
      "set/light/status",
      jsonEncode({
        "positionPath": positionPath,
        "status": lightOn,
        "title": title,
      }),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final status = body["status"] as bool? ?? false;
        onMessage(status);
      },
    );
  }

  void getLightStatus(
    String positionPath,
    String title,
    void Function(bool status) onMessage,
  ) {
    _client?.request(
      "get/light/status",
      jsonEncode({"positionPath": positionPath, "title": title}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final status = body["status"] as bool? ?? false;
        onMessage(status);
      },
    );
  }

  void publishScene(String positionPath, String title) {
    _client?.publish(
      'request/scene/$title',
      jsonEncode({"positionPath": positionPath, "title": title}),
    );
  }

  void setDimmer(
    String positionPath,
    String title,
    double percent,
    void Function(int brightness) onMessage,
  ) {
    _client?.request(
      "set/dimmer/status",
      jsonEncode({
        "positionPath": positionPath,
        "percent": percent,
        "title": title,
      }),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final brightness = body["percent"] as int? ?? 0;
        onMessage(brightness);
      },
    );
  }

  void getDimmer(String positionPath, void Function(Dimmer dimmer) onMessage) {
    _client?.request(
      "get/dimmer/status",
      jsonEncode({"positionPath": positionPath}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final value = body["value"] as int? ?? 0;
        final max = body["max"] as int? ?? 0;
        final min = body["min"] as int? ?? 0;
        onMessage(Dimmer(min: min, max: max, value: value));
      },
    );
  }

  void getJalousie(
    String positionPath,
    void Function(double position) onMessage,
  ) {
    _client?.request(
      "get/jalousie/status",
      jsonEncode({"positionPath": positionPath}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final pos = (body["position"] as num?)?.toDouble() ?? 0.0;
        onMessage(pos);
      },
    );
  }

  void setStoppJalousie(
    String positionPath,
    void Function(double position) onMessage,
  ) {
    _client?.request(
      "set/jalousie/stopp",
      jsonEncode({"positionPath": positionPath}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final pos = (body["position"] as num?)?.toDouble() ?? 0.0;
        onMessage(pos);
      },
    );
  }

  void setReferenceJalousie(
    String positionPath,
    void Function(double position) onMessage,
  ) {
    _client?.request(
      "set/jalousie/reference",
      jsonEncode({"positionPath": positionPath}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final pos = (body["position"] as num?)?.toDouble() ?? 0.0;
        onMessage(pos);
      },
    );
  }

  void setJalousie(
    String positionPath,
    double position,
    void Function(double position) onMessage,
  ) {
    _client?.request(
      "set/jalousie/status",
      jsonEncode({"positionPath": positionPath, "position": position.toInt()}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final pos = (body["position"] as num?)?.toDouble() ?? 0.0;
        onMessage(pos);
      },
    );
  }

  void setPlugStatus(
    String positionPath,
    String title,
    bool plugOn,
    void Function(bool status) onMessage,
  ) {
    _client?.request(
      "set/plug/status",
      jsonEncode({
        "positionPath": positionPath,
        "status": plugOn,
        "title": title,
      }),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final status = body["status"] as bool? ?? false;
        onMessage(status);
      },
    );
  }

  void getPlugStatus(
    String positionPath,
    String title,
    void Function(bool status) onMessage,
  ) {
    _client?.request(
      "get/plug/status",
      jsonEncode({"positionPath": positionPath, "title": title}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final status = body["status"] as bool? ?? false;
        onMessage(status);
      },
    );
  }

  void getUsage(String positionPath, void Function(String, int) onMessage) {
    _client?.request(
      "get/usage/status",
      jsonEncode({"positionPath": positionPath}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final usedLastMinutes = body["usedLastMinutes"] as int? ?? 0;
        final isUsed = body["used"] as String? ?? "Unknown";
        onMessage(isUsed, usedLastMinutes);
      },
    );
  }

  void getFloorHeater(
    String positionPath,
    void Function(FloorHeater floorheater) onMessage,
  ) {
    _client?.request(
      "get/temperature/status",
      jsonEncode({"positionPath": positionPath}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final temperatur = body["temperatur"] as double? ?? 0.0;
        log.d("body: " + bodyString);
        final betriebsart = Betriebsart.values.firstWhere(
          (e) =>
              e.name.toLowerCase() ==
              (body["betriebsart"] as String?)?.toLowerCase(),
          orElse: () => Betriebsart.STANDBY,
        );
        final sollwert = body["sollwert"] as double? ?? 0.0;
        final error = body["error"] as bool? ?? false;
        final position = body["position"] as int? ?? 0;
        onMessage(
          FloorHeater(
            temperatur: temperatur,
            sollwert: sollwert,
            error: error,
            position: position,
            betriebsart: betriebsart,
          ),
        );
      },
    );
  }

  void setRGBW(
    String positionPath,
    String hex,
    void Function(String hex) onMessage,
  ) {
    _client?.request(
      "set/led/status",
      jsonEncode({"positionPath": positionPath, "hex": hex}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final hex = body["hex"] as String? ?? "#00000000";
        onMessage(hex);
      },
    );
  }

  void setFloorHeater(
    String positionPath,
    double temperature,
    void Function(bool success) onMessage,
  ) {
    _client?.request(
      "set/temperature/sollwert",
      jsonEncode({"positionPath": positionPath, "temperature": temperature}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final success = body["success"] as bool? ?? false;
        onMessage(success);
      },
    );
  }

  void setFloorHeaterMode(
    String positionPath,
    Betriebsart mode,
    void Function(bool success) onMessage,
  ) {
    _client?.request(
      "set/temperature/mode",
      jsonEncode({"positionPath": positionPath, "betriebsart": mode.name}),
      (bodyString, topic) {
        final body = jsonDecode(bodyString);
        final success = body["success"] as bool? ?? false;
        onMessage(success);
      },
    );
  }

  void getTemperaturStatistics(
    String positionPath,
    void Function(List<Map<String, dynamic>> data) onMessage,
  ) {
    _client?.request(
      "get/statistics/temperatur",
      jsonEncode({"positionPath": positionPath}),
      (bodyString, topic) {
        try {
          var body = jsonDecode(bodyString);
          final List<dynamic> jsonArray = body['statistics'] ?? [];

          final List<Map<String, dynamic>> data = jsonArray.map((item) {
            final dynamic tDyn = item["time"];
            final int tInt = tDyn is int
                ? tDyn
                : tDyn is String
                ? int.tryParse(tDyn) ?? 0
                : 0;

            final DateTime time = tInt != null
                ? DateTime.fromMillisecondsSinceEpoch(tInt)
                : DateTime.now();
            var temp = item["temp"] as double;
            return {
              'time': time,
              'temp': temp,
            };
          }).toList();
          onMessage(data);
        } catch (e) {
          print("Error parsing statistics: $e");
          onMessage([]);
        }
      },
    );
  }
}
