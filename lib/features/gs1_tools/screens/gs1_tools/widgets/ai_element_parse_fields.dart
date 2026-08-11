import 'package:flutter/material.dart';

class AiElementParseFields extends StatelessWidget {
  const AiElementParseFields({
    required this.controller,
    required this.loading,
    super.key,
  });

  final TextEditingController controller;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'GS1 element string',
        hintText: 'Paste barcode data or human-readable AIs',
      ),
      maxLines: 6,
      enabled: !loading,
    );
  }
}
