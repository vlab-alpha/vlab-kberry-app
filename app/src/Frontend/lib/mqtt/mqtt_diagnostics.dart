import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';

class MqttDiagnostics {
  final String broker;
  final int port;
  final MqttClient client;
  final Stream<List<MqttReceivedMessage<MqttMessage>>>? updatesStream;

  late Timer _socketTimer;
  late Timer _streamTimer;
  late Timer _threadTimer;
  late Timer _statusTimer;

  int _lastMsg = DateTime.now().millisecondsSinceEpoch;
  int _lastTick = DateTime.now().millisecondsSinceEpoch;
  int _lastPong = DateTime.now().millisecondsSinceEpoch;

  MqttDiagnostics({
    required this.broker,
    required this.port,
    required this.client,
    required this.updatesStream,
  });

  /// Startet alle Überwachungen
  void start() {
    _startSocketCheck();
    _startMainThreadWatchdog();
    _startMqttStreamMonitor();
    _startStatusCheck();
    _registerPongCallback();
    _checkBrokerPingResponse();
  }

  /// Stoppt alle Timer (z. B. beim Dispose)
  void stop() {
    _socketTimer.cancel();
    _streamTimer.cancel();
    _threadTimer.cancel();
    _statusTimer.cancel();
  }

  // ------------------------------
  // 🧩 1. Socket-Check
  // ------------------------------
  void _startSocketCheck() {
    _socketTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final socket = await Socket.connect(broker, port,
            timeout: const Duration(seconds: 3));
        print('✅ Socket erreichbar: $broker:$port');
        socket.destroy();
      } catch (e) {
        print('❌ Socket NICHT erreichbar: $broker:$port — $e');
      }
    });
  }

  // ------------------------------
  // 🧩 2. Main-Thread-Watchdog
  // ------------------------------
  void _startMainThreadWatchdog() {
    _threadTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final delta = now - _lastTick;
      if (delta > 3000) {
        print('⚠️ Main Thread blockiert? Zeitabweichung: ${delta} ms');
      }
      _lastTick = now;
    });

    // Eventloop-Heartbeat
    () async {
      while (true) {
        await Future.delayed(const Duration(milliseconds: 500));
        _lastTick = DateTime.now().millisecondsSinceEpoch;
      }
    }();

    Timer.periodic(const Duration(seconds: 5), (_) {
      print('🧠 Mainloop tickt normal.');
    });
  }

  // ------------------------------
  // 🧩 3. MQTT-Stream-Monitor
  // ------------------------------
  void _startMqttStreamMonitor() {
    updatesStream?.listen((messages) {
      _lastMsg = DateTime.now().millisecondsSinceEpoch;
      for (var msg in messages) {
        print('📩 MQTT-Nachricht: ${msg.topic}');
      }
    }, onError: (e) {
      print('❌ MQTT Stream-Fehler: $e');
    }, onDone: () {
      print('⚠️ MQTT Stream wurde geschlossen!');
    });

    _streamTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastMsg > 30000) {
        print('⚠️ Seit 30 Sekunden keine MQTT-Nachricht mehr empfangen!');
      }
    });
  }

  // ------------------------------
  // 🧩 4. Connection-Status-Check
  // ------------------------------
  void _startStatusCheck() {
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final state = client.connectionStatus?.state;
      print('🔍 MQTT-State: $state');
      if (state != MqttConnectionState.connected) {
        print('⚠️ MQTT ist NICHT verbunden! (${client.connectionStatus})');
      }
    });
  }

  // ------------------------------
  // 🧩 5. Ping/Pong-Überwachung
  // ------------------------------
  void _registerPongCallback() {
    client.pongCallback = () {
      _lastPong = DateTime.now().millisecondsSinceEpoch;
      print('🏓 Pong vom Broker empfangen');
    };

    Timer.periodic(const Duration(seconds: 20), (_) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastPong > 40000) {
        print('⚠️ Seit 40 Sekunden kein Pong erhalten — evtl. Ping hängt!');
      }
    });
  }

  void _checkBrokerPingResponse() async {
    try {
      final socket = await Socket.connect(broker, port, timeout: const Duration(seconds: 3));
      socket.write('PINGREQ');
      await socket.flush();
      socket.listen((data) {
        print('📨 Broker antwortete direkt auf Ping: ${String.fromCharCodes(data)}');
      });
      await Future.delayed(const Duration(seconds: 2));
      socket.destroy();
    } catch (e) {
      print('❌ Direkter Ping-Test fehlgeschlagen: $e');
    }
  }
}