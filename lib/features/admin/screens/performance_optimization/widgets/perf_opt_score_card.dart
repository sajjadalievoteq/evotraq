import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class PerfOptScoreCard extends StatelessWidget {
  const PerfOptScoreCard(this.score, {super.key});

  final double score;

  @override
  Widget build(BuildContext context) {
    final scoreColor = score >= 80
        ? AppColorMapper.successColor(context)
        : score >= 60
            ? AppColorMapper.warningColor(context)
            : AppColorMapper.errorColor(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                TraqIcon(AppAssets.iconClock, size: 32, color: scoreColor),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Performance Score',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'System health and efficiency rating',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${score.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
          ],
        ),
      ),
    );
  }
}
