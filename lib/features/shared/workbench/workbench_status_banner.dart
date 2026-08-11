import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

class WorkbenchStatusBanner extends StatelessWidget {
  const WorkbenchStatusBanner({
    required this.color,
    required this.icon,
    required this.text,
  });

  final Color color;
  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TraqSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          TraqIcon(icon, color: color, size: 16),
          const SizedBox(width: TraqSpacing.sm),
          Expanded(
            child: Text(text, style: context.text.body.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
