import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/widgets/integrity_event_type_row.dart';
import 'package:traqtrace_app/features/admin/widgets/integrity_violation_card.dart';
import 'package:traqtrace_app/features/admin/widgets/integrity_coverage_metric.dart';
import 'package:traqtrace_app/features/admin/widgets/integrity_metric_tile.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import 'package:traqtrace_app/data/models/admin/monitoring_models.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/status_visual_mappers.dart';

class IntegrityStatisticsCard extends StatelessWidget {
  final IntegrityStatistics integrity;
  final Function(String) onVerifyIntegrity;

  const IntegrityStatisticsCard({
    super.key,
    required this.integrity,
    required this.onVerifyIntegrity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Data Integrity Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: StatusVisualMappers.integrityScoreColor(
                      context,
                      integrity.overallIntegrityScore,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: StatusVisualMappers.integrityScoreColor(
                        context,
                        integrity.overallIntegrityScore,
                      ),
                    ),
                  ),
                  child: Text(
                    'Score: ${integrity.overallIntegrityScore.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: StatusVisualMappers.integrityScoreColor(
                        context,
                        integrity.overallIntegrityScore,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: IntegrityCoverageMetric(
                    'Hash Coverage',
                    integrity.hashCoveragePercentage,
                    integrity.totalEventsWithHashes,
                    AppAssets.iconFingerprint,
                    AppColorMapper.chartColor(context, 0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: IntegrityCoverageMetric(
                    'Signature Coverage',
                    integrity.signatureCoveragePercentage,
                    integrity.totalEventsWithSignatures,
                    AppAssets.iconVerified,
                    AppColorMapper.chartColor(context, 1),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: IntegrityMetricTile(
                    'Audit Trail Entries',
                    '${integrity.auditTrailCount}',
                    AppAssets.iconHistory,
                    AppColorMapper.chartColor(context, 2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: IntegrityMetricTile(
                    'Immutable Events',
                    '${integrity.immutableEventsCount}',
                    AppAssets.iconLock,
                    AppColorMapper.chartColor(context, 3),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Integrity by Event Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...integrity.integrityByEventType.entries.map((entry) => 
              IntegrityEventTypeRow(entry.key, entry.value)
            ).toList(),
            
            const SizedBox(height: 24),
            
            if (integrity.recentViolations.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Integrity Violations',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  TraqIcon(AppAssets.iconAlert,
                    color: AppColorMapper.errorColor(context),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: integrity.recentViolations.length,
                  itemBuilder: (context, index) {
                    final violation = integrity.recentViolations[index];
                    return IntegrityViolationCard(violation);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  TraqIcon(AppAssets.iconClock,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last integrity check: ${DisplayDateUtils.dmHm(integrity.lastIntegrityCheck)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showVerifyDialog(context),
                    child: const Text('Verify Event'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }





  void _showVerifyDialog(BuildContext context) {
    String eventId = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Event Integrity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter Event ID to verify:'),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => eventId = value,
              decoration: const InputDecoration(
                hintText: 'Event ID',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (eventId.isNotEmpty) {
                Navigator.pop(context);
                onVerifyIntegrity(eventId);
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}
