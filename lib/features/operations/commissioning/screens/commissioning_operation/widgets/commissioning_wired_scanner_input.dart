import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;

class CommissioningWiredScannerInput extends StatelessWidget {
  const CommissioningWiredScannerInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isActive,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isActive;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        KeyboardListener(
          focusNode: focusNode,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEnter) {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  onSubmitted(value);
                  controller.clear();
                }
              } else if (event.character != null &&
                  event.character!.isNotEmpty) {
                controller.text += event.character!;
              }
            }
          },
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
