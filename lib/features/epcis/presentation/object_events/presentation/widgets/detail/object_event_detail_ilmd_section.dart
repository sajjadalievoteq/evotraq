import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/detail/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/object_event_detail_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class ObjectEventDetailIlmdSection extends StatelessWidget {
  const ObjectEventDetailIlmdSection({super.key, required this.event});

  final ObjectEvent event;

  @override
  Widget build(BuildContext context) {
    final ilmd = event.ilmd;
    final bizData = event.bizData;
    final ext = event.extensions;
    final hasData = (ilmd?.isNotEmpty ?? false) ||
        (bizData?.isNotEmpty ?? false) ||
        (ext?.isNotEmpty ?? false);
    if (!hasData) return const SizedBox.shrink();

    return Gs1GroupCard(
      title: ObjectEventDetailUiConstants.sectionIlmd,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ilmd != null && ilmd.isNotEmpty) ...[
            Text(
              ObjectEventDetailUiConstants.labelIlmd,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 6),
            ...ilmd.entries.map(
              (e) => ObjectEventDetailField(
                label: e.key,
                value: e.value?.toString(),
              ),
            ),
          ],
          if (bizData != null && bizData.isNotEmpty) ...[
            if (ilmd?.isNotEmpty ?? false) const SizedBox(height: 8),
            Text(
              ObjectEventDetailUiConstants.labelBizData,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 6),
            ...bizData.entries.map(
              (e) => ObjectEventDetailField(label: e.key, value: e.value),
            ),
          ],
          if (ext != null && ext.isNotEmpty) ...[
            if ((ilmd?.isNotEmpty ?? false) ||
                (bizData?.isNotEmpty ?? false))
              const SizedBox(height: 8),
            Text(
              ObjectEventDetailUiConstants.labelExtensions,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 6),
            ...ext.entries.map(
              (e) => ObjectEventDetailField(label: e.key, value: e.value),
            ),
          ],
        ],
      ),
    );
  }
}
