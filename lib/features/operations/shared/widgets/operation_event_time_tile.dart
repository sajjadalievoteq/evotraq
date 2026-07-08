import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class OperationEventTimeTile extends StatelessWidget {
  const OperationEventTimeTile({
    super.key,
    required this.eventTime,
    required this.onEventTimeChanged,
    this.title = 'Event Date & Time',
    this.nowLabel = 'Now (at time of submission)',
    this.firstDate,
    this.lastDate,
  });

  final DateTime? eventTime;
  final ValueChanged<DateTime?> onEventTimeChanged;
  final String title;
  final String nowLabel;
  final DateTime? firstDate;
  final DateTime? lastDate;

  static final DateFormat _displayFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final display = eventTime != null
        ? _displayFormat.format(eventTime!.toLocal())
        : nowLabel;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: TraqIcon(AppAssets.iconClock),
      title: Text(title),
      subtitle: Text(
        display,
        style: TextStyle(
          color: eventTime != null
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: TraqIcon(AppAssets.iconEdit),
            tooltip: 'Set event date & time',
            onPressed: () => _pick(context, now),
          ),
          if (eventTime != null)
            IconButton(
              icon: TraqIcon(AppAssets.iconX),
              tooltip: 'Reset to now',
              onPressed: () => onEventTimeChanged(null),
            ),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context, DateTime now) async {
    final date = await showDatePicker(
      context: context,
      initialDate: eventTime ?? now,
      firstDate: firstDate ?? now.subtract(const Duration(days: 365)),
      lastDate: lastDate ?? now.add(const Duration(days: 1)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(eventTime ?? now),
    );
    if (time == null || !context.mounted) return;

    onEventTimeChanged(
      DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }
}
