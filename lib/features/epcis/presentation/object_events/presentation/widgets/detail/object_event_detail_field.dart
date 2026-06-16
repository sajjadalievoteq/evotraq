import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/detail/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/shared/object_event_shared_ui_constants.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

class ObjectEventDetailField extends StatelessWidget {
  const ObjectEventDetailField({
    super.key,
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final String label;
  final String? value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final display = (value == null || value!.isEmpty)
        ? ObjectEventSharedUiConstants.emDash
        : value!;
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
            onLongPress: display == ObjectEventSharedUiConstants.emDash
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: display));
                    context.showSuccess(
                      ObjectEventDetailUiConstants.detailCopied,
                    );
                  },
            child: Text(
              display,
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
