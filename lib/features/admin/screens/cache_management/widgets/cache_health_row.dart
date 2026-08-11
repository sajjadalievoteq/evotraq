import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CacheHealthRow extends StatelessWidget {
  const CacheHealthRow(this.label, this.value, this.isHealthy, {super.key});

  final String label;
  final String value;
  final bool isHealthy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Row(
            children: [
              TraqIcon(
                isHealthy ? AppAssets.iconCheckCircle : AppAssets.iconXCircle,
                size: 16,
                color: isHealthy
                    ? AppColorMapper.successColor(context)
                    : AppColorMapper.errorColor(context),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isHealthy
                      ? AppColorMapper.successColor(context)
                      : AppColorMapper.errorColor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
