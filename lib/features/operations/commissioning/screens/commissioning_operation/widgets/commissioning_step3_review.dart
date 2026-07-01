import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:intl/intl.dart';

import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class CommissioningStep3Review extends StatelessWidget {
  const CommissioningStep3Review({
    super.key,
    required this.selectedGTIN,
    required this.gtinController,
    required this.batchLotController,
    required this.referenceController,
    required this.commissioningLocationGLN,
    required this.productionDate,
    required this.expiryDate,
    required this.bestBeforeDate,
    required this.serialNumbers,
    this.countryOfOrigin,
    this.productionOrder,
    this.productionLine,
    this.regulatoryMarket,
    this.regulatoryStatus,
    this.operatorId,
  });

  final GTIN? selectedGTIN;
  final TextEditingController gtinController;
  final TextEditingController batchLotController;
  final TextEditingController referenceController;
  final GLN? commissioningLocationGLN;
  final DateTime? productionDate;
  final DateTime? expiryDate;
  final DateTime? bestBeforeDate;
  final List<String> serialNumbers;
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
    final gtinDisplay = selectedGTIN != null
        ? '${selectedGTIN!.gtinCode} - ${selectedGTIN!.productName}'
        : gtinController.text;

    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
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
                SgtinInfoRow('GTIN', gtinDisplay),
                const SizedBox(height: 12),
                SgtinInfoRow('Batch/Lot', batchLotController.text),
                const SizedBox(height: 12),
                SgtinInfoRow(
                  'Location',
                  commissioningLocationGLN?.locationName ??
                      commissioningLocationGLN?.glnCode,
                ),
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
                  SgtinInfoRow(
                    'Expiry Date',
                    _dateFormat.format(expiryDate!),
                  ),
                ],
                if (bestBeforeDate != null) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow(
                    'Best Before',
                    _dateFormat.format(bestBeforeDate!),
                  ),
                ],
                if (countryOfOrigin != null &&
                    countryOfOrigin!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SgtinInfoRow('Country of Origin', countryOfOrigin),
                ],
                if (productionOrder != null &&
                    productionOrder!.isNotEmpty) ...[
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
            title: 'Serial Numbers (${serialNumbers.length})',
            outlineColor: outline,
            child: serialNumbers.isEmpty
                ? const SgtinInfoRow('Serial Numbers', 'None added yet')
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: serialNumbers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => SgtinInfoRow(
                        '${index + 1}',
                        serialNumbers[index],
                        monospace: true,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 24),
       if(serialNumbers.isNotEmpty)   Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TraqIcon(AppAssets.iconInfo, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Submitting will create ${serialNumbers.length} SGTIN(s) with status '
                      '"COMMISSIONED" and generate corresponding ObjectEvent(s) for EPCIS 2.0 compliance.',
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
