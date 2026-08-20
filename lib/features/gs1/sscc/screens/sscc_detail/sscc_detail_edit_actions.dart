import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/extensions/validation_feedback_extension.dart';
import 'package:traqtrace_app/core/utils/gs1_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_route_constants.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_pharmaceutical_extension_service.dart';
import 'package:traqtrace_app/features/barcode/widgets/dialog/gs1_barcode_scan.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/sscc_detail_actions.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/sscc_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/utils/sscc_input_mode.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharmaceutical_extension_actions.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_create_form_validation.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_edit_rules.dart'
    as edit_rules;
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_input_parser.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_validators.dart';
extension SSCCDetailEditActions on SSCCDetailScreenState {
  void setFieldError(String fieldName, String? error) {
    if (validationCubit.getFieldError(fieldName) == error) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      validationCubit.setFieldError(fieldName, error);
    });
  }
  Future<void> savePharmaExtensionIfNeeded(int? ssccId, String ssccCode) async {
    final pharmaState = pharmaExtensionKey.currentState;
    debugPrint(
      'SSCC Pharma extension check - state: ${pharmaState != null}, hasData: ${pharmaState?.hasData}',
    );
    if (pharmaState == null) {
      debugPrint(
        'Pharma extension widget not in tree (probably not in pharmaceutical mode)',
      );
      return;
    }
    if (!pharmaState.hasData) {
      debugPrint('No pharmaceutical extension data to save');
      return;
    }
    try {
      final extension = pharmaState.buildExtension(
        ssccId: ssccId,
        ssccCode: ssccCode,
      );
      debugPrint('Built pharma extension: ${extension != null}');
      if (extension != null) {
        final pharmaService = getIt<SSCCPharmaceuticalExtensionService>();
        await pharmaService.createBySsccCode(ssccCode, extension);
        debugPrint('SSCC Pharmaceutical extension saved for SSCC: $ssccCode');
      }
    } catch (e) {
      debugPrint('Error saving SSCC pharmaceutical extension: $e');
    }
  }
  void populateFormFields(SSCC sscc) {
    sscc = sscc;
    hydrateSsccDetailFields(sscc);
    issuingGln = sscc.issuingGLN;
    issuingGlnError = null;
    containedExpiry = sscc.containedExpiry;
    shipFromGln = _glnFromStoredCode(sscc.shipFromGln);
    shipToGln = _glnFromStoredCode(sscc.shipToGln);
    billToGln = _glnFromStoredCode(sscc.billToGln);
    shipForGln = _glnFromStoredCode(sscc.shipForGln);
    custodianGln = _glnFromStoredCode(sscc.currentCustodianGln);
    setState(() {
      unitType = sscc.unitType;
      status = sscc.status;
      contentHomogeneity = sscc.contentHomogeneity;
      serverTransitions = sscc.availableTransitions ?? const [];
      packingDate = sscc.packingDate;
      formFieldsHydrated = true;
    });

    if (sscc.id != null && serverTransitions.isEmpty) {
      _loadTransitions(sscc.id!);
    }
    loadAggregationLinks(sscc.ssccCode);
    loadedSsccKey = requestedSsccKey;
    applyGlnCatalogToFields();
    ensureGlnPickerCatalog();
    _enforceEditRouteIfNeeded(sscc);
  }

  void _enforceEditRouteIfNeeded(SSCC sscc) {
    if (editRedirectHandled || widget.isCreating || !widget.isEditing) {
      return;
    }
    if (edit_rules.canEditSsccRecord(sscc.status)) {
      return;
    }
    editRedirectHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.showInfo(edit_rules.readOnlyLifecycleMessage(sscc.status));
      if (widget.embedded) {
        return;
      }
      final code = sscc.ssccCode;
      if (code.isNotEmpty) {
        context.push(SsccRouteConstants.pathForSsccCode(code));
      }
    });
  }

  void applyGlnCatalogToFields() {
    if (glnPickerCatalog.isEmpty) return;
    setState(() {
      issuingGln = resolveGlnForPicker(
        code: issuingGln?.glnCode ?? sscc?.issuingGLN?.glnCode,
        fallback: issuingGln ?? sscc?.issuingGLN,
        catalog: glnPickerCatalog,
      );
      shipFromGln = resolveGlnForPicker(
        code: shipFromGln?.glnCode ?? sscc?.shipFromGln,
        fallback: shipFromGln,
        catalog: glnPickerCatalog,
      );
      shipToGln = resolveGlnForPicker(
        code: shipToGln?.glnCode ?? sscc?.shipToGln,
        fallback: shipToGln,
        catalog: glnPickerCatalog,
      );
      billToGln = resolveGlnForPicker(
        code: billToGln?.glnCode ?? sscc?.billToGln,
        fallback: billToGln,
        catalog: glnPickerCatalog,
      );
      shipForGln = resolveGlnForPicker(
        code: shipForGln?.glnCode ?? sscc?.shipForGln,
        fallback: shipForGln,
        catalog: glnPickerCatalog,
      );
      custodianGln = resolveGlnForPicker(
        code: custodianGln?.glnCode ?? sscc?.currentCustodianGln,
        fallback: custodianGln,
        catalog: glnPickerCatalog,
      );
    });
  }

  Future<void> loadAggregationLinks(String ssccCode) {
    if (aggregationLinksRequestedCode == ssccCode &&
        aggregationLinksFuture != null) {
      return aggregationLinksFuture!;
    }
    aggregationLinksRequestedCode = ssccCode;
    final future = () async {
      final links = await cubit.fetchAggregationLinks(ssccCode);
      if (!mounted || aggregationLinksRequestedCode != ssccCode) return;
      setState(() => aggregationLinks = links);
    }();
    aggregationLinksFuture = future;
    return future;
  }

  Future<bool> addAggregationChild({
    required String childEpc,
    required String childKind,
    required String aggregationEventId,
  }) async {
    final ssccId = sscc?.id;
    if (ssccId == null) return false;

    final link = await cubit.addAggregationChild(
      ssccId: ssccId,
      childEpc: childEpc,
      childKind: childKind,
      aggregationEventId: aggregationEventId,
    );
    if (link != null && mounted) {
      await loadAggregationLinks(sscc!.ssccCode);
      context.showSuccess('Child aggregated successfully');
      return true;
    }
    return false;
  }

  Future<bool> disaggregateChild({
    required int linkId,
    required String disaggregationEventId,
  }) async {
    final ok = await cubit.disaggregateChild(
      linkId: linkId,
      disaggregationEventId: disaggregationEventId,
    );
    if (ok && mounted) {
      await loadAggregationLinks(sscc!.ssccCode);
      context.showSuccess('Child disaggregated');
    }
    return ok;
  }

  Future<void> _loadTransitions(String id) async {
    final transitions = await cubit.fetchAvailableTransitions(id);
    if (mounted && transitions.isNotEmpty) {
      setState(() => serverTransitions = transitions);
    }
  }

  Future<void> saveSSCC() async {
    if (widget.awaitingListSelection) return;

    if (!forceMountAllSections) {
      setState(() => forceMountAllSections = true);
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }

    setState(() {
      issuingGlnError = validateIssuingGlnRequired(issuingGln?.glnCode);
    });

    final validationErrors = SsccCreateFormValidation.collectErrors(
      isCreating: widget.isCreating,
      issuingGlnCode: issuingGln?.glnCode,
      extensionDigit: extensionDigitText(),
      ssccCodeRaw: ssccCodeText(),
      ssccMissingMessage: ssccCodeMissingMessage(),
      contentHomogeneity: contentHomogeneity,
      containedGtin: containedGtinText(),
      containedQuantity: containedQuantityText(),
      gsin: gsinText(),
      purchaseOrder: poText(),
    );

    formKey.currentState?.validate();

    validationErrors.addAll(
      SsccCreateFormValidation.collectFormFieldErrors(formKey),
    );

    if (validationErrors.isNotEmpty) {
      _scrollToFormTop();
      context.showValidationErrors(
        validationErrors,
        title: 'Cannot save SSCC — fix these fields',
      );
      return;
    }

    final now = DateTime.now();

    setState(() {
      hasSubmittedForm = true;
    });

    String gs1CompanyPrefix = '';
    String serialReference = '';
    String checkDigit = '';
    if (ssccCodeText().isNotEmpty) {
      var ssccCode =
          SsccInputParser.parseToSsccCode(ssccCodeText()) ??
          ssccCodeText().trim();

      if (ssccCode.length != 18) {
        final fixedSSCC = GS1Utils.validateAndFixSSCC(ssccCode);
        if (fixedSSCC != null) {
          ssccCode = fixedSSCC;
          setSsccFieldSeedOrController('ssccCode', ssccCode);
        } else {
          context.showValidationErrors([
            'SSCC Code: must be 18 digits or a valid GS1 (00) barcode (current: ${ssccCode.length} digits)',
          ], title: 'Cannot save SSCC — fix these fields');
          return;
        }
      }

      syncExtensionDigitFromSscc(ssccCode);

      gs1CompanyPrefix = ssccCode.substring(1, 8);
      serialReference = ssccCode.substring(8, 17);
      checkDigit = ssccCode.substring(17);
    } else {
      context.showValidationErrors([
        'SSCC Code: ${ssccCodeMissingMessage()}',
      ], title: 'Cannot save SSCC — fix these fields');
      return;
    }

    final containedQty = int.tryParse(containedQuantityText().trim());
    final identityLocked =
        !widget.isCreating &&
        sscc != null &&
        edit_rules.isSsccIdentityLocked(sscc!.status);
    final persistedStatus = sscc?.status ?? status;
    final saveStatus =
        edit_rules.canManuallyEditSsccStatus(
          persistedStatus,
          isCreating: widget.isCreating,
        )
        ? status
        : persistedStatus;

    final savedSscc = SSCC(
      id: widget.isCreating ? null : sscc?.id,
      ssccCode: identityLocked ? sscc!.ssccCode : ssccCodeText(),
      unitType: unitType,
      status: saveStatus,
      contentHomogeneity: contentHomogeneity,
      containedGtin: containedGtinText().trim().isEmpty
          ? null
          : containedGtinText().trim(),
      containedQuantity: containedQty,
      containedBatch: containedBatchText().trim().isEmpty
          ? null
          : containedBatchText().trim(),
      containedExpiry: containedExpiry,
      packingDate: packingDate,
      shipFromGln: _glnCodeOrNull(shipFromGln),
      shipToGln: _glnCodeOrNull(shipToGln),
      billToGln: _glnCodeOrNull(billToGln),
      shipForGln: _glnCodeOrNull(shipForGln),
      currentCustodianGln: _glnCodeOrNull(custodianGln),
      gsin: _trimOrNull(gsinText()),
      ginc: _trimOrNull(gincText()),
      purchaseOrderNumber: _trimOrNull(poText()),
      carrierRoutingCode: _trimOrNull(carrierRoutingText()),
      parentSsccCode: sscc?.parentSsccCode,
      extensionDigit: identityLocked
          ? (sscc!.extensionDigit ?? '0')
          : (extensionDigitText().isEmpty ? '0' : extensionDigitText()),
      gs1CompanyPrefix: identityLocked
          ? (sscc!.gs1CompanyPrefix ?? gs1CompanyPrefix)
          : gs1CompanyPrefix,
      serialReference: identityLocked
          ? (sscc!.serialReference ?? serialReference)
          : serialReference,
      checkDigit: identityLocked
          ? (sscc!.checkDigit ?? checkDigit)
          : checkDigit,
      issuingGLN: issuingGln,
      createdAt: sscc?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.isCreating) {
      cubit.createSSCC(savedSscc);
    } else if (widget.isEditing &&
        sscc?.id != null &&
        edit_rules.canEditSsccRecord(sscc!.status)) {
      cubit.updateSSCC(sscc!.id!, savedSscc);
    }
  }

  void _scrollToFormTop() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void generateSSCCCode() {
    context.dismissSnackBar();

    final issuingError = validateIssuingGlnRequired(issuingGln?.glnCode);
    if (issuingError != null) {
      setState(() => issuingGlnError = issuingError);
      context.showError(issuingError);
      return;
    }

    if (extensionDigitText().isEmpty) {
      context.showError('Extension Digit is required to generate SSCC');
      return;
    }

    final extensionError = validateExtensionDigit(extensionDigitText());
    if (extensionError != null) {
      context.showError(extensionError);
      return;
    }

    context.showInfo(
      'Generating SSCC code...',
      duration: const Duration(seconds: 2),
    );

    cubit.generateSSCCFromGLN(issuingGln!.glnCode, extensionDigitText());
  }

  Future<void> scanSSCCCode() async {
    final result = await GS1BarcodeScanDialog.show(
      context,
      title: 'Scan SSCC Barcode',
      allowedFormats: const ['SSCC', 'CODE_128'],
    );
    if (result == null || !mounted) return;

    if (!result.isValid) {
      context.showError(result.error ?? 'Invalid barcode scan');
      return;
    }

    final parsed = SsccInputParser.parseToSsccCode(result.data);
    if (parsed == null) {
      context.showError(
        'Could not read an SSCC from the scan. Use a GS1 (00) barcode or 18-digit SSCC.',
      );
      return;
    }

    setState(() {
      setSsccFieldSeedOrController('ssccCode', parsed);
      syncExtensionDigitFromSsccCode(parsed);
    });
    context.showSuccess('SSCC captured: $parsed');
  }

  String ssccCodeMissingMessage() {
    switch (ssccInputMode) {
      case SsccInputMode.generate:
        return 'Generate an SSCC code using the button, or switch to Manual or Scan';
      case SsccInputMode.scan:
        return 'Scan an SSCC barcode using the scan button';
      case SsccInputMode.manual:
        return 'Enter an 18-digit SSCC code or paste a GS1 (00) barcode';
    }
  }

  void syncExtensionDigitFromSscc(String ssccCode) {
    syncExtensionDigitFromSsccCode(ssccCode);
  }

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  GLN? _glnFromStoredCode(String? code) {
    if (code == null || code.trim().isEmpty) return null;
    return GLN.fromCode(code.trim());
  }

  int? parseSsccId(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    return int.tryParse(id.trim());
  }

  String? _glnCodeOrNull(GLN? gln) {
    final code = gln?.glnCode.trim();
    if (code == null || code.isEmpty) return null;
    return code;
  }

  Future<void> selectDate(
    BuildContext context,
    Function(DateTime) onDateSelected, {
    DateTime? initialDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
