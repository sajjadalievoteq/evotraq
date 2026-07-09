import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/operations/commissioning/models/commissioning_epc_item.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_epcis_preview_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_status.dart';
import 'package:intl/intl.dart';

class CommissioningStep3Review extends StatelessWidget {
  const CommissioningStep3Review({
    super.key,
    required this.identifiedType,
    required this.primaryParsed,
    required this.batchLotController,
    required this.referenceController,
    required this.commissioningLocationGLN,
    required this.readPointGln,
    required this.productionDate,
    required this.expiryDate,
    required this.bestBeforeDate,
    required this.items,
    this.countryOfOrigin,
    this.productionOrder,
    this.productionLine,
    this.regulatoryMarket,
    this.regulatoryStatus,
    this.operatorId,
  });

  final EPCType? identifiedType;
  final EPCParseResult? primaryParsed;
  final TextEditingController batchLotController;
  final TextEditingController referenceController;
  final GLN? commissioningLocationGLN;
  final String? readPointGln;
  final DateTime? productionDate;
  final DateTime? expiryDate;
  final DateTime? bestBeforeDate;
  final List<CommissioningEpcItem> items;
  final String? countryOfOrigin;
  final String? productionOrder;
  final String? productionLine;
  final String? regulatoryMarket;
  final String? regulatoryStatus;
  final String? operatorId;

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final poolCount = items
        .where((i) => i.poolStatus == CommissioningSerialPoolStatus.preReserved)
        .length;
    final typeLabel = identifiedType?.name.toUpperCase() ?? '—';

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: ResponsiveUtils.paddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Review Commissioning Operation'),
          const SizedBox(height: 8),
          Gs1GroupCard(
            title: 'Operation Details',
            outlineColor: outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SgtinInfoRow('Identifier type', typeLabel),
                if (primaryParsed?.gtin != null) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow('GTIN', primaryParsed!.gtin!),
                ],
                if (primaryParsed?.sscc != null) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow('SSCC', primaryParsed!.sscc!),
                ],
                if (identifiedType == EPCType.sgtin) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow('Batch/Lot', batchLotController.text),
                ],
                const SizedBox(height: 12),
                SgtinInfoRow(
                  'Location',
                  commissioningLocationGLN?.locationName ??
                      commissioningLocationGLN?.glnCode,
                ),
                if (readPointGln != null && readPointGln!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow('Read Point GLN', readPointGln),
                ],
                if (referenceController.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow('Reference', referenceController.text),
                ],
                if (productionDate != null) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow(
                    'Production Date',
                    _dateFormat.format(productionDate!),
                  ),
                ],
                if (expiryDate != null) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow('Expiry Date', _dateFormat.format(expiryDate!)),
                ],
                if (bestBeforeDate != null) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow(
                    'Best Before',
                    _dateFormat.format(bestBeforeDate!),
                  ),
                ],
                if (countryOfOrigin != null && countryOfOrigin!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow('Country of Origin', countryOfOrigin),
                ],
                if (productionOrder != null && productionOrder!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow('Production Order', productionOrder),
                ],
                if (productionLine != null && productionLine!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow('Production Line', productionLine),
                ],
                if (regulatoryMarket != null &&
                    regulatoryMarket!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow('Regulatory Market', regulatoryMarket),
                ],
                if (regulatoryStatus != null &&
                    regulatoryStatus!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow('Regulatory Status', regulatoryStatus),
                ],
                if (operatorId != null && operatorId!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow('Operator ID', operatorId),
                ],
              ],
            ),
          ),
          Gs1GroupCard(
            title: 'EPCs to commission (${items.length})',
            outlineColor: outline,
            child: items.isEmpty
                ? const SgtinInfoRow('EPCs', 'None added yet')
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return SgtinInfoRow(
                          '${index + 1}',
                          '${item.epc}\n'
                          '${item.sourceStatus ?? '?'} → ${item.targetStatus ?? 'COMMISSIONED'}',
                          monospace: true,
                        );
                      },
                    ),
                  ),
          ),
          if (poolCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$poolCount pre-allocated from pool',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          CommissioningEpcisPreviewCard(
            items: items,
            bizLocationGln: commissioningLocationGLN?.glnCode,
            readPointGln: readPointGln,
            batchLot: batchLotController.text.trim(),
            expiryDate: expiryDate,
          ),
          const SizedBox(height: 24),
          if (items.isNotEmpty)
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    TraqIcon(AppAssets.iconInfo, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Submitting will transition ${items.length} '
                        '${typeLabel}(s) from pool to commissioned and emit '
                        'one GS1 EPCIS 2.0 ObjectEvent (action ADD, '
                        'bizStep commissioning).',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
