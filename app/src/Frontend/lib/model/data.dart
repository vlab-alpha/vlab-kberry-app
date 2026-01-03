enum InformationType {
  temperature,
  light,
  humidity,
  jalousie,
  usage,
  plug,
  weather,
  dimmer,
  fan,
  scene,
  camera,
  co2,
  energy,
  launcher,
  led,
  alle,
}

class Information {
  final String positionPath;
  final String value;
  final String title;
  final InformationType type;
  final String? password;
  final String? extraValue;
  final String? icon;

  Information({
    required this.type,
    required this.positionPath,
    required this.title,
    required this.value,
    required this.password,
    this.extraValue,
    this.icon,
  });

  String room() {
    var path = positionPath.split("/");
    return path.last;
  }
}

enum ValueType { Integer, Double, String, Boolean, Time }

class Value {
  ValueType type;
  String? from;
  String? to;
  String value;

  Value({required this.type, required this.value, this.to, this.from});

  factory Value.fromJson(Map<String, dynamic> json) {
    // Typ-String zu Enum umwandeln (case-insensitive)
    final typeString = json["type"]?.toString().toLowerCase();
    final type = ValueType.values.firstWhere(
      (e) => e.name.toLowerCase() == typeString,
      orElse: () => ValueType.String,
    );

    return Value(
      type: type,
      value: json["value"]?.toString() ?? "",
      from: json["from"]?.toString(),
      to: json["to"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "type": type.name,
    "value": value,
    "from": from,
    "to": to,
  };

  static Value fromDynamic(
    dynamic val, {
    ValueType? type,
    String? from,
    String? to,
  }) {
    if (val is int) {
      return Value(
        type: ValueType.Integer,
        value: val.toString(),
        from: from,
        to: to,
      );
    } else if (val is double) {
      return Value(
        type: ValueType.Double,
        value: val.toString(),
        from: from,
        to: to,
      );
    } else {
      return Value(
        type: type ?? ValueType.String,
        value: val.toString(),
        from: from,
        to: to,
      );
    }
  }

  /// Gibt den Value als konkreten Dart-Datentyp zurück.
  dynamic get parsedValue {
    switch (type) {
      case ValueType.Integer:
        return int.tryParse(value);
      case ValueType.Double:
        return double.tryParse(value);
      case ValueType.String:
      default:
        return value;
    }
  }

  /// Gibt 'from' als passenden Typ zurück
  dynamic get parsedFrom {
    if (from == null) return null;
    switch (type) {
      case ValueType.Integer:
        return int.tryParse(from!);
      case ValueType.Double:
        return double.tryParse(from!);
      case ValueType.String:
      default:
        return from;
    }
  }

  /// Gibt 'to' als passenden Typ zurück
  dynamic get parsedTo {
    if (to == null) return null;
    switch (type) {
      case ValueType.Integer:
        return int.tryParse(to!);
      case ValueType.Double:
        return double.tryParse(to!);
      case ValueType.String:
      default:
        return to;
    }
  }
}

enum SettingType {
  Time,
  TimeSpan,
  Date,
  DateSpan,
  Number,
  NumberSpan,
  Checkbox,
  Text,
  Minutes
}

class Setting {
  SettingType type;
  String title;
  Value value;
  String? icon;

  Setting({
    required this.type,
    required this.title,
    required this.value,
    this.icon,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    final title = json["title"] ?? "";
    final icon = json["icon"];
    final typeString = json["type"];

    // SettingType anhand des ValueType bestimmen (optional)
    final type = SettingType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => SettingType.Text,
    );

    // 🔸 Hier den Value richtig konvertieren
    final valueJson = json["value"];
    final value = valueJson is Map<String, dynamic>
        ? Value.fromJson(valueJson)
        : Value(type: ValueType.String, value: valueJson.toString());

    return Setting(type: type, title: title, value: value, icon: icon);
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "icon": icon,
    "type": type.name,
    "value": value.toJson(),
  };

  /// Gibt den eigentlichen Wert (z. B. int/double/String/DateTime/bool)
  /// passend zum SettingType zurück.
  dynamic get concreteValue {
    switch (type) {
      case SettingType.Minutes:
      case SettingType.Number:
        return value.parsedValue;
      case SettingType.NumberSpan:
        return {'from': value.parsedFrom, 'to': value.parsedTo};
      case SettingType.Time:
      case SettingType.Date:
        // nur der eigentliche Wert
        return value.parsedValue;
      case SettingType.TimeSpan:
      case SettingType.DateSpan:
        return {
          'from': value.parsedFrom,
          'to': value.parsedTo,
          'value': value.parsedValue,
        };
      case SettingType.Checkbox:
        return value.value.toLowerCase() == 'true';
      default:
        return value.parsedValue;
    }
  }

  /// Komfortfunktion: Gibt from/to als Paar zurück (z. B. bei Spans)
  ({dynamic from, dynamic to})? get range {
    if (value.from == null && value.to == null) return null;
    return (from: value.parsedFrom, to: value.parsedTo);
  }

  @override
  String toString() {
    return 'Setting(title: $title, type: $type, value: ${value.toString()})';
  }
}

class Dimmer {
  int min;
  int max;
  int value;

  Dimmer({required this.min, required this.max, required this.value});
}

enum Betriebsart { KOMFORT, STANDBY, NACHT }

class FloorHeater {
  double temperatur;
  double sollwert;
  bool error;
  int position;
  Betriebsart betriebsart;

  FloorHeater({
    required this.temperatur,
    required this.sollwert,
    required this.error,
    required this.position,
    required this.betriebsart
  });
}

