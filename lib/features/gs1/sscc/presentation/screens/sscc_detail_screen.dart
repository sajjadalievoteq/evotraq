import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_route_constants.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_text_field.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/shared/widgets/gln_selector.dart';
import 'package:traqtrace_app/features/gs1/sscc/cubit/sscc_cubit.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_form_validation_mixin.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_form_shimmer_layer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_data_detail_scaffold.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_aggregation_link_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_utils.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/tobacco/sscc_tobacco_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/pharma/sscc_pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/utilities/sscc_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/core_groups/sscc_aggregation_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/core_groups/sscc_pharma_compliance_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/core_groups/sscc_epcis_audit_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/core_groups/sscc_parties_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/core_groups/sscc_transport_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/core_groups/sscc_classification_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/core_groups/sscc_dates_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/core_groups/sscc_lifecycle_status_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/skeleton/sscc_detail_skeleton.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_list_parsing.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_validators.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_edit_rules.dart'
    as edit_rules;
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_status_rules.dart'
    as status_rules;

import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_pharmaceutical_extension_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_pharma_compliance_service.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_tobacco_extension_service.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

import '../../../../../../core/theme/traq_theme.dart';

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

  UnitType _unitType = UnitType.PALLET;
  LogisticUnitStatus _status = LogisticUnitStatus.DRAFT;
  ContentHomogeneity _contentHomogeneity = ContentHomogeneity.UNKNOWN;
  List<String> _serverTransitions = const [];
  List<SsccAggregationLink> _aggregationLinks = const [];
  DateTime? _packingDate;

  bool _isLoading = false;
  bool _formFieldsHydrated = true;
  bool _hasSubmittedForm = false;
  bool _ssccInitialLoadStarted = false;
  String? _loadedSsccKey;
  List<GLN> _glnPickerCatalog = const [];
  bool _glnCatalogLoadStarted = false;
  SSCCCubit? _ssccCubit;
  SSCC? _sscc;

  dynamic _capturedTobaccoExtension;
  dynamic _capturedPharmaExtension;
  String? _capturedSsccCode;
  bool _editRedirectHandled = false;

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
    setState(() {
      _formFieldsHydrated = false;
      _loadedSsccKey = null;
      _isLoading = true;
    });
    if (RegExp(r'^\d{18}$').hasMatch(code)) {
      _cubit.fetchSSCCByCode(code);
    } else {
      _cubit.fetchSSCCById(code);
    }
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

  bool _fieldSkeletonsActive(SSCCState state) {
    if (state.status == SSCCStatus.error) return false;
    if (widget.awaitingListSelection) {
      return state.isListLoading || state.status == SSCCStatus.initial;
    }
    return !_formFieldsHydrated;
  }

  SsccDetailSkeleton _detailFormSkeleton() {
    return SsccDetailSkeleton(
      showHeaderBanner: !widget.isCreating,
      showCreateSection: widget.isCreating,
    );
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
    super.dispose();
  }

  Future<void> _loadData() async => _startInitialLoad();

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
      _isLoading = false;
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
    if (_ssccCodeController.text.isEmpty &&
        widget.isCreating) {
      context.showWarning(
        'Please generate an SSCC code first by clicking the generate button',
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();

      setState(() {
        _isLoading = true;
        _hasSubmittedForm = true;
      });
      String gs1CompanyPrefix = '';
      String serialReference = '';
      String checkDigit = '';
      if (_ssccCodeController.text.isNotEmpty) {
        var ssccCode = _ssccCodeController.text;

        if (ssccCode.length != 18) {
          final fixedSSCC = GS1Utils.validateAndFixSSCC(ssccCode);
          if (fixedSSCC != null) {
            ssccCode = fixedSSCC;
            _ssccCodeController.text =
                ssccCode;
          } else {
            context.showError(
              'Invalid SSCC code - must be 18 digits (current: ${ssccCode.length} digits)',
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }

        gs1CompanyPrefix = ssccCode.substring(
          1,
          8,
        );
        serialReference = ssccCode.substring(8, 17);
        checkDigit = ssccCode.substring(17);
      } else {
        context.showWarning('Please generate an SSCC code first');
        setState(() {
          _isLoading = false;
        });
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
        gs1CompanyPrefix:
            identityLocked ? (_sscc!.gs1CompanyPrefix ?? gs1CompanyPrefix) : gs1CompanyPrefix,
        serialReference:
            identityLocked ? (_sscc!.serialReference ?? serialReference) : serialReference,
        checkDigit: identityLocked ? (_sscc!.checkDigit ?? checkDigit) : checkDigit,
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

    setState(() {
      _isLoading = true;
    });

    context.showInfo('Generating SSCC code...', duration: const Duration(seconds: 2));

    _cubit.generateSSCCFromGLN(
      _issuingGln!.glnCode,
      _extensionDigitController.text,
    );
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
          if (state.status == SSCCStatus.error && state.error != null) {
            if (_shouldIgnoreCubitError(state)) return;
            setState(() {
              _isLoading = false;
              _formFieldsHydrated = true;
            });
            if (_sscc == null && !widget.isCreating) {
              context.showError(userFacingSsccErrorMessage(state.error));
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
                _loadedSsccKey == _requestedSsccKey) {
              return;
            }

            _populateFormFields(sscc);

            if (_hasSubmittedForm) {
              setState(() => _hasSubmittedForm = false);
              final ssccCode = _ssccCodeController.text;
              _saveTobaccoExtensionIfNeeded(null, ssccCode);
              _savePharmaExtensionIfNeeded(
                _parseSsccId(state.selectedSSCC?.id ?? _sscc?.id),
                ssccCode,
              );
              setState(() => _isLoading = false);

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
                  setState(() => _isLoading = false);
                  return;
                }
              }
            }
            setState(() {
              _isLoading = false;
              _ssccCodeController.text = ssccCode;
            });
          }
        });
      },
      builder: (context, state) {
        if (widget.awaitingListSelection &&
            !state.isListLoading &&
            state.status != SSCCStatus.initial) {
          return Center(
            child: Text(
              SsccUiConstants.detailAwaitSelection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        if (state.status == SSCCStatus.codeGenerated &&
            state.generatedCode != null) {
          if (_ssccCodeController.text.isEmpty) {
            _ssccCodeController.text = state.generatedCode!;
          }
          _isLoading = false;
        }

        if (state.status == SSCCStatus.error &&
            !widget.isCreating &&
            _sscc == null &&
            !_shouldIgnoreCubitError(state)) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  state.error ?? SsccUiConstants.errorGeneric,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  onPressed: _startInitialLoad,
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return _buildForm(
          allowMasterDataActions: allowMasterDataActions,
          showSkeleton: _fieldSkeletonsActive(state),
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

  Widget _buildForm({
    required bool allowMasterDataActions,
    required bool showSkeleton,
  }) {
    final recordEditable = widget.isCreating ||
        (widget.isEditing &&
            _sscc != null &&
            edit_rules.canEditSsccRecord(_sscc!.status));
    final isReadOnly = !recordEditable;
    final allowManualStatusEdit = edit_rules.canManuallyEditSsccStatus(
      _status,
      isCreating: widget.isCreating,
    );
    final aggregationEditable =
        edit_rules.isSsccAggregationEditable(isCreating: widget.isCreating);
    final borderColor = Theme.of(context).colorScheme.outlineVariant;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          top: context.horizontalPadding.left,
          right: context.horizontalPadding.left,
          left: context.horizontalPadding.left,
        ),
        child: Form(
          key: _formKey,
          child: Gs1FormShimmerLayer(
            show: showSkeleton,
            formColumn: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_ssccCodeController.text.isNotEmpty && !widget.isCreating)
                  CardWithBackgroundWidget(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "(00)${_ssccCodeController.text}",
                            style: context.text.h1.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          if (_sscc != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              status_rules.friendlyUnitTypeLabel(_unitType),
                              style: context.text.h3.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                _status.name.replaceAll('_', ' '),
                                style: context.text.body.copyWith(
                                  color: context.colors.textFaint,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                if (_ssccCodeController.text.isNotEmpty && !widget.isCreating)
                  const SizedBox(height: 16),
                if (widget.isCreating)
                  _buildSSCCCodeSection(isReadOnly)
                else if (_ssccCodeController.text.isEmpty)
                  const SizedBox.shrink()
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 16),
            SsccClassificationCard(
              borderColor: borderColor,
              isReadOnly: isReadOnly,
              unitType: _unitType,
              contentHomogeneity: _contentHomogeneity,
              onUnitTypeChanged: (v) => setState(() => _unitType = v),
              onHomogeneityChanged: (v) =>
                  setState(() => _contentHomogeneity = v),
              containedGtinController: _containedGtinController,
              containedQuantityController: _containedQuantityController,
              containedBatchController: _containedBatchController,
              containedExpiry: _containedExpiry,
              onPickContainedExpiry: isReadOnly
                  ? null
                  : () => _selectDate(
                        context,
                        (date) => setState(() => _containedExpiry = date),
                        initialDate: _containedExpiry,
                      ),
            ),
            const SizedBox(height: 12),
            SsccLifecycleStatusCard(
              borderColor: borderColor,
              allowManualStatusEdit: allowManualStatusEdit,
              isCreating: widget.isCreating,
              sscc: _sscc,
              selectedStatus: _status,
              serverTransitions: _serverTransitions,
              onStatusChanged: (s) => setState(() => _status = s),
              onTransitionError: (msg) => context.showError(msg),
            ),
            const SizedBox(height: 12),
            SsccDatesCard(
              borderColor: borderColor,
              isReadOnly: isReadOnly,
              packingDate: _packingDate,
              sscc: _sscc,
              onPackingDateSelected: () => _selectDate(
                context,
                (date) => setState(() => _packingDate = date),
                initialDate: _packingDate,
              ),
            ),
            if (!widget.isCreating) ...[
              const SizedBox(height: 12),
              SsccPartiesCard(
                borderColor: borderColor,
                isReadOnly: isReadOnly,
                shipFromGln: _shipFromGln,
                shipToGln: _shipToGln,
                billToGln: _billToGln,
                shipForGln: _shipForGln,
                custodianGln: _custodianGln,
                onShipFromChanged: (gln) => setState(() => _shipFromGln = gln),
                onShipToChanged: (gln) => setState(() => _shipToGln = gln),
                onBillToChanged: (gln) => setState(() => _billToGln = gln),
                onShipForChanged: (gln) => setState(() => _shipForGln = gln),
                onCustodianChanged: (gln) =>
                    setState(() => _custodianGln = gln),
                sscc: _sscc,
                pickerCatalog:
                    _glnPickerCatalog.isEmpty ? null : _glnPickerCatalog,
              ),
              const SizedBox(height: 12),
              SsccTransportCard(
                borderColor: borderColor,
                isReadOnly: isReadOnly,
                gsinController: _gsinController,
                gincController: _gincController,
                poController: _poController,
                carrierRoutingController: _carrierRoutingController,
                sscc: _sscc,
              ),
              const SizedBox(height: 12),
              SsccAggregationCard(
                borderColor: borderColor,
                sscc: _sscc,
                aggregationLinks: _aggregationLinks,
                isReadOnly: !aggregationEditable,
                onAddChild: !aggregationEditable || _sscc?.id == null
                    ? null
                    : _addAggregationChild,
                onDisaggregate:
                    aggregationEditable ? _disaggregateChild : null,
              ),
              const SizedBox(height: 12),
              SsccEpcisAuditCard(
                borderColor: borderColor,
                sscc: _sscc,
              ),
            ],

            const SizedBox(height: 24.0),
            BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
              builder: (context, settingsState) {
                final settings = settingsState.settings;
                final currentSsccCode =
                    (_sscc?.ssccCode ?? _ssccCodeController.text).trim();
                final hasSsccCode = currentSsccCode.isNotEmpty;
                final hasPersistedSscc =
                    !widget.isCreating && hasSsccCode;

                if (settings.isPharmaceuticalMode) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasPersistedSscc && _sscc?.id != null) ...[
                        SsccPharmaComplianceCard(
                          borderColor: borderColor,
                          ssccId: _sscc!.id!,
                          isReadOnly: isReadOnly,
                        ),
                        const SizedBox(height: 12),
                      ],
                      SSCCPharmaceuticalExtensionWidget(
                        key: _pharmaExtensionKey,
                        ssccId: _parseSsccId(_sscc?.id),
                        ssccCode: hasSsccCode ? currentSsccCode : null,
                        isEditing: !isReadOnly,
                        borderColor: borderColor,
                      ),
                    ],
                  );
                }

                if (settings.isTobaccoMode && kTobaccoExtensionEnabled) {
                  return SSCCTobaccoExtensionWidget(
                    key: _tobaccoExtensionKey,
                    ssccCode: hasSsccCode ? currentSsccCode : null,
                    isEditing: !isReadOnly,
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),
            if ((MediaQuery.of(context).size.width < 600 ||
                    widget.embedded) &&
                allowMasterDataActions)
              CustomButtonWidget(
                onTap: _saveSSCC,
                title: SsccUiConstants.detailSaveButton,
              ),
            const SizedBox(height: 32),
              ],
            ),
            skeleton: _detailFormSkeleton(),
          ),
        ),
      ),
    );
  }

  Widget _buildSSCCCodeSection(bool isReadOnly) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SSCC Identification',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Enter the GLN of the location that will create/issue this SSCC for GS1 traceability',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            if (isReadOnly)
              SgtinInfoRow(
                'Issuing GLN (Location Creating This SSCC)',
                _issuingGln != null
                    ? '${_issuingGln!.glnCode} – ${_issuingGln!.locationName}'
                    : (_sscc?.gs1CompanyPrefix != null
                        ? 'GS1 Company Prefix: ${_sscc!.gs1CompanyPrefix}'
                        : null),
              )
            else
              GLNSelector(
                label: 'Issuing GLN (Location Creating This SSCC)',
                hintText: 'Search and select issuing location',
                initialValue: _issuingGln,
                pickerCatalog:
                    _glnPickerCatalog.isEmpty ? null : _glnPickerCatalog,
                isRequired: true,
                errorText: _issuingGlnError,
                onChanged: (gln) {
                  setState(() {
                    _issuingGln = gln;
                    _issuingGlnError = validateIssuingGlnRequired(gln?.glnCode);
                    setFieldError('gln', _issuingGlnError);
                  });
                },
              ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ValidatedTextField(
                    controller: _extensionDigitController,
                    decoration: const InputDecoration(
                      labelText: 'Extension Digit',
                      helperText: 'Logistic variants (0-9)',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: isReadOnly,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final err = validateExtensionDigit(value);
                      setFieldError('extensionDigit', err);
                      return err;
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 3,
                  child: ValidatedTextField(
                    controller: _ssccCodeController,
                    decoration: InputDecoration(
                      labelText: 'SSCC Code',
                      helperText: 'Will be generated automatically',
                      hintText: 'Click Generate button →',
                      border: OutlineInputBorder(),
                      suffixIcon: !isReadOnly
                          ? IconButton(
                              icon: const Icon(Icons.autorenew),
                              tooltip: 'Generate SSCC Code',
                              onPressed: _generateSSCCCode,
                            )
                          : null,
                      filled: true,
                      fillColor: _ssccCodeController.text.isEmpty
                          ? Colors.grey.shade100
                          : (_ssccCodeController.text.length == 18
                                ? Colors.green.shade50
                                : Colors.red.shade50),
                    ),
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please generate an SSCC code';
                      }
                      return validateSsccCode(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
