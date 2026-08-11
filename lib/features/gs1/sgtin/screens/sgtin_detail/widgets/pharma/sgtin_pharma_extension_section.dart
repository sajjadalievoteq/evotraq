import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/pharma/sgtin_pharma_info_row.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/pharma/sgtin_pharma_boolean_row.dart';

class SgtinPharmaExtensionSection extends StatelessWidget {
  const SgtinPharmaExtensionSection({
    super.key,
    required this.extension_,
    required this.borderColor,
  });

  final SGTINPharmaceuticalExtensionModel extension_;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = extension_;

    return Gs1GroupCard(
      title: 'Pharmaceutical Extension',
      outlineColor: theme.colorScheme.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ext.reportingRegimes.isNotEmpty ||
              ext.emvoUploadStatus != null ||
              ext.tatmeenSubmissionStatus != null ||
              ext.dscsaTransactionHash != null) ...[
            SectionLabel(
              'Regulatory Reporting',
              padding: const EdgeInsets.only(top: 4, bottom: 8),
            ),
            if (ext.reportingRegimes.isNotEmpty)
              SgtinPharmaInfoRow(
                'Reporting Regimes',
                ext.reportingRegimes.join(' • '),
              ),
            if (ext.emvoUploadStatus != null) ...[
              const SizedBox(height: 8),
              SgtinPharmaInfoRow(
                'EMVO Upload Status',
                ext.emvoUploadStatus!,
                valueColor: _submissionColor(context, ext.emvoUploadStatus),
              ),
            ],
            if (ext.tatmeenSubmissionStatus != null) ...[
              const SizedBox(height: 8),
              SgtinPharmaInfoRow(
                'Tatmeen Submission',
                ext.tatmeenSubmissionStatus!,
                valueColor: _submissionColor(
                  context,
                  ext.tatmeenSubmissionStatus,
                ),
              ),
            ],
            if (ext.dscsaTransactionHash != null) ...[
              const SizedBox(height: 8),
              SgtinPharmaInfoRow(
                'DSCSA Transaction Hash',
                ext.dscsaTransactionHash!,
                monospace: true,
              ),
            ],
            const SizedBox(height: 16),
          ],

          SectionLabel(
            'Cold Chain Monitoring',
            padding: const EdgeInsets.only(top: 4, bottom: 8),
          ),
          SgtinPharmaBooleanRow(
            'Cold Chain Excursion',
            ext.coldChainExcursionFlag,
            trueColor: AppColorMapper.errorColor(context),
          ),
          if (ext.tempMinRecorded != null) ...[
            const SizedBox(height: 8),
            SgtinPharmaInfoRow(
              'Min Temp Recorded',
              '${ext.tempMinRecorded!.toStringAsFixed(2)} °C',
            ),
          ],
          if (ext.tempMaxRecorded != null) ...[
            const SizedBox(height: 8),
            SgtinPharmaInfoRow(
              'Max Temp Recorded',
              '${ext.tempMaxRecorded!.toStringAsFixed(2)} °C',
            ),
          ],
          if (ext.lastSensorEventId != null) ...[
            const SizedBox(height: 8),
            SgtinPharmaInfoRow(
              'Last Sensor Event ID',
              ext.lastSensorEventId!,
              monospace: true,
            ),
          ],
          const SizedBox(height: 16),

          SectionLabel(
            'Anti-Counterfeit & Tamper Evidence',
            padding: const EdgeInsets.only(top: 4, bottom: 8),
          ),
          SgtinPharmaInfoRow(
            'Anti-Tamper Seal Status',
            ext.antiTamperStatus.displayName,
            valueColor: _tamperColor(context, ext.antiTamperStatus),
          ),
          if (ext.fraudScore != null) ...[
            const SizedBox(height: 8),
            SgtinPharmaInfoRow(
              'Fraud Risk Score',
              ext.fraudScore!.toStringAsFixed(2),
              valueColor: ext.fraudScore! > 0.5
                  ? AppColorMapper.errorColor(context)
                  : null,
            ),
          ],
          if (ext.duplicateEvidenceCount > 0) ...[
            const SizedBox(height: 8),
            SgtinPharmaInfoRow(
              'Duplicate Evidence Records',
              ext.duplicateEvidenceCount.toString(),
              valueColor: AppColorMapper.warningColor(context),
            ),
          ],
          const SizedBox(height: 16),

