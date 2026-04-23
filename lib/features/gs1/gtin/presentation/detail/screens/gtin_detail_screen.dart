import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_form_validation_mixin.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';
import 'package:traqtrace_app/features/tobacco/widgets/tobacco_extension_widget.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/data/services/pharmaceutical_service.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/data/services/gtin_tobacco_extension_service.dart';
import 'package:traqtrace_app/features/pharmaceutical/models/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/tobacco/models/gtin_tobacco_extension_model.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_detail_loading_shimmer.dart';

class GTINDetailScreen extends StatefulWidget {
  final String? gtinCode;
  final bool isEditing;
  final GTIN? gtin; // Optional GTIN for editing
  final bool embedded;

  const GTINDetailScreen({
    Key? key,
    this.gtinCode,
    required this.isEditing,
    this.gtin,
    this.embedded = false,
  }) : super(key: key);

  @override
  State<GTINDetailScreen> createState() => _GTINDetailScreenState();
}

class _GTINDetailScreenState extends State<GTINDetailScreen>
    with GS1FormValidationMixin<GTINDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tobaccoExtensionKey = GlobalKey<TobaccoExtensionWidgetState>();
  final _pharmaExtensionKey = GlobalKey<PharmaceuticalExtensionWidgetState>();
  bool _isValidating = false;
  bool _isSubmitting = false;
  GTINPharmaceuticalExtension? _pharmaceuticalExtension;
  GTINTobaccoExtension? _tobaccoExtension;

  // Form controllers
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

  final _packagingLevelOptions = ['ITEM', 'INNER_PACK', 'PACK', 'CASE', 'PALLET'];
  final _statusOptions = ['ACTIVE', 'WITHDRAWN', 'SUSPENDED', 'DISCONTINUED'];

  @override
  void initState() {
    super.initState();

    // If editing an existing GTIN, load its data
    if (widget.gtin != null) {
      _initializeFormWithGTIN(widget.gtin!);
    } else if (widget.gtinCode != null && !widget.isEditing) {
      // Fetch GTIN + extensions in parallel
      context.read<GTINCubit>().fetchGTINDetails(widget.gtinCode!);
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
    print('Initializing form with GTIN: ${gtin.gtinCode}');
    print(
      'GTIN dates: registrationDate=${gtin.registrationDate}, expirationDate=${gtin.expirationDate}',
    );

    _gtinCodeController.text = gtin.gtinCode;
    _productNameController.text = gtin.productName;
    _manufacturerController.text = gtin.manufacturer ?? '';
    _packagingLevelController.text = gtin.packagingLevel ?? '';
    _packSizeController.text = gtin.packSize?.toString() ?? '';
    _registrationNumberController.text = gtin.registrationNumber ?? '';

    // Convert status to uppercase to match dropdown options
    _status = gtin.status?.toUpperCase();

    if (gtin.registrationDate != null) {
      _registrationDate = gtin.registrationDate;
      _registrationDateController.text =
          DateFormat('yyyy-MM-dd').format(gtin.registrationDate!);
      print('Set registration date display: ${_registrationDateController.text}');
    }

    if (gtin.expirationDate != null) {
      _expirationDate = gtin.expirationDate;
      _expirationDateController.text =
          DateFormat('yyyy-MM-dd').format(gtin.expirationDate!);
      print('Set expiration date display: ${_expirationDateController.text}');
    }
  }

  @override
  void dispose() {
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

  void _validateGTIN() {
    setState(() {
      _isValidating = true;
    });

    context.read<GTINCubit>().validateGTIN(_gtinCodeController.text);
  }

  void _submitForm() {
    // Re-validate required fields at submission time
    final isValid = validateAllFields({
      'gtinCode': {'value': _gtinCodeController.text, 'validator': validateGTIN},
      'productName': {
        'value': _productNameController.text,
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return 'Product Name is required';
          }
          return null;
        }
      },
      'packSize': {
        'value': _packSizeController.text,
        'validator': (value) {
          if (value != null && value.isNotEmpty) {
            if (int.tryParse(value) == null) {
              return 'Pack Size must be a valid number';
            }
          }
          return null;
        }
      },
    });

    // Form-level validation with FormKey
    final isFormValid = _formKey.currentState?.validate() ?? false;

    // Validate tobacco extension if present
    final tobaccoValidation = _tobaccoExtensionKey.currentState?.validate();
    if (tobaccoValidation != null) {
      context.showError(tobaccoValidation);
      return;
    }

    // Validate pharmaceutical extension if present
    final pharmaValidation = _pharmaExtensionKey.currentState?.validate();
    if (pharmaValidation != null) {
      context.showError(pharmaValidation);
      return;
    }

    if (isValid && isFormValid) {
      setState(() {
        _isSubmitting = true;
      });

      final gtin = GTIN(
        gtinCode: _gtinCodeController.text,
        productName: _productNameController.text,
        manufacturer: _manufacturerController.text.isEmpty
            ? null
            : _manufacturerController.text,
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

  /// Save tobacco extension if the widget has data
  Future<void> _saveTobaccoExtensionIfNeeded(int? gtinId, String gtinCode) async {
    final tobaccoState = _tobaccoExtensionKey.currentState;
    if (tobaccoState == null || !tobaccoState.hasData) {
      return; // No tobacco data to save
    }

    try {
      final extension = tobaccoState.buildExtension(gtinId: gtinId, gtinCode: gtinCode);
      if (extension != null) {
        final tobaccoService = getIt<GTINTobaccoExtensionService>();
        // Use the method that accepts GTIN code instead of ID
        await tobaccoService.createByGtinCode(gtinCode, extension);
        debugPrint('Tobacco extension saved for GTIN: $gtinCode');
      }
    } catch (e) {
      debugPrint('Error saving tobacco extension: $e');
    }
  }

  /// Save pharmaceutical extension if the widget has data
  Future<void> _savePharmaExtensionIfNeeded(int? gtinId, String gtinCode) async {
    final pharmaState = _pharmaExtensionKey.currentState;
    if (pharmaState == null || !pharmaState.hasData) {
      return; // No pharmaceutical data to save
    }

    try {
      final extension = pharmaState.buildExtension(gtinId: gtinId, gtinCode: gtinCode);
      if (extension != null) {
        final pharmaService = getIt<PharmaceuticalService>();
        await pharmaService.createExtension(gtinCode, extension);
        debugPrint('Pharmaceutical extension saved for GTIN: $gtinCode');
      }
    } catch (e) {
      debugPrint('Error saving pharmaceutical extension: $e');
    }
  }

  // Helper method to create a ValidatedTextFieldWrapper with consistent styling
  Widget _buildValidatedField({
    required TextEditingController controller,
    required String fieldName,
    required String label,
    String? helperText,
    bool readOnly = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return ValidatedTextFieldWrapper(
      controller: controller,
      fieldName: fieldName,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
      readOnly: readOnly,
      setFieldError: setFieldError,
      validator: validator ?? (value) => null,
    );
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
              _isValidating = false;
            });
            debugPrint(
              '[GTIN UI] detail error (snackbar): ${state.error} '
              'gtinCode=${widget.gtinCode}',
            );
            context.showError(state.error ?? '');

          }

          if (state.status == GTINStatus.success) {
            if (state.gtin != null && !widget.isEditing && widget.gtinCode != null) {
              // When loading an existing GTIN for display
              _initializeFormWithGTIN(state.gtin!);
              _pharmaceuticalExtension = state.pharmaceuticalExtension;
              _tobaccoExtension = state.tobaccoExtension;
            } else if (state.isValidFormat != null && _isValidating) {
              // Handle GTIN validation result
              setState(() {
                _isValidating = false;
              });

              if (state.isValidFormat == true) {
                context.showSuccess('Valid GTIN format');
              } else {
                context.showWarning('Invalid GTIN format');
              }
            } else if (_isSubmitting) {
              // Handle successful create/update
              setState(() {
                _isSubmitting = false;
              });

              // Get GTIN info from the state
              final createdGtin = state.gtin;
              final gtinCode = createdGtin?.gtinCode ?? _gtinCodeController.text;

              // Save extensions if there's data (based on industry mode)
              _saveTobaccoExtensionIfNeeded(null, gtinCode);
              _savePharmaExtensionIfNeeded(null, gtinCode);

              context.showSuccess(
                widget.isEditing && widget.gtinCode != null
                    ? 'GTIN $gtinCode updated successfully'
                    : 'GTIN $gtinCode created successfully',
              );

              Navigator.of(context).pop();
            }
          }
        },
        builder: (context, state) {
          if (state.status == GTINStatus.loading && !_isValidating && !_isSubmitting) {
            return GtinDetailLoadingShimmer(readOnly: isReadOnly);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Constants.spacing),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                 SizedBox(height: Constants.spacing,),
                  _buildValidatedField(
                    controller: _gtinCodeController,
                    fieldName: 'gtinCode',
                    label: 'GTIN Code *',
                    helperText: 'GTIN-8, GTIN-12, GTIN-13, or GTIN-14',
                    suffixIcon: !isReadOnly
                        ? IconButton(
                            icon: Icon(
                              Icons.check_circle,
                              color: _isValidating ? Colors.grey : Colors.blue,
                            ),
                            onPressed: _isValidating ? null : _validateGTIN,
                          )
                        : null,
                    readOnly: isReadOnly || (widget.gtinCode != null),
                    validator: (value) {
                      final result = validateGTIN(value);
                      return result;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Product Name field
                  _buildValidatedField(
                    controller: _productNameController,
                    fieldName: 'productName',
                    label: 'Product Name *',
                    readOnly: isReadOnly,
                    validator: (value) {
                      final error = value == null || value.isEmpty
                          ? 'Product Name is required'
                          : null;
                      return error;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Manufacturer field
                  _buildValidatedField(
                    controller: _manufacturerController,
                    fieldName: 'manufacturer',
                    label: 'Manufacturer',
                    readOnly: isReadOnly,
                    validator: (value) => null,
                  ),
                  const SizedBox(height: 16),

                  // Packaging Level dropdown
                  DropdownButtonFormField<String>(
                    value: _packagingLevelController.text.isEmpty
                        ? null
                        : _packagingLevelController.text,
                    decoration: const InputDecoration(
                      labelText: 'Packaging Level',
                    ),
                    items: _packagingLevelOptions
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ),
                        )
                        .toList(),
                    onChanged: isReadOnly
                        ? null
                        : (value) {
                            setState(() {
                              _packagingLevelController.text = value ?? '';
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // Pack Size field
                  _buildValidatedField(
                    controller: _packSizeController,
                    fieldName: 'packSize',
                    label: 'Pack Size',
                    helperText: 'e.g., 30, 100, 500',
                    readOnly: isReadOnly,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^\\d+$').hasMatch(value)) {
                          return 'Pack Size must be a valid number';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status dropdown
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                    ),
                    items: _statusOptions
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: isReadOnly
                        ? null
                        : (value) {
                            setState(() {
                              _status = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // Registration Number field
                  _buildValidatedField(
                    controller: _registrationNumberController,
                    fieldName: 'registrationNumber',
                    label: 'Registration Number',
                    helperText: 'Market authorization or registration number',
                    readOnly: isReadOnly,
                    validator: (value) => null,
                  ),
                  const SizedBox(height: 16),

                  // Registration Date field
                  GestureDetector(
                    onTap: isReadOnly
                        ? null
                        : () async {
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
                          },
                    child: AbsorbPointer(
                      child: _buildValidatedField(
                        controller: _registrationDateController,
                        fieldName: 'registrationDate',
                        label: 'Registration Date',
                        suffixIcon: const Icon(Icons.calendar_today),
                        readOnly: true,
                        validator: (value) => null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Expiration Date field
                  GestureDetector(
                    onTap: isReadOnly
                        ? null
                        : () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _expirationDate ??
                                  DateTime.now().add(const Duration(days: 365)),
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
                          },
                    child: AbsorbPointer(
                      child: _buildValidatedField(
                        controller: _expirationDateController,
                        fieldName: 'expirationDate',
                        label: 'Expiration Date',
                        suffixIcon: const Icon(Icons.calendar_today),
                        readOnly: true,
                        validator: (value) => null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Industry-specific Extension Sections
                  BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
                    builder: (context, settingsState) {
                      final settings = settingsState.settings;
                      debugPrint(
                        'SystemSettings - isInitialized: ${settingsState.isInitialized}, '
                        'mode: ${settings.industryMode}, '
                        'isPharmaceutical: ${settings.isPharmaceuticalMode}, '
                        'isTobacco: ${settings.isTobaccoMode}',
                      );

                      if (settings.isPharmaceuticalMode) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            PharmaceuticalExtensionWidget(
                              key: _pharmaExtensionKey,
                              gtinCode: _gtinCodeController.text.isNotEmpty
                                  ? _gtinCodeController.text
                                  : widget.gtinCode,
                              isEditing: widget.isEditing,
                              initialExtension: _pharmaceuticalExtension,
                            ),
                          ],
                        );
                      }

                      if (settings.isTobaccoMode) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            const SizedBox(height: 8),
                            TobaccoExtensionWidget(
                              key: _tobaccoExtensionKey,
                              gtinCode: _gtinCodeController.text.isNotEmpty
                                  ? _gtinCodeController.text
                                  : widget.gtinCode,
                              isEditing: widget.isEditing,
                              initialExtension: _tobaccoExtension,
                            ),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 32),

                  if (!isReadOnly)
                    CustomButtonWidget(
                      onTap: _isSubmitting ? null : _submitForm,
                      title: widget.gtinCode != null
                          ? 'Update GTIN'
                          : 'Create GTIN',
                    ),
                ],
              ),
            ),
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

