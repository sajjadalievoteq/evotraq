import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_aggregation_link_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/cubit/sscc_cubit.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/utils/sscc_input_mode.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/skeleton/sscc_detail_skeleton.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/sscc_detail_form_body.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/tobacco/sscc_tobacco_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_edit_rules.dart' as edit_rules;

class SsccDetailFormBlocBody extends StatelessWidget {
  const SsccDetailFormBlocBody({
    super.key,
    required this.awaitingListSelection,
    required this.formFieldsHydrated,
    required this.isCreating,
    required this.isEditing,
    required this.embedded,
    required this.allowMasterDataActions,
    required this.formKey,
    required this.scrollController,
    required this.ssccCodeController,
    required this.sscc,
    required this.unitType,
    required this.status,
    required this.contentHomogeneity,
    required this.serverTransitions,
    required this.packingDate,
    required this.containedExpiry,
    required this.aggregationLinks,
    required this.shipFromGln,
    required this.shipToGln,
    required this.billToGln,
    required this.shipForGln,
    required this.custodianGln,
    required this.glnPickerCatalog,
    required this.ssccInputMode,
    required this.extensionDigitController,
    required this.containedGtinController,
    required this.containedQuantityController,
    required this.containedBatchController,
    required this.gsinController,
    required this.gincController,
    required this.poController,
    required this.carrierRoutingController,
    required this.issuingGln,
    required this.issuingGlnError,
    required this.pharmaExtensionKey,
    required this.tobaccoExtensionKey,
    required this.parseSsccId,
    required this.onRefresh,
    required this.onUnitTypeChanged,
    required this.onHomogeneityChanged,
    required this.onPickContainedExpiry,
    required this.onStatusChanged,
    required this.onTransitionError,
    required this.onPackingDateSelected,
    required this.onShipFromChanged,
    required this.onShipToChanged,
    required this.onBillToChanged,
    required this.onShipForChanged,
    required this.onCustodianChanged,
    required this.onAddChild,
    required this.onDisaggregate,
    required this.onSave,
    required this.onIssuingGlnChanged,
    required this.onInputModeChanged,
    required this.onGenerateSsccCode,
    required this.onScanSsccCode,
    required this.onClearSsccCode,
    required this.setFieldError,
    required this.onSyncExtensionDigitFromSscc,
    required this.onManualSsccCodeChanged,
    required this.forceMountAllSections,
    required this.state,
  });

  final bool awaitingListSelection;
  final bool formFieldsHydrated;
  final bool isCreating;
  final bool isEditing;
  final bool embedded;
  final bool allowMasterDataActions;
  final bool forceMountAllSections;
  final SSCCState state;

  final GlobalKey<FormState> formKey;
  final ScrollController scrollController;
  final TextEditingController ssccCodeController;
  final SSCC? sscc;
  final UnitType unitType;
  final LogisticUnitStatus status;
  final ContentHomogeneity contentHomogeneity;
  final List<String> serverTransitions;
  final DateTime? packingDate;
  final DateTime? containedExpiry;
  final List<SsccAggregationLink> aggregationLinks;

  final GLN? shipFromGln;
  final GLN? shipToGln;
  final GLN? billToGln;
  final GLN? shipForGln;
  final GLN? custodianGln;
  final List<GLN> glnPickerCatalog;

  final SsccInputMode ssccInputMode;
  final TextEditingController extensionDigitController;
  final TextEditingController containedGtinController;
  final TextEditingController containedQuantityController;
  final TextEditingController containedBatchController;
  final TextEditingController gsinController;
  final TextEditingController gincController;
  final TextEditingController poController;
  final TextEditingController carrierRoutingController;

  final GLN? issuingGln;
  final String? issuingGlnError;
  final GlobalKey<SSCCPharmaceuticalExtensionWidgetState> pharmaExtensionKey;
  final GlobalKey<SSCCTobaccoExtensionWidgetState> tobaccoExtensionKey;
  final int? Function(String? id) parseSsccId;

