import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

class AggregationEventDetailField extends StatelessWidget {
  const AggregationEventDetailField({
    super.key,
    required this.label,
    this.value,
    this.monospace = false,
  });

  final String label;
  final String? value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onLongPress: value == null || value == '—'
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: value!));
                    context.showSuccess('Copied to clipboard');
                  },
            child: Text(
              value ?? '—',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: monospace ? 'monospace' : null,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
