import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class Gs1DatePickerField extends StatelessWidget {
  const Gs1DatePickerField({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.helperText,
    this.emptyValueLabel = 'Select date',
  });
  final String label;
  final DateTime? value;
  final VoidCallback? onTap;
  final String? helperText;
  final String emptyValueLabel;
  static final DateFormat displayDateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          helperText: helperText,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value == null
                  ? emptyValueLabel
                  : displayDateFormat.format(value!),
              style: TextStyle(
                color: value != null ? context.colors.textPrimary : Colors.grey,
              ),
            ),
            TraqIcon(
              AppAssets.iconClock,
              size: 18,
              color: enabled ? null : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
