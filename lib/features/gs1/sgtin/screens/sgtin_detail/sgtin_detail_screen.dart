
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/bloc/sgtin_cubit.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/sgtin_detail_awaiting_selection.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/sgtin_detail_form_bloc_body.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/sgtin_detail_scaffold.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_form_validation_mixin.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart' as gtin_model;

class SGTINDetailScreen extends StatefulWidget {
  const SGTINDetailScreen({
    super.key,
    this.sgtinId,
    this.epcUri,
    required this.isEditing,
    this.embedded = false,
    this.awaitingListSelection = false,
    this.onEmbeddedActionSuccess,
  });

  final String? sgtinId;

  final String? epcUri;

  final bool isEditing;

  final bool embedded;

  final bool awaitingListSelection;

  final VoidCallback? onEmbeddedActionSuccess;

  bool get isCreating => sgtinId == null && epcUri == null;

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
    } else if (widget.epcUri != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadByEpc(widget.epcUri!);
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
    } else if (widget.epcUri != oldWidget.epcUri && widget.epcUri != null) {
      _loadByEpc(widget.epcUri!);
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

  void _loadByEpc(String epcUri) {
    setState(() {
      _isLocalLoading = true;
      _formFieldsHydrated = false;
    });
    context.read<SGTINCubit>().fetchSGTINByEPC(epcUri);
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


  @override
  Widget build(BuildContext context) {
    if (widget.awaitingListSelection) {
      return SgtinDetailAwaitingSelection(embedded: widget.embedded);
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
          } else if (widget.epcUri != null &&
              state.sgtin!.epcUri == widget.epcUri &&
              state.sgtin!.id != _loadedSgtinId) {
            // Navigated from product journey — loaded by EPC URI instead of DB PK.
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
      child: widget.embedded
          ? _formBlocBody()
          : SgtinDetailScaffold(
              appBarTitle: _appBarTitle,
              showEditAction: !widget.isCreating && !_isEditing,
              showCloseEditAction: !widget.isCreating && _isEditing,
              onEdit: () => setState(() => _isEditing = true),
              onCloseEdit: () => setState(() => _isEditing = false),
              body: _formBlocBody(),
              showSaveFab: _isEditing || widget.isCreating,
              isSaving: _isLocalLoading,
              onSave: _submit,
            ),
    );
  }

  SgtinDetailFormBlocBody _formBlocBody() {
    return SgtinDetailFormBlocBody(
      sgtinId: widget.sgtinId,
      formFieldsHydrated: _formFieldsHydrated,
      formKey: _formKey,
      onRefresh: () async {
        if (widget.sgtinId != null) _loadById(widget.sgtinId!);
      },
      isCreating: widget.isCreating,
      isEditing: _isEditing,
      isLocalLoading: _isLocalLoading,
      loadedSgtin: _loadedSgtin,
      gtinController: _gtinController,
      serialNumberController: _serialNumberController,
      batchLotNumberController: _batchLotNumberController,
      regulatoryMarketController: _regulatoryMarketController,
      regulatoryStatusController: _regulatoryStatusController,
      selectedGtin: _selectedGtin,
      selectedLocation: _selectedLocation,
      selectedStatus: _selectedStatus,
      expiryDate: _expiryDate,
      productionDate: _productionDate,
      bestBeforeDate: _bestBeforeDate,
      onGtinChanged: (gtin) {
        setState(() {
          _selectedGtin = gtin;
          _gtinController.text = gtin?.gtinCode ?? '';
        });
      },
      onLocationChanged: (gln) => setState(() => _selectedLocation = gln),
      onStatusChanged: (s) => setState(() => _selectedStatus = s),
      onTransitionError: (msg) => context.showError(msg),
      onPickExpiry: () => _pickDate((d) => setState(() => _expiryDate = d)),
      onPickProduction: () =>
          _pickDate((d) => setState(() => _productionDate = d)),
      onPickBestBefore: () =>
          _pickDate((d) => setState(() => _bestBeforeDate = d)),
      setFieldError: setFieldError,
      onDecommission: _decommission,
      onSubmit: _submit,
    );
  }

  String get _appBarTitle {
    if (widget.isCreating) return SgtinUiConstants.detailTitleCreate;
    if (_isEditing) return SgtinUiConstants.detailTitleEdit;
    return SgtinUiConstants.detailTitleView;
  }

}
