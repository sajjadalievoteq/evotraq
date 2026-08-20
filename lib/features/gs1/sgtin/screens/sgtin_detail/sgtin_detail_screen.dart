import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_lookup_status.dart';
import 'package:traqtrace_app/features/gs1/sgtin/cubit/sgtin_batch_state.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/sgtin_detail_form_bloc_body.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/sgtin_detail_body.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/sgtin_detail_cubit_providers.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/sgtin_detail_screen_content.dart';
import 'package:traqtrace_app/features/gs1/sgtin/utils/sgtin_ui_constants.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart'
    as gtin_model;
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';
import 'package:traqtrace_app/features/gs1/sgtin/screens/sgtin_detail/widgets/sgtin_decommission_dialog.dart';

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

class _SGTINDetailScreenState extends State<SGTINDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ValidationCubit _validationCubit;

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
  SGTINCubit? _sgtinCubit;
  SgtinBatchCubit? _batchCubit;

  SGTINCubit get _cubit => _sgtinCubit ?? context.read<SGTINCubit>();

  void _setFieldError(String fieldName, String? error) {
    if (_validationCubit.getFieldError(fieldName) == error) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _validationCubit.setFieldError(fieldName, error);
    });
  }

  @override
  void initState() {
    super.initState();
    _validationCubit = ValidationCubit();
    _isEditing = widget.isEditing;

    _serialNumberController = TextEditingController();
    _batchLotNumberController = TextEditingController();
    _gtinController = TextEditingController();
    _regulatoryMarketController = TextEditingController();
    _regulatoryStatusController = TextEditingController();
    _expiryDateController = TextEditingController();

    if (!widget.embedded) {
      _sgtinCubit = getIt<SGTINCubit>();
    }
    if (widget.isCreating) {
      _batchCubit = getIt<SgtinBatchCubit>();
      _batchLotNumberController.addListener(_onBatchLotTextChanged);
    }

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.embedded) {
      _sgtinCubit = context.read<SGTINCubit>();
    }
  }

  @override
  void dispose() {
    if (!widget.embedded) {
      _sgtinCubit?.close();
    }
    _batchCubit?.close();
    _serialNumberController.dispose();
    _batchLotNumberController.dispose();
    _gtinController.dispose();
    _expiryDateController.dispose();
    _regulatoryMarketController.dispose();
    _regulatoryStatusController.dispose();
    _validationCubit.close();
    super.dispose();
  }

  void _loadById(String id) {
    setState(() {
      _isLocalLoading = true;
      _formFieldsHydrated = false;
    });
    _cubit.fetchSGTINById(id);
  }

  void _loadByEpc(String epcUri) {
    setState(() {
      _isLocalLoading = true;
      _formFieldsHydrated = false;
    });
    _cubit.fetchSGTINByEPC(epcUri);
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
    _batchCubit?.clear();
  }

  void _populateForm(SGTIN sgtin) {
    _serialNumberController.text = sgtin.serialNumber;
    _batchLotNumberController.text = sgtin.batchLotNumber ?? '';
    _gtinController.text = sgtin.gtinCode;
    _regulatoryMarketController.text = sgtin.regulatoryMarket ?? '';
    _regulatoryStatusController.text = sgtin.regulatoryStatus ?? '';
    if (sgtin.expiryDate != null) {
      _expiryDateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(sgtin.expiryDate!);
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

  void _onBatchLotTextChanged() {
    _batchCubit?.onBatchLotInputChanged(_batchLotNumberController.text);
    setState(() {});
  }

  DateTime? _parseBatchDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  void _applyResolvedBatchDates(SgtinBatchState state) {
    final batch = state.resolvedBatch;
    if (batch == null || !state.status.isResolved) return;
    setState(() {
      _expiryDate = _parseBatchDate(batch.expiryDate) ?? _expiryDate;
      _productionDate =
          _parseBatchDate(batch.manufactureDate) ?? _productionDate;
    });
  }

  Future<void> _submit() async {
    if (_isLocalLoading) return;
    if (!_formKey.currentState!.validate()) return;
    if (widget.isCreating && _selectedGtin == null) {
      context.showWarning('A GTIN must be selected for new SGTINs');
      return;
    }
    if (widget.isCreating &&
        (_selectedGtin?.id == null || _selectedGtin!.id! <= 0)) {
      context.showWarning('Select a saved GTIN before creating an SGTIN');
      return;
    }

    if (widget.isCreating) {
      final batchCubit = _batchCubit;
      if (batchCubit == null) return;
      if (batchCubit.state.isBusy) {
        context.showWarning('Wait for batch lookup or registration to finish.');
        return;
      }
      if (!batchCubit.state.canSubmitSgtin) {
        if (batchCubit.state.status == SgtinBatchLookupStatus.notFound) {
          context.showError(
            'Register the batch in Batch Master before creating the SGTIN.',
          );
          return;
        }
        if (batchCubit.state.status == SgtinBatchLookupStatus.error) {
          context.showError(
            batchCubit.state.error ??
                'Batch lookup failed. Resolve the batch before creating the SGTIN.',
          );
          return;
        }
        if (batchCubit.state.status == SgtinBatchLookupStatus.idle) {
          batchCubit.triggerLookupNow(_batchLotNumberController.text);
          context.showInfo('Verifying batch in Batch Master…');
          return;
        }
        context.showError(
          'Resolve the batch in Batch Master before creating the SGTIN.',
        );
        return;
      }

      final batch = batchCubit.state.resolvedBatch;
      if (batch != null) {
        _expiryDate = _parseBatchDate(batch.expiryDate) ?? _expiryDate;
        _productionDate =
            _parseBatchDate(batch.manufactureDate) ?? _productionDate;
      }
    }

    setState(() => _isLocalLoading = true);

    final sgtin = SGTIN(
      id: _loadedSgtinId,
      serialNumber: _serialNumberController.text,
      gtinCode: _selectedGtin?.gtinCode ?? _gtinController.text,
      batchLotNumber: _batchLotNumberController.text.trim(),
      expiryDate: _expiryDate,
      productionDate: _productionDate,
      bestBeforeDate: _bestBeforeDate,
      status:
          _selectedStatus ??
          (widget.isCreating ? ItemStatus.ALLOCATED : ItemStatus.COMMISSIONED),
      currentLocation: widget.isCreating ? null : _selectedLocation,
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
      _cubit.updateSGTIN(_loadedSgtinId!, sgtin);
    } else {
      _cubit.createSGTIN(sgtin);
    }
  }

  void _decommission() {
    SgtinDecommissionDialog.show(
      context,
      onConfirm: (reason) =>
          _cubit.decommission(_serialNumberController.text, reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SgtinDetailCubitProviders(
      validationCubit: _validationCubit,
      sgtinCubit: widget.embedded ? null : _sgtinCubit,
      batchCubit: _batchCubit,
      onBatchStateChanged: _applyResolvedBatchDates,
      child: SgtinDetailBody(
        awaitingListSelection: widget.awaitingListSelection,
        embedded: widget.embedded,
        onStateChanged: _handleSgtinState,
        content: SgtinDetailScreenContent(
          embedded: widget.embedded,
          appBarTitle: _appBarTitle,
          isCreating: widget.isCreating,
          isEditing: _isEditing,
          isSaving: _isLocalLoading,
          onEdit: () => setState(() => _isEditing = true),
          onCloseEdit: () => setState(() => _isEditing = false),
          onSave: _submit,
          formBody: SgtinDetailFormBlocBody(
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
            selectedStatus: _selectedStatus,
            expiryDate: _expiryDate,
            productionDate: _productionDate,
            bestBeforeDate: _bestBeforeDate,
            onGtinChanged: (gtin) {
              setState(() {
                _selectedGtin = gtin;
                _gtinController.text = gtin?.gtinCode ?? '';
                _expiryDate = null;
                _productionDate = null;
              });
              _batchCubit?.onGtinChanged(
                gtinId: gtin?.id,
                gtinCode: gtin?.gtinCode,
              );
              if (widget.isCreating &&
                  gtin?.id != null &&
                  _batchLotNumberController.text.trim().isNotEmpty) {
                _batchCubit?.onBatchLotInputChanged(
                  _batchLotNumberController.text,
                );
              }
            },
            onStatusChanged: (status) =>
                setState(() => _selectedStatus = status),
            onTransitionError: (message) => context.showError(message),
            onPickExpiry: () =>
                _pickDate((date) => setState(() => _expiryDate = date)),
            onPickProduction: () =>
                _pickDate((date) => setState(() => _productionDate = date)),
            onPickBestBefore: () =>
                _pickDate((date) => setState(() => _bestBeforeDate = date)),
            setFieldError: _setFieldError,
            onDecommission: _decommission,
            onSubmit: _submit,
            onBatchLotEditingComplete: () =>
                _batchCubit?.triggerLookupNow(_batchLotNumberController.text),
            onBatchLotFocusLost: () =>
                _batchCubit?.triggerLookupNow(_batchLotNumberController.text),
          ),
        ),
      ),
    );
  }

  void _handleSgtinState(BuildContext context, SGTINState state) {
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
          state.sgtin!.canonicalIdentifier == widget.epcUri &&
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
  }

  String get _appBarTitle {
    if (widget.isCreating) return SgtinUiConstants.detailTitleCreate;
    if (_isEditing) return SgtinUiConstants.detailTitleEdit;
    return SgtinUiConstants.detailTitleView;
  }
}
