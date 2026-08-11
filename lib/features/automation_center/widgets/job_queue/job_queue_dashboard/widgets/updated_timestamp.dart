import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class JobQueueUpdatedTimestamp extends StatelessWidget {
  const JobQueueUpdatedTimestamp({super.key, required this.lastUpdated});
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final time = lastUpdated == null
        ? '—'
        : DateFormat.Hms().format(lastUpdated!.toLocal());
    return Text(
      'Updated $time',
      style: context.text.cap.copyWith(color: context.colors.textMuted),
    );
  }
}
