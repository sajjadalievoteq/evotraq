import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/navigation/pop_or_go.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_picker_catalog.dart';
import 'package:traqtrace_app/features/gs1/sscc/cubit/sscc_state.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/sscc_detail_edit_actions.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/sscc_detail_screen.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_commission_helper.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_commissioning_prefill.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_create_flow.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';

extension SSCCDetailActions on SSCCDetailScreenState {
  void startInitialLoad() {
    final code = widget.routeSsccCode;
    if (code == null || code.isEmpty) {
      setState(() => formFieldsHydrated = true);
      return;
    }
    _reloadFromServer();
  }

  String? get requestedSsccKey => widget.routeSsccCode;

  bool matchesRequestedSscc(SSCC sscc) {
    final key = requestedSsccKey;
    if (key == null || key.isEmpty) return false;
    if (RegExp(r'^\d{18}$').hasMatch(key)) {
      return sscc.ssccCode == key;
    }
    return sscc.id?.toString() == key;
  }

  bool ssccRecordDiffers(SSCC current, SSCC incoming) {
    return current.status != incoming.status ||
        current.packingDate != incoming.packingDate ||
        current.commissionedAt != incoming.commissionedAt ||
        current.childCount != incoming.childCount ||
        current.updatedAt != incoming.updatedAt;
  }

  SSCC? ssccFromList(SSCCState state, String code) {
    for (final sscc in state.ssccs) {
      if (sscc.ssccCode == code) return sscc;
    }
    return null;
  }

  void _reloadFromServer() {
    if (serverRefreshInFlight) return;
    final code = widget.routeSsccCode;
    if (code == null || code.isEmpty) return;

    serverRefreshInFlight = true;
    aggregationLinksRequestedCode = null;
    aggregationLinksFuture = null;
    setState(() {
      loadedSsccKey = null;
      formFieldsHydrated = false;
    });
    if (RegExp(r'^\d{18}$').hasMatch(code)) {
      cubit.fetchSSCCByCode(code);

      loadAggregationLinks(code);
    } else {
      cubit.fetchSSCCById(code);
    }
  }

  void syncDetailWithListIfStale(SSCCState state) {
    if (widget.isCreating || widget.awaitingListSelection) return;
    final code = widget.routeSsccCode;
    if (code == null || code.isEmpty || sscc == null) return;

    final listItem = ssccFromList(state, code);
    if (listItem == null || !ssccRecordDiffers(sscc!, listItem)) return;

    final syncKey =
        '${listItem.updatedAt.toIso8601String()}:${listItem.status.name}';
    if (syncKey == lastListSyncKey) return;
    lastListSyncKey = syncKey;
    _reloadFromServer();
  }

  bool shouldIgnoreCubitError(SSCCState state) {
    if (state.isListLoading) return true;
    return false;
  }

  Future<void> ensureGlnPickerCatalog() async {
    if (glnCatalogLoadStarted) return;
    glnCatalogLoadStarted = true;
    try {
      final catalog = await getIt<GlnPickerCatalog>().ensureLoaded();
      if (!mounted) return;
      setState(() => glnPickerCatalog = catalog);
      applyGlnCatalogToFields();
    } catch (_) {}
  }

  Future<void> refresh() async {
    if (widget.isCreating || widget.awaitingListSelection) return;
    startInitialLoad();
  }

  void saveOnly() {
    setState(() => pendingCommissionAfterSave = false);
    saveSSCC();
  }

  void saveAndCommission() {
    setState(() => pendingCommissionAfterSave = true);
    saveSSCC();
  }

  void navigateToCommission() {
    final record = sscc;
    final code = (record?.ssccCode ?? ssccCodeText()).trim();
    if (code.isEmpty) return;

    final prefill = record != null
        ? SsccCommissioningPrefill.fromSscc(
            sscc: record,
            issuingGln: issuingGln,
            shipFromGln: shipFromGln,
            purchaseOrder: poText(),
          )
        : SsccCommissioningPrefill(ssccCode: code);

    context.push(SsccCreateFlow.commissioningRoute(prefill: prefill));
  }

  Future<void> handleCommissionAfterCreate(
    SSCC savedSscc, {
    bool wasCreate = true,
  }) async {
    final locationGln = issuingGln?.glnCode ?? savedSscc.issuingGLN?.glnCode;
    if (locationGln == null || locationGln.isEmpty) {
      context.showError(
        'SSCC was saved but commissioning location GLN is missing.',
      );
      if (mounted) setState(() => isSaving = false);
      _finishCreateSuccessNavigation();
      return;
    }

    try {
      await SsccCommissionHelper.commissionAllocatedSscc(
        ssccCode: savedSscc.ssccCode,
        commissioningLocationGln: locationGln,
        readPointGln: shipFromGln?.glnCode ?? savedSscc.shipFromGln,
        batchLotNumber: containedBatchText().trim().isNotEmpty
            ? containedBatchText().trim()
            : savedSscc.containedBatch,
        expiryDate: containedExpiry ?? savedSscc.containedExpiry,
        productionDate: packingDate ?? savedSscc.packingDate,
        commissioningReference: poText().trim().isNotEmpty
            ? poText().trim()
            : savedSscc.purchaseOrderNumber,
      );
      if (!mounted) return;
      context.showSuccess(
        wasCreate
            ? SsccUiConstants.successSsccCreatedAndCommissioned
            : SsccUiConstants.successSsccSavedAndCommissioned,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      context.showError(
        'SSCC was saved but commissioning failed: ${e.message}',
      );
    } catch (e) {
      if (!mounted) return;
      context.showError(
        'SSCC was saved but commissioning failed: $e',
      );
    }

    _finishCreateSuccessNavigation();
    if (mounted) {
      setState(() => isSaving = false);
    }
  }

  void _finishCreateSuccessNavigation() {
    if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
      widget.onEmbeddedActionSuccess!();
      return;
    }
    if (mounted) {
      popOrGo(context, Constants.gs1SsccsRoute);
    }
  }
}
