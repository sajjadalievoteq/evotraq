import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/utils/update_status_disposition.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_epc_type_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation/operation_review_rows.dart';

class UpdateStatusReviewStep extends StatelessWidget {
  const UpdateStatusReviewStep({
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
  final UpdateStatusDisposition? disposition;
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
          OperationReviewStepHeader(
            title: 'Review Update Status Operation',
            showPageHeader: showPageHeader,
          ),
          Gs1GroupCard(
            title: 'Operation Details',
            outlineColor: outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OperationReviewInfoRow('Reference', 'Auto-generated on submit'),
                const SizedBox(height: 12),
                OperationReviewInfoRow('Location GLN', locationGln?.glnCode ?? '-'),
                if (locationGln?.locationName.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      locationGln!.locationName,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 12),
                OperationReviewInfoRow('Status', disposition?.label ?? '-'),
                const SizedBox(height: 12),
                OperationReviewInfoRow('Reason', reason.isNotEmpty ? reason : '-'),
                OperationReviewOptionalFields([
                  OperationReviewField('Comments', comments),
                ]),
                const SizedBox(height: 12),
                OperationReviewInfoRow(
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
            title: 'Items to Update (${scannedEpcs.length})',
            outlineColor: outline,
            child: scannedEpcs.isEmpty
                ? const Text('No items scanned.')
                : Column(
                    children: scannedEpcs
                        .map(
                          (epc) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: TraqIcon(
                              AppAssets.iconQr,
                              color: OperationEpcTypeUtils.colorFromValue(epc),
                            ),
                            title: Text(
                              epc,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            subtitle: Text(OperationEpcTypeUtils.labelFromValue(epc)),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
