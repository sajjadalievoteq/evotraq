import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';

class DashboardHealthStatusRow extends StatelessWidget {
  const DashboardHealthStatusRow({
    super.key,
    required this.title,
    required this.isHealthy,
  });

  final String title;
  final bool isHealthy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHealthy ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: context.text.body.copyWith(color: context.colors.textPrimary),
            ),
          ),
          Text(
            isHealthy
                ? HomeStrings.healthStatusHealthy
                : HomeStrings.healthStatusUnhealthy,
            style: context.text.bodySm.copyWith(
              color: isHealthy ? context.colors.success : context.colors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
