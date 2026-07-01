import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_route_constants.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/epcis/mixins/event_form_validation_mixin.dart';
import 'package:traqtrace_app/features/gs1/sscc/cubit/sscc_cubit.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_form_validation_mixin.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_data_detail_scaffold.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_aggregation_link_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/core/utils/gs1_utils.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/utils/sscc_input_mode.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/sscc_detail_awaiting_selection.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/sscc_detail_error_pane.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/sscc_detail_form_bloc_body.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/tobacco/sscc_tobacco_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_list_parsing.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_create_form_validation.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_input_parser.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_validators.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/features/barcode/widgets/gs1_barcode_scan_dialog.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_edit_rules.dart'
    as edit_rules;

import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_pharmaceutical_extension_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_tobacco_extension_service.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

class SSCCDetailScreen extends StatefulWidget {
  final String? ssccId;
  final String? ssccCode;
  final bool isEditing;
  final bool embedded;
  final bool awaitingListSelection;
  final VoidCallback? onEmbeddedActionSuccess;

  const SSCCDetailScreen({
    super.key,
    this.ssccId,
    this.ssccCode,
    required this.isEditing,
    this.embedded = false,
    this.awaitingListSelection = false,
    this.onEmbeddedActionSuccess,
  });

  bool get isCreating =>
      (ssccId == null || ssccId!.isEmpty) &&
      (ssccCode == null || ssccCode!.isEmpty);

  String? get routeSsccCode =>
      (ssccCode != null && ssccCode!.isNotEmpty) ? ssccCode : ssccId;

  @override
  State<SSCCDetailScreen> createState() => _SSCCDetailScreenState();
}


