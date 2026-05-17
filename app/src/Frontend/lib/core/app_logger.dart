import 'package:flutter/foundation.dart';

class AppLogger extends ChangeNotifier {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  final List<String> _logs = [];

  List<String> get logs => List.unmodifiable(_logs);

  void log(String message, {dynamic error}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = error != null
        ? "[$timestamp] $message | Error: $error"
        : "[$timestamp] $message";

    _logs.add(logMessage);

    // Nur im Debug-Modus print
    assert(() {
      print(logMessage);
      return true;
    }());
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }
}