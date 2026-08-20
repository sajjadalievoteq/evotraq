import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/navigation/pop_or_go.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/cubit/commissioning_operation_cubit.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/commissioning_identification_actions.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/commissioning_operation_view.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/commissioning_workflow_actions.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_partial_success_choice.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_partial_success_result.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_step1_product_details.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_step2_serial_numbers.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_step3_review.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_submit_error_message.dart';
import 'widgets/commissioning_partial_success_dialog.dart';

extension CommissioningSubmissionActions on CommissioningOperationViewState {
  void _syncItemsAfterPartialSuccess(
    CommissioningResponse response,
    CommissioningPartialSuccessResult dialogResult,
  ) {
    final results = response.itemResults ?? [];
    final successfulSerials = results
        .where((r) => r.success)
        .map((r) => r.serialNumber)
        .toSet();

    setState(() {
      commissionItems.removeWhere(
        (i) =>
            i.parsed.serial != null &&
            successfulSerials.contains(i.parsed.serial),
      );

      if (dialogResult.choice ==
          CommissioningPartialSuccessChoice.removeSelectedAndRetry) {
        commissionItems.removeWhere(
          (i) =>
              i.parsed.serial != null &&
              dialogResult.serialsMarkedForRemoval.contains(i.parsed.serial),
        );
      }
    });
  }

  Future<void> _handlePartialSuccess(CommissioningResponse response) async {
    final dialogResult = await showPartialSuccessDialog(context, response);
    if (!mounted || dialogResult == null) return;

    _syncItemsAfterPartialSuccess(response, dialogResult);

    final commissioned = response.commissionedCount ?? 0;
    final failed = response.failedCount ?? 0;

    switch (dialogResult.choice) {
      case CommissioningPartialSuccessChoice.acceptPartialSuccess:
        context.showSuccess(
          'Partial success: $commissioned commissioned, $failed failed',
        );
        if (mounted) popOrGo(context, Constants.opCommissioningRoute);
      case CommissioningPartialSuccessChoice.continueWithoutRemoving:
        context.showInfo(
          '${commissionItems.length} failed EPC(s) remain — review and submit again.',
        );
        setState(() => currentStep = 1);
        pageController.jumpToPage(1);
      case CommissioningPartialSuccessChoice.removeSelectedAndRetry:
        if (commissionItems.isEmpty) {
          context.showWarning('All failed EPCs were removed.');
          setState(() => currentStep = 1);
          pageController.jumpToPage(1);
          break;
        }
        context.showInfo('Retrying for ${commissionItems.length} EPC(s)...');
        await submit(isRetry: true);
    }
  }

  Future<void> submit({bool isRetry = false}) async {
    if (!await validateDetailsStep()) return;
    if (!await validateItemsStep()) return;

    setState(() => isLoading = true);

    try {
      final cubit = context.read<CommissioningOperationCubit>();
      final CommissioningResponse? response;

      if (identifiedType == EPCType.sscc) {
        response = await cubit.commissionSscc(buildSsccCommissioningRequest());
      } else {
        response = await cubit.commissionBulk(buildCommissioningRequest());
      }

      if (response == null) {
        context.showError(
          cubit.state.error ?? 'Failed to create commissioning operation',
        );
        return;
      }

      if (response.status == CommissioningStatus.success) {
        context.showSuccess(
          'Successfully commissioned ${response.commissionedCount} items',
        );
        if (mounted) popOrGo(context, Constants.opCommissioningRoute);
      } else if (response.status == CommissioningStatus.partialSuccess) {
        await _handlePartialSuccess(response);
      } else {
        context.showError(commissioningSubmitErrorMessage(response));
      }
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        applyApiRejectionResults(e);
        context.showError(e.getUserFriendlyMessage());
      } else {
        context.showError(e.getUserFriendlyMessage());
      }
    } catch (e) {
      context.showError('Error creating commissioning operation: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Form buildStep1({bool embeddedInPanel = false}) => Form(
    key: step1FormKey,
    child: CommissioningStep1ProductDetails(
      commissioningLocationGLN: commissioningLocationGLN,
      locationError: locationError,
      onLocationChanged: (gln) => setState(() {
        commissioningLocationGLN = gln;
        locationError = null;
      }),
      pickerCatalog: availableLocations.isEmpty ? null : availableLocations,
      referenceController: referenceController,
      countryOfOriginController: countryOfOriginController,
      productionOrderController: productionOrderController,
      productionLineController: productionLineController,
      regulatoryMarketController: regulatoryMarketController,
      regulatoryStatusController: regulatoryStatusController,
      operatorIdController: operatorIdController,
      notesController: notesController,
      readPointGlnController: readPointGlnController,
      showPageHeader: !embeddedInPanel,
    ),
  );

  CommissioningStep2SerialNumbers buildStep2({
    bool embeddedInPanel = false,
    bool fillHeight = false,
  }) => CommissioningStep2SerialNumbers(
    scannedEpcs: commissionItems.map((i) => i.epc).toList(),
    onItemAdded: onScanItemAdded,
    onRemoveItem: removeItem,
    onClearAll: clearAllItems,
    onParseFallback: epcFallbackResolve,
    embeddedInPanel: embeddedInPanel,
    fillHeight: fillHeight,
    identifiedType: identifiedType,
    stepFormKey: step2FormKey,
    batchLotController: batchLotController,
    expiryDate: expiryDate,
    productionDate: productionDate,
    bestBeforeDate: bestBeforeDate,
    onSelectDate: selectDate,
    onClearDate: clearDate,
    requireExpiry: isPharmaSgtin,
    itemProductNames: itemProductNames,
  );

  CommissioningStep3Review buildStep3() => CommissioningStep3Review(
    identifiedType: identifiedType,
    primaryParsed: primaryParsed,
    batchLotController: batchLotController,
    referenceController: referenceController,
    commissioningLocationGLN: commissioningLocationGLN,
    readPointGln: readPointGlnController.text.trim().isNotEmpty
        ? readPointGlnController.text.trim()
        : null,
    productionDate: productionDate,
    expiryDate: expiryDate,
    bestBeforeDate: bestBeforeDate,
    items: commissionItems,
    countryOfOrigin: countryOfOriginController.text.trim(),
    productionOrder: productionOrderController.text.trim(),
    productionLine: productionLineController.text.trim(),
    regulatoryMarket: regulatoryMarketController.text.trim(),
    regulatoryStatus: regulatoryStatusController.text.trim(),
    operatorId: operatorIdController.text.trim(),
  );
}
