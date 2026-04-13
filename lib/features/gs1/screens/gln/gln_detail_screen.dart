import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/loading_indicator.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_service_provider.dart';
import 'package:traqtrace_app/features/gs1/bloc/gln/gln_cubit.dart';
import 'package:traqtrace_app/features/gs1/mixins/gs1_form_validation_mixin.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'package:traqtrace_app/features/epcis/widgets/geospatial_coordinates_widget.dart';
import 'package:traqtrace_app/features/epcis/models/geospatial_coordinates.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_form_builder_text_field.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/tobacco/widgets/gln_tobacco_extension_widget.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/data/services/gln_tobacco_extension_service.dart';
import 'package:traqtrace_app/data/services/gln_pharmaceutical_extension_service.dart';
import 'package:traqtrace_app/features/tobacco/models/gln_tobacco_extension_model.dart';
import 'package:traqtrace_app/features/pharmaceutical/models/gln_pharmaceutical_extension_model.dart';

/// Screen for viewing and editing GLN details
class GLNDetailScreen extends StatefulWidget {
  /// GLN ID for existing GLN, null for new GLN
  final String? glnId;
  
  /// Whether we are editing an existing GLN or creating a new one
  final bool isEditing;

  /// Creates a new GLNDetailScreen
  const GLNDetailScreen({
    Key? key,
    this.glnId,
    required this.isEditing,
  }) : super(key: key);

  @override
  State<GLNDetailScreen> createState() => _GLNDetailScreenState();
}

