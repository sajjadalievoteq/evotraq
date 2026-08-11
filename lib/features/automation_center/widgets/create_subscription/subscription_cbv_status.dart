import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_state.dart';

class SubscriptionCbvStatus extends StatelessWidget {
  const SubscriptionCbvStatus({
    required this.state,
    required this.onRetry,
    super.key,
  });

  final CbvVocabularyState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.isLoaded) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LinearProgressIndicator(),
      );
    }
    if (state.hasError && !state.isLoaded) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const Expanded(child: Text('Failed to load CBV vocabulary.')),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
