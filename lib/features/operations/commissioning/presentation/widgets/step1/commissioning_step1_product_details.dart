import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step1/commissioning_additional_info_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step1/commissioning_dates_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step1/commissioning_location_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/step1/commissioning_product_info_card.dart';

/// Step 1 of the commissioning wizard — product info, location, dates and
/// optional ILMD / regulatory fields.
class CommissioningStep1ProductDetails extends StatelessWidget {
  const CommissioningStep1ProductDetails({
    super.key,
    required this.availableGTINs,
    required this.selectedGTIN,
    required this.gtinError,
    required this.isLoadingGTINs,
    required this.gtinController,
    required this.batchLotController,
    required this.referenceController,
    required this.commissioningLocationGLN,
    required this.locationError,
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
    required this.onGtinChanged,
    required this.onLocationChanged,
    required this.onSelectDate,
    required this.onClearDate,
    this.onScanProductBarcode,
  });

  final List<GTIN> availableGTINs;
  final GTIN? selectedGTIN;
  final String? gtinError;
  final bool isLoadingGTINs;

  final TextEditingController gtinController;
  final TextEditingController batchLotController;
  final TextEditingController referenceController;

  final GLN? commissioningLocationGLN;
  final String? locationError;

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

  final ValueChanged<GTIN?> onGtinChanged;
  final ValueChanged<GLN?> onLocationChanged;
  final ValueChanged<String> onSelectDate;
  final ValueChanged<String> onClearDate;

  /// Called when the user taps the "Scan Barcode" button on Step 1.
  /// The parent screen opens the scanner and applies the result.
  final VoidCallback? onScanProductBarcode;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
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
            batchLotController: batchLotController,
            referenceController: referenceController,
            onGtinChanged: onGtinChanged,
            onScanProductBarcode: onScanProductBarcode,
          ),
          CommissioningLocationCard(
            commissioningLocationGLN: commissioningLocationGLN,
            locationError: locationError,
            onLocationChanged: onLocationChanged,
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
