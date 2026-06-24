import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_aggregation_link_model.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/utils/sscc_input_mode.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/core_groups/sscc_aggregation_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/core_groups/sscc_classification_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/core_groups/sscc_dates_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/core_groups/sscc_epcis_audit_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/core_groups/sscc_lifecycle_status_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/core_groups/sscc_parties_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/core_groups/sscc_pharma_compliance_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/core_groups/sscc_transport_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/sscc_detail_code_section.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/sscc_detail_header_card.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/tobacco/sscc_tobacco_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_form_shimmer_layer.dart';

class SsccDetailFormBody extends StatelessWidget {
  const SsccDetailFormBody({
    super.key,
    required this.formKey,
    required this.scrollController,
    required this.showSkeleton,
    required this.skeleton,
    required this.isCreating,
    required this.embedded,
    required this.allowMasterDataActions,
    required this.isReadOnly,
    required this.allowManualStatusEdit,
    required this.aggregationEditable,
    required this.borderColor,
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
  });

  final GlobalKey<FormState> formKey;
  final ScrollController scrollController;
  final bool showSkeleton;
  final Widget skeleton;
  final bool isCreating;
  final bool embedded;
  final bool allowMasterDataActions;
  final bool isReadOnly;
  final bool allowManualStatusEdit;
  final bool aggregationEditable;
  final Color borderColor;

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

