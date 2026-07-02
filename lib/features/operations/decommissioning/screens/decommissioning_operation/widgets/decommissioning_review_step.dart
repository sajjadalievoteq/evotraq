import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation/utils/decommissioning_disposition.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class DecommissioningReviewStep extends StatelessWidget {
  const DecommissioningReviewStep({
    super.key,
    required this.locationGln,
    required this.disposition,
    required this.reason,
    required this.comments,
    required this.eventTime,
    required this.scannedEpcs,
    this.showPageHeader = true,
  });

  final GLN? locationGln;
  final DecommissioningDisposition? disposition;
  final String reason;
  final String comments;
  final DateTime? eventTime;
  final List<String> scannedEpcs;
  final bool showPageHeader;

  static final DateFormat _eventTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: ResponsiveUtils.paddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Review Decommissioning Operation'),
          if (showPageHeader) ...[
            const SizedBox(height: 8),
            const Text(
              'Please review all details before submitting.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
          const SizedBox(height: 16),
          Gs1GroupCard(
            title: 'Operation Details',
            outlineColor: outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _row('Reference', 'Auto-generated on submit'),
                const SizedBox(height: 12),
                _row('Location GLN', locationGln?.glnCode ?? '-'),
                if (locationGln?.locationName.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      locationGln!.locationName,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 12),
                _row('Disposition', disposition?.label ?? '-'),
                const SizedBox(height: 12),
                _row('Reason', reason.isNotEmpty ? reason : '-'),
                if (comments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _row('Comments', comments),
                ],
                const SizedBox(height: 12),
                _row(
                  'Event Time',
                  eventTime != null
                      ? _eventTimeFormat.format(eventTime!.toLocal())
                      : 'Now (at time of submission)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Gs1GroupCard(
            title: 'Items to Decommission (${scannedEpcs.length})',
            outlineColor: outline,
            child: scannedEpcs.isEmpty
                ? const Text('No items scanned.')
                : Column(
                    children: scannedEpcs
                        .map(
                          (epc) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: TraqIcon(AppAssets.iconQr,
                              color: _epcColor(epc),
                            ),
                            title: Text(
                              epc,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            subtitle: Text(_epcLabel(epc)),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  String _epcLabel(String value) {
    return switch (OperationEpcScanValidator.resolveEpcType(value)) {
      OperationScanItemType.sgtin => 'SGTIN',
      OperationScanItemType.sscc => 'SSCC',
      OperationScanItemType.gtin => 'GTIN',
      OperationScanItemType.unknown => 'EPC',
    };
  }

  Color _epcColor(String value) {
    return switch (OperationEpcScanValidator.resolveEpcType(value)) {
      OperationScanItemType.sgtin => Colors.blue,
      OperationScanItemType.sscc => Colors.teal,
      OperationScanItemType.gtin => Colors.orange,
      OperationScanItemType.unknown => Colors.grey,
    };
  }
}
