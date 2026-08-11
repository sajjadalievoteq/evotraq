import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class BarcodeManualInputSection extends StatelessWidget {
  const BarcodeManualInputSection({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isProcessing,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isProcessing;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or enter barcode manually',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: !isProcessing,
            decoration: const InputDecoration(
              hintText: 'e.g. (01)12345678901234(21)SN001',
              border: OutlineInputBorder(),
              prefixIcon: TraqIcon(AppAssets.iconKeyboard),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              isDense: true,
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) onSubmit(value.trim());
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: isProcessing
                  ? null
                  : () {
                      final value = controller.text.trim();
                      if (value.isNotEmpty) onSubmit(value);
                    },
              child: isProcessing
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Parse Barcode'),
            ),
          ),
        ],
      ),
    );
  }
}
