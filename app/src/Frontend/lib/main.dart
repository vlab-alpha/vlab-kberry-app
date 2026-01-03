import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:SmartHome/pages/dashboard_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await WakelockPlus.enable();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ProviderScope(  // <-- HIER ProviderScope hinzufügen
    child: SmartHomeApp(),
  ));
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2E2E2E),
        dropdownMenuTheme: const DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: MaterialStatePropertyAll(Color(0xFF3C3C3C)),
          ),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

