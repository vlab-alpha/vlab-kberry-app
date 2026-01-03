import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReolinkCard extends StatelessWidget {
  final String title;
  final String rtspUrl;
  static const platform = MethodChannel('app.channel.shared.data');

  const ReolinkCard({
    super.key,
    required this.title,
    required this.rtspUrl,
  });

  void _openReolinkApp() async {
    try {

      await platform.invokeMethod('openReolinkApp');
    } on PlatformException catch (e) {
      print("Fehler beim Öffnen der App: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: _openReolinkApp,
        child:Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2E2E2E),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade800, width: 5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Expanded(
                child: kIsWeb || defaultTargetPlatform != TargetPlatform.android
                    ? const Center(child: Text("RTSP nur auf Android"))
                    : AndroidView(
                  viewType: 'rtsp_player',
                  creationParams: {'url': rtspUrl},
                  creationParamsCodec: const StandardMessageCodec(),
                ),
              ),
            ],
          ),
        ));
  }
}