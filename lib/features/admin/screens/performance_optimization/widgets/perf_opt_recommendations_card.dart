import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class PerfOptRecommendationsCard extends StatelessWidget {
  const PerfOptRecommendationsCard(this.recommendations, {super.key});

  final List recommendations;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  AppAssets.iconLightbulb,
                  color: AppColorMapper.warningColor(context),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Top Recommendations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recommendations.isEmpty)
              const Text(
                'No recommendations at this time',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...recommendations.take(3).map(
                    (rec) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          TraqIcon(
                            AppAssets.iconChevronR,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(rec.toString())),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
