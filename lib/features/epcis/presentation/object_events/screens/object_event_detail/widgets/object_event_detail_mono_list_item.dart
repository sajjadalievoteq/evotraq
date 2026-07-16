import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/utils/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

class ObjectEventDetailMonoListItem extends StatelessWidget {
  const ObjectEventDetailMonoListItem({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          context.showSuccess(ObjectEventDetailUiConstants.detailCopied);
        },
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: value));
          context.showSuccess(ObjectEventDetailUiConstants.detailCopied);
        },
        child: Row(
          children: [
            TraqIcon(AppAssets.iconCircle, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 6),
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
