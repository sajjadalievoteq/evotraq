import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class PerformanceTestStatusBadge extends StatelessWidget {
  const PerformanceTestStatusBadge({super.key, required this.passed});

  final bool passed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: passed
            ? AppColorMapper.successColor(context).withOpacity(0.1)
            : AppColorMapper.errorColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: passed
              ? AppColorMapper.successColor(context)
              : AppColorMapper.errorColor(context),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TraqIcon(
            passed ? AppAssets.iconCheckCircle : AppAssets.iconXCircle,
            size: 16,
            color: passed
                ? AppColorMapper.successColor(context)
                : AppColorMapper.errorColor(context),
          ),
          const SizedBox(width: 4),
          Text(
            passed ? 'PASSED' : 'FAILED',
            style: TextStyle(
              color: passed
                  ? AppColorMapper.successColor(context)
                  : AppColorMapper.errorColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
