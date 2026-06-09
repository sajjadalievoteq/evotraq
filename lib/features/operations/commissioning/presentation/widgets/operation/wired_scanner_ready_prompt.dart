import 'package:flutter/material.dart';

class CommissioningWiredScannerReadyPrompt extends StatelessWidget {
  const CommissioningWiredScannerReadyPrompt({
    super.key,
    required this.captureController,
    required this.captureFocusNode,
    required this.onSubmitted,
  });

  final TextEditingController captureController;
  final FocusNode captureFocusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.document_scanner_outlined,
                  size: 80,
                  color: cs.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 24),
                Text(
                  'Ready to scan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Point your barcode scanner at the product label.\nThe barcode will be captured automatically.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: SizedBox(
            width: 1,
            height: 1,
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: captureController,
                focusNode: captureFocusNode,
                autofocus: true,
                onSubmitted: onSubmitted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
