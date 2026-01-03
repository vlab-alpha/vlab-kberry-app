import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mqtt/mqtt_smart_home_service.dart';
import 'config.dart';

// Erzeugt eine einzige Instanz von SmartHomeService
final smartHomeServiceProvider = Provider<SmartHomeService>((ref) {
  return SmartHomeService.instance();
});