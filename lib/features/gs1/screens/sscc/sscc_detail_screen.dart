// filepath: c:\Code\traqTrace\frontend\traqtrace_app\lib\features\gs1\screens\sscc\sscc_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/loading_indicator.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_text_field.dart';
import 'package:traqtrace_app/features/gs1/bloc/sscc/sscc_cubit.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_form_validation_mixin.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/models/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_utils.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/features/tobacco/widgets/sscc_tobacco_extension_widget.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/sscc_pharmaceutical_extension_widget.dart';

import '../../../../data/services/sscc_pharmaceutical_extension_service.dart';
import '../../../../data/services/sscc_tobacco_extension_service.dart';

enum SSCCDetailMode { create, edit, view }

class SSCCDetailScreen extends StatefulWidget {
  final SSCCDetailMode mode;
  final String? ssccId; // Changed from int? to String? to match UUID in backend
  final String? ssccCode;

  const SSCCDetailScreen({
    Key? key,
    required this.mode,
    this.ssccId,
    this.ssccCode,
  }) : super(key: key);

  @override
  State<SSCCDetailScreen> createState() => _SSCCDetailScreenState();
}

class _SSCCDetailScreenState extends State<SSCCDetailScreen>
    with GS1FormValidationMixin<SSCCDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tobaccoExtensionKey = GlobalKey<SSCCTobaccoExtensionWidgetState>();
  final _pharmaExtensionKey =
      GlobalKey<SSCCPharmaceuticalExtensionWidgetState>();
  late TextEditingController _ssccCodeController;
  late TextEditingController
  _glnController; // Simplified to use GLN instead of separate fields
  late TextEditingController _extensionDigitController;

  ContainerType _containerType = ContainerType.PALLET;
  ContainerStatus _containerStatus = ContainerStatus.CREATED;
  DateTime? _packingDate;

  bool _isLoading = false;
  bool _isEditMode = false;
  SSCC? _sscc;

  // Captured extension data - stored before save to ensure we have it when SSCCCreated is emitted
  dynamic _capturedTobaccoExtension;
  dynamic _capturedPharmaExtension;
  String? _capturedSsccCode;

  @override
  void initState() {
    super.initState();
    print('SSCCDetailScreen - initState - mode: ${widget.mode}');
    _ssccCodeController = TextEditingController();
    _glnController = TextEditingController();
    _extensionDigitController = TextEditingController();

    // Set default extension digit to 0
    _extensionDigitController.text = '0';

    // Always start with CREATED status for new SSCCs
    _containerStatus = ContainerStatus.CREATED;

    _isEditMode = widget.mode == SSCCDetailMode.edit;

    _loadData();
  }

  @override
  void dispose() {
    _ssccCodeController.dispose();
    _glnController.dispose();
    _extensionDigitController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    print('SSCCDetailScreen - _loadData - mode: ${widget.mode}');
    if (widget.mode == SSCCDetailMode.create) {
      print('Create mode - no data to load');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    print('Setting loading state to true');
    setState(() {
      _isLoading = true;
    });

    // Prefer using code for lookup as it's more reliable
    if (widget.ssccCode != null && widget.ssccCode!.isNotEmpty) {
      print('Loading SSCC by code: ${widget.ssccCode}');
      context.read<SSCCCubit>().fetchSSCCByCode(widget.ssccCode!);
    } else if (widget.ssccId != null && widget.ssccId!.isNotEmpty) {
      print('Loading SSCC by ID: ${widget.ssccId}');
      context.read<SSCCCubit>().fetchSSCCById(widget.ssccId!);
    } else {
      print('No ID or code provided to load SSCC details');
      // Show error in the UI
      setState(() {
        _isLoading = false;
      });

      // Show error message
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No SSCC code or ID provided for lookup'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  /// Save tobacco extension if the widget has data
  Future<void> _saveTobaccoExtensionIfNeeded(
    int? ssccId,
    String ssccCode,
  ) async {
    if (!kTobaccoExtensionEnabled) return;
    final tobaccoState = _tobaccoExtensionKey.currentState;
    debugPrint(
      'SSCC Tobacco extension check - state: ${tobaccoState != null}, hasData: ${tobaccoState?.hasData}',
    );

    if (tobaccoState == null) {
      debugPrint(
        'Tobacco extension widget not in tree (probably not in tobacco mode)',
      );
      return; // Widget not in tree
    }

    if (!tobaccoState.hasData) {
      debugPrint('No tobacco extension data to save');
      return; // No data to save
    }

    try {
      final extension = tobaccoState.buildExtension(
        ssccId: ssccId,
        ssccCode: ssccCode,
      );
      debugPrint('Built tobacco extension: ${extension != null}');
      if (extension != null) {
        final tobaccoService = getIt<SSCCTobaccoExtensionService>();
        await tobaccoService.createBySsccCode(ssccCode, extension);
        debugPrint('SSCC Tobacco extension saved for SSCC: $ssccCode');
      }
    } catch (e) {
      debugPrint('Error saving SSCC tobacco extension: $e');
      // Don't show error to user since SSCC was saved successfully
      // The tobacco extension can be added later if needed
    }
  }

  /// Save pharmaceutical extension if the widget has data
  Future<void> _savePharmaExtensionIfNeeded(
    int? ssccId,
    String ssccCode,
  ) async {
    final pharmaState = _pharmaExtensionKey.currentState;
    debugPrint(
      'SSCC Pharma extension check - state: ${pharmaState != null}, hasData: ${pharmaState?.hasData}',
    );

    if (pharmaState == null) {
      debugPrint(
        'Pharma extension widget not in tree (probably not in pharmaceutical mode)',
      );
      return; // Widget not in tree
    }

    if (!pharmaState.hasData) {
      debugPrint('No pharmaceutical extension data to save');
      return; // No data to save
    }

    try {
      final extension = pharmaState.buildExtension(
        ssccId: ssccId,
        ssccCode: ssccCode,
      );
      debugPrint('Built pharma extension: ${extension != null}');
      if (extension != null) {
        final pharmaService = getIt<SSCCPharmaceuticalExtensionService>();
        await pharmaService.createBySsccCode(ssccCode, extension);
        debugPrint('SSCC Pharmaceutical extension saved for SSCC: $ssccCode');
      }
    } catch (e) {
      debugPrint('Error saving SSCC pharmaceutical extension: $e');
      // Don't show error to user since SSCC was saved successfully
      // The pharmaceutical extension can be added later if needed
    }
  }

  void _populateFormFields(SSCC sscc) {
    print(
      'Populating form fields with SSCC: id=${sscc.id}, code=${sscc.ssccCode}',
    );

    _sscc = sscc;
    _ssccCodeController.text = sscc.ssccCode;

    if (sscc.issuingGLN != null) {
      // GS1 compliance: Display the issuing GLN (the location that created this SSCC)
      _glnController.text = sscc.issuingGLN!.glnCode;
    } else if (sscc.gs1CompanyPrefix != null) {
      // Fallback: In edit mode we don't have the GLN, but we have the company prefix
      // We'll display the company prefix in the GLN field for reference
      _glnController.text = '(GS1 Company Prefix: ${sscc.gs1CompanyPrefix})';
    } else {
      _glnController.text = '(Issuing GLN not available)';
    }

    _extensionDigitController.text = sscc.extensionDigit ?? '0';

    setState(() {
      _containerType = sscc.containerType;
      _containerStatus = sscc.containerStatus;
      _packingDate = sscc.packingDate;
      _isLoading = false;
    });

    print('Form fields populated successfully');
  }

  Future<void> _saveSSCC() async {
    // Check if SSCC code has been generated
    if (_ssccCodeController.text.isEmpty &&
        widget.mode == SSCCDetailMode.create) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please generate an SSCC code first by clicking the generate button',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();

      // Show loading indicator
      setState(() {
        _isLoading = true;
      });
      // Extract the GS1 company prefix from SSCC (first 7-10 digits after extension digit)
      // For a standard SSCC with format: Extension Digit (1) + GS1 Company Prefix (7-10) + Serial Reference (variable) + Check Digit (1)
      String gs1CompanyPrefix = '';
      String serialReference = '';
      String checkDigit = '';
      if (_ssccCodeController.text.isNotEmpty) {
        var ssccCode = _ssccCodeController.text;

        // Validate and fix the SSCC code if needed
        if (ssccCode.length != 18) {
          // Try to fix the SSCC code
          final fixedSSCC = GS1Utils.validateAndFixSSCC(ssccCode);
          if (fixedSSCC != null) {
            print('Fixed SSCC before saving: $fixedSSCC (was: $ssccCode)');
            ssccCode = fixedSSCC;
            _ssccCodeController.text =
                ssccCode; // Update the controller with the fixed code
          } else {
            // If we couldn't fix the SSCC, show an error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Invalid SSCC code - must be 18 digits (current: ${ssccCode.length} digits)',
                ),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }

        // SSCC must be 18 digits now
        // First digit is extension digit, last digit is check digit
        gs1CompanyPrefix = ssccCode.substring(
          1,
          8,
        ); // Using 7 digit company prefix as default
        serialReference = ssccCode.substring(8, 17); // Rest is serial reference
        checkDigit = ssccCode.substring(17); // Last digit is check digit

        print(
          'Extracted from SSCC: prefix=$gs1CompanyPrefix, serial=$serialReference, check=$checkDigit',
        );
      } else {
        // If no SSCC code available, we can't save
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please generate an SSCC code first'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      // Create an absolutely minimal SSCC object with ONLY the fields that the backend accepts
      // After multiple test attempts, we've discovered the backend is very strict

      // Extract the actual GLN code from the input for issuing GLN
      String? issuingGLNCode;
      if (_glnController.text.isNotEmpty) {
        try {
          issuingGLNCode = GS1Utils.extractGLNCode(_glnController.text);
          print('DEBUG: GLN Controller text: ${_glnController.text}');
          print('DEBUG: Extracted issuing GLN code: $issuingGLNCode');
        } catch (e) {
          print(
            'Could not extract GLN from input: ${_glnController.text}, error: $e',
          );
        }
      }

      print('DEBUG: SSCC Code Controller text: ${_ssccCodeController.text}');
      print('DEBUG: GLN Controller text: ${_glnController.text}');
      print(
        'DEBUG: Are they the same? ${_ssccCodeController.text == _glnController.text}',
      );

      final sscc = SSCC(
        // Only include ID when editing, not for new creation
        id: widget.mode == SSCCDetailMode.create ? null : _sscc?.id,
        // The SSCC code is the main identifier the backend needs
        ssccCode: _ssccCodeController.text,
        // Basic container information
        containerType: _containerType,
        containerStatus: _containerStatus,
        // Only include packingDate if it exists - this seems to be accepted
        packingDate: _packingDate,

        // The following fields are only stored locally and are NOT sent to backend
        // but are required by our SSCC model constructor
        extensionDigit: _extensionDigitController.text.isEmpty
            ? '0'
            : _extensionDigitController.text,
        gs1CompanyPrefix: gs1CompanyPrefix,
        serialReference: serialReference,
        checkDigit: checkDigit,

        // GS1 compliance: Store the issuing GLN (the location that created this SSCC)
        // This will be sent to the backend for proper supply chain traceability
        issuingGLN: issuingGLNCode != null
            ? GLN.fromCode(issuingGLNCode)
            : null,

        // These timestamps are now only stored locally - backend will handle its own timestamps
        createdAt: _sscc?.createdAt ?? now,
        updatedAt: now,
      );

      // Debug log to see what we're working with locally vs what will be sent to backend
      print('Creating SSCC with:');
      print('FIELDS TO BE SENT TO BACKEND:');
      print('- SSCC Code: ${sscc.ssccCode}');
      print('- Container Type: ${sscc.containerType.name}');
      print('- Container Status: ${sscc.containerStatus.name}');
      if (sscc.packingDate != null) {
        print('- Packing Date: ${sscc.packingDate!.toIso8601String()}');
      }
      if (sscc.issuingGLN != null) {
        print(
          '- Issuing GLN: ${sscc.issuingGLN!.glnCode} (GS1 Compliance - tracks SSCC origin)',
        );
      }

      print('LOCAL FIELDS (NOT SENT to backend):');
      print('  - Company Prefix: ${sscc.gs1CompanyPrefix}');
      print('  - Extension Digit: ${sscc.extensionDigit}');
      print('  - Serial Reference: ${sscc.serialReference}');
      print('  - Check Digit: ${sscc.checkDigit}');
      print('  - CreatedAt/UpdatedAt: [REMOVED FROM PAYLOAD]');

      // Print the actual JSON that will be sent to the backend
      final jsonToSend = sscc.toJson();
      print(
        'FINAL SSCC JSON to be sent to backend: ${json.encode(jsonToSend)}',
      );
      print('Fields included in JSON: ${jsonToSend.keys.toList()}');
      print(
        'Fields NOT included: extensionDigit, serialReference, checkDigit, companyPrefix, gs1CompanyPrefix, createdAt, updatedAt',
      );

      // Extra validation - make sure we're only sending what the backend expects
      if (jsonToSend.containsKey('createdAt') ||
          jsonToSend.containsKey('updatedAt')) {
        print(
          'WARNING: JSON still contains timestamps that backend may reject!',
        );
      }

      if (widget.mode == SSCCDetailMode.create) {
        print(
          'Creating new SSCC - JSON to be sent: ${json.encode(sscc.toJson())}',
        );
        context.read<SSCCCubit>().createSSCC(sscc);
      } else if (widget.mode == SSCCDetailMode.edit && _sscc?.id != null) {
        print('Updating SSCC - JSON to be sent: ${json.encode(sscc.toJson())}');
        context.read<SSCCCubit>().updateSSCC(_sscc!.id!, sscc);
      }
    }
  }

  void _generateSSCCCode() {
    // Clear any previous errors
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (_glnController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GLN is required to generate SSCC'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_extensionDigitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Extension Digit is required to generate SSCC'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate extension digit
    if (!RegExp(r'^\d$').hasMatch(_extensionDigitController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Extension Digit must be a single digit (0-9)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set state to loading
    setState(() {
      _isLoading = true;
    });

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating SSCC code...'),
        duration: Duration(seconds: 2),
      ),
    );

    print(
      'Generating SSCC from GLN: ${_glnController.text}, Extension: ${_extensionDigitController.text}',
    );

    // Use the GLN to generate the SSCC
    context.read<SSCCCubit>().generateSSCCFromGLN(
      _glnController.text,
      _extensionDigitController.text,
    );
  }
  // Using GS1Utils.validateAndFixSSCC instead of this method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleText()),
        actions: _buildAppBarActions(),
      ),
      drawer: const AppDrawer(),
      body: BlocConsumer<SSCCCubit, SSCCState>(
        listener: (context, state) async {
          print('BlocConsumer listener received status: ${state.status}');

          if (state.status == SSCCStatus.error && state.error != null) {
            // Always reset loading state when an error occurs
            setState(() {
              _isLoading = false;
            });

            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 8),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    // Dismiss the snackbar
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          } else if (state.status == SSCCStatus.success &&
              state.selectedSSCC != null) {
            _populateFormFields(state.selectedSSCC!);

            // Handle extension data capture and saving for CREATE/UPDATE
            if (_isLoading) {
              final ssccCode = _ssccCodeController.text;

              // Save extensions if there's data (based on industry mode)
              _saveTobaccoExtensionIfNeeded(null, ssccCode);
              _savePharmaExtensionIfNeeded(null, ssccCode);

              setState(() {
                _isLoading = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SSCC saved successfully'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.of(context).pop();
            }
          } else if (state.status == SSCCStatus.codeGenerated &&
              state.generatedCode != null) {
            // Get the generated SSCC code
            String ssccCode = state.generatedCode!;

            // Check if the SSCC code is valid (18 digits)
            if (ssccCode.length != 18) {
              // Try to fix the SSCC code if it's only 17 digits
              final fixedSSCC = GS1Utils.validateAndFixSSCC(ssccCode);
              if (fixedSSCC != null) {
                ssccCode = fixedSSCC;
                print('Fixed SSCC code from backend: $ssccCode');
              } else {
                // Show an error if we couldn't fix the SSCC
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Invalid SSCC generated (${ssccCode.length} digits instead of 18). Trying to regenerate...',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );

                // Try to generate locally
                try {
                  // Extract company prefix from GLN
                  final companyPrefix = GS1Utils.extractCompanyPrefixFromGLN(
                    GS1Utils.extractGLNCode(_glnController.text) ?? '',
                  );

                  // Generate locally
                  ssccCode = GS1Utils.generateSSCC(
                    companyPrefix,
                    _extensionDigitController.text,
                  );

                  print('Generated SSCC locally: $ssccCode');
                } catch (e) {
                  print('Error generating SSCC locally: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to generate valid SSCC: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }
              }
            }
            // Reset loading state first before updating UI
            setState(() {
              _isLoading = false;
            });

            // Then update the fields in a separate setState to ensure UI refresh
            Future.microtask(() {
              if (mounted) {
                setState(() {
                  _ssccCodeController.text = ssccCode;

                  // DO NOT overwrite the GLN field - keep the original GLN value for issuing GLN!
                  // The original GLN is needed for proper GS1 compliance and supply chain traceability
                  print('SSCC Generated: $ssccCode');
                  print('Preserving original GLN: ${_glnController.text}');
                });

                // Show success message
                //ScaffoldMessenger.of(context).showSnackBar(
                //  SnackBar(
                //    content: Text('SSCC code generated successfully: $ssccCode'),
                //    backgroundColor: Colors.green,
                //    duration: Duration(seconds: 8),
                //    action: SnackBarAction(
                //      label: 'Save',
                //      textColor: Colors.white,
                //      onPressed: _saveSSCC,
                //    ),
                //  ),
                //);
              }
            });
          }
        },
        builder: (context, state) {
          print('Detail screen builder status: ${state.status}');

          // Handle SSCCStatus.codeGenerated state immediately to prevent getting stuck on loading
          if (state.status == SSCCStatus.codeGenerated &&
              state.generatedCode != null) {
            print(
              'Building UI for SSCCStatus.codeGenerated state, SSCC: ${state.generatedCode}',
            );
            // We need to make sure the UI has access to the generated SSCC code
            // Since the listener might not have completed updating the controller
            if (_ssccCodeController.text.isEmpty) {
              print(
                'SSCC code controller is empty, updating with generated code',
              );
              _ssccCodeController.text = state.generatedCode!;
            }

            // Since we handle the state in the listener, we should just return the form here
            _isLoading = false; // Make sure we're not stuck in loading
            return _buildForm();
          }

          if (state.status == SSCCStatus.loading || _isLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state.status == SSCCStatus.error) {
            // Show error but also the form for create mode to allow retry
            if (widget.mode == SSCCDetailMode.create) {
              // Reset loading state
              _isLoading = false;

              // Return the form so user can try again
              return _buildForm();
            }

            // For other modes, show detailed error
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error ${widget.mode == SSCCDetailMode.edit ? 'Updating' : 'Loading'} SSCC Details',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      state.error ?? 'Unknown error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadData,
                        label: const Text('Retry'),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                        label: const Text('Go Back'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state.status == SSCCStatus.success) {
            // Already populated from listener
            return _buildForm();
          }

          // Default return - for any other state (including SSCCInitial)
          // or when we're on the create screen and just need the form
          if (widget.mode == SSCCDetailMode.create) {
            print('Showing form for create mode (default case)');
            return _buildForm();
          }

          // For edit or view modes, if we have data, show the form
          if (_sscc != null) {
            print('Showing form with existing SSCC data');
            return _buildForm();
          }

          // Fallback to loading indicator if none of the above conditions are met
          print('Showing loading indicator as fallback');
          return const Center(child: LoadingIndicator());
        },
      ),
    );
  }

  String _getTitleText() {
    switch (widget.mode) {
      case SSCCDetailMode.create:
        return 'Create New SSCC';
      case SSCCDetailMode.edit:
        return 'Edit SSCC';
      case SSCCDetailMode.view:
        return 'SSCC Details';
    }
  }

  List<Widget> _buildAppBarActions() {
    final actions = <Widget>[];

    if (widget.mode == SSCCDetailMode.view) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            setState(() {
              _isEditMode = true;
            });
          },
        ),
      );
    }

    if (_isEditMode || widget.mode == SSCCDetailMode.create) {
      actions.add(
        IconButton(icon: const Icon(Icons.save), onPressed: _saveSSCC),
      );
    }

    return actions;
  }

  Widget _buildForm() {
    print(
      'Building form, SSCC code: ${_ssccCodeController.text}, GLN: ${_glnController.text}',
    );
    final isReadOnly = widget.mode == SSCCDetailMode.view && !_isEditMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GS1 Compliance Info Card
            if (widget.mode == SSCCDetailMode.create)
              // Card(
              //   color: Colors.blue.shade50,
              //   child: Padding(
              //     padding: const EdgeInsets.all(16.0),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: const [
              //         Text(
              //           'GS1 Compliant SSCC Creation',
              //           style: TextStyle(
              //             fontSize: 18.0,
              //             fontWeight: FontWeight.bold,
              //             color: Colors.blue,
              //           ),
              //         ),
              //         SizedBox(height: 8.0),
              //         Text(
              //           'SSCC (Serial Shipping Container Code) is an 18-digit GS1 identifier used for tracking and tracing logistics units.',
              //           style: TextStyle(fontSize: 14.0),
              //         ),
              //         SizedBox(height: 8.0),
              //         Text(
              //           '• Enter your organization\'s GLN (Global Location Number)\n'
              //           '• Select an Extension Digit (0-9)\n'
              //           '• A valid SSCC will be generated automatically',
              //           style: TextStyle(fontSize: 14.0),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              //const SizedBox(height: 16.0),
              // Main form sections
              _buildSSCCCodeSection(isReadOnly),
            const SizedBox(height: 16.0),
            _buildContainerInfoSection(isReadOnly),
            const SizedBox(height: 16.0),
            _buildDateSection(isReadOnly),

            // Location section only for edit/view modes
            if (widget.mode != SSCCDetailMode.create)
              Column(
                children: [
                  const SizedBox(height: 16.0),
                  _buildLocationSection(isReadOnly),
                ],
              ),

            const SizedBox(height: 24.0),

            // Industry Extension Widgets (based on global industry mode)
            BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
              builder: (context, settingsState) {
                final settings = settingsState.settings;
                debugPrint(
                  'SSCC SystemSettings - isInitialized: ${settingsState.isInitialized}, '
                  'mode: ${settings.industryMode}, '
                  'isPharmaceutical: ${settings.isPharmaceuticalMode}, '
                  'isTobacco: ${settings.isTobaccoMode}',
                );

                // Get the SSCC code from the existing SSCC or form
                // For view/edit mode, _sscc will have the loaded SSCC with code
                // Extensions are loaded by ssccCode (not ssccId) since SSCC uses UUID but extensions use integer FK
                final currentSsccCode =
                    _sscc?.ssccCode ?? _ssccCodeController.text;
                // Only pass ssccCode for loading - extensions are keyed by code for lookup
                final hasExistingSscc =
                    widget.mode != SSCCDetailMode.create &&
                    currentSsccCode.isNotEmpty;

                // Pharmaceutical Mode: Show pharmaceutical extension
                if (settings.isPharmaceuticalMode) {
                  return SSCCPharmaceuticalExtensionWidget(
                    key: _pharmaExtensionKey,
                    ssccCode: hasExistingSscc ? currentSsccCode : null,
                    isEditing: !isReadOnly,
                  );
                }

                // Tobacco Mode: Show tobacco extension (when feature enabled)
                if (settings.isTobaccoMode && kTobaccoExtensionEnabled) {
                  return SSCCTobaccoExtensionWidget(
                    key: _tobaccoExtensionKey,
                    ssccCode: hasExistingSscc ? currentSsccCode : null,
                    isEditing: !isReadOnly,
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24.0),

            // Save button
            if (!isReadOnly)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveSSCC,
                  icon: const Icon(Icons.save),
                  label: Text(
                    widget.mode == SSCCDetailMode.create
                        ? 'Create SSCC'
                        : 'Save Changes',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSSCCCodeSection(bool isReadOnly) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SSCC Identification',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Enter the GLN of the location that will create/issue this SSCC for GS1 traceability',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            ValidatedTextField(
              controller: _glnController,
              decoration: InputDecoration(
                labelText: 'Issuing GLN (Location Creating This SSCC)',
                helperText:
                    'Enter 13-digit GLN, GS1 barcode format (414)nnnnnnnnnnnn or URN format',
                border: OutlineInputBorder(),
                suffixIcon: !isReadOnly
                    ? IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        tooltip: 'Scan GLN Barcode',
                        onPressed: () {
                          // This would integrate with a barcode scanner
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Barcode scanner not implemented'),
                            ),
                          );
                        },
                      )
                    : null,
              ),
              readOnly: isReadOnly,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  setFieldError('gln', 'GLN is required');
                  return 'GLN is required';
                }
                setFieldError('gln', null);
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ValidatedTextField(
                    controller: _extensionDigitController,
                    decoration: const InputDecoration(
                      labelText: 'Extension Digit',
                      helperText: 'Logistic variants (0-9)',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: isReadOnly,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setFieldError('extensionDigit', 'Required');
                        return 'Required';
                      }
                      if (!RegExp(r'^[0-9]$').hasMatch(value)) {
                        setFieldError('extensionDigit', 'Must be 0-9');
                        return 'Must be 0-9';
                      }
                      setFieldError('extensionDigit', null);
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 3,
                  child: ValidatedTextField(
                    controller: _ssccCodeController,
                    decoration: InputDecoration(
                      labelText: 'SSCC Code',
                      helperText: 'Will be generated automatically',
                      hintText: 'Click Generate button →',
                      border: OutlineInputBorder(),
                      suffixIcon: !isReadOnly
                          ? IconButton(
                              icon: const Icon(Icons.autorenew),
                              tooltip: 'Generate SSCC Code',
                              onPressed: _generateSSCCCode,
                            )
                          : null,
                      // Add filled background to make it more visible
                      filled: true,
                      fillColor: _ssccCodeController.text.isEmpty
                          ? Colors.grey.shade100
                          : (_ssccCodeController.text.length == 18
                                ? Colors.green.shade50
                                : Colors.red.shade50),
                    ),
                    // Always read-only since it's generated
                    readOnly: true,
                    // Make validation require a value
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please generate an SSCC code';
                      }
                      if (value.length != 18) {
                        return 'SSCC code must be 18 digits';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerInfoSection(bool isReadOnly) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Container Information',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<ContainerType>(
              decoration: const InputDecoration(
                labelText: 'Container Type',
                helperText: 'Select the physical container type',
                border: OutlineInputBorder(),
              ),
              value: _containerType,
              items: ContainerType.values.map((type) {
                return DropdownMenuItem<ContainerType>(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: isReadOnly
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _containerType = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16.0),
            // Only show status field in edit mode, not in create mode
            if (widget.mode != SSCCDetailMode.create || _isEditMode)
              DropdownButtonFormField<ContainerStatus>(
                decoration: const InputDecoration(
                  labelText: 'Container Status',
                  border: OutlineInputBorder(),
                ),
                value: _containerStatus,
                items: ContainerStatus.values.map((status) {
                  return DropdownMenuItem<ContainerStatus>(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),
                onChanged: isReadOnly
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _containerStatus = value;
                          });
                        }
                      },
              )
            else
              // For create mode, just show a text field indicating CREATED status
              ValidatedTextField(
                decoration: const InputDecoration(
                  labelText: 'Container Status',
                  helperText: 'New containers are always in CREATED status',
                  border: OutlineInputBorder(),
                ),
                initiallyValidated: true,
                readOnly: true,
                validator: (_) {
                  setFieldError('containerStatus', null);
                  return null;
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(bool isReadOnly) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date Information',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            // For initial SSCC creation, only packing date is relevant
            GestureDetector(
              onTap: isReadOnly
                  ? null
                  : () => _selectDate(context, (date) {
                      setState(() {
                        _packingDate = date;
                      });
                    }),
              child: AbsorbPointer(
                child: ValidatedTextField(
                  decoration: InputDecoration(
                    labelText: 'Packing Date',
                    helperText:
                        'Date when the container is packed (optional for initial creation)',
                    border: const OutlineInputBorder(),
                    suffixIcon: isReadOnly
                        ? null
                        : const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: _packingDate != null
                        ? dateFormat.format(_packingDate!)
                        : '',
                  ),
                  validator: (value) {
                    // Optional field, no validation needed
                    setFieldError('packingDate', null);
                    return null;
                  },
                ),
              ),
            ),
            // If we're in edit mode, we might show more date fields here
            if (widget.mode != SSCCDetailMode.create)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Additional dates (shipping, receiving) can be updated later in the container lifecycle.',
                  style: TextStyle(
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(bool isReadOnly) {
    // In create mode, don't show location information
    if (widget.mode == SSCCDetailMode.create) {
      return const SizedBox.shrink(); // Return an empty widget
    }

    // In edit or view mode, show a placeholder for location information
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Information',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Location information (source and destination) can be added later in the SSCC lifecycle when shipping or receiving occurs.',
              style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