class _GLNDetailScreenState extends State<GLNDetailScreen> with GS1FormValidationMixin<GLNDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _pharmaExtensionKey = GlobalKey<GLNPharmaceuticalExtensionWidgetState>();
  final _tobaccoExtensionKey = GlobalKey<GLNTobaccoExtensionWidgetState>();
  DateTime? _licenseExpiry;
  bool _hasSubmittedForm = false;
  GeospatialCoordinates? _coordinates;
  @override
  void initState() {
    super.initState();
    
    // Always clear the selected GLN when entering the screen
    context.read<GLNCubit>().clearSelection();
    
    if (widget.glnId != null) {
      // Load existing GLN data
      print('Loading GLN with ID: ${widget.glnId}');
      context.read<GLNCubit>().fetchGLNById(widget.glnId!);
    } else {
      print('Creating new GLN (no ID provided)');
    }
  }

  @override
  void dispose() {
    // Clear the selected GLN when leaving the screen
    context.read<GLNCubit>().clearSelection();
    super.dispose();
  }

  void _submitForm() {
    // Check if form is valid using standard FormBuilder validation first
    if (!(_formKey.currentState?.validate() ?? false)) {
      // Show a snackbar if form is invalid according to Flutter's built-in validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Save the form values to work with them
    _formKey.currentState?.save();
    final formValues = _formKey.currentState?.value ?? {};
    
    // Extract key form values
    final glnCode = formValues['glnCode'] as String? ?? '';
    final locationName = formValues['locationName'] as String? ?? '';
    final addressLine1 = formValues['addressLine1'] as String? ?? '';
    final city = formValues['city'] as String? ?? '';
    final stateProvince = formValues['stateProvince'] as String? ?? '';
    final postalCode = formValues['postalCode'] as String? ?? '';
    final country = formValues['country'] as String? ?? '';
    
    // Debug print to verify form values are being extracted correctly
    print('Form values being submitted:');
    print('GLN Code: $glnCode');
    print('Location Name: $locationName');
    
    // Perform field-level validation
    final isValid = validateAllFields({
      'glnCode': {'value': glnCode, 'validator': validateGLN},
      'locationName': {'value': locationName, 'validator': (value) {
        if (value == null || value.isEmpty) {
          return 'Location Name is required';
        }
        return null;
      }},
      'addressLine1': {'value': addressLine1, 'validator': (value) {
        if (value == null || value.isEmpty) {
          return 'Address Line 1 is required';
        }
        return null;
      }},
      'city': {'value': city, 'validator': (value) {
        if (value == null || value.isEmpty) {
          return 'City is required';
        }
        return null;
      }},
      'stateProvince': {'value': stateProvince, 'validator': (value) {
        if (value == null || value.isEmpty) {
          return 'State/Province is required';
        }
        return null;
      }},
      'postalCode': {'value': postalCode, 'validator': (value) {
        if (value == null || value.isEmpty) {
          return 'Postal Code is required';
        }
        return null;
      }},
      'country': {'value': country, 'validator': (value) {
        if (value == null || value.isEmpty) {
          return 'Country is required';
        }
        return null;
      }}
    });
    
    // If both validation methods pass, proceed with submission
    if (isValid) {
      // Set the form submission flag
      setState(() {
        _hasSubmittedForm = true;
      });
      
      // Convert form values to LocationType
      final locationType = _parseLocationType(formValues['locationType'] as String);
      
      if (locationName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location Name is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (city.trim().isEmpty || stateProvince.trim().isEmpty || 
          postalCode.trim().isEmpty || country.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('City, State/Province, Postal Code, and Country are required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }      // Create GLN object from form values
      final gln = GLN(
        glnCode: glnCode, // Primary identifier
        locationName: locationName,
        addressLine1: addressLine1,
        addressLine2: formValues['addressLine2'] as String? ?? '',
        city: city,
        stateProvince: stateProvince,
        postalCode: postalCode,
        country: country,
        contactName: formValues['contactName'] as String?,
        contactEmail: formValues['contactEmail'] as String?,
        contactPhone: formValues['contactPhone'] as String?,
        locationType: locationType,
        parentGln: null, // Parent GLN management would need additional implementation
        licenseNumber: formValues['licenseNumber'] as String?,
        licenseType: formValues['licenseType'] as String?,
        licenseExpiry: _licenseExpiry,
        active: formValues['active'] as bool? ?? true,
        coordinates: _coordinates,
      );
      
      if (widget.isEditing && widget.glnId != null) {
        // Update existing GLN
        context.read<GLNCubit>().updateGLN(widget.glnId!, gln);
      } else {
        // Create new GLN
        context.read<GLNCubit>().createGLN(gln);
      }
    }
  }

  LocationType _parseLocationType(String type) {
    switch (type) {
      case 'Manufacturing Site':
        return LocationType.manufacturing_site;
      case 'Warehouse':
        return LocationType.warehouse;
      case 'Distribution Center':
        return LocationType.distribution_center;
      case 'Pharmacy':
        return LocationType.pharmacy;
      case 'Hospital':
        return LocationType.hospital;
      case 'Wholesaler':
        return LocationType.wholesaler;
      case 'Clinic':
        return LocationType.clinic;
      case 'Regulatory Body':
        return LocationType.regulatory_body;
      default:
        return LocationType.other;
    }
  }

  /// Save tobacco extension if the widget has data
  Future<void> _saveTobaccoExtensionIfNeeded(int? glnId, String glnCode) async {
    final tobaccoState = _tobaccoExtensionKey.currentState;
    if (tobaccoState == null || !tobaccoState.hasData) {
      return; // No tobacco data to save
    }
    
    try {
      final extension = tobaccoState.buildExtension(glnId: glnId, glnCode: glnCode);
      if (extension != null) {
        final tobaccoService = getIt<GLNTobaccoExtensionService>();
        await tobaccoService.createByGlnCode(glnCode, extension);
        debugPrint('GLN Tobacco extension saved for GLN: $glnCode');
      }
    } catch (e) {
      debugPrint('Error saving GLN tobacco extension: $e');
      // Don't show error to user since GLN was saved successfully
      // The tobacco extension can be added later if needed
    }
  }

  /// Save pharmaceutical extension if the widget has data
  Future<void> _savePharmaExtensionIfNeeded(int? glnId, String glnCode) async {
    final pharmaState = _pharmaExtensionKey.currentState;
    if (pharmaState == null || !pharmaState.hasData) {
      return; // No pharmaceutical data to save
    }
    
    try {
      final extension = pharmaState.buildExtension(glnId: glnId, glnCode: glnCode);
      if (extension != null) {
        final pharmaService = getIt<GLNPharmaceuticalExtensionService>();
        await pharmaService.createByGlnCode(glnCode, extension);
        debugPrint('GLN Pharmaceutical extension saved for GLN: $glnCode');
      }
    } catch (e) {
      debugPrint('Error saving GLN pharmaceutical extension: $e');
      // Don't show error to user since GLN was saved successfully
      // The pharmaceutical extension can be added later if needed
    }
  }

  String _locationTypeToString(LocationType type) {
    switch (type) {
      case LocationType.manufacturing_site:
        return 'Manufacturing Site';
      case LocationType.warehouse:
        return 'Warehouse';
      case LocationType.distribution_center:
        return 'Distribution Center';
      case LocationType.pharmacy:
        return 'Pharmacy';
      case LocationType.hospital:
        return 'Hospital';
      case LocationType.wholesaler:
        return 'Wholesaler';
      case LocationType.clinic:
        return 'Clinic';
      case LocationType.regulatory_body:
        return 'Regulatory Body';
      case LocationType.other:
        return 'Other';
    }
  }

  void _showLicenseExpiryPicker() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _licenseExpiry ?? DateTime(now.year + 1, now.month, now.day),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _licenseExpiry) {
      setState(() {
        _licenseExpiry = picked;
      });
    }
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing
            ? (widget.glnId != null ? 'Edit GLN' : 'Create GLN')
            : 'GLN Details'),
        actions: [
          // Show save button only when editing (creating or updating)
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save',
              onPressed: () {
                print('Save button pressed, calling _submitForm');
                _submitForm();
              },
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: BlocConsumer<GLNCubit, GLNState>(
        listener: (context, state) {
          debugPrint('GLN BlocListener - status: ${state.status}, error: ${state.error}, _hasSubmittedForm: $_hasSubmittedForm');
          
          if (state.status == GLNStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == GLNStatus.success && _hasSubmittedForm) {
            debugPrint('GLN save successful, processing extensions and navigating back...');
            
            // Reset the flag first (similar to GTIN pattern with _isSubmitting)
            setState(() {
              _hasSubmittedForm = false;
            });
            
            // Get GLN code from form values for extension saving
            final glnCode = _formKey.currentState?.fields['glnCode']?.value as String? ?? '';
            debugPrint('GLN code for extension saving: $glnCode');
            
            // Save extensions if there's data (based on industry mode)
            // These are fire-and-forget async calls (matching GTIN pattern)
            _saveTobaccoExtensionIfNeeded(null, glnCode);
            _savePharmaExtensionIfNeeded(null, glnCode);
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('GLN saved successfully'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            
            // Navigate back (matching GTIN pattern - direct call)
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          // Show loading indicator while fetching GLN details
          if (widget.glnId != null && state.selectedGLN == null && state.status == GLNStatus.loading) {
            return const Center(child: LoadingIndicator());
          }

          // Get the GLN to display/edit
          // For create mode (glnId is null), ensure gln is null
          final gln = widget.glnId != null ? state.selectedGLN : null;

          // If we're viewing/editing an existing GLN but it's not loaded yet, show loading
          if (widget.glnId != null && gln == null) {
            return const Center(child: Text('Loading GLN details...'));
          }          // Set license expiry from GLN if it exists
          if (gln?.licenseExpiry != null && _licenseExpiry == null) {
            _licenseExpiry = gln!.licenseExpiry;
            print('Setting license expiry from GLN: $_licenseExpiry');
          }

          // Debug print the GLN data to help troubleshoot
          if (gln != null) {
            print('Loaded GLN data:');
            print('GLN Code: ${gln.glnCode}');
            print('Location Name: ${gln.locationName}');
            print('Address: ${gln.addressLine1}, ${gln.addressLine2}');
            print('City: ${gln.city}');
            print('State/Province: ${gln.stateProvince}');
            print('Postal Code: ${gln.postalCode}');
            print('Country: ${gln.country}');
            print('Contact Name: ${gln.contactName}');
            print('Email: ${gln.contactEmail}');
            print('Phone: ${gln.contactPhone}');
            print('Location Type: ${gln.locationType}');
            print('License Number: ${gln.licenseNumber}');
            print('License Type: ${gln.licenseType}');
            print('License Expiry: ${gln.licenseExpiry}');
            print('Active: ${gln.active}');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'glnCode': gln?.glnCode ?? '',
                'locationName': gln?.locationName ?? '',
                'addressLine1': gln?.addressLine1 ?? '',
                'addressLine2': gln?.addressLine2 ?? '',
                'city': gln?.city ?? '',
                'stateProvince': gln?.stateProvince ?? '',
                'postalCode': gln?.postalCode ?? '',
                'country': gln?.country ?? '',
                'contactName': gln?.contactName ?? '',
                'contactEmail': gln?.contactEmail ?? '',
                'contactPhone': gln?.contactPhone ?? '',
                'locationType': gln != null ? _locationTypeToString(gln.locationType) : 'Other',
                'licenseNumber': gln?.licenseNumber ?? '',
                'licenseType': gln?.licenseType ?? '',
                'active': gln?.active ?? true,
              },
              enabled: widget.isEditing,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GLN Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // GLN Code
                  ValidatedFormBuilderTextField(
                    name: 'glnCode',
                    decoration: const InputDecoration(
                      labelText: 'GLN Code',
                      hintText: 'Enter 13-digit GLN code',
                      border: OutlineInputBorder(),
                    ),
                    setFieldError: setFieldError,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'GLN Code is required';
                      }
                      if (!RegExp(r'^\d{13}$').hasMatch(value)) {
                        return 'GLN must be exactly 13 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Location Name
                  ValidatedFormBuilderTextField(
                    name: 'locationName',
                    decoration: const InputDecoration(
                      labelText: 'Location Name',
                      hintText: 'Enter the name of this location',
                      border: OutlineInputBorder(),
                    ),
                    setFieldError: setFieldError,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Location Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Address section
                  const Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                    // Address Line 1
                  ValidatedFormBuilderTextField(
                    name: 'addressLine1',
                    decoration: const InputDecoration(
                      labelText: 'Address Line 1 *',
                      hintText: 'Required - Enter street address',
                      border: OutlineInputBorder(),
                      helperText: 'This field is required',
                    ),
                    setFieldError: setFieldError,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Address Line 1 is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Address Line 2
                  ValidatedFormBuilderTextField(
                    name: 'addressLine2',
                    decoration: const InputDecoration(
                      labelText: 'Address Line 2 (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    setFieldError: setFieldError,
                    validator: (value) {
                      // Optional field, no validation needed
                      setFieldError('addressLine2', null);
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // City and State/Province
                  Row(
                    children: [
                      Expanded(
                        child: ValidatedFormBuilderTextField(
                          name: 'city',
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                          setFieldError: setFieldError,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'City is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ValidatedFormBuilderTextField(
                          name: 'stateProvince',
                          decoration: const InputDecoration(
                            labelText: 'State/Province',
                            border: OutlineInputBorder(),
                          ),
                          setFieldError: setFieldError,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'State/Province is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Postal Code and Country
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ValidatedFormBuilderTextField(
                          name: 'postalCode',
                          decoration: const InputDecoration(
                            labelText: 'Postal Code',
                            border: OutlineInputBorder(),
                          ),
                          setFieldError: setFieldError,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Postal Code is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ValidatedFormBuilderTextField(
                          name: 'country',
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            border: OutlineInputBorder(),
                          ),
                          setFieldError: setFieldError,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Country is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Contact Information section
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Contact Name
                  ValidatedFormBuilderTextField(
                    name: 'contactName',
                    decoration: const InputDecoration(
                      labelText: 'Contact Name',
                      border: OutlineInputBorder(),
                    ),
                    setFieldError: setFieldError,
                    validator: (value) {
                      // Optional field
                      setFieldError('contactName', null);
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Contact Email and Phone
                  Row(
                    children: [
                      Expanded(
                        child: ValidatedFormBuilderTextField(
                          name: 'contactEmail',
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          setFieldError: setFieldError,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                            }
                            setFieldError('contactEmail', null);
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ValidatedFormBuilderTextField(
                          name: 'contactPhone',
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                          ),
                          setFieldError: setFieldError,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[0-9+\-() ]+$').hasMatch(value)) {
                                return 'Please enter a valid phone number';
                              }
                            }
                            setFieldError('contactPhone', null);
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Location Details section
                  const Text(
                    'Location Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Location Type
                  FormBuilderDropdown<String>(
                    name: 'locationType',
                    decoration: const InputDecoration(
                      labelText: 'Location Type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'Manufacturing Site',
                      'Warehouse',
                      'Distribution Center',
                      'Pharmacy',
                      'Hospital',
                      'Wholesaler',
                      'Clinic',
                      'Regulatory Body',
                      'Other',
                    ]
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // License Information section
                  const Text(
                    'License Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // License Number and Type
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'licenseNumber',
                          decoration: const InputDecoration(
                            labelText: 'License Number (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'licenseType',
                          decoration: const InputDecoration(
                            labelText: 'License Type (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // License Expiry
                  InkWell(
                    onTap: widget.isEditing ? _showLicenseExpiryPicker : null,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'License Expiry Date (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _licenseExpiry != null
                                ? DateFormat('yyyy-MM-dd').format(_licenseExpiry!)
                                : 'Select Date',
                            style: TextStyle(
                              color: _licenseExpiry != null ? Colors.black : Colors.grey,
                            ),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Status
                  FormBuilderSwitch(
                    name: 'active',
                    title: const Text('Active Location'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // EPCIS 2.0 Geospatial Coordinates
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Geospatial Coordinates (EPCIS 2.0)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GeospatialCoordinatesWidget(
                          coordinates: gln?.coordinates,
                          onCoordinatesChanged: (coordinates) {
                            setState(() {
                              _coordinates = coordinates;
                            });
                          },
                          isViewOnly: !widget.isEditing,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Industry Extension Widgets
                  BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
                    builder: (context, settingsState) {
                      final settings = settingsState.settings;
                      debugPrint(
                        'GLN SystemSettings - isInitialized: ${settingsState.isInitialized}, '
                        'mode: ${settings.industryMode}, '
                        'isPharmaceutical: ${settings.isPharmaceuticalMode}, '
                        'isTobacco: ${settings.isTobaccoMode}',
                      );
                      
                      // Get the GLN code from the existing GLN or form
                      final currentGlnCode = gln?.glnCode ?? 
                          _formKey.currentState?.fields['glnCode']?.value as String?;
                      
                      // Pharmaceutical Mode: Show pharmaceutical extension
                      if (settings.isPharmaceuticalMode) {
                        return GLNPharmaceuticalExtensionWidget(
                          key: _pharmaExtensionKey,
                          glnCode: currentGlnCode,
                          isEditing: widget.isEditing,
                        );
                      }
                      
                      // Tobacco Mode: Show tobacco extension
                      if (settings.isTobaccoMode) {
                        return GLNTobaccoExtensionWidget(
                          key: _tobaccoExtensionKey,
                          glnCode: currentGlnCode,
                          isEditing: widget.isEditing,
                        );
                      }
                      
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  const SizedBox(height: 32),
                    // Submit button for mobile screens when editing
                  if (MediaQuery.of(context).size.width < 600 && widget.isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'SAVE GLN',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
