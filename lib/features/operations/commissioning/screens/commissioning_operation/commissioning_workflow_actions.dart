import 'dart:async';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/commissioning_identification_actions.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/commissioning_operation_view.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_clear_serials_dialog.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_field_validators.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_serial_pool_status.dart';

extension CommissioningWorkflowActions on CommissioningOperationViewState {
  Future<void> nextStep() async {
    if (currentStep < 2 && await _validateCurrentStep()) {
      await pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> previousStep() async {
    if (currentStep > 0) {
      await pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<bool> validateDetailsStep() async {
    setState(() => locationError = null);
    final formValid = step1FormKey.currentState?.validate() ?? false;
    var isValid = formValid;
    if (commissioningLocationGLN == null) {
      setState(() => locationError = 'Commissioning Location is required');
      isValid = false;
    }
    return isValid;
  }

  Future<bool> validateItemsStep() async {
    if (commissionItems.isEmpty) {
      context.showError('At least one EPC is required');
      return false;
    }
    final blocking = commissionItems
        .where((i) => i.poolStatus.blocksCommissioning)
        .map((i) => i.displayKey)
        .toList();
    if (blocking.isNotEmpty) {
      context.showError(
        'Remove blocked EPC(s): ${blocking.take(3).join(', ')}',
      );
      return false;
    }
    final checking = commissionItems
        .where((i) => i.poolStatus == CommissioningSerialPoolStatus.checking)
        .length;
    if (checking > 0) {
      context.showWarning('Pool check still running — wait and retry.');
      return false;
    }
    if (identifiedType == EPCType.sgtin) {
      final gtinCode = resolvedGtinCode();
      if (gtinCode == null || gtinCode.isEmpty) {
        context.showError(
          'Could not determine GTIN from the scanned identifier',
        );
        return false;
      }
      final formValid = step2FormKey.currentState?.validate() ?? true;
      if (!formValid) return false;
      final batchErr =
          CommissioningFieldValidators.validateBatchLotNumberRequired(
            batchLotController.text,
          );
      if (batchErr != null) {
        context.showError(batchErr);
        return false;
      }
      if (isPharmaSgtin && expiryDate == null) {
        context.showError(
          'Expiry Date is required for pharmaceutical commissioning',
        );
        return false;
      }
    }
    return true;
  }

  Future<bool> _validateCurrentStep() async {
    switch (currentStep) {
      case 0:
        return validateDetailsStep();
      case 1:
        return validateItemsStep();
      default:
        return true;
    }
  }

  void removeItem(int index) {
    setState(() {
      if (index == 0 && commissionItems.length == 1) {
        _resetIdentification();
      } else {
        poolCheckCache.remove(commissionItems[index].epc);
        commissionItems.removeAt(index);
      }
    });
  }

  void _resetIdentification() {
    identifiedType = null;
    primaryParsed = null;
    isPharmaGtin = false;
    guessabilityWarning = null;
    selectedGTIN = null;
    gtinLoadInFlightFor = null;
    pharmaGtinIdentifiedFor = null;
    poolCheckCache.clear();
    commissionItems.clear();
  }

  Future<void> clearAllItems() async {
    final confirmed = await CommissioningClearSerialsDialog.show(
      context,
      commissionItems.length,
    );
    if (confirmed == true) {
      setState(_resetIdentification);
    }
  }

  Future<void> selectDate(String dateType) async {
    final now = DateTime.now();
    final initialDate = switch (dateType) {
      'production' => productionDate ?? now,
      'expiry' => expiryDate ?? now.add(const Duration(days: 365)),
      _ => bestBeforeDate ?? now.add(const Duration(days: 180)),
    };
    final label = switch (dateType) {
      'production' => 'Production',
      'expiry' => 'Expiry',
      _ => 'Best Before',
    };

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: dateType == 'production' ? DateTime(now.year - 2) : now,
      lastDate: DateTime(now.year + 10),
      helpText: 'Select $label Date',
    );

    if (selected != null) {
      setState(() {
        switch (dateType) {
          case 'production':
            productionDate = selected;
            productionDateManuallySet = true;
          case 'expiry':
            expiryDate = selected;
            expiryManuallySet = true;
          case 'bestBefore':
            bestBeforeDate = selected;
        }
      });
    }
  }

  void clearDate(String dateType) {
    setState(() {
      switch (dateType) {
        case 'production':
          productionDate = null;
          productionDateManuallySet = false;
        case 'expiry':
          expiryDate = null;
          expiryManuallySet = false;
        case 'bestBefore':
          bestBeforeDate = null;
      }
    });
  }

  SsccCommissioningRequest buildSsccCommissioningRequest() {
    final readPoint = readPointGlnController.text.trim();
    return SsccCommissioningRequest(
      commissioningReference: referenceController.text.trim().isNotEmpty
          ? referenceController.text.trim()
          : null,
      epcUris: commissionItems.map((i) => i.epc).toList(),
      commissioningLocationGLN: commissioningLocationGLN!.glnCode,
      readPointGLN: readPoint.isNotEmpty ? readPoint : null,
      operatorId: operatorIdController.text.trim().isNotEmpty
          ? operatorIdController.text.trim()
          : null,
      notes: notesController.text.trim().isNotEmpty
          ? notesController.text.trim()
          : null,
      countryOfOrigin: countryOfOriginController.text.trim().isNotEmpty
          ? countryOfOriginController.text.trim().toUpperCase()
          : null,

      childEpcUris: null,
    );
  }

  CommissioningRequest buildCommissioningRequest() {
    final serials = commissionItems
        .where((i) => i.type == EPCType.sgtin)
        .map((i) => i.parsed.serial!)
        .toList();
    final gtinCode = resolvedGtinCode() ?? '';
    final readPoint = readPointGlnController.text.trim();

    return CommissioningRequest(
      gtinCode: gtinCode,
      serialNumbers: serials,
      batchLotNumber: batchLotController.text.trim(),
      commissioningLocationGLN: commissioningLocationGLN!.glnCode,
      expiryDate: expiryDate,
      productionDate: productionDate,
      bestBeforeDate: bestBeforeDate,
      commissioningReference: referenceController.text.trim().isNotEmpty
          ? referenceController.text.trim()
          : null,
      operatorId: operatorIdController.text.trim().isNotEmpty
          ? operatorIdController.text.trim()
          : null,
      comments: notesController.text.trim().isNotEmpty
          ? notesController.text.trim()
          : null,
      countryOfOrigin: countryOfOriginController.text.trim().isNotEmpty
          ? countryOfOriginController.text.trim().toUpperCase()
          : null,
      productionOrder: productionOrderController.text.trim().isNotEmpty
          ? productionOrderController.text.trim()
          : null,
      productionLine: productionLineController.text.trim().isNotEmpty
          ? productionLineController.text.trim()
          : null,
      regulatoryMarket: regulatoryMarketController.text.trim().isNotEmpty
          ? regulatoryMarketController.text.trim()
          : null,
      regulatoryStatus: regulatoryStatusController.text.trim().isNotEmpty
          ? regulatoryStatusController.text.trim()
          : null,
      readPointGLN: readPoint.isNotEmpty ? readPoint : null,
      identifierType: identifiedType?.name,
      canonicalIdentifiers: commissionItems.map((i) => i.epc).toList(),
    );
  }
}
