import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_epc_type_utils.dart';

class OperationReviewInfoRow extends StatelessWidget {
  const OperationReviewInfoRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class OperationReviewComplianceRow extends StatelessWidget {
  const OperationReviewComplianceRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final missing = value.trim().isEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(
            missing
                ? '⚠ Not provided — DSCSA requires the original GINC'
                : value,
            style: TextStyle(color: missing ? Colors.orange[700] : null),
          ),
        ),
      ],
    );
  }
}

class OperationReviewField {
  const OperationReviewField(this.label, this.value);

  final String label;
  final String value;
}


class OperationReviewOptionalFields extends StatelessWidget {
  const OperationReviewOptionalFields(this.fields, {super.key});

  final List<OperationReviewField> fields;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final field in fields)
          if (field.value.isNotEmpty) ...[
            const SizedBox(height: 12),
            OperationReviewInfoRow(field.label, field.value),
          ],
      ],
    );
  }
}

class OperationReviewStepHeader extends StatelessWidget {
  const OperationReviewStepHeader({
    super.key,
    required this.title,
    this.showPageHeader = true,
    this.subtitle = 'Please review all details before submitting.',
  });

  final String title;
  final bool showPageHeader;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title),
        if (showPageHeader) ...[
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

class OperationReviewGlnTransfer extends StatelessWidget {
  const OperationReviewGlnTransfer({
    super.key,
    required this.sourceLabel,
    required this.sourceGln,
    required this.destinationLabel,
    required this.destinationGln,
  });

  final String sourceLabel;
  final GLN? sourceGln;
  final String destinationLabel;
  final GLN? destinationGln;

  static TextStyle _locationNameStyle() =>
      TextStyle(color: Colors.grey[700], fontSize: 12);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OperationReviewInfoRow(sourceLabel, sourceGln?.glnCode ?? '-'),
        if (sourceGln?.locationName.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(sourceGln!.locationName, style: _locationNameStyle()),
          ),
        const SizedBox(height: 12),
        const Center(child: TraqIcon(AppAssets.iconArrowD, size: 20)),
        const SizedBox(height: 12),
        OperationReviewInfoRow(
          destinationLabel,
          destinationGln?.glnCode ?? '-',
        ),
        if (destinationGln?.locationName.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              destinationGln!.locationName,
              style: _locationNameStyle(),
            ),
          ),
      ],
    );
  }
}


class OperationReviewEpcBadgeList extends StatelessWidget {
  const OperationReviewEpcBadgeList({
    super.key,
    required this.epcs,
    required this.outlineColor,
    this.titlePrefix = 'EPC List',
    this.emptyMessage = 'No EPCs added yet',
  });

  final List<String> epcs;
  final Color outlineColor;
  final String titlePrefix;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: '$titlePrefix (${epcs.length})',
      outlineColor: outlineColor,
      child: epcs.isEmpty
          ? Text(emptyMessage)
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: epcs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final epc = epcs[index];
                final badgeColor = OperationEpcTypeUtils.colorFromValue(epc);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            epc,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: badgeColor.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              OperationEpcTypeUtils.labelFromValue(epc),
                              style: TextStyle(
                                color: badgeColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
