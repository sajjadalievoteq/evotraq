import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

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
              _infoRow(context, 'Reporting Regimes',
                  ext.reportingRegimes.join(' • ')),
            if (ext.emvoUploadStatus != null) ...[
              const SizedBox(height: 8),
              _infoRow(context, 'EMVO Upload Status',
                  ext.emvoUploadStatus!,
                  valueColor: _submissionColor(ext.emvoUploadStatus)),
            ],
            if (ext.tatmeenSubmissionStatus != null) ...[
              const SizedBox(height: 8),
              _infoRow(context, 'Tatmeen Submission',
                  ext.tatmeenSubmissionStatus!,
                  valueColor: _submissionColor(ext.tatmeenSubmissionStatus)),
            ],
            if (ext.dscsaTransactionHash != null) ...[
              const SizedBox(height: 8),
              _infoRow(context, 'DSCSA Transaction Hash',
                  ext.dscsaTransactionHash!,
                  monospace: true),
            ],
            const SizedBox(height: 16),
          ],

          SectionLabel(
            'Cold Chain Monitoring',
            padding: const EdgeInsets.only(top: 4, bottom: 8),
          ),
          _boolRow(context, 'Cold Chain Excursion', ext.coldChainExcursionFlag,
              trueColor: Colors.red.shade600),
          if (ext.tempMinRecorded != null) ...[
            const SizedBox(height: 8),
            _infoRow(context, 'Min Temp Recorded',
                '${ext.tempMinRecorded!.toStringAsFixed(2)} °C'),
          ],
          if (ext.tempMaxRecorded != null) ...[
            const SizedBox(height: 8),
            _infoRow(context, 'Max Temp Recorded',
                '${ext.tempMaxRecorded!.toStringAsFixed(2)} °C'),
          ],
          if (ext.lastSensorEventId != null) ...[
            const SizedBox(height: 8),
            _infoRow(context, 'Last Sensor Event ID',
                ext.lastSensorEventId!,
                monospace: true),
          ],
          const SizedBox(height: 16),

          SectionLabel(
            'Anti-Counterfeit & Tamper Evidence',
            padding: const EdgeInsets.only(top: 4, bottom: 8),
          ),
          _infoRow(context, 'Anti-Tamper Seal Status',
              ext.antiTamperStatus.displayName,
              valueColor: _tamperColor(ext.antiTamperStatus)),
          if (ext.fraudScore != null) ...[
            const SizedBox(height: 8),
            _infoRow(context, 'Fraud Risk Score',
                ext.fraudScore!.toStringAsFixed(2),
                valueColor: ext.fraudScore! > 0.5 ? Colors.red.shade600 : null),
          ],
          if (ext.duplicateEvidenceCount > 0) ...[
            const SizedBox(height: 8),
            _infoRow(context, 'Duplicate Evidence Records',
                ext.duplicateEvidenceCount.toString(),
                valueColor: Colors.deepOrange.shade600),
          ],
          const SizedBox(height: 16),

          if (ext.controlledCustodyRef != null) ...[
            SectionLabel(
              'Controlled Substances',
              padding: const EdgeInsets.only(top: 4, bottom: 8),
            ),
            _infoRow(context, 'Custody Reference',
                ext.controlledCustodyRef!,
                monospace: true),
            const SizedBox(height: 16),
          ],

          SectionLabel(
            'Dispensing & Returns',
            padding: const EdgeInsets.only(top: 4, bottom: 8),
          ),
          _infoRow(context, 'Return Status',
              ext.returnStatus.displayName,
              valueColor: _returnColor(ext.returnStatus)),
          if (ext.dispenseEventId != null) ...[
            const SizedBox(height: 8),
            _infoRow(context, 'Dispense Event ID',
                ext.dispenseEventId!,
                monospace: true),
          ],
          if (ext.dispenseGln != null) ...[
            const SizedBox(height: 8),
            _infoRow(context, 'Dispensing Location GLN', ext.dispenseGln!),
          ],
          const SizedBox(height: 16),

          SectionLabel(
            'Recall Status',
            padding: const EdgeInsets.only(top: 4, bottom: 8),
          ),
          _boolRow(context, 'Recall Affected', ext.recallAffectedFlag,
              trueColor: Colors.red.shade700),
          if (ext.recallNotificationId != null) ...[
            const SizedBox(height: 8),
            _infoRow(context, 'Recall Notification ID',
                ext.recallNotificationId!,
                monospace: true),
          ],
          const SizedBox(height: 16),

          SectionLabel(
            'Parallel Trade / Repackaging',
            padding: const EdgeInsets.only(top: 4, bottom: 8),
          ),
          _infoRow(context, 'Parallel Trade Status',
              ext.parallelTradeStatus.displayName),
          if (ext.newSerialLinkage != null) ...[
            const SizedBox(height: 8),
            _infoRow(context, 'New Serial Linkage',
                ext.newSerialLinkage!,
                monospace: true),
          ],
          if (ext.originalSgtinRef != null) ...[
            const SizedBox(height: 8),
            _infoRow(context, 'Original SGTIN',
                ext.originalSgtinRef!,
                monospace: true),
          ],

          if (ext.protocolId != null || ext.trialSubjectLinkage != null) ...[
            const SizedBox(height: 16),
            SectionLabel(
              'Clinical Trial',
              padding: const EdgeInsets.only(top: 4, bottom: 8),
            ),
            if (ext.protocolId != null)
              _infoRow(context, 'Protocol ID', ext.protocolId!),
            if (ext.trialSubjectLinkage != null) ...[
              const SizedBox(height: 8),
              _infoRow(context, 'Trial Subject Linkage',
                  ext.trialSubjectLinkage!,
                  monospace: true),
            ],
          ],
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool monospace = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 190,
          child: Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor ?? theme.colorScheme.onSurface,
              fontFamily: monospace ? 'monospace' : null,
              fontWeight: valueColor != null ? FontWeight.w600 : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _boolRow(
    BuildContext context,
    String label,
    bool value, {
    Color? trueColor,
    Color? falseColor,
  }) {
    final theme = Theme.of(context);
    final color = value
        ? (trueColor ?? Colors.green.shade700)
        : (falseColor ?? Colors.grey);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 190,
          child: Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        TraqIcon(
          value ? AppAssets.iconCheckCircle : AppAssets.iconXCircle,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          value ? 'Yes' : 'No',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color? _tamperColor(SgtinAntiTamperStatus status) {
    switch (status) {
      case SgtinAntiTamperStatus.intact:
        return Colors.green.shade700;
      case SgtinAntiTamperStatus.broken:
      case SgtinAntiTamperStatus.missing:
        return Colors.red.shade700;
      case SgtinAntiTamperStatus.notApplicable:
        return null;
    }
  }

  Color? _returnColor(SgtinReturnStatus status) {
    switch (status) {
      case SgtinReturnStatus.notReturned:
        return null;
      case SgtinReturnStatus.returnPending:
        return Colors.orange.shade700;
      case SgtinReturnStatus.returnVerified:
        return Colors.green.shade700;
      case SgtinReturnStatus.returnRejected:
        return Colors.red.shade700;
    }
  }

  Color? _submissionColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'ACKNOWLEDGED':
      case 'ACCEPTED':
        return Colors.green.shade700;
      case 'UPLOADED':
      case 'SUBMITTED':
        return Colors.teal.shade600;
      case 'PENDING':
        return Colors.orange.shade700;
      case 'REJECTED':
        return Colors.red.shade700;
      default:
        return null;
    }
  }
}