  final Future<void> Function() onRefresh;
  final ValueChanged<UnitType> onUnitTypeChanged;
  final ValueChanged<ContentHomogeneity> onHomogeneityChanged;
  final VoidCallback? onPickContainedExpiry;
  final ValueChanged<LogisticUnitStatus> onStatusChanged;
  final ValueChanged<String> onTransitionError;
  final VoidCallback onPackingDateSelected;
  final ValueChanged<GLN?> onShipFromChanged;
  final ValueChanged<GLN?> onShipToChanged;
  final ValueChanged<GLN?> onBillToChanged;
  final ValueChanged<GLN?> onShipForChanged;
  final ValueChanged<GLN?> onCustodianChanged;
  final Future<bool> Function({
    required String childEpc,
    required String childKind,
    required String aggregationEventId,
  })? onAddChild;
  final Future<bool> Function({
    required int linkId,
    required String disaggregationEventId,
  })? onDisaggregate;
  final VoidCallback onSave;

  final ValueChanged<GLN?> onIssuingGlnChanged;
  final ValueChanged<SsccInputMode> onInputModeChanged;
  final VoidCallback onGenerateSsccCode;
  final VoidCallback onScanSsccCode;
  final VoidCallback onClearSsccCode;
  final void Function(String fieldName, String? error) setFieldError;
  final ValueChanged<String> onSyncExtensionDigitFromSscc;
  final VoidCallback onManualSsccCodeChanged;

  bool _fieldSkeletonsActive() {
    if (state.status == SSCCStatus.error) return false;
    if (awaitingListSelection) {
      return state.isListLoading || state.status == SSCCStatus.initial;
    }
    return !formFieldsHydrated;
  }

  @override
  Widget build(BuildContext context) {
    final recordEditable = isCreating ||
        (isEditing && sscc != null && edit_rules.canEditSsccRecord(sscc!.status));
    final isReadOnly = !recordEditable;
    final allowManualStatusEdit = !isReadOnly &&
        edit_rules.canManuallyEditSsccStatus(
          status,
          isCreating: isCreating,
        );
    final aggregationEditable =
        edit_rules.isSsccAggregationEditable(isCreating: isCreating);
    final borderColor = Theme.of(context).colorScheme.outlineVariant;

    return SsccDetailFormBody(
      formKey: formKey,
      scrollController: scrollController,
      showSkeleton: _fieldSkeletonsActive(),
      skeleton: SsccDetailSkeleton(
        showHeaderBanner: !isCreating,
        showCreateSection: isCreating,
      ),
      isCreating: isCreating,
      embedded: embedded,
      allowMasterDataActions: allowMasterDataActions,
      isReadOnly: isReadOnly,
      allowManualStatusEdit: allowManualStatusEdit,
      aggregationEditable: aggregationEditable,
      borderColor: borderColor,
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
      tobaccoExtensionKey: tobaccoExtensionKey,
      parseSsccId: parseSsccId,
      onRefresh: onRefresh,
      onUnitTypeChanged: onUnitTypeChanged,
      onHomogeneityChanged: onHomogeneityChanged,
      onPickContainedExpiry: onPickContainedExpiry,
      onStatusChanged: onStatusChanged,
      onTransitionError: onTransitionError,
      onPackingDateSelected: onPackingDateSelected,
      onShipFromChanged: onShipFromChanged,
      onShipToChanged: onShipToChanged,
      onBillToChanged: onBillToChanged,
      onShipForChanged: onShipForChanged,
      onCustodianChanged: onCustodianChanged,
      onAddChild: onAddChild,
      onDisaggregate: onDisaggregate,
      onSave: onSave,
      onIssuingGlnChanged: onIssuingGlnChanged,
      onInputModeChanged: onInputModeChanged,
      onGenerateSsccCode: onGenerateSsccCode,
      onScanSsccCode: onScanSsccCode,
      onClearSsccCode: onClearSsccCode,
      setFieldError: setFieldError,
      onSyncExtensionDigitFromSscc: onSyncExtensionDigitFromSscc,
      onManualSsccCodeChanged: onManualSsccCodeChanged,
      forceMountAllSections: forceMountAllSections,
    );
  }
}
