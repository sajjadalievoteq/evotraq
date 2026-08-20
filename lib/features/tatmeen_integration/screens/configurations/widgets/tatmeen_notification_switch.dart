import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class TatmeenNotificationSwitch extends StatelessWidget {
  const TatmeenNotificationSwitch({
    super.key,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: context.text.body),
      subtitle: Text(
        subtitle,
        style: context.text.bodySm.copyWith(color: context.colors.textMuted),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
