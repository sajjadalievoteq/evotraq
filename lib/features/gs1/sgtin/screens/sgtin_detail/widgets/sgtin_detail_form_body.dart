import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart'
    as gtin_model;
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_lookup_status.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_state.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/batch/sgtin_batch_master_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_audit_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_batch_date_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_commissioning_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_epc_identity_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_epcis_snapshot_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_lifecycle_status_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_location_custody_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_packed_items_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_regulatory_info_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_serial_governance_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_serial_item_identity_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/core_groups/sgtin_verification_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/pharma/sgtin_pharma_extension_section.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/sgtin_detail_header_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_status_rules.dart'
    as status_rules;
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_detail_skeleton.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_form_shimmer_layer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';

class SgtinDetailFormBody extends StatelessWidget {
  const SgtinDetailFormBody({
    super.key,
    required this.formKey,
    required this.onRefresh,
    required this.showSkeleton,
    required this.isCreating,
    required this.isEditing,
    required this.isLocalLoading,
    required this.loadedSgtin,
    required this.borderColor,
    required this.gtinController,
    required this.serialNumberController,
    required this.batchLotNumberController,
    required this.regulatoryMarketController,
    required this.regulatoryStatusController,
    required this.selectedGtin,
    required this.selectedStatus,
    required this.expiryDate,
    required this.productionDate,
    required this.bestBeforeDate,
    required this.onGtinChanged,
    required this.onStatusChanged,
    required this.onTransitionError,
    required this.onPickExpiry,
    required this.onPickProduction,
    required this.onPickBestBefore,
    required this.setFieldError,
    required this.onDecommission,
    required this.onSubmit,
    this.onBatchLotEditingComplete,
    this.onBatchLotFocusLost,
  });

  final GlobalKey<FormState> formKey;
  final Future<void> Function() onRefresh;
  final bool showSkeleton;
  final bool isCreating;
  final bool isEditing;
  final bool isLocalLoading;
  final SGTIN? loadedSgtin;
  final Color borderColor;

  final TextEditingController gtinController;
  final TextEditingController serialNumberController;
  final TextEditingController batchLotNumberController;
  final TextEditingController regulatoryMarketController;
  final TextEditingController regulatoryStatusController;

  final gtin_model.GTIN? selectedGtin;
  final ItemStatus? selectedStatus;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;

  final ValueChanged<gtin_model.GTIN?> onGtinChanged;
  final ValueChanged<ItemStatus> onStatusChanged;
  final ValueChanged<String> onTransitionError;
  final VoidCallback onPickExpiry;
  final VoidCallback onPickProduction;
  final VoidCallback onPickBestBefore;
  final void Function(String fieldName, String? error) setFieldError;
  final VoidCallback onDecommission;
  final VoidCallback onSubmit;
  final VoidCallback? onBatchLotEditingComplete;
  final VoidCallback? onBatchLotFocusLost;

