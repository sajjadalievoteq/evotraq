import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

import '../../../../core/utils/responsive_utils.dart';

/// Step 3 of the commissioning wizard — review all entered data before submit.
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

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final gtinDisplay = selectedGTIN != null
        ? '${selectedGTIN!.gtinCode} - ${selectedGTIN!.productName ?? 'Unknown'}'
        : gtinController.text;

    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      padding: ResponsiveUtils.paddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Review Commissioning Operation'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReviewRow(label: 'GTIN', value: gtinDisplay),
                  const Divider(),
                  _ReviewRow(label: 'Batch/Lot', value: batchLotController.text),
                  const Divider(),
                  _ReviewRow(
                    label: 'Location',
                    value: commissioningLocationGLN?.locationName ??
                        commissioningLocationGLN?.glnCode ??
                        '-',
                  ),
                  if (referenceController.text.isNotEmpty) ...[
                    const Divider(),
                    _ReviewRow(label: 'Reference', value: referenceController.text),
                  ],
                  if (productionDate != null) ...[
                    const Divider(),
                    _ReviewRow(
                      label: 'Production Date',
                      value: _formatDate(productionDate!),
                    ),
                  ],
                  if (expiryDate != null) ...[
                    const Divider(),
                    _ReviewRow(
                      label: 'Expiry Date',
                      value: _formatDate(expiryDate!),
                    ),
                  ],
                  if (bestBeforeDate != null) ...[
                    const Divider(),
                    _ReviewRow(
                      label: 'Best Before',
                      value: _formatDate(bestBeforeDate!),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_2),
                      const SizedBox(width: 8),
                      Text(
                        'Serial Numbers (${serialNumbers.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
         if(serialNumbers.isNotEmpty)         Column(
                    children: [
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: serialNumbers.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text(
                                  '${index + 1}. ',
                                  style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Expanded(child: Text(serialNumbers[index])),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
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
                  Icon(Icons.info, color: Colors.blue[700]),
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

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
