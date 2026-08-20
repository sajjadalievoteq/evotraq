import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_detail.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/navigation/pop_or_go.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
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
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_validators.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_edit_rules.dart'
    as edit_rules;

import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';

import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/sscc_detail_actions.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/sscc_detail_edit_actions.dart';

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
  State<SSCCDetailScreen> createState() => SSCCDetailScreenState();
}

class SSCCDetailScreenState extends State<SSCCDetailScreen>
    with SsccDetailScreenFields {
  final formKey = GlobalKey<FormState>();
  final pharmaExtensionKey =
      GlobalKey<SSCCPharmaceuticalExtensionWidgetState>();
  late final ValidationCubit validationCubit;
  GLN? issuingGln;
  String? issuingGlnError;
  GLN? shipFromGln;
  GLN? shipToGln;
  GLN? billToGln;
  GLN? shipForGln;
  GLN? custodianGln;
  DateTime? containedExpiry;

  SsccInputMode ssccInputMode = SsccInputMode.generate;

  UnitType unitType = UnitType.PALLET;
  LogisticUnitStatus status = LogisticUnitStatus.DRAFT;
  ContentHomogeneity contentHomogeneity = ContentHomogeneity.UNKNOWN;
  List<String> serverTransitions = const [];
  List<SsccAggregationLink> aggregationLinks = const [];
  DateTime? packingDate;

  bool formFieldsHydrated = true;
  bool hasSubmittedForm = false;
  bool ssccInitialLoadStarted = false;
  String? loadedSsccKey;
  List<GLN> glnPickerCatalog = const [];
  bool glnCatalogLoadStarted = false;
  SSCCCubit? ssccCubit;
  SSCC? sscc;

  bool editRedirectHandled = false;
  bool forceMountAllSections = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    validationCubit = ValidationCubit();
    formFieldsHydrated =
        widget.awaitingListSelection ||
        widget.isCreating ||
        widget.routeSsccCode == null ||
        widget.routeSsccCode!.isEmpty;
    initSsccDetailFields();
    status = LogisticUnitStatus.DRAFT;

    if (!widget.embedded) {
      ssccCubit = SSCCCubit(ssccService: getIt<SSCCService>());
    }

    if (!widget.awaitingListSelection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ensureGlnPickerCatalog();
      });
    }
  }

  @override
  void didUpdateWidget(SSCCDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeSsccCode == widget.routeSsccCode) return;
    if (widget.isCreating || widget.awaitingListSelection) return;

    loadedSsccKey = null;
    lastListSyncKey = null;
    serverRefreshInFlight = false;
    sscc = null;
    formFieldsHydrated = false;
    ssccInitialLoadStarted = false;
    editRedirectHandled = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!ssccInitialLoadStarted) {
        ssccInitialLoadStarted = true;
        startInitialLoad();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.embedded) {
      ssccCubit = context.read<SSCCCubit>();
    }
    if (!ssccInitialLoadStarted) {
      ssccInitialLoadStarted = true;
      if (widget.awaitingListSelection || widget.isCreating) {
        return;
      }
      startInitialLoad();
    }
  }

  bool serverRefreshInFlight = false;
  String? lastListSyncKey;
  String? aggregationLinksRequestedCode;
  Future<void>? aggregationLinksFuture;

  @override
  void dispose() {
    disposeSsccDetailFields();
    scrollController.dispose();
    validationCubit.close();
    super.dispose();
  }

  SSCCCubit get cubit => ssccCubit ?? context.read<SSCCCubit>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final canEditMasterData = auth.isAdmin || auth.isManufacturer;
    final recordEditable =
        widget.isCreating ||
        (widget.isEditing &&
            sscc != null &&
            edit_rules.canEditSsccRecord(sscc!.status));
    final allowMasterDataActions =
        canEditMasterData &&
        !widget.awaitingListSelection &&
        (widget.isCreating || recordEditable);

    final body = BlocConsumer<SSCCCubit, SSCCState>(
      listenWhen: (previous, current) {
        if (previous.ssccs != current.ssccs) return true;
        if (current.status == SSCCStatus.error && current.error != null) {
          if (shouldIgnoreCubitError(current)) return false;
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
            syncDetailWithListIfStale(state);
          }
          if (state.status == SSCCStatus.error && state.error != null) {
            if (shouldIgnoreCubitError(state)) return;
            setState(() {
              formFieldsHydrated = true;
              serverRefreshInFlight = false;
            });
            final message = userFacingSsccErrorMessage(state.error);
            if (hasSubmittedForm) {
              context.showValidationErrors([
                message,
              ], title: 'Cannot save SSCC');
            } else if (sscc == null && !widget.isCreating) {
              context.showError(message);
            }
            return;
          }

          if (state.status == SSCCStatus.success &&
              state.selectedSSCC != null) {
            final sscc = state.selectedSSCC!;
            final matchesRequest = matchesRequestedSscc(sscc);
            final isSaveResult = hasSubmittedForm;

            if (!matchesRequest && !isSaveResult) return;
            if (!isSaveResult &&
                matchesRequest &&
                loadedSsccKey == requestedSsccKey &&
                (sscc == null || !ssccRecordDiffers(sscc!, sscc))) {
              serverRefreshInFlight = false;
              return;
            }

            populateFormFields(sscc);
            serverRefreshInFlight = false;

            if (hasSubmittedForm) {
              setState(() => hasSubmittedForm = false);
              final ssccCode = ssccCodeText();
              savePharmaExtensionIfNeeded(
                parseSsccId(state.selectedSSCC?.id ?? sscc?.id),
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
                    issuingGln!.glnCode,
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
              syncExtensionDigitFromSscc(ssccCode);
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
            sscc == null &&
            !shouldIgnoreCubitError(state)) {
          return SsccDetailErrorPane(
            errorMessage: state.error,
            onRetry: startInitialLoad,
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
      onSave: saveSSCC,
      saveActionTooltip: SsccUiConstants.detailSaveButton,
      body: body,
    );

    Widget result = scaffold;
    if (!widget.embedded) {
      final cubit = ssccCubit;
      if (cubit != null) {
        result = BlocProvider<SSCCCubit>.value(value: cubit, child: scaffold);
      }
    }
    return BlocProvider<ValidationCubit>.value(
      value: validationCubit,
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
            sscc != null &&
            edit_rules.canEditSsccRecord(sscc!.status));
    final isReadOnly = !recordEditable;
    final aggregationEditable = edit_rules.isSsccAggregationEditable(
      isCreating: widget.isCreating,
    );

    return SsccDetailFormBlocBody(
      awaitingListSelection: widget.awaitingListSelection,
      formFieldsHydrated: formFieldsHydrated,
      isCreating: widget.isCreating,
      isEditing: widget.isEditing,
      embedded: widget.embedded,
      allowMasterDataActions: allowMasterDataActions,
      state: state,
      formKey: formKey,
      scrollController: scrollController,
      forceMountAllSections: forceMountAllSections,
      ssccCodeController: ssccCodeController,
      sscc: sscc,
      unitType: unitType,
      status: status,
      contentHomogeneity: contentHomogeneity,
      serverTransitions: serverTransitions,
      packingDate: packingDate,
      containedExpiry: containedExpiry,
      aggregationLinks: aggregationLinks,
      shipFromGln: shipFromGln,
      shipToGln: shipToGln,
      billToGln: billToGln,
      shipForGln: shipForGln,
      custodianGln: custodianGln,
      glnPickerCatalog: glnPickerCatalog,
      ssccInputMode: ssccInputMode,
      extensionDigitController: extensionDigitController,
      containedGtinController: containedGtinController,
      containedQuantityController: containedQuantityController,
      containedBatchController: containedBatchController,
      gsinController: gsinController,
      gincController: gincController,
      poController: poController,
      carrierRoutingController: carrierRoutingController,
      issuingGln: issuingGln,
      issuingGlnError: issuingGlnError,
      pharmaExtensionKey: pharmaExtensionKey,
      parseSsccId: parseSsccId,
      onRefresh: refresh,
      onUnitTypeChanged: (v) => setState(() => unitType = v),
      onHomogeneityChanged: (v) => setState(() => contentHomogeneity = v),
      onPickContainedExpiry: isReadOnly
          ? null
          : () => selectDate(
              context,
              (date) => setState(() => containedExpiry = date),
              initialDate: containedExpiry,
            ),
      onStatusChanged: (s) => setState(() => status = s),
      onTransitionError: (msg) => context.showError(msg),
      onPackingDateSelected: () => selectDate(
        context,
        (date) => setState(() => packingDate = date),
        initialDate: packingDate,
      ),
      onShipFromChanged: (gln) => setState(() => shipFromGln = gln),
      onShipToChanged: (gln) => setState(() => shipToGln = gln),
      onBillToChanged: (gln) => setState(() => billToGln = gln),
      onShipForChanged: (gln) => setState(() => shipForGln = gln),
      onCustodianChanged: (gln) => setState(() => custodianGln = gln),
      onAddChild: !aggregationEditable || sscc?.id == null
          ? null
          : addAggregationChild,
      onDisaggregate: aggregationEditable ? disaggregateChild : null,
      onSave: saveSSCC,
      onIssuingGlnChanged: (gln) {
        setState(() {
          issuingGln = gln;
          issuingGlnError = validateIssuingGlnRequired(gln?.glnCode);
          setFieldError('gln', issuingGlnError);
        });
      },
      onInputModeChanged: (mode) {
        setState(() {
          ssccInputMode = mode;
          clearSsccCodeFields();
        });
        if (mode == SsccInputMode.scan) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) scanSSCCCode();
          });
        }
      },
      onGenerateSsccCode: generateSSCCCode,
      onScanSsccCode: scanSSCCCode,
      onClearSsccCode: () => setState(clearSsccCodeFields),
      setFieldError: setFieldError,
      onSyncExtensionDigitFromSscc: syncExtensionDigitFromSscc,
      onManualSsccCodeChanged: () => setState(() {}),
    );
  }
}