          if (ext.controlledCustodyRef != null) ...[
            SectionLabel(
              'Controlled Substances',
              padding: const EdgeInsets.only(top: 4, bottom: 8),
            ),
            SgtinPharmaInfoRow(
              'Custody Reference',
              ext.controlledCustodyRef!,
              monospace: true,
            ),
            const SizedBox(height: 16),
          ],

          SectionLabel(
            'Dispensing & Returns',
            padding: const EdgeInsets.only(top: 4, bottom: 8),
          ),
          SgtinPharmaInfoRow(
            'Return Status',
            ext.returnStatus.displayName,
            valueColor: _returnColor(context, ext.returnStatus),
          ),
          if (ext.dispenseEventId != null) ...[
            const SizedBox(height: 8),
            SgtinPharmaInfoRow(
              'Dispense Event ID',
              ext.dispenseEventId!,
              monospace: true,
            ),
          ],
          if (ext.dispenseGln != null) ...[
            const SizedBox(height: 8),
            SgtinPharmaInfoRow('Dispensing Location GLN', ext.dispenseGln!),
          ],
          const SizedBox(height: 16),

          SectionLabel(
            'Recall Status',
            padding: const EdgeInsets.only(top: 4, bottom: 8),
          ),
          SgtinPharmaBooleanRow(
            'Recall Affected',
            ext.recallAffectedFlag,
            trueColor: AppColorMapper.errorColor(context),
          ),
          if (ext.recallNotificationId != null) ...[
            const SizedBox(height: 8),
            SgtinPharmaInfoRow(
              'Recall Notification ID',
              ext.recallNotificationId!,
              monospace: true,
            ),
          ],
          const SizedBox(height: 16),

          SectionLabel(
            'Parallel Trade / Repackaging',
            padding: const EdgeInsets.only(top: 4, bottom: 8),
          ),
          SgtinPharmaInfoRow(
            'Parallel Trade Status',
            ext.parallelTradeStatus.displayName,
          ),
          if (ext.newSerialLinkage != null) ...[
            const SizedBox(height: 8),
            SgtinPharmaInfoRow(
              'New Serial Linkage',
              ext.newSerialLinkage!,
              monospace: true,
            ),
          ],
          if (ext.originalSgtinRef != null) ...[
            const SizedBox(height: 8),
            SgtinPharmaInfoRow(
              'Original SGTIN',
              ext.originalSgtinRef!,
              monospace: true,
            ),
          ],

          if (ext.protocolId != null || ext.trialSubjectLinkage != null) ...[
            const SizedBox(height: 16),
            SectionLabel(
              'Clinical Trial',
              padding: const EdgeInsets.only(top: 4, bottom: 8),
            ),
            if (ext.protocolId != null)
              SgtinPharmaInfoRow('Protocol ID', ext.protocolId!),
            if (ext.trialSubjectLinkage != null) ...[
              const SizedBox(height: 8),
              SgtinPharmaInfoRow(
                'Trial Subject Linkage',
                ext.trialSubjectLinkage!,
                monospace: true,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Color? _tamperColor(BuildContext context, SgtinAntiTamperStatus status) {
    switch (status) {
      case SgtinAntiTamperStatus.intact:
        return AppColorMapper.successColor(context);
      case SgtinAntiTamperStatus.broken:
      case SgtinAntiTamperStatus.missing:
        return AppColorMapper.errorColor(context);
      case SgtinAntiTamperStatus.notApplicable:
        return null;
    }
  }

  Color? _returnColor(BuildContext context, SgtinReturnStatus status) {
    switch (status) {
      case SgtinReturnStatus.notReturned:
        return null;
      case SgtinReturnStatus.returnPending:
        return AppColorMapper.warningColor(context);
      case SgtinReturnStatus.returnVerified:
        return AppColorMapper.successColor(context);
      case SgtinReturnStatus.returnRejected:
        return AppColorMapper.errorColor(context);
    }
  }

  Color? _submissionColor(BuildContext context, String? status) {
    switch (status?.toUpperCase()) {
      case 'ACKNOWLEDGED':
      case 'ACCEPTED':
        return AppColorMapper.successColor(context);
      case 'UPLOADED':
      case 'SUBMITTED':
        return AppColorMapper.infoColor(context);
      case 'PENDING':
        return AppColorMapper.warningColor(context);
      case 'REJECTED':
        return AppColorMapper.errorColor(context);
      default:
        return null;
    }
  }
}
