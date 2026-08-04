import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

class CacheTypeRow extends StatelessWidget {
  const CacheTypeRow(
    this.type,
    this.hitRatio,
    this.hits,
    this.misses, {
    super.key,
  });

  final String type;
  final double hitRatio;
  final int hits;
  final int misses;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(type, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: hitRatio,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              hitRatio > 0.8
                  ? AppColorMapper.successColor(context)
                  : hitRatio > 0.5
                      ? AppColorMapper.warningColor(context)
                      : AppColorMapper.errorColor(context),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(hitRatio * 100).toStringAsFixed(1)}%'),
        const SizedBox(width: 16),
        Text('$hits/$misses'),
      ],
    );
  }
}
