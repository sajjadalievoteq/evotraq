import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_additional_info_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_auto_reference_notice.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_gln_selector.dart';

class CommissioningStep1ProductDetails extends StatelessWidget {
  const CommissioningStep1ProductDetails({
    super.key,
    required this.commissioningLocationGLN,
    required this.locationError,
    required this.onLocationChanged,
    required this.referenceController,
    required this.countryOfOriginController,
    required this.productionOrderController,
    required this.productionLineController,
    required this.regulatoryMarketController,
    required this.regulatoryStatusController,
    required this.operatorIdController,
    required this.notesController,
    required this.readPointGlnController,
    this.pickerCatalog,
    this.showPageHeader = true,
  });

  final GLN? commissioningLocationGLN;
  final String? locationError;
  final ValueChanged<GLN?> onLocationChanged;
  final List<GLN>? pickerCatalog;
  final TextEditingController referenceController;
  final TextEditingController countryOfOriginController;
  final TextEditingController productionOrderController;
  final TextEditingController productionLineController;
  final TextEditingController regulatoryMarketController;
  final TextEditingController regulatoryStatusController;
  final TextEditingController operatorIdController;
  final TextEditingController notesController;
  final TextEditingController readPointGlnController;
  final bool showPageHeader;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.padding.top,
        context.padding.top,
        context.padding.top,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showPageHeader) ...[
            const Text(
              'Commissioning Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Specify location and optional reference information.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
          ],
          Gs1GroupCard(
            title: 'Operation Reference',
            outlineColor: outline,
            child: Column(
              children: [
                const OperationAutoReferenceNotice(
                  operationLabel: 'Commissioning',
                ),
                const SizedBox(height: 16),
                Gs1ValidatedField(
                  controller: referenceController,
                  fieldName: 'commissioningReference',
                  label: 'Commissioning Reference',
                  hintText: 'Enter reference (optional)',
                  validator: CommissioningFieldValidators
                      .validateCommissioningReferenceOptional,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Gs1GroupCard(
            title: 'Location',
            showRequiredStar: true,
            outlineColor: outline,
            child: OperationGlnSelector(
              label: 'Commissioning Location GLN',
              hintText: 'Search and select commissioning location',
              gln: commissioningLocationGLN,
              errorText: locationError,
              onChanged: onLocationChanged,
              pickerCatalog: pickerCatalog,
            ),
          ),
          const SizedBox(height: 16),
          CommissioningAdditionalInfoCard(
            countryOfOriginController: countryOfOriginController,
            productionOrderController: productionOrderController,
            productionLineController: productionLineController,
            regulatoryMarketController: regulatoryMarketController,
            regulatoryStatusController: regulatoryStatusController,
            operatorIdController: operatorIdController,
            notesController: notesController,
            readPointGlnController: readPointGlnController,
          ),
        ],
      ),
    );
  }
}
