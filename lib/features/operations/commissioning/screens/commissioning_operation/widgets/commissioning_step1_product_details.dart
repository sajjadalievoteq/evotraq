import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_batch.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_batch_lookup_status.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_additional_info_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_dates_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_location_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_product_info_card.dart';

class CommissioningStep1ProductDetails extends StatelessWidget {
  const CommissioningStep1ProductDetails({
    super.key,
    required this.gtinController,
    required this.availableGTINs,
    required this.selectedGTIN,
    required this.gtinError,
    required this.isLoadingGTINs,
    required this.onGtinChanged,
    required this.commissioningLocationGLN,
    required this.locationError,
    required this.onLocationChanged,
    required this.availableLocations,
    required this.batchLotController,
    required this.referenceController,
    required this.expiryDate,
    required this.productionDate,
    required this.bestBeforeDate,
    required this.countryOfOriginController,
    required this.productionOrderController,
    required this.productionLineController,
    required this.regulatoryMarketController,
    required this.regulatoryStatusController,
    required this.operatorIdController,
    required this.notesController,
    required this.onSelectDate,
    required this.onClearDate,
    required this.onBatchLotEditingComplete,
    required this.onBatchLotFocusLost,
    required this.registrationQuantityController,
    required this.onSelectRegistrationDate,
    required this.onClearRegistrationDate,
    required this.onRegisterBatch,
    required this.onToggleRegistrationPanel,
    this.showPharmaBatchLookup = false,
    this.batchLookupStatus = CommissioningBatchLookupStatus.idle,
    this.resolvedBatch,
    this.batchLookupError,
    this.registrationPanelExpanded = false,
    this.registrationExpiryDate,
    this.registrationManufactureDate,
    this.isBatchRegistering = false,
    this.onScanProductBarcode,
  });

  final TextEditingController gtinController;
  final List<GTIN> availableGTINs;
  final GTIN? selectedGTIN;
  final String? gtinError;
  final bool isLoadingGTINs;
  final ValueChanged<GTIN?> onGtinChanged;
  final GLN? commissioningLocationGLN;
  final String? locationError;
  final ValueChanged<GLN?> onLocationChanged;
  final List<GLN> availableLocations;
  final TextEditingController batchLotController;
  final TextEditingController referenceController;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;
  final TextEditingController countryOfOriginController;
  final TextEditingController productionOrderController;
  final TextEditingController productionLineController;
  final TextEditingController regulatoryMarketController;
  final TextEditingController regulatoryStatusController;
  final TextEditingController operatorIdController;
  final TextEditingController notesController;
  final ValueChanged<String> onSelectDate;
  final ValueChanged<String> onClearDate;
  final VoidCallback onBatchLotEditingComplete;
  final VoidCallback onBatchLotFocusLost;
  final TextEditingController registrationQuantityController;
  final ValueChanged<String> onSelectRegistrationDate;
  final ValueChanged<String> onClearRegistrationDate;
  final VoidCallback onRegisterBatch;
  final ValueChanged<bool> onToggleRegistrationPanel;
  final bool showPharmaBatchLookup;
  final CommissioningBatchLookupStatus batchLookupStatus;
  final GtinBatch? resolvedBatch;
  final String? batchLookupError;
  final bool registrationPanelExpanded;
  final DateTime? registrationExpiryDate;
  final DateTime? registrationManufactureDate;
  final bool isBatchRegistering;
  final VoidCallback? onScanProductBarcode;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: ResponsiveUtils.paddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommissioningProductInfoCard(
            availableGTINs: availableGTINs,
            selectedGTIN: selectedGTIN,
            gtinError: gtinError,
            isLoadingGTINs: isLoadingGTINs,
            gtinController: gtinController,
            onGtinChanged: onGtinChanged,
            batchLotController: batchLotController,
            referenceController: referenceController,
            onScanProductBarcode: onScanProductBarcode,
            onBatchLotEditingComplete: onBatchLotEditingComplete,
            onBatchLotFocusLost: onBatchLotFocusLost,
            showPharmaBatchLookup: showPharmaBatchLookup,
            batchLookupStatus: batchLookupStatus,
            resolvedBatch: resolvedBatch,
            batchLookupError: batchLookupError,
            registrationPanelExpanded: registrationPanelExpanded,
            registrationExpiryDate: registrationExpiryDate,
            registrationManufactureDate: registrationManufactureDate,
            registrationQuantityController: registrationQuantityController,
            onSelectRegistrationDate: onSelectRegistrationDate,
            onClearRegistrationDate: onClearRegistrationDate,
            onRegisterBatch: onRegisterBatch,
            onToggleRegistrationPanel: onToggleRegistrationPanel,
            isBatchRegistering: isBatchRegistering,
          ),
          CommissioningLocationCard(
            commissioningLocationGLN: commissioningLocationGLN,
            locationError: locationError,
            onLocationChanged: onLocationChanged,
            pickerCatalog: availableLocations.isEmpty ? null : availableLocations,
          ),
          CommissioningDatesCard(
            productionDate: productionDate,
            expiryDate: expiryDate,
            bestBeforeDate: bestBeforeDate,
            onSelectDate: onSelectDate,
            onClearDate: onClearDate,
          ),
          CommissioningAdditionalInfoCard(
            countryOfOriginController: countryOfOriginController,
            productionOrderController: productionOrderController,
            productionLineController: productionLineController,
            regulatoryMarketController: regulatoryMarketController,
            regulatoryStatusController: regulatoryStatusController,
            operatorIdController: operatorIdController,
            notesController: notesController,
          ),
        ],
      ),
    );
  }
}
