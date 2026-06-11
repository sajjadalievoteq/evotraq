import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/detail/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

class ObjectEventDetailMonoListItem extends StatelessWidget {
  const ObjectEventDetailMonoListItem({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: value));
          context.showSuccess(ObjectEventDetailUiConstants.detailCopied);
        },
        child: Row(
          children: [
            Icon(
              Icons.circle,
              size: 6,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
