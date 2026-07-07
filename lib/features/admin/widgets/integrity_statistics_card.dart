import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';
import '../models/monitoring_models.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/admin/widgets/utils/admin_helper_mappers.dart';
import 'package:traqtrace_app/features/epcis/presentation/utils/epcis_event_ui_utils.dart';

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
                    color: AdminHelperMappers.integrityScoreColor(
                      integrity.overallIntegrityScore,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AdminHelperMappers.integrityScoreColor(
                        integrity.overallIntegrityScore,
                      ),
                    ),
                  ),
                  child: Text(
                    'Score: ${integrity.overallIntegrityScore.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: AdminHelperMappers.integrityScoreColor(
                        integrity.overallIntegrityScore,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Coverage metrics
            Row(
              children: [
                Expanded(
                  child: _buildCoverageMetric(
                    'Hash Coverage',
                    integrity.hashCoveragePercentage,
                    integrity.totalEventsWithHashes,
                    AppAssets.iconFingerprint,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCoverageMetric(
                    'Signature Coverage',
                    integrity.signatureCoveragePercentage,
                    integrity.totalEventsWithSignatures,
                    AppAssets.iconVerified,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildIntegrityMetric(
                    'Audit Trail Entries',
                    '${integrity.auditTrailCount}',
                    AppAssets.iconHistory,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildIntegrityMetric(
                    'Immutable Events',
                    '${integrity.immutableEventsCount}',
                    AppAssets.iconLock,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Integrity by event type
            const Text(
              'Integrity by Event Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...integrity.integrityByEventType.entries.map((entry) => 
              _buildEventTypeIntegrityRow(entry.key, entry.value)
            ).toList(),
            
            const SizedBox(height: 24),
            
            // Recent violations
            if (integrity.recentViolations.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Integrity Violations',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  TraqIcon(AppAssets.iconAlert,
                    color: Colors.red,
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
                    return _buildViolationCard(violation);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Last integrity check
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

  Widget _buildCoverageMetric(String title, double percentage, int count, String iconAsset, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TraqIcon(iconAsset, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          Text(
            '($count events)',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrityMetric(String title, String value, String iconAsset, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TraqIcon(iconAsset, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeIntegrityRow(String eventType, int integrityCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: EpcisEventUiUtils.eventTypeColor(eventType),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              eventType,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Spacer(),
          Text(
            '$integrityCount events',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildViolationCard(IntegrityViolation violation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            TraqIcon(
              AdminHelperMappers.severityIcon(violation.severity),
              color: AdminHelperMappers.severityColor(violation.severity),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    violation.violationType,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    violation.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Event: ${violation.eventId} (${violation.eventType})',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              DisplayDateUtils.dmHm(violation.detectedAt),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
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
