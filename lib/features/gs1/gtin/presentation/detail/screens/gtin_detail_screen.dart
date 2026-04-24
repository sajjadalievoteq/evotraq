import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/data/services/pharmaceutical_service.dart';
import 'package:traqtrace_app/data/services/gtin_tobacco_extension_service.dart';
import 'package:traqtrace_app/features/pharmaceutical/models/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/tobacco/models/gtin_tobacco_extension_model.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_detail_loading_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_detail_form.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_unbound_spec_fields.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_industry_extensions_section.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/tobacco/widgets/tobacco_extension_widget.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/pharmaceutical_extension_widget.dart';

class GTINDetailScreen extends StatefulWidget {
  final String? gtinCode;
  final bool isEditing;
  final GTIN? gtin;
  final bool embedded;

  /// When [embedded] is true, invoked after a successful create/update instead of [Navigator.pop].
  final VoidCallback? onEmbeddedActionSuccess;

  const GTINDetailScreen({
    Key? key,
    this.gtinCode,
    required this.isEditing,
    this.gtin,
    this.embedded = false,
    this.onEmbeddedActionSuccess,
  }) : super(key: key);

  @override
  State<GTINDetailScreen> createState() => _GTINDetailScreenState();
}

class _GTINDetailScreenState extends State<GTINDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gtinFocusNode = FocusNode();
  final _tobaccoExtensionKey = GlobalKey<TobaccoExtensionWidgetState>();
  final _pharmaExtensionKey = GlobalKey<PharmaceuticalExtensionWidgetState>();
  bool _isSubmitting = false;
  GTINPharmaceuticalExtension? _pharmaceuticalExtension;
  GTINTobaccoExtension? _tobaccoExtension;

  final _gtinCodeController = TextEditingController();
  final _productNameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _packagingLevelController = TextEditingController();
  final _packSizeController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _registrationDateController = TextEditingController();
  final _expirationDateController = TextEditingController();
  DateTime? _registrationDate;
  DateTime? _expirationDate;
  String? _status = 'ACTIVE';

  @override
  void initState() {
    super.initState();
    _gtinFocusNode.addListener(_onGtinFocusChanged);

    if (widget.gtin != null) {
      _initializeFormWithGTIN(widget.gtin!);
    } else if (widget.gtinCode != null && !widget.isEditing) {
      context.read<GTINCubit>().fetchGTINDetails(widget.gtinCode!);
    }
  }

  void _onGtinFocusChanged() {
    if (!_gtinFocusNode.hasFocus) {
      _tryNormalizeGtinCodeField();
    }
  }

  @override
  void didUpdateWidget(covariant GTINDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldCode = oldWidget.gtinCode;
    final newCode = widget.gtinCode;
    if (oldCode != newCode && newCode != null && !widget.isEditing) {
      context.read<GTINCubit>().fetchGTINDetails(newCode);
    }
  }

  void _initializeFormWithGTIN(GTIN gtin) {
    if (kDebugMode) {
      debugPrint('Initializing form with GTIN: ${gtin.gtinCode}');
      debugPrint(
        'GTIN dates: registrationDate=${gtin.registrationDate}, expirationDate=${gtin.expirationDate}',
      );
    }

    _gtinCodeController.text = gtin.gtinCode;
    _productNameController.text = gtin.productName;
    _manufacturerController.text = gtin.manufacturer ?? '';
    _packagingLevelController.text = gtin.packagingLevel ?? '';
    _packSizeController.text = gtin.packSize?.toString() ?? '';
    _registrationNumberController.text = gtin.registrationNumber ?? '';

    _status = gtin.status?.toUpperCase();

    if (gtin.registrationDate != null) {
      _registrationDate = gtin.registrationDate;
      _registrationDateController.text =
          DateFormat('yyyy-MM-dd').format(gtin.registrationDate!);
      if (kDebugMode) {
        debugPrint(
          'Set registration date display: ${_registrationDateController.text}',
        );
      }
    }

    if (gtin.expirationDate != null) {
      _expirationDate = gtin.expirationDate;
      _expirationDateController.text =
          DateFormat('yyyy-MM-dd').format(gtin.expirationDate!);
      if (kDebugMode) {
        debugPrint(
          'Set expiration date display: ${_expirationDateController.text}',
        );
      }
    }
  }

  void _tryNormalizeGtinCodeField() {
    final isReadOnly = !widget.isEditing && widget.gtinCode != null;
    final fieldLocked = isReadOnly || (widget.gtinCode != null);
    if (fieldLocked) return;
    if (!GtinFieldValidators.isGtinCodeValid(_gtinCodeController.text)) return;
    final n =
        GtinFieldValidators.canonicalGtin14FromInput(_gtinCodeController.text);
    if (_gtinCodeController.text == n) return;
    _gtinCodeController.value = TextEditingValue(
      text: n,
      selection: TextSelection.collapsed(offset: n.length),
    );
  }

  @override
  void dispose() {
    _gtinFocusNode.removeListener(_onGtinFocusChanged);
    _gtinFocusNode.dispose();
    _gtinCodeController.dispose();
    _productNameController.dispose();
    _manufacturerController.dispose();
    _packagingLevelController.dispose();
    _packSizeController.dispose();
    _registrationNumberController.dispose();
    _registrationDateController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  Future<void> _pickRegistrationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _registrationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _registrationDate = picked;
        _registrationDateController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickExpirationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _expirationDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _expirationDate = picked;
        _expirationDateController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitForm() {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    final tobaccoValidation = _tobaccoExtensionKey.currentState?.validate();
    if (tobaccoValidation != null) {
      context.showError(tobaccoValidation);
      return;
    }

    final pharmaValidation = _pharmaExtensionKey.currentState?.validate();
    if (pharmaValidation != null) {
      context.showError(pharmaValidation);
      return;
    }

    if (isFormValid) {
      setState(() {
        _isSubmitting = true;
      });

      final gtinCodeForApi =
          GtinFieldValidators.canonicalGtin14FromInput(_gtinCodeController.text);

      final gtin = GTIN(
        gtinCode: gtinCodeForApi,
        productName: _productNameController.text,
        manufacturer: _manufacturerController.text.trim(),
        packagingLevel: _packagingLevelController.text.isEmpty
            ? null
            : _packagingLevelController.text,
        packSize: _packSizeController.text.isEmpty
            ? null
            : int.tryParse(_packSizeController.text),
        status: _status,
        registrationNumber: _registrationNumberController.text.isEmpty
            ? null
            : _registrationNumberController.text,
        registrationDate: _registrationDate,
        expirationDate: _expirationDate,
      );

      if (widget.isEditing && widget.gtinCode != null) {
        context.read<GTINCubit>().updateGTIN(gtin);
      } else {
        context.read<GTINCubit>().createGTIN(gtin);
      }
    }
  }

  Future<void> _saveTobaccoExtensionIfNeeded(int? gtinId, String gtinCode) async {
    final tobaccoState = _tobaccoExtensionKey.currentState;
    if (tobaccoState == null || !tobaccoState.hasData) {
      return;
    }

    try {
      final extension =
          tobaccoState.buildExtension(gtinId: gtinId, gtinCode: gtinCode);
      if (extension != null) {
        final tobaccoService = getIt<GTINTobaccoExtensionService>();
        await tobaccoService.createByGtinCode(gtinCode, extension);
        debugPrint('Tobacco extension saved for GTIN: $gtinCode');
      }
    } catch (e) {
      debugPrint('Error saving tobacco extension: $e');
    }
  }

  Future<void> _savePharmaExtensionIfNeeded(int? gtinId, String gtinCode) async {
    final pharmaState = _pharmaExtensionKey.currentState;
    if (pharmaState == null || !pharmaState.hasData) {
      return;
    }

    try {
      final extension =
          pharmaState.buildExtension(gtinId: gtinId, gtinCode: gtinCode);
      if (extension != null) {
        final pharmaService = getIt<PharmaceuticalService>();
        await pharmaService.createExtension(gtinCode, extension);
        debugPrint('Pharmaceutical extension saved for GTIN: $gtinCode');
      }
    } catch (e) {
      debugPrint('Error saving pharmaceutical extension: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = !widget.isEditing && widget.gtinCode != null;
    final screenTitle = isReadOnly
        ? 'GTIN Details'
        : widget.isEditing && widget.gtinCode != null
            ? 'Edit GTIN'
            : 'Create GTIN';

    final body = BlocConsumer<GTINCubit, GTINState>(
      listener: (context, state) {
        if (state.status == GTINStatus.error) {
          setState(() {
            _isSubmitting = false;
          });
          debugPrint(
            '[GTIN UI] detail error (snackbar): ${state.error} '
            'routeGtinParam=${widget.gtinCode ?? "(new)"}',
          );
          context.showError(state.error ?? '');
        }

        if (state.status == GTINStatus.success) {
          if (state.gtin != null &&
              !widget.isEditing &&
              widget.gtinCode != null) {
            _initializeFormWithGTIN(state.gtin!);
            _pharmaceuticalExtension = state.pharmaceuticalExtension;
            _tobaccoExtension = state.tobaccoExtension;
          } else if (_isSubmitting) {
            setState(() {
              _isSubmitting = false;
            });

            final createdGtin = state.gtin;
            final gtinCode = createdGtin?.gtinCode ?? _gtinCodeController.text;

            _saveTobaccoExtensionIfNeeded(null, gtinCode);
            _savePharmaExtensionIfNeeded(null, gtinCode);

            context.showSuccess(
              widget.isEditing && widget.gtinCode != null
                  ? 'GTIN $gtinCode updated successfully'
                  : 'GTIN $gtinCode created successfully',
            );

            if (widget.embedded && widget.onEmbeddedActionSuccess != null) {
              widget.onEmbeddedActionSuccess!();
            } else {
              Navigator.of(context).pop();
            }
          }
        }
      },
      builder: (context, state) {
        if (state.status == GTINStatus.loading && !_isSubmitting) {
          return GtinDetailLoadingShimmer(readOnly: isReadOnly);
        }

        return GtinDetailForm(
          formKey: _formKey,
          isReadOnly: isReadOnly,
          gtinFieldLocked: isReadOnly || (widget.gtinCode != null),
          gtinFocusNode: _gtinFocusNode,
          onGtinEditingComplete: _tryNormalizeGtinCodeField,
          gtinCodeController: _gtinCodeController,
          productNameController: _productNameController,
          manufacturerController: _manufacturerController,
          packagingLevelController: _packagingLevelController,
          onPackagingLevelChanged: (value) {
            setState(() {
              _packagingLevelController.text = value ?? '';
            });
          },
          packSizeController: _packSizeController,
          status: _status,
          onStatusChanged: (value) {
            setState(() {
              _status = value;
            });
          },
          registrationNumberController: _registrationNumberController,
          registrationDateController: _registrationDateController,
          expirationDateController: _expirationDateController,
          onPickRegistrationDate: _pickRegistrationDate,
          onPickExpirationDate: _pickExpirationDate,
          unboundSpecSection: GtinUnboundSpecFields(
            isReadOnly: isReadOnly,
            gtinCodeController: _gtinCodeController,
          ),
          industrySection: ListenableBuilder(
            listenable: _gtinCodeController,
            builder: (context, _) {
              return GtinIndustryExtensionsSection(
                pharmaExtensionKey: _pharmaExtensionKey,
                tobaccoExtensionKey: _tobaccoExtensionKey,
                gtinCodeText: _gtinCodeController.text,
                routeGtinCode: widget.gtinCode,
                isEditing: widget.isEditing,
                pharmaceuticalExtension: _pharmaceuticalExtension,
                tobaccoExtension: _tobaccoExtension,
              );
            },
          ),
          showSubmitButton: !isReadOnly,
          isSubmitting: _isSubmitting,
          onSubmit: _submitForm,
          submitButtonTitle: widget.gtinCode != null
              ? 'Update GTIN'
              : 'Create GTIN',
        );
      },
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          screenTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!isReadOnly)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSubmitting ? null : _submitForm,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: body,
    );
  }
}
