import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SsccDateRangeRow extends StatelessWidget {
  const SsccDateRangeRow({
    super.key,
    required this.label,
    required this.from,
    required this.to,
    required this.onFromChanged,
    required this.onToChanged,
    this.dateFormat,
  });

  final String label;
  final DateTime? from;
  final DateTime? to;
  final ValueChanged<DateTime?>? onFromChanged;
  final ValueChanged<DateTime?>? onToChanged;
  final DateFormat? dateFormat;

  static final _defaultDateFormat = DateFormat.yMMMd();

  Future<void> _pick(
    BuildContext context,
    DateTime? initial,
    ValueChanged<DateTime?>? onChanged,
  ) async {
    if (onChanged == null) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onChanged(DateTime(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = dateFormat ?? _defaultDateFormat;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pick(context, from, onFromChanged),
                child: Text(from == null ? 'From' : format.format(from!)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pick(context, to, onToChanged),
                child: Text(to == null ? 'To' : format.format(to!)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