  @override
  Widget build(BuildContext context) {
    if (showSkeleton) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            top: context.padding.left,
            right: context.padding.left,
            left: context.padding.left,
          ),
          child: Form(
            key: formKey,
            child: Gs1FormShimmerLayer(
              show: true,
              skeleton: const SgtinDetailSkeleton(),
              formColumn: const SizedBox.shrink(),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          top: context.padding.left,
          right: context.padding.left,
          left: context.padding.left,
        ),
        child: Form(
          key: formKey,
          child: Gs1FormShimmerLayer(
            show: showSkeleton,
            skeleton: const SgtinDetailSkeleton(),
            formColumn: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (loadedSgtin != null && !isCreating) ...[
                  SgtinDetailHeaderCard(
                    gtinCode: gtinController.text,
                    serialNumber: serialNumberController.text,
                    batchLotNumber: batchLotNumberController.text,
                    status: selectedStatus,
                  ),
                  const SizedBox(height: 16),
                  SgtinEpcIdentityCard(
                    sgtin: loadedSgtin!,
                    borderColor: borderColor,
                  ),
                ],
                SgtinSerialItemIdentityCard(
                  borderColor: borderColor,
                  isEditing: isEditing,
                  isCreating: isCreating,
                  gtinController: gtinController,
                  serialNumberController: serialNumberController,
                  selectedGtin: selectedGtin,
                  onGtinChanged: onGtinChanged,
                  setFieldError: setFieldError,
                ),
                if (isCreating)
                  _SgtinCreateBatchSection(
                    borderColor: borderColor,
                    batchLotNumberController: batchLotNumberController,
                    expiryDate: expiryDate,
                    productionDate: productionDate,
                    bestBeforeDate: bestBeforeDate,
                    expiryDateTime: loadedSgtin?.expiryDateTime,
                    onPickExpiry: onPickExpiry,
                    onPickProduction: onPickProduction,
                    onPickBestBefore: onPickBestBefore,
                    setFieldError: setFieldError,
                    onBatchLotEditingComplete: onBatchLotEditingComplete,
                    onBatchLotFocusLost: onBatchLotFocusLost,
                  )
                else
                  SgtinBatchDateCard(
                    borderColor: borderColor,
                    isCreating: isCreating,
                    batchLotNumberController: batchLotNumberController,
                    expiryDate: expiryDate,
                    productionDate: productionDate,
                    bestBeforeDate: bestBeforeDate,
                    expiryDateTime: loadedSgtin?.expiryDateTime,
                    onPickExpiry: onPickExpiry,
                    onPickProduction: onPickProduction,
                    onPickBestBefore: onPickBestBefore,
                    setFieldError: setFieldError,
                  ),
                SgtinLifecycleStatusCard(
                  borderColor: borderColor,
                  isEditing: isEditing,
                  isCreating: isCreating,
                  selectedStatus: selectedStatus,
                  sgtin: loadedSgtin,
                  onStatusChanged: onStatusChanged,
                  onTransitionError: onTransitionError,
                ),
                if (!isCreating)
                  SgtinCommissioningCard(
                    borderColor: borderColor,
                    sgtin: loadedSgtin,
                  ),
                if (loadedSgtin != null && !isCreating)
                  SgtinLocationCustodyCard(
                    sgtin: loadedSgtin!,
                    borderColor: borderColor,
                  ),
                if (loadedSgtin != null && !isCreating)
                  SgtinPackedItemsCard(
                    sgtin: loadedSgtin!,
                    borderColor: borderColor,
                  ),
                SgtinRegulatoryInfoCard(
                  borderColor: borderColor,
                  isEditing: isEditing,
                  regulatoryMarketController: regulatoryMarketController,
                  regulatoryStatusController: regulatoryStatusController,
                  setFieldError: setFieldError,
                ),
                if (loadedSgtin != null && !isCreating)
                  SgtinEpcisSnapshotCard(
                    sgtin: loadedSgtin!,
                    borderColor: borderColor,
                  ),
                if (loadedSgtin != null && !isCreating)
                  SgtinVerificationCard(
                    sgtin: loadedSgtin!,
                    borderColor: borderColor,
                  ),
                if (loadedSgtin != null &&
                    !isCreating &&
                    (loadedSgtin!.serialGenerationStrategy != null ||
                        loadedSgtin!.serialOrigin != null ||
                        loadedSgtin!.serialRangeId != null ||
                        loadedSgtin!.serialGuessingProbability != null ||
                        loadedSgtin!.serialEntropySeed != null))
                  SgtinSerialGovernanceCard(
                    sgtin: loadedSgtin!,
                    borderColor: borderColor,
                  ),
                if (loadedSgtin != null && !isCreating)
                  SgtinAuditCard(sgtin: loadedSgtin!, borderColor: borderColor),
                if (loadedSgtin?.pharmaExtension != null && !isCreating)
                  SgtinPharmaExtensionSection(
                    extension_: loadedSgtin!.pharmaExtension!,
                    borderColor: borderColor,
                  ),
                if (!isCreating &&
                    !isEditing &&
                    loadedSgtin != null &&
                    selectedStatus != null &&
                    !status_rules.isTerminal(selectedStatus!))
                  Gs1GroupCard(
                    title: 'Actions',
                    outlineColor: borderColor,
                    child: SizedBox(
                      width: double.infinity,
                      child: CustomButtonWidget(
                        title: 'Decommission SGTIN',
                        onTap: onDecommission,
                      ),
                    ),
                  ),
                if (isEditing || isCreating) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: isCreating
                        ? BlocBuilder<SgtinBatchCubit, SgtinBatchState>(
                            builder: (context, batchState) {
                              final blocked =
                                  isLocalLoading || batchState.isBusy;
                              return CustomButtonWidget(
                                title: SgtinUiConstants.submitCreateSgtin,
                                onTap: blocked ? null : onSubmit,
                                height: 50,
                              );
                            },
                          )
                        : CustomButtonWidget(
                            title: SgtinUiConstants.submitUpdateSgtin,
                            onTap: isLocalLoading ? null : onSubmit,
                            height: 50,
                          ),
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SgtinCreateBatchSection extends StatefulWidget {
  const _SgtinCreateBatchSection({
    required this.borderColor,
    required this.batchLotNumberController,
    required this.expiryDate,
    required this.productionDate,
    required this.bestBeforeDate,
    required this.expiryDateTime,
    required this.onPickExpiry,
    required this.onPickProduction,
    required this.onPickBestBefore,
    required this.setFieldError,
    this.onBatchLotEditingComplete,
    this.onBatchLotFocusLost,
  });

  final Color borderColor;
  final TextEditingController batchLotNumberController;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final DateTime? bestBeforeDate;
  final DateTime? expiryDateTime;
  final VoidCallback onPickExpiry;
  final VoidCallback onPickProduction;
  final VoidCallback onPickBestBefore;
  final void Function(String, String?) setFieldError;
  final VoidCallback? onBatchLotEditingComplete;
  final VoidCallback? onBatchLotFocusLost;

  @override
  State<_SgtinCreateBatchSection> createState() =>
      _SgtinCreateBatchSectionState();
}

class _SgtinCreateBatchSectionState extends State<_SgtinCreateBatchSection> {
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _register() {
    final qtyText = _quantityController.text.trim();
    context.read<SgtinBatchCubit>().registerBatch(
      batchLot: widget.batchLotNumberController.text,
      manufactureDate: widget.productionDate,
      expiryDate: widget.expiryDate,
      quantityManufactured: qtyText.isEmpty ? null : int.tryParse(qtyText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.batchLotNumberController,
      builder: (context, _) {
        return BlocBuilder<SgtinBatchCubit, SgtinBatchState>(
          builder: (context, batchState) {
            final lot = widget.batchLotNumberController.text.trim();
            final canRegister = batchState.status.needsRegistration;
            return SgtinBatchDateCard(
              borderColor: widget.borderColor,
              isCreating: true,
              batchLotNumberController: widget.batchLotNumberController,
              expiryDate: widget.expiryDate,
              productionDate: widget.productionDate,
              bestBeforeDate: widget.bestBeforeDate,
              expiryDateTime: widget.expiryDateTime,
              onPickExpiry: widget.onPickExpiry,
              onPickProduction: widget.onPickProduction,
              onPickBestBefore: widget.onPickBestBefore,
              lockDatesFromBatch: batchState.status.isResolved,
              showRegistrationFields: canRegister,
              quantityController: _quantityController,
              onRegister: canRegister ? _register : null,
              isRegistering:
                  batchState.status == SgtinBatchLookupStatus.registering,
              setFieldError: widget.setFieldError,
              onBatchLotEditingComplete: widget.onBatchLotEditingComplete,
              onBatchLotFocusLost: widget.onBatchLotFocusLost,
              batchStatusPanel: lot.isEmpty
                  ? null
                  : SgtinBatchMasterCard(state: batchState, batchLot: lot),
            );
          },
        );
      },
    );
  }
}
