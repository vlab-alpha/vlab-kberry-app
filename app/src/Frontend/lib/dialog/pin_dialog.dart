import 'package:flutter/material.dart';

Future<bool> showPinDialog(BuildContext context, String correctPin) async {
  final controller = TextEditingController();
  bool isValid = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("PIN eingeben"),
      content: TextField(
        controller: controller,
        obscureText: true,
        maxLength: 4,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: "4-stellige PIN",
          counterText: "",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Abbrechen"),
        ),
        FilledButton(
          onPressed: () {
            if (controller.text == correctPin) {
              isValid = true;
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Falsche PIN")),
              );
            }
          },
          child: const Text("OK"),
        ),
      ],
    ),
  );

  return isValid;
}