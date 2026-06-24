import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';

class SsccDetailErrorPane extends StatelessWidget {
  const SsccDetailErrorPane({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? SsccUiConstants.errorGeneric,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            onPressed: onRetry,
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
