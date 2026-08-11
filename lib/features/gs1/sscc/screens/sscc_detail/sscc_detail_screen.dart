import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/navigation/pop_or_go.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_route_constants.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_picker_catalog.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/core/extensions/validation_feedback_extension.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';
import 'package:traqtrace_app/features/gs1/sscc/cubit/sscc_cubit.dart';
import 'package:traqtrace_app/features/gs1/sscc/cubit/sscc_state.dart';
import 'package:traqtrace_app/features/gs1/sscc/cubit/sscc_status.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_data_detail_scaffold.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_aggregation_link_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/core/utils/gs1_utils.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/sscc_detail_screen_fields.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/utils/sscc_input_mode.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/sscc_detail_error_pane.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/sscc_detail_form_bloc_body.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/skeleton/sscc_detail_skeleton.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_form_shimmer_layer.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_list_parsing.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_create_form_validation.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_input_parser.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_validators.dart';
import 'package:traqtrace_app/features/barcode/widgets/dialog/gs1_barcode_scan_dialog.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_edit_rules.dart'
    as edit_rules;

import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_pharmaceutical_extension_service.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

part 'sscc_detail_actions.dart';
part 'sscc_detail_edit_actions.dart';

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
    with SsccDetailScreenFields {
  final _formKey = GlobalKey<FormState>();
  final _pharmaExtensionKey =
      GlobalKey<SSCCPharmaceuticalExtensionWidgetState>();
  late final ValidationCubit _validationCubit;
  GLN? _issuingGln;
  String? _issuingGlnError;
  GLN? _shipFromGln;
  GLN? _shipToGln;
  GLN? _billToGln;
  GLN? _shipForGln;
  GLN? _custodianGln;
  DateTime? _containedExpiry;

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
  bool _forceMountAllSections = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _validationCubit = ValidationCubit();
    _formFieldsHydrated =
        widget.awaitingListSelection ||
        widget.isCreating ||
        widget.routeSsccCode == null ||
        widget.routeSsccCode!.isEmpty;
    initSsccDetailFields();
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

  bool _serverRefreshInFlight = false;
  String? _lastListSyncKey;
  String? _aggregationLinksRequestedCode;
  Future<void>? _aggregationLinksFuture;

  @override
  void dispose() {
    disposeSsccDetailFields();
    _scrollController.dispose();
    _validationCubit.close();
    super.dispose();
  }

  SSCCCubit get _cubit => _ssccCubit ?? context.read<SSCCCubit>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final canEditMasterData = auth.isAdmin || auth.isManufacturer;
    final recordEditable =
        widget.isCreating ||
        (widget.isEditing &&
            _sscc != null &&
            edit_rules.canEditSsccRecord(_sscc!.status));
    final allowMasterDataActions =
        canEditMasterData &&
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
              context.showValidationErrors([
                message,
              ], title: 'Cannot save SSCC');
            } else if (_sscc == null && !widget.isCreating) {
              context.showError(message);
            }
            return;
          }

          if (state.status == SSCCStatus.success &&
              state.selectedSSCC != null) {
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
              final ssccCode = ssccCodeText();
              _savePharmaExtensionIfNeeded(
                _parseSsccId(state.selectedSSCC?.id ?? _sscc?.id),
                ssccCode,
              );

              context.showSuccess(SsccUiConstants.successSsccSaved);

              if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
                widget.onEmbeddedActionSuccess!();
              } else if (context.mounted) {
                popOrGo(context, Constants.gs1SsccsRoute);
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
                    extensionDigitText(),
                  );
                } catch (e) {
                  context.showError('Failed to generate valid SSCC: $e');
                  return;
                }
              }
            }
            setState(() {
              setSsccFieldSeedOrController('ssccCode', ssccCode);
              _syncExtensionDigitFromSscc(ssccCode);
            });
          }
        });
      },
      builder: (context, state) {
        if (widget.awaitingListSelection) {
          final listLoading =
              state.isListLoading || state.status == SSCCStatus.initial;
          if (listLoading) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                context.padding.top,
                context.padding.top,
                context.padding.top,
                0,
              ),
              child: Gs1FormShimmerLayer(
                show: true,
                formColumn: const SizedBox.shrink(),
                skeleton: const SsccDetailSkeleton(),
              ),
            );
          }
          return AppEmptyDetail(
            title: SsccUiConstants.awaitingSelectionTitle,
            subtitle: SsccUiConstants.awaitingSelectionSubtitle,
            iconAsset: NavIcons.sscc,
          );
        }

        if (state.status == SSCCStatus.codeGenerated &&
            state.generatedCode != null) {
          if (ssccCodeText().isEmpty) {
            setSsccFieldSeedOrController('ssccCode', state.generatedCode!);
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

    Widget result = scaffold;
    if (!widget.embedded) {
      final cubit = _ssccCubit;
      if (cubit != null) {
        result = BlocProvider<SSCCCubit>.value(value: cubit, child: scaffold);
      }
    }
    return BlocProvider<ValidationCubit>.value(
      value: _validationCubit,
      child: result,
    );
  }

  SsccDetailFormBlocBody _formBlocBody({
    required bool allowMasterDataActions,
    required SSCCState state,
  }) {
    final recordEditable =
        widget.isCreating ||
        (widget.isEditing &&
            _sscc != null &&
            edit_rules.canEditSsccRecord(_sscc!.status));
    final isReadOnly = !recordEditable;
    final aggregationEditable = edit_rules.isSsccAggregationEditable(
      isCreating: widget.isCreating,
    );

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
      forceMountAllSections: _forceMountAllSections,
      ssccCodeController: ssccCodeController,
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
      extensionDigitController: extensionDigitController,
      containedGtinController: containedGtinController,
      containedQuantityController: containedQuantityController,
      containedBatchController: containedBatchController,
      gsinController: gsinController,
      gincController: gincController,
      poController: poController,
      carrierRoutingController: carrierRoutingController,
      issuingGln: _issuingGln,
      issuingGlnError: _issuingGlnError,
      pharmaExtensionKey: _pharmaExtensionKey,
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
          _setFieldError('gln', _issuingGlnError);
        });
      },
      onInputModeChanged: (mode) {
        setState(() {
          _ssccInputMode = mode;
          clearSsccCodeFields();
        });
        if (mode == SsccInputMode.scan) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scanSSCCCode();
          });
        }
      },
      onGenerateSsccCode: _generateSSCCCode,
      onScanSsccCode: _scanSSCCCode,
      onClearSsccCode: () => setState(clearSsccCodeFields),
      setFieldError: _setFieldError,
      onSyncExtensionDigitFromSscc: _syncExtensionDigitFromSscc,
      onManualSsccCodeChanged: () => setState(() {}),
    );
  }
}
