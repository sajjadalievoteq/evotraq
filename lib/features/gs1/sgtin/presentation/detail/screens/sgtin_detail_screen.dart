
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/bloc/sgtin_cubit.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/core_groups/sgtin_audit_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/core_groups/sgtin_batch_date_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/core_groups/sgtin_commissioning_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/core_groups/sgtin_epc_identity_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/core_groups/sgtin_epcis_snapshot_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/core_groups/sgtin_lifecycle_status_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/core_groups/sgtin_location_custody_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/core_groups/sgtin_regulatory_info_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/core_groups/sgtin_serial_governance_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/core_groups/sgtin_serial_item_identity_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/core_groups/sgtin_verification_card.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/pharma/sgtin_pharma_extension_section.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_detail_skeleton.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/utilities/sgtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_form_validation_mixin.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_form_shimmer_layer.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart' as gtin_model;
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_status_rules.dart'
    as status_rules;

import '../../../../../../core/theme/traq_theme.dart';
import '../../../../../../core/utils/responsive_utils.dart';
import '../../../../widgets/card_with_background_widget.dart';

class SGTINDetailScreen extends StatefulWidget {
  const SGTINDetailScreen({
    super.key,
    this.sgtinId,
    required this.isEditing,
    this.embedded = false,
    this.awaitingListSelection = false,
    this.onEmbeddedActionSuccess,
  });

  final String? sgtinId;

  final bool isEditing;

  final bool embedded;

  final bool awaitingListSelection;

  final VoidCallback? onEmbeddedActionSuccess;

  bool get isCreating => sgtinId == null;

  @override
  State<SGTINDetailScreen> createState() => _SGTINDetailScreenState();
}