class _SSCCDetailScreenState extends State<SSCCDetailScreen>
    with GS1FormValidationMixin<SSCCDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tobaccoExtensionKey = GlobalKey<SSCCTobaccoExtensionWidgetState>();
  final _pharmaExtensionKey =
      GlobalKey<SSCCPharmaceuticalExtensionWidgetState>();
  late TextEditingController _ssccCodeController;
  GLN? _issuingGln;
  String? _issuingGlnError;
  GLN? _shipFromGln;
  GLN? _shipToGln;
  GLN? _billToGln;
  GLN? _shipForGln;
  GLN? _custodianGln;
  late TextEditingController _extensionDigitController;
  late TextEditingController _containedGtinController;
  late TextEditingController _containedQuantityController;
  late TextEditingController _containedBatchController;
  DateTime? _containedExpiry;
  late TextEditingController _gsinController;
  late TextEditingController _gincController;
  late TextEditingController _poController;
  late TextEditingController _carrierRoutingController;

  SsccInputMode _ssccInputMode = SsccInputMode.generate;

  UnitType _unitType = UnitType.PALLET;
  LogisticUnitStatus _status = LogisticUnitStatus.DRAFT;
  ContentHomogeneity _contentHomogeneity = ContentHomogeneity.UNKNOWN;
  List<String> _serverTransitions = const [];
  List<SsccAggregationLink> _aggregationLinks = const [];
  DateTime? _packingDate;

  bool _formFieldsHydrated = true;
  bool _hasSubmittedForm = false;
  bool _ssccInitialLoadStarted = false;
  String? _loadedSsccKey;
  List<GLN> _glnPickerCatalog = const [];
  bool _glnCatalogLoadStarted = false;
  SSCCCubit? _ssccCubit;
  SSCC? _sscc;

  bool _editRedirectHandled = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _formFieldsHydrated = widget.awaitingListSelection ||
        widget.isCreating ||
        widget.routeSsccCode == null ||
        widget.routeSsccCode!.isEmpty;
    _ssccCodeController = TextEditingController();
    _extensionDigitController = TextEditingController();
    _containedGtinController = TextEditingController();
    _containedQuantityController = TextEditingController();
    _containedBatchController = TextEditingController();
    _gsinController = TextEditingController();
    _gincController = TextEditingController();
    _poController = TextEditingController();
    _carrierRoutingController = TextEditingController();

    _extensionDigitController.text = '0';
    _status = LogisticUnitStatus.DRAFT;

    if (!widget.embedded) {
      _ssccCubit = SSCCCubit(ssccService: getIt<SSCCService>());
    }

    if (!widget.awaitingListSelection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ensureGlnPickerCatalog();
      });
    }
  }

  @override
  void didUpdateWidget(SSCCDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeSsccCode == widget.routeSsccCode) return;
    if (widget.isCreating || widget.awaitingListSelection) return;

    _loadedSsccKey = null;
    _lastListSyncKey = null;
    _serverRefreshInFlight = false;
    _sscc = null;
    _formFieldsHydrated = false;
    _ssccInitialLoadStarted = false;
    _editRedirectHandled = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_ssccInitialLoadStarted) {
        _ssccInitialLoadStarted = true;
        _startInitialLoad();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.embedded) {
      _ssccCubit = context.read<SSCCCubit>();
    }
    if (!_ssccInitialLoadStarted) {
      _ssccInitialLoadStarted = true;
      if (widget.awaitingListSelection || widget.isCreating) {
        return;
      }
      _startInitialLoad();
    }
  }

  SSCCCubit get _cubit => _ssccCubit ?? context.read<SSCCCubit>();

  void _startInitialLoad() {
    final code = widget.routeSsccCode;
    if (code == null || code.isEmpty) {
      setState(() => _formFieldsHydrated = true);
      return;
    }
    _reloadFromServer();
  }

  String? get _requestedSsccKey => widget.routeSsccCode;

  bool _matchesRequestedSscc(SSCC sscc) {
    final key = _requestedSsccKey;
    if (key == null || key.isEmpty) return false;
    if (RegExp(r'^\d{18}$').hasMatch(key)) {
      return sscc.ssccCode == key;
    }
    return sscc.id?.toString() == key;
  }

  bool _ssccRecordDiffers(SSCC current, SSCC incoming) {
    return current.status != incoming.status ||
        current.packingDate != incoming.packingDate ||
        current.commissionedAt != incoming.commissionedAt ||
        current.childCount != incoming.childCount ||
        current.updatedAt != incoming.updatedAt;
  }

  SSCC? _ssccFromList(SSCCState state, String code) {
    for (final sscc in state.ssccs) {
      if (sscc.ssccCode == code) return sscc;
    }
    return null;
  }

  bool _serverRefreshInFlight = false;

  String? _lastListSyncKey;

  void _reloadFromServer() {
    if (_serverRefreshInFlight) return;
    final code = widget.routeSsccCode;
    if (code == null || code.isEmpty) return;

    _serverRefreshInFlight = true;
    setState(() {
      _loadedSsccKey = null;
      _formFieldsHydrated = false;
    });
    if (RegExp(r'^\d{18}$').hasMatch(code)) {
      _cubit.fetchSSCCByCode(code);
    } else {
      _cubit.fetchSSCCById(code);
    }
  }

  void _syncDetailWithListIfStale(SSCCState state) {
    if (widget.isCreating || widget.awaitingListSelection) return;
    final code = widget.routeSsccCode;
    if (code == null || code.isEmpty || _sscc == null) return;

    final listItem = _ssccFromList(state, code);
    if (listItem == null || !_ssccRecordDiffers(_sscc!, listItem)) return;

    final syncKey =
        '${listItem.updatedAt.toIso8601String()}:${listItem.status.name}';
    if (syncKey == _lastListSyncKey) return;
    _lastListSyncKey = syncKey;
    _reloadFromServer();
  }

  bool _shouldIgnoreCubitError(SSCCState state) {
    if (state.isListLoading) return true;
    return false;
  }

  Future<void> _ensureGlnPickerCatalog() async {
    if (_glnCatalogLoadStarted) return;
    _glnCatalogLoadStarted = true;
    try {
      final catalog =
          await getIt<GLNService>().getAllGLNs(page: 0, size: 500);
      if (!mounted) return;
      setState(() => _glnPickerCatalog = catalog);
      _applyGlnCatalogToFields();
    } catch (_) {
    }
  }

  Future<void> _refresh() async {
    if (widget.isCreating || widget.awaitingListSelection) return;
    _startInitialLoad();
  }

  @override
  void dispose() {
    _ssccCodeController.dispose();
    _extensionDigitController.dispose();
    _containedGtinController.dispose();
    _containedQuantityController.dispose();
    _containedBatchController.dispose();
    _gsinController.dispose();
    _gincController.dispose();
    _poController.dispose();
    _carrierRoutingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveTobaccoExtensionIfNeeded(
    int? ssccId,
    String ssccCode,
  ) async {
    if (!kTobaccoExtensionEnabled) return;
    final tobaccoState = _tobaccoExtensionKey.currentState;
    debugPrint(
      'SSCC Tobacco extension check - state: ${tobaccoState != null}, hasData: ${tobaccoState?.hasData}',
    );

    if (tobaccoState == null) {
      debugPrint(
        'Tobacco extension widget not in tree (probably not in tobacco mode)',
      );
      return;
    }

    if (!tobaccoState.hasData) {
      debugPrint('No tobacco extension data to save');
      return;
    }

    try {
      final extension = tobaccoState.buildExtension(
        ssccId: ssccId,
        ssccCode: ssccCode,
      );
      debugPrint('Built tobacco extension: ${extension != null}');
      if (extension != null) {
        final tobaccoService = getIt<SSCCTobaccoExtensionService>();
        await tobaccoService.createBySsccCode(ssccCode, extension);
        debugPrint('SSCC Tobacco extension saved for SSCC: $ssccCode');
      }
    } catch (e) {
      debugPrint('Error saving SSCC tobacco extension: $e');
    }
  }

  Future<void> _savePharmaExtensionIfNeeded(
    int? ssccId,
    String ssccCode,
  ) async {
    final pharmaState = _pharmaExtensionKey.currentState;
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

  void _populateFormFields(SSCC sscc) {
    _sscc = sscc;
    _ssccCodeController.text = sscc.ssccCode;

    _issuingGln = sscc.issuingGLN;
    _issuingGlnError = null;

    _extensionDigitController.text = sscc.extensionDigit ?? '0';
    _containedGtinController.text = sscc.containedGtin ?? '';
    _containedQuantityController.text =
        sscc.containedQuantity?.toString() ?? '';
    _containedBatchController.text = sscc.containedBatch ?? '';
    _containedExpiry = sscc.containedExpiry;
    _shipFromGln = _glnFromStoredCode(sscc.shipFromGln);
    _shipToGln = _glnFromStoredCode(sscc.shipToGln);
    _billToGln = _glnFromStoredCode(sscc.billToGln);
    _shipForGln = _glnFromStoredCode(sscc.shipForGln);
    _custodianGln = _glnFromStoredCode(sscc.currentCustodianGln);
    _gsinController.text = sscc.gsin ?? '';
    _gincController.text = sscc.ginc ?? '';
    _poController.text = sscc.purchaseOrderNumber ?? '';
    _carrierRoutingController.text = sscc.carrierRoutingCode ?? '';

    setState(() {
      _unitType = sscc.unitType;
      _status = sscc.status;
      _contentHomogeneity = sscc.contentHomogeneity;
      _serverTransitions = sscc.availableTransitions ?? const [];
      _packingDate = sscc.packingDate;
      _formFieldsHydrated = true;
    });

    if (sscc.id != null && _serverTransitions.isEmpty) {
      _loadTransitions(sscc.id!);
    }
    _loadAggregationLinks(sscc.ssccCode);
    _loadedSsccKey = _requestedSsccKey;
    _applyGlnCatalogToFields();
    _ensureGlnPickerCatalog();
    _enforceEditRouteIfNeeded(sscc);
  }

  void _enforceEditRouteIfNeeded(SSCC sscc) {
    if (_editRedirectHandled || widget.isCreating || !widget.isEditing) {
      return;
    }
    if (edit_rules.canEditSsccRecord(sscc.status)) {
      return;
    }
    _editRedirectHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.showInfo(edit_rules.readOnlyLifecycleMessage(sscc.status));
      if (widget.embedded) {
        return;
      }
      final code = sscc.ssccCode;
      if (code.isNotEmpty) {
        context.go(SsccRouteConstants.pathForSsccCode(code));
      }
    });
  }

  void _applyGlnCatalogToFields() {
    if (_glnPickerCatalog.isEmpty) return;
    setState(() {
      _issuingGln = resolveGlnForPicker(
        code: _issuingGln?.glnCode ?? _sscc?.issuingGLN?.glnCode,
        fallback: _issuingGln ?? _sscc?.issuingGLN,
        catalog: _glnPickerCatalog,
      );
      _shipFromGln = resolveGlnForPicker(
        code: _shipFromGln?.glnCode ?? _sscc?.shipFromGln,
        fallback: _shipFromGln,
        catalog: _glnPickerCatalog,
      );
      _shipToGln = resolveGlnForPicker(
        code: _shipToGln?.glnCode ?? _sscc?.shipToGln,
        fallback: _shipToGln,
        catalog: _glnPickerCatalog,
      );
      _billToGln = resolveGlnForPicker(
        code: _billToGln?.glnCode ?? _sscc?.billToGln,
        fallback: _billToGln,
        catalog: _glnPickerCatalog,
      );
      _shipForGln = resolveGlnForPicker(
        code: _shipForGln?.glnCode ?? _sscc?.shipForGln,
        fallback: _shipForGln,
        catalog: _glnPickerCatalog,
      );
      _custodianGln = resolveGlnForPicker(
        code: _custodianGln?.glnCode ?? _sscc?.currentCustodianGln,
        fallback: _custodianGln,
        catalog: _glnPickerCatalog,
      );
    });
  }

  Future<void> _loadAggregationLinks(String ssccCode) async {
    final links =
        await _cubit.fetchAggregationLinks(ssccCode);
    if (mounted) {
      setState(() => _aggregationLinks = links);
    }
  }

  Future<bool> _addAggregationChild({
    required String childEpc,
    required String childKind,
    required String aggregationEventId,
  }) async {
    final ssccId = _sscc?.id;
    if (ssccId == null) return false;

    final link = await _cubit.addAggregationChild(
          ssccId: ssccId,
          childEpc: childEpc,
          childKind: childKind,
          aggregationEventId: aggregationEventId,
        );
    if (link != null && mounted) {
      await _loadAggregationLinks(_sscc!.ssccCode);
      context.showSuccess('Child aggregated successfully');
      return true;
    }
    return false;
  }

  Future<bool> _disaggregateChild({
    required int linkId,
    required String disaggregationEventId,
  }) async {
    final ok = await _cubit.disaggregateChild(
          linkId: linkId,
          disaggregationEventId: disaggregationEventId,
        );
    if (ok && mounted) {
      await _loadAggregationLinks(_sscc!.ssccCode);
      context.showSuccess('Child disaggregated');
    }
    return ok;
  }

  Future<void> _loadTransitions(String id) async {
    final transitions =
        await _cubit.fetchAvailableTransitions(id);
    if (mounted && transitions.isNotEmpty) {
      setState(() => _serverTransitions = transitions);
    }
  }

  Future<void> _saveSSCC() async {
    if (widget.awaitingListSelection) return;

    setState(() {
      _issuingGlnError = validateIssuingGlnRequired(_issuingGln?.glnCode);
    });

    final validationErrors = SsccCreateFormValidation.collectErrors(
      isCreating: widget.isCreating,
      issuingGlnCode: _issuingGln?.glnCode,
      extensionDigit: _extensionDigitController.text,
      ssccCodeRaw: _ssccCodeController.text,
      ssccMissingMessage: _ssccCodeMissingMessage(),
      contentHomogeneity: _contentHomogeneity,
      containedGtin: _containedGtinController.text,
      containedQuantity: _containedQuantityController.text,
      gsin: _gsinController.text,
      purchaseOrder: _poController.text,
    );

    _formKey.currentState?.validate();

    validationErrors.addAll(
      SsccCreateFormValidation.collectFormFieldErrors(_formKey),
    );

    if (validationErrors.isNotEmpty) {
      _scrollToFormTop();
      showValidationErrors(
        context,
        validationErrors,
        title: 'Cannot save SSCC — fix these fields',
      );
      return;
    }

    final now = DateTime.now();

    setState(() {
      _hasSubmittedForm = true;
    });

    String gs1CompanyPrefix = '';
    String serialReference = '';
    String checkDigit = '';
    if (_ssccCodeController.text.isNotEmpty) {
      var ssccCode = SsccInputParser.parseToSsccCode(_ssccCodeController.text)
          ?? _ssccCodeController.text.trim();

      if (ssccCode.length != 18) {
        final fixedSSCC = GS1Utils.validateAndFixSSCC(ssccCode);
        if (fixedSSCC != null) {
          ssccCode = fixedSSCC;
          _ssccCodeController.text = ssccCode;
        } else {
          showValidationErrors(
            context,
            [
              'SSCC Code: must be 18 digits or a valid GS1 (00) barcode (current: ${ssccCode.length} digits)',
            ],
            title: 'Cannot save SSCC — fix these fields',
          );
          return;
        }
      }

      _syncExtensionDigitFromSscc(ssccCode);

      gs1CompanyPrefix = ssccCode.substring(1, 8);
      serialReference = ssccCode.substring(8, 17);
      checkDigit = ssccCode.substring(17);
    } else {
      showValidationErrors(
        context,
        ['SSCC Code: ${_ssccCodeMissingMessage()}'],
        title: 'Cannot save SSCC — fix these fields',
      );
      return;
    }

    final containedQty = int.tryParse(_containedQuantityController.text.trim());
    final identityLocked = !widget.isCreating &&
        _sscc != null &&
        edit_rules.isSsccIdentityLocked(_sscc!.status);
    final persistedStatus = _sscc?.status ?? _status;
    final saveStatus = edit_rules.canManuallyEditSsccStatus(
          persistedStatus,
          isCreating: widget.isCreating,
        )
        ? _status
        : persistedStatus;

    final sscc = SSCC(
      id: widget.isCreating ? null : _sscc?.id,
      ssccCode: identityLocked ? _sscc!.ssccCode : _ssccCodeController.text,
      unitType: _unitType,
      status: saveStatus,
      contentHomogeneity: _contentHomogeneity,
      containedGtin: _containedGtinController.text.trim().isEmpty
          ? null
          : _containedGtinController.text.trim(),
      containedQuantity: containedQty,
      containedBatch: _containedBatchController.text.trim().isEmpty
          ? null
          : _containedBatchController.text.trim(),
      containedExpiry: _containedExpiry,
      packingDate: _packingDate,
      shipFromGln: _glnCodeOrNull(_shipFromGln),
      shipToGln: _glnCodeOrNull(_shipToGln),
      billToGln: _glnCodeOrNull(_billToGln),
      shipForGln: _glnCodeOrNull(_shipForGln),
      currentCustodianGln: _glnCodeOrNull(_custodianGln),
      gsin: _trimOrNull(_gsinController.text),
      ginc: _trimOrNull(_gincController.text),
      purchaseOrderNumber: _trimOrNull(_poController.text),
      carrierRoutingCode: _trimOrNull(_carrierRoutingController.text),
      parentSsccCode: _sscc?.parentSsccCode,
      extensionDigit: identityLocked
          ? (_sscc!.extensionDigit ?? '0')
          : (_extensionDigitController.text.isEmpty
              ? '0'
              : _extensionDigitController.text),
      gs1CompanyPrefix: identityLocked
          ? (_sscc!.gs1CompanyPrefix ?? gs1CompanyPrefix)
          : gs1CompanyPrefix,
      serialReference: identityLocked
          ? (_sscc!.serialReference ?? serialReference)
          : serialReference,
      checkDigit:
          identityLocked ? (_sscc!.checkDigit ?? checkDigit) : checkDigit,
      issuingGLN: _issuingGln,
      createdAt: _sscc?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.isCreating) {
      _cubit.createSSCC(sscc);
    } else if (widget.isEditing &&
        _sscc?.id != null &&
        edit_rules.canEditSsccRecord(_sscc!.status)) {
      _cubit.updateSSCC(_sscc!.id!, sscc);
    }
  }

  void _scrollToFormTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _generateSSCCCode() {
    context.dismissSnackBar();

    final issuingError = validateIssuingGlnRequired(_issuingGln?.glnCode);
    if (issuingError != null) {
      setState(() => _issuingGlnError = issuingError);
      context.showError(issuingError);
      return;
    }

    if (_extensionDigitController.text.isEmpty) {
      context.showError('Extension Digit is required to generate SSCC');
      return;
    }

    final extensionError =
        validateExtensionDigit(_extensionDigitController.text);
    if (extensionError != null) {
      context.showError(extensionError);
      return;
    }

    context.showInfo('Generating SSCC code...', duration: const Duration(seconds: 2));

    _cubit.generateSSCCFromGLN(
      _issuingGln!.glnCode,
      _extensionDigitController.text,
    );
  }

  Future<void> _scanSSCCCode() async {
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
      _ssccCodeController.text = parsed;
      _syncExtensionDigitFromSscc(parsed);
    });
    context.showSuccess('SSCC captured: $parsed');
  }

  String _ssccCodeMissingMessage() {
    switch (_ssccInputMode) {
      case SsccInputMode.generate:
        return 'Generate an SSCC code using the button, or switch to Manual or Scan';
      case SsccInputMode.scan:
        return 'Scan an SSCC barcode using the scan button';
      case SsccInputMode.manual:
        return 'Enter an 18-digit SSCC code or paste a GS1 (00) barcode';
    }
  }

  void _syncExtensionDigitFromSscc(String ssccCode) {
    final digits = ssccCode.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    // Full SSCC: extension is digit 0; while typing manually, preview from first digit.
    _extensionDigitController.text = digits[0];
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthCubit>().state.user?.role;
    final canEditMasterData = role == 'ADMIN' || role == 'MANUFACTURER';
    final recordEditable = widget.isCreating ||
        (widget.isEditing &&
            _sscc != null &&
            edit_rules.canEditSsccRecord(_sscc!.status));
    final allowMasterDataActions = canEditMasterData &&
        !widget.awaitingListSelection &&
        (widget.isCreating || recordEditable);

    final body = BlocConsumer<SSCCCubit, SSCCState>(
      listenWhen: (previous, current) {
        if (previous.ssccs != current.ssccs) return true;
        if (current.status == SSCCStatus.error && current.error != null) {
          if (_shouldIgnoreCubitError(current)) return false;
          if (previous.isListLoading && !current.isListLoading) return false;
          return previous.status != SSCCStatus.error ||
              previous.error != current.error;
        }
        if (current.status == SSCCStatus.success &&
            current.selectedSSCC != null) {
          return current.selectedSSCC != previous.selectedSSCC;
        }
        if (current.status == SSCCStatus.codeGenerated &&
            current.generatedCode != null) {
          return current.generatedCode != previous.generatedCode;
        }
        return false;
      },
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (state.ssccs.isNotEmpty) {
            _syncDetailWithListIfStale(state);
          }
          if (state.status == SSCCStatus.error && state.error != null) {
            if (_shouldIgnoreCubitError(state)) return;
            setState(() {
              _formFieldsHydrated = true;
              _serverRefreshInFlight = false;
            });
            final message = userFacingSsccErrorMessage(state.error);
            if (_hasSubmittedForm) {
              showValidationErrors(
                context,
                [message],
                title: 'Cannot save SSCC',
              );
            } else if (_sscc == null && !widget.isCreating) {
              context.showError(message);
            }
            return;
          }

          if (state.status == SSCCStatus.success && state.selectedSSCC != null) {
            final sscc = state.selectedSSCC!;
            final matchesRequest = _matchesRequestedSscc(sscc);
            final isSaveResult = _hasSubmittedForm;

            if (!matchesRequest && !isSaveResult) return;
            if (!isSaveResult &&
                matchesRequest &&
                _loadedSsccKey == _requestedSsccKey &&
                (_sscc == null || !_ssccRecordDiffers(_sscc!, sscc))) {
              _serverRefreshInFlight = false;
              return;
            }

            _populateFormFields(sscc);
            _serverRefreshInFlight = false;

            if (_hasSubmittedForm) {
              setState(() => _hasSubmittedForm = false);
              final ssccCode = _ssccCodeController.text;
              _saveTobaccoExtensionIfNeeded(null, ssccCode);
              _savePharmaExtensionIfNeeded(
                _parseSsccId(state.selectedSSCC?.id ?? _sscc?.id),
                ssccCode,
              );

              context.showSuccess(SsccUiConstants.successSsccSaved);

              if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
                widget.onEmbeddedActionSuccess!();
              } else if (context.mounted) {
                final code =
                    state.selectedSSCC?.ssccCode ?? widget.routeSsccCode;
                if (code != null && code.isNotEmpty) {
                  context.go(SsccRouteConstants.pathForSsccCode(code));
                } else {
                  context.go(Constants.gs1SsccsRoute);
                }
              }
            }
            return;
          }

          if (state.status == SSCCStatus.codeGenerated &&
              state.generatedCode != null) {
            var ssccCode = state.generatedCode!;
            if (ssccCode.length != 18) {
              final fixedSSCC = GS1Utils.validateAndFixSSCC(ssccCode);
              if (fixedSSCC != null) {
                ssccCode = fixedSSCC;
              } else {
                try {
                  final companyPrefix = GS1Utils.extractCompanyPrefixFromGLN(
                    _issuingGln!.glnCode,
                  );
                  ssccCode = GS1Utils.generateSSCC(
                    companyPrefix,
                    _extensionDigitController.text,
                  );
                } catch (e) {
                  context.showError('Failed to generate valid SSCC: $e');
                  return;
                }
              }
            }
            setState(() {
              _ssccCodeController.text = ssccCode;
              _syncExtensionDigitFromSscc(ssccCode);
            });
          }
        });
      },
      builder: (context, state) {
        if (widget.awaitingListSelection &&
            !state.isListLoading &&
            state.status != SSCCStatus.initial) {
          return const SsccDetailAwaitingSelection();
        }

        if (state.status == SSCCStatus.codeGenerated &&
            state.generatedCode != null) {
          if (_ssccCodeController.text.isEmpty) {
            _ssccCodeController.text = state.generatedCode!;
          }
        }

        if (state.status == SSCCStatus.error &&
            !widget.isCreating &&
            _sscc == null &&
            !_shouldIgnoreCubitError(state)) {
          return SsccDetailErrorPane(
            errorMessage: state.error,
            onRetry: _startInitialLoad,
          );
        }

        return _formBlocBody(
          allowMasterDataActions: allowMasterDataActions,
          state: state,
        );
      },
    );

    final scaffold = Gs1MasterDataDetailScaffold(
      embedded: widget.embedded,
      title: widget.isCreating
          ? SsccUiConstants.detailCreateTitle
          : (recordEditable
              ? SsccUiConstants.detailEditTitle
              : SsccUiConstants.detailViewTitle),
      showSaveAction: allowMasterDataActions,
      onSave: _saveSSCC,
      saveActionTooltip: SsccUiConstants.detailSaveButton,
      body: body,
    );

    if (widget.embedded) {
      return scaffold;
    }
    final cubit = _ssccCubit;
    if (cubit == null) {
      return scaffold;
    }
    return BlocProvider<SSCCCubit>.value(value: cubit, child: scaffold);
  }

  SsccDetailFormBlocBody _formBlocBody({
    required bool allowMasterDataActions,
    required SSCCState state,
  }) {
    final recordEditable = widget.isCreating ||
        (widget.isEditing &&
            _sscc != null &&
            edit_rules.canEditSsccRecord(_sscc!.status));
    final isReadOnly = !recordEditable;
    final aggregationEditable =
        edit_rules.isSsccAggregationEditable(isCreating: widget.isCreating);

    return SsccDetailFormBlocBody(
      awaitingListSelection: widget.awaitingListSelection,
      formFieldsHydrated: _formFieldsHydrated,
      isCreating: widget.isCreating,
      isEditing: widget.isEditing,
      embedded: widget.embedded,
      allowMasterDataActions: allowMasterDataActions,
      state: state,
      formKey: _formKey,
      scrollController: _scrollController,
      ssccCodeController: _ssccCodeController,
      sscc: _sscc,
      unitType: _unitType,
      status: _status,
      contentHomogeneity: _contentHomogeneity,
      serverTransitions: _serverTransitions,
      packingDate: _packingDate,
      containedExpiry: _containedExpiry,
      aggregationLinks: _aggregationLinks,
      shipFromGln: _shipFromGln,
      shipToGln: _shipToGln,
      billToGln: _billToGln,
      shipForGln: _shipForGln,
      custodianGln: _custodianGln,
      glnPickerCatalog: _glnPickerCatalog,
      ssccInputMode: _ssccInputMode,
      extensionDigitController: _extensionDigitController,
      containedGtinController: _containedGtinController,
      containedQuantityController: _containedQuantityController,
      containedBatchController: _containedBatchController,
      gsinController: _gsinController,
      gincController: _gincController,
      poController: _poController,
      carrierRoutingController: _carrierRoutingController,
      issuingGln: _issuingGln,
      issuingGlnError: _issuingGlnError,
      pharmaExtensionKey: _pharmaExtensionKey,
      tobaccoExtensionKey: _tobaccoExtensionKey,
      parseSsccId: _parseSsccId,
      onRefresh: _refresh,
      onUnitTypeChanged: (v) => setState(() => _unitType = v),
      onHomogeneityChanged: (v) => setState(() => _contentHomogeneity = v),
      onPickContainedExpiry: isReadOnly
          ? null
          : () => _selectDate(
                context,
                (date) => setState(() => _containedExpiry = date),
                initialDate: _containedExpiry,
              ),
      onStatusChanged: (s) => setState(() => _status = s),
      onTransitionError: (msg) => context.showError(msg),
      onPackingDateSelected: () => _selectDate(
        context,
        (date) => setState(() => _packingDate = date),
        initialDate: _packingDate,
      ),
      onShipFromChanged: (gln) => setState(() => _shipFromGln = gln),
      onShipToChanged: (gln) => setState(() => _shipToGln = gln),
      onBillToChanged: (gln) => setState(() => _billToGln = gln),
      onShipForChanged: (gln) => setState(() => _shipForGln = gln),
      onCustodianChanged: (gln) => setState(() => _custodianGln = gln),
      onAddChild: !aggregationEditable || _sscc?.id == null
          ? null
          : _addAggregationChild,
      onDisaggregate: aggregationEditable ? _disaggregateChild : null,
      onSave: _saveSSCC,
      onIssuingGlnChanged: (gln) {
        setState(() {
          _issuingGln = gln;
          _issuingGlnError = validateIssuingGlnRequired(gln?.glnCode);
          setFieldError('gln', _issuingGlnError);
        });
      },
      onInputModeChanged: (mode) {
        setState(() {
          _ssccInputMode = mode;
          _ssccCodeController.clear();
          _extensionDigitController.text = '0';
        });
        if (mode == SsccInputMode.scan) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scanSSCCCode();
          });
        }
      },
      onGenerateSsccCode: _generateSSCCCode,
      onScanSsccCode: _scanSSCCCode,
      onClearSsccCode: () => setState(() {
        _ssccCodeController.clear();
        _extensionDigitController.text = '0';
      }),
      setFieldError: setFieldError,
      onSyncExtensionDigitFromSscc: _syncExtensionDigitFromSscc,
      onManualSsccCodeChanged: () => setState(() {}),
    );
  }

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  GLN? _glnFromStoredCode(String? code) {
    if (code == null || code.trim().isEmpty) return null;
    return GLN.fromCode(code.trim());
  }

  int? _parseSsccId(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    return int.tryParse(id.trim());
  }

  String? _glnCodeOrNull(GLN? gln) {
    final code = gln?.glnCode.trim();
    if (code == null || code.isEmpty) return null;
    return code;
  }

  Future<void> _selectDate(
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