  @override
  Widget build(BuildContext context) {
    final showHeader =
        ssccCodeController.text.isNotEmpty && !isCreating;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          top: context.horizontalPadding.left,
          right: context.horizontalPadding.left,
          left: context.horizontalPadding.left,
        ),
        child: Form(
          key: formKey,
          child: Gs1FormShimmerLayer(
            show: showSkeleton,
            formColumn: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showHeader) ...[
                  SsccDetailHeaderCard(
                    ssccCode: ssccCodeController.text,
                    unitType: unitType,
                    status: status,
                    sscc: sscc,
                  ),
                  const SizedBox(height: 16),
                ],

                if (isCreating)
                  SsccDetailCodeSection(
                    isReadOnly: isReadOnly,
                    ssccInputMode: ssccInputMode,
                    ssccCodeController: ssccCodeController,
                    extensionDigitController: extensionDigitController,
                    issuingGln: issuingGln,
                    issuingGlnError: issuingGlnError,
                    sscc: sscc,
                    glnPickerCatalog: glnPickerCatalog,
                    onIssuingGlnChanged: onIssuingGlnChanged,
                    onInputModeChanged: onInputModeChanged,
                    onGenerateSsccCode: onGenerateSsccCode,
                    onScanSsccCode: onScanSsccCode,
                    onClearSsccCode: onClearSsccCode,
                    setFieldError: setFieldError,
                    onSyncExtensionDigitFromSscc: onSyncExtensionDigitFromSscc,
                    onManualSsccCodeChanged: onManualSsccCodeChanged,
                  ),
                const SizedBox(height: 16),
                SsccClassificationCard(
                  borderColor: borderColor,
                  isReadOnly: isReadOnly,
                  unitType: unitType,
                  contentHomogeneity: contentHomogeneity,
                  onUnitTypeChanged: onUnitTypeChanged,
                  onHomogeneityChanged: onHomogeneityChanged,
                  containedGtinController: containedGtinController,
                  containedQuantityController: containedQuantityController,
                  containedBatchController: containedBatchController,
                  containedExpiry: containedExpiry,
                  onPickContainedExpiry: onPickContainedExpiry,
                ),
                const SizedBox(height: 12),
                SsccLifecycleStatusCard(
                  borderColor: borderColor,
                  allowManualStatusEdit: allowManualStatusEdit,
                  isCreating: isCreating,
                  isReadOnly: isReadOnly,
                  sscc: sscc,
                  selectedStatus: status,
                  serverTransitions: serverTransitions,
                  onStatusChanged: onStatusChanged,
                  onTransitionError: onTransitionError,
                ),
                const SizedBox(height: 12),
                SsccDatesCard(
                  borderColor: borderColor,
                  isReadOnly: isReadOnly,
                  packingDate: packingDate,
                  sscc: sscc,
                  onPackingDateSelected: onPackingDateSelected,
                ),
                if (!isCreating) ...[
                  const SizedBox(height: 12),
                  SsccPartiesCard(
                    borderColor: borderColor,
                    isReadOnly: isReadOnly,
                    shipFromGln: shipFromGln,
                    shipToGln: shipToGln,
                    billToGln: billToGln,
                    shipForGln: shipForGln,
                    custodianGln: custodianGln,
                    onShipFromChanged: onShipFromChanged,
                    onShipToChanged: onShipToChanged,
                    onBillToChanged: onBillToChanged,
                    onShipForChanged: onShipForChanged,
                    onCustodianChanged: onCustodianChanged,
                    sscc: sscc,
                    pickerCatalog:
                        glnPickerCatalog.isEmpty ? null : glnPickerCatalog,
                  ),
                  const SizedBox(height: 12),
                  SsccTransportCard(
                    borderColor: borderColor,
                    isReadOnly: isReadOnly,
                    gsinController: gsinController,
                    gincController: gincController,
                    poController: poController,
                    carrierRoutingController: carrierRoutingController,
                    sscc: sscc,
                  ),
                  const SizedBox(height: 12),
                  SsccAggregationCard(
                    borderColor: borderColor,
                    sscc: sscc,
                    aggregationLinks: aggregationLinks,
                    isReadOnly: !aggregationEditable,
                    onAddChild: onAddChild,
                    onDisaggregate: onDisaggregate,
                  ),
                  const SizedBox(height: 12),
                  SsccEpcisAuditCard(
                    borderColor: borderColor,
                    sscc: sscc,
                  ),
                ],
                const SizedBox(height: 24.0),
                BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
                  builder: (context, settingsState) {
                    final settings = settingsState.settings;
                    final currentSsccCode =
                        (sscc?.ssccCode ?? ssccCodeController.text).trim();
                    final hasSsccCode = currentSsccCode.isNotEmpty;
                    final hasPersistedSscc = !isCreating && hasSsccCode;

                    if (settings.isPharmaceuticalMode) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (hasPersistedSscc && sscc?.id != null) ...[
                            SsccPharmaComplianceCard(
                              borderColor: borderColor,
                              ssccId: sscc!.id!,
                              isReadOnly: isReadOnly,
                            ),
                            const SizedBox(height: 12),
                          ],
                          SSCCPharmaceuticalExtensionWidget(
                            key: pharmaExtensionKey,
                            ssccId: parseSsccId(sscc?.id),
                            ssccCode: hasSsccCode ? currentSsccCode : null,
                            isEditing: !isReadOnly,
                            borderColor: borderColor,
                          ),
                        ],
                      );
                    }

                    if (settings.isTobaccoMode && kTobaccoExtensionEnabled) {
                      return SSCCTobaccoExtensionWidget(
                        key: tobaccoExtensionKey,
                        ssccCode: hasSsccCode ? currentSsccCode : null,
                        isEditing: !isReadOnly,
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 24),
                if (embedded && allowMasterDataActions) ...[
                  CustomButtonWidget(
                    onTap: onSave,
                    title: SsccUiConstants.detailSaveButton,
                  ),
                  const SizedBox(height: 32),
                ],
                if (allowMasterDataActions &&
                    (!embedded || MediaQuery.of(context).size.width < 600))
                  CustomButtonWidget(
                    onTap: onSave,
                    title: SsccUiConstants.detailSaveButton,
                  ),
                const SizedBox(height: 32),
              ],
            ),
            skeleton: skeleton,
          ),
        ),
      ),
    );
  }
}