class _SGTINDetailScreenState extends State<SGTINDetailScreen>
    with GS1FormValidationMixin<SGTINDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late bool _isEditing;
  bool _isLocalLoading = false;
  bool _formFieldsHydrated = false;

  late TextEditingController _serialNumberController;
  late TextEditingController _batchLotNumberController;
  late TextEditingController _gtinController;
  late TextEditingController _expiryDateController;
  late TextEditingController _regulatoryMarketController;
  late TextEditingController _regulatoryStatusController;

  DateTime? _expiryDate;
  DateTime? _productionDate;
  DateTime? _bestBeforeDate;
  ItemStatus? _selectedStatus;
  GLN? _selectedLocation;
  gtin_model.GTIN? _selectedGtin;

  String? _loadedSgtinId;

  SGTIN? _loadedSgtin;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isEditing;

    _serialNumberController = TextEditingController();
    _batchLotNumberController = TextEditingController();
    _gtinController = TextEditingController();
    _regulatoryMarketController = TextEditingController();
    _regulatoryStatusController = TextEditingController();
    _expiryDateController = TextEditingController();

    if (widget.sgtinId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadById(widget.sgtinId!);
      });
    }
  }

  @override
  void didUpdateWidget(SGTINDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sgtinId != oldWidget.sgtinId) {
      _isEditing = widget.isEditing;
      if (widget.sgtinId != null) {
        _loadById(widget.sgtinId!);
      } else {
        _clearForm();
      }
    }
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    _batchLotNumberController.dispose();
    _gtinController.dispose();
    _expiryDateController.dispose();
    _regulatoryMarketController.dispose();
    _regulatoryStatusController.dispose();
    super.dispose();
  }

  void _loadById(String id) {
    setState(() {
      _isLocalLoading = true;
      _formFieldsHydrated = false;
    });
    context.read<SGTINCubit>().fetchSGTINById(id);
  }

  void _clearForm() {
    _serialNumberController.clear();
    _batchLotNumberController.clear();
    _gtinController.clear();
    _expiryDateController.clear();
    _regulatoryMarketController.clear();
    _regulatoryStatusController.clear();
    setState(() {
      _expiryDate = null;
      _productionDate = null;
      _bestBeforeDate = null;
      _selectedStatus = null;
      _selectedLocation = null;
      _selectedGtin = null;
      _loadedSgtinId = null;
      _loadedSgtin = null;
    });
  }

  void _populateForm(SGTIN sgtin) {
    _serialNumberController.text = sgtin.serialNumber;
    _batchLotNumberController.text = sgtin.batchLotNumber ?? '';
    _gtinController.text = sgtin.gtinCode;
    _regulatoryMarketController.text = sgtin.regulatoryMarket ?? '';
    _regulatoryStatusController.text = sgtin.regulatoryStatus ?? '';
    if (sgtin.expiryDate != null) {
      _expiryDateController.text =
          DateFormat('yyyy-MM-dd').format(sgtin.expiryDate!);
    } else {
      _expiryDateController.clear();
    }
    setState(() {
      _expiryDate = sgtin.expiryDate;
      _productionDate = sgtin.productionDate;
      _bestBeforeDate = sgtin.bestBeforeDate;
      _selectedStatus = sgtin.status;
      _selectedLocation = sgtin.currentLocation;
      _selectedGtin = null;
      _loadedSgtinId = sgtin.id;
      _loadedSgtin = sgtin;
      _isLocalLoading = false;
      _formFieldsHydrated = true;
    });
  }

  Future<void> _pickDate(void Function(DateTime) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) onPicked(picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.isCreating && _selectedLocation == null) {
      context.showWarning('Commissioning Location is required for new SGTINs');
      return;
    }
    if (widget.isCreating && _selectedGtin == null) {
      context.showWarning('A GTIN must be selected for new SGTINs');
      return;
    }

    setState(() => _isLocalLoading = true);

    final sgtin = SGTIN(
      id: _loadedSgtinId,
      serialNumber: _serialNumberController.text,
      gtinCode: _selectedGtin?.gtinCode ?? _gtinController.text,
      batchLotNumber: _batchLotNumberController.text.isNotEmpty
          ? _batchLotNumberController.text
          : null,
      expiryDate: _expiryDate,
      productionDate: _productionDate,
      bestBeforeDate: _bestBeforeDate,
      status: _selectedStatus ?? ItemStatus.COMMISSIONED,
      currentLocation: _selectedLocation,
      regulatoryMarket: _regulatoryMarketController.text.isNotEmpty
          ? _regulatoryMarketController.text
          : null,
      regulatoryStatus: _regulatoryStatusController.text.isNotEmpty
          ? _regulatoryStatusController.text
          : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_loadedSgtinId != null) {
      context.read<SGTINCubit>().updateSGTIN(_loadedSgtinId!, sgtin);
    } else {
      context.read<SGTINCubit>().createSGTIN(sgtin);
    }
  }

  void _decommission() {
    String reason = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decommission SGTIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for decommissioning:'),
            SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (v) => reason = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (reason.isNotEmpty) {
                Navigator.pop(ctx);
                final serial = _serialNumberController.text;
                context.read<SGTINCubit>().decommission(serial, reason);
              }
            },
            child: const Text('Decommission'),
          ),
        ],
      ),
    );
  }

  bool _fieldSkeletonsActive(SGTINState state) {
    if (state.status == SGTINStatus.error) return false;
    return !_formFieldsHydrated;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.awaitingListSelection) {
      return _buildAwaitingSelection();
    }

    return BlocListener<SGTINCubit, SGTINState>(
      listenWhen: (prev, curr) =>
          curr.status != prev.status ||
          curr.sgtin != prev.sgtin ||
          curr.creationSuccessful != prev.creationSuccessful,
      listener: (context, state) {
        if (state.status == SGTINStatus.loading) return;

        setState(() => _isLocalLoading = false);

        if (state.status == SGTINStatus.error) {
          context.showError(state.error ?? 'An error occurred');
          return;
        }

        if (state.status == SGTINStatus.success && state.sgtin != null) {
          if (widget.sgtinId != null &&
              state.sgtin!.id == widget.sgtinId &&
              state.sgtin!.id != _loadedSgtinId) {
            _populateForm(state.sgtin!);
          }

          if (state.creationSuccessful) {
            final serial = state.sgtin!.serialNumber;
            if (widget.isCreating) {
              context.showSuccess(SgtinUiConstants.successSgtinCreated(serial));
            } else {
              context.showSuccess(SgtinUiConstants.successSgtinUpdated(serial));
            }

            if (widget.onEmbeddedActionSuccess != null) {
              widget.onEmbeddedActionSuccess!();
            } else {
              context.go(Constants.gs1SgtinsRoute);
            }
          }
        }
      },
      child: widget.embedded ? _buildBody() : _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: Text(_appBarTitle),
        actions: [
          if (!widget.isCreating && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (!widget.isCreating && _isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
      floatingActionButton: (_isEditing || widget.isCreating)
          ? FloatingActionButton(
              onPressed: _submit,
              child: _isLocalLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save),
            )
          : null,
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant;

    return BlocBuilder<SGTINCubit, SGTINState>(
      builder: (context, state) {
        final sk = widget.sgtinId != null && _fieldSkeletonsActive(state);

        return RefreshIndicator(
          onRefresh: () async {
            if (widget.sgtinId != null) _loadById(widget.sgtinId!);
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(
              top: context.padding.left,
              right: context.padding.left,
              left: context.padding.left,
            ),
            child: Form(
              key: _formKey,
              child: Gs1FormShimmerLayer(
                show: sk,
                skeleton: const SgtinDetailSkeleton(),
                formColumn: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_loadedSgtin != null && !widget.isCreating) ...[
                      CardWithBackgroundWidget(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 3,
                            children: [
                              Text(
                                '(01)${_gtinController.text??''}(21)${_serialNumberController.text??''}',
                                style: context.text.h1.copyWith(color: Colors.white),
                              ),
                              Text(
                              _batchLotNumberController.text,
                                style: context.text.h3.copyWith(color: Colors.white),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  _selectedStatus?.name??'',
                                  style: context.text.h3.copyWith(
                                    color: context.colors.textFaint,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SgtinEpcIdentityCard(
                        sgtin: _loadedSgtin!,
                        borderColor: borderColor,
                      ),
                    ],

                    SgtinSerialItemIdentityCard(
                      borderColor: borderColor,
                      isEditing: _isEditing,
                      isCreating: widget.isCreating,
                      gtinController: _gtinController,
                      serialNumberController: _serialNumberController,
                      batchLotNumberController: _batchLotNumberController,
                      selectedGtin: _selectedGtin,
                      onGtinChanged: (gtin) {
                        setState(() {
                          _selectedGtin = gtin;
                          _gtinController.text = gtin?.gtinCode ?? '';
                        });
                      },
                      setFieldError: setFieldError,
                    ),

                    SgtinBatchDateCard(
                      borderColor: borderColor,
                      isCreating: widget.isCreating,
                      expiryDate: _expiryDate,
                      productionDate: _productionDate,
                      bestBeforeDate: _bestBeforeDate,
                      expiryDateTime: _loadedSgtin?.expiryDateTime,
                      onPickExpiry: () =>
                          _pickDate((d) => setState(() => _expiryDate = d)),
                      onPickProduction: () =>
                          _pickDate((d) => setState(() => _productionDate = d)),
                      onPickBestBefore: () =>
                          _pickDate((d) => setState(() => _bestBeforeDate = d)),
                    ),

                    SgtinLifecycleStatusCard(
                      borderColor: borderColor,
                      isEditing: _isEditing,
                      isCreating: widget.isCreating,
                      selectedStatus: _selectedStatus,
                      sgtin: _loadedSgtin,
                      onStatusChanged: (s) => setState(() => _selectedStatus = s),
                      onTransitionError: (msg) => context.showError(msg),
                    ),

                    SgtinCommissioningCard(
                      borderColor: borderColor,
                      isEditing: _isEditing,
                      isCreating: widget.isCreating,
                      sgtin: _loadedSgtin,
                      selectedLocation: _selectedLocation,
                      onLocationChanged: (gln) =>
                          setState(() => _selectedLocation = gln),
                    ),

                    if (_loadedSgtin != null && !widget.isCreating)
                      SgtinLocationCustodyCard(
                        sgtin: _loadedSgtin!,
                        borderColor: borderColor,
                      ),

                    SgtinRegulatoryInfoCard(
                      borderColor: borderColor,
                      isEditing: _isEditing,
                      regulatoryMarketController: _regulatoryMarketController,
                      regulatoryStatusController: _regulatoryStatusController,
                      setFieldError: setFieldError,
                    ),

                    if (_loadedSgtin != null && !widget.isCreating)
                      SgtinEpcisSnapshotCard(
                        sgtin: _loadedSgtin!,
                        borderColor: borderColor,
                      ),

                    if (_loadedSgtin != null && !widget.isCreating)
                      SgtinVerificationCard(
                        sgtin: _loadedSgtin!,
                        borderColor: borderColor,
                      ),

                    if (_loadedSgtin != null &&
                        !widget.isCreating &&
                        (_loadedSgtin!.serialGenerationStrategy != null ||
                            _loadedSgtin!.serialOrigin != null ||
                            _loadedSgtin!.serialRangeId != null ||
                            _loadedSgtin!.serialGuessingProbability != null ||
                            _loadedSgtin!.serialEntropySeed != null))
                      SgtinSerialGovernanceCard(
                        sgtin: _loadedSgtin!,
                        borderColor: borderColor,
                      ),

                    if (_loadedSgtin != null && !widget.isCreating)
                      SgtinAuditCard(
                        sgtin: _loadedSgtin!,
                        borderColor: borderColor,
                      ),

                    if (_loadedSgtin?.pharmaExtension != null &&
                        !widget.isCreating)
                      SgtinPharmaExtensionSection(
                        extension_: _loadedSgtin!.pharmaExtension!,
                        borderColor: borderColor,
                      ),

                    if (!widget.isCreating &&
                        !_isEditing &&
                        _loadedSgtin != null &&
                        _selectedStatus != null &&
                        !status_rules.isTerminal(_selectedStatus!))
                      Gs1GroupCard(
                        title: 'Actions',
                        outlineColor: borderColor,
                        child: SizedBox(
                          width: double.infinity,
                          child: CustomButtonWidget(
                            title: 'Decommission SGTIN',

                            onTap: _decommission,
                          ),
                        ),
                      ),
                    if (_isEditing || widget.isCreating) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButtonWidget(
                          title: widget.isCreating
                              ? SgtinUiConstants.submitCreateSgtin
                              : SgtinUiConstants.submitUpdateSgtin,
                          onTap: _isLocalLoading ? null : _submit,
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
      },
    );
  }

  Widget _buildAwaitingSelection() {
    final theme = Theme.of(context);
    final body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
           SizedBox(height: 16),
          Text(
            SgtinUiConstants.awaitingSelectionTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
           SizedBox(height: 8),
          Text(
            SgtinUiConstants.awaitingSelectionSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return widget.embedded ? body : Scaffold(body: body);
  }

  String get _appBarTitle {
    if (widget.isCreating) return SgtinUiConstants.detailTitleCreate;
    if (_isEditing) return SgtinUiConstants.detailTitleEdit;
    return SgtinUiConstants.detailTitleView;
  }

}
