import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/gs1/bloc/sgtin/sgtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';
import 'package:traqtrace_app/features/gs1/mixins/gs1_form_validation_mixin.dart';
import 'package:traqtrace_app/features/gs1/models/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'package:traqtrace_app/core/widgets/loading_indicator.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/shared/widgets/gln_selector.dart';

class SGTINDetailScreen extends StatefulWidget {
  final SGTIN? sgtin; // If provided, we're viewing or editing an existing SGTIN
  final String? sgtinId; // ID to load the SGTIN by ID if needed
  final bool isEditing;

  const SGTINDetailScreen({
    Key? key,
    this.sgtin,
    this.sgtinId,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<SGTINDetailScreen> createState() => _SGTINDetailScreenState();
}

class _SGTINDetailScreenState extends State<SGTINDetailScreen> with GS1FormValidationMixin<SGTINDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditing;
  
  // Form controllers
  late TextEditingController _serialNumberController;
  late TextEditingController _batchLotNumberController;
  late TextEditingController _gtinController;
  late TextEditingController _expiryDateController;
  late TextEditingController _productionDateController;
  late TextEditingController _bestBeforeDateController;
  late TextEditingController _regulatoryMarketController;
  late TextEditingController _regulatoryStatusController;
  
  DateTime? _expiryDate;
  DateTime? _productionDate;
  DateTime? _bestBeforeDate;
  
  ItemStatus? _selectedStatus;
  GLN? _selectedLocation;
  bool _isLoading = false;
  String _decommissionReason = '';

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isEditing;
    
    // Initialize controllers with empty values initially
    _serialNumberController = TextEditingController();
    _batchLotNumberController = TextEditingController();
    _gtinController = TextEditingController();
    _regulatoryMarketController = TextEditingController();
    _regulatoryStatusController = TextEditingController();
    _expiryDateController = TextEditingController();
    _productionDateController = TextEditingController();
    _bestBeforeDateController = TextEditingController();
    
    // If we have a SGTIN object directly, use it
    if (widget.sgtin != null) {
      _populateFormWithSGTIN(widget.sgtin!);
    } 
    // If we have an ID, load the SGTIN after the first frame
    else if (widget.sgtinId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadSGTINById(widget.sgtinId!);
        }
      });
    }
  }
  
  void _loadSGTINById(String id) {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    context.read<SGTINCubit>().fetchSGTINById(id);
  }
  
  void _populateFormWithSGTIN(SGTIN sgtin) {
    _serialNumberController.text = sgtin.serialNumber;
    _batchLotNumberController.text = sgtin.batchLotNumber ?? '';
    _gtinController.text = sgtin.gtinCode;
    _regulatoryMarketController.text = sgtin.regulatoryMarket ?? '';
    _regulatoryStatusController.text = sgtin.regulatoryStatus ?? '';
    
    _expiryDate = sgtin.expiryDate;
    _productionDate = sgtin.productionDate;
    _bestBeforeDate = sgtin.bestBeforeDate;
    _selectedStatus = sgtin.status;
    _selectedLocation = sgtin.currentLocation;
    
    if (sgtin.expiryDate != null) {
      _expiryDateController.text = DateFormat('yyyy-MM-dd').format(sgtin.expiryDate!);
    }
    
    if (sgtin.productionDate != null) {
      _productionDateController.text = DateFormat('yyyy-MM-dd').format(sgtin.productionDate!);
    }
    
    if (sgtin.bestBeforeDate != null) {
      _bestBeforeDateController.text = DateFormat('yyyy-MM-dd').format(sgtin.bestBeforeDate!);
    }
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    _batchLotNumberController.dispose();
    _gtinController.dispose();
    _expiryDateController.dispose();
    _productionDateController.dispose();
    _bestBeforeDateController.dispose();
    _regulatoryMarketController.dispose();
    _regulatoryStatusController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        onDateSelected(picked);
      });
    }
  }  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check commissioning location for new SGTINs
      if (widget.sgtin == null && _selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commissioning Location is required for new SGTINs')),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      final sgtin = SGTIN(
        id: widget.sgtin?.id, // Will be null for new SGTINs, which is fine
        serialNumber: _serialNumberController.text,
        batchLotNumber: _batchLotNumberController.text,
        gtinCode: _gtinController.text,
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
        createdAt: widget.sgtin?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      try {
        if (widget.sgtin != null && widget.sgtin!.id != null) {
          // Update existing SGTIN
          context.read<SGTINCubit>().updateSGTIN(widget.sgtin!.id!, sgtin);
        } else {
          // Creating a new SGTIN
          context.read<SGTINCubit>().createSGTIN(sgtin);
        }
      } catch (e) {
        // Handle any exceptions during the process
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _decommissionSGTIN() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decommission SGTIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide reason for decommissioning:'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _decommissionReason = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              if (_decommissionReason.isNotEmpty) {
                Navigator.pop(context);
                context.read<SGTINCubit>().decommission(
                  widget.sgtin!.serialNumber,
                  _decommissionReason,
                );
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
    return BlocListener<SGTINCubit, SGTINState>(
      listenWhen: (previous, current) => 
        current.status != previous.status ||
        current.error != previous.error ||
        current.sgtin != previous.sgtin ||
        current.creationSuccessful != previous.creationSuccessful,
      listener: (context, state) {
        // Handle the various state changes
        if (state.status == SGTINStatus.loading) {
          if (!_isLoading) {
            setState(() {
              _isLoading = true;
            });
          }
        } else if (state.status == SGTINStatus.success) {
          // If we just loaded data with success
          if (state.sgtin != null && (widget.sgtin == null || widget.sgtinId != null)) {
            // Populate form with data if we're loading an existing SGTIN
            _populateFormWithSGTIN(state.sgtin!);
          }
          
          setState(() {
            _isLoading = false;
          });

          // Handle successful creation/update
          if (state.creationSuccessful) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.sgtin == null ? 'SGTIN created successfully' : 'SGTIN updated successfully')),
            );
            context.go('/gs1/sgtins');
          }
        } else if (state.status == SGTINStatus.error) {
          setState(() {
            _isLoading = false;
          });
          
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}')),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.sgtin == null ? 'Create SGTIN' : 'SGTIN Details'),
          actions: [
            if (widget.sgtin != null && !_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
            if (widget.sgtin != null && _isEditing)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
              ),
          ],
        ),
        drawer: const AppDrawer(),
        body: _buildBody(),
        floatingActionButton: _isEditing || widget.sgtin == null
            ? FloatingActionButton(
                onPressed: _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.save),
              )
            : null,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SGTIN Details
            _buildSectionHeader('SGTIN Details'),
            _buildValidatedField(
              label: 'GTIN',
              controller: _gtinController,
              fieldName: 'gtinCode',
              enabled: _isEditing && widget.sgtin == null, // Can only set GTIN when creating
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter GTIN code';
                }
                if (!RegExp(r'^\d{8}$|^\d{12,14}$').hasMatch(value)) {
                  return 'Invalid GTIN format. Must be 8, 12, 13, or 14 digits.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildValidatedField(
              label: 'Serial Number',
              controller: _serialNumberController,
              fieldName: 'serialNumber',
              enabled: _isEditing && widget.sgtin == null, // Can only set serial when creating
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter serial number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildValidatedField(
              label: 'Batch/Lot Number',
              controller: _batchLotNumberController,
              fieldName: 'batchLotNumber',
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter batch/lot number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Commissioning Location - Required for new SGTINs (GS1 EPCIS 2.0)
            _buildSectionHeader('Commissioning Location'),
            if (_isEditing || widget.sgtin == null)
              GLNSelector(
                label: 'Location (GLN) *',
                hintText: 'Select commissioning location',
                initialValue: _selectedLocation,
                isRequired: widget.sgtin == null, // Required only for new SGTINs
                onChanged: (gln) {
                  setState(() {
                    _selectedLocation = gln;
                  });
                },
              )
            else
              _buildInfoField(
                label: 'Current Location',
                value: _selectedLocation != null 
                    ? '${_selectedLocation!.glnCode} - ${_selectedLocation!.locationName}'
                    : 'N/A',
              ),
            if (widget.sgtin == null)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  'Required: Where was this product commissioned (manufactured/serialized)?',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            
            // Dates
            _buildSectionHeader('Dates'),
            GestureDetector(
              onTap: _isEditing 
                  ? () => _selectDate(context, _expiryDateController, (date) {
                      _expiryDate = date;
                    }) 
                  : null,
              child: AbsorbPointer(
                child: _buildValidatedField(
                  label: 'Expiry Date',
                  controller: _expiryDateController,
                  enabled: _isEditing,
                  suffixIcon: _isEditing ? const Icon(Icons.calendar_today) : null,
                  fieldName: 'expiryDate',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expiry date';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isEditing 
                  ? () => _selectDate(context, _productionDateController, (date) {
                      _productionDate = date;
                    }) 
                  : null,
              child: AbsorbPointer(
                child: _buildValidatedField(
                  label: 'Production Date',
                  controller: _productionDateController,
                  enabled: _isEditing,
                  fieldName: 'productionDate',
                  suffixIcon: _isEditing ? const Icon(Icons.calendar_today) : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isEditing 
                  ? () => _selectDate(context, _bestBeforeDateController, (date) {
                      _bestBeforeDate = date;
                    })
                  : null,
              child: AbsorbPointer(
                child: _buildValidatedField(
                  label: 'Best Before Date',
                  controller: _bestBeforeDateController,
                  enabled: _isEditing,
                  fieldName: 'bestBeforeDate',
                  suffixIcon: _isEditing ? const Icon(Icons.calendar_today) : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Status
            _buildSectionHeader('Status'),
            // For new SGTINs, status is always COMMISSIONED (per GS1 EPCIS 2.0)
            // Status can only be changed via decommissioning action
            if (widget.sgtin == null)
              _buildInfoField(
                label: 'Status',
                value: 'COMMISSIONED',
                color: Colors.green,
              )
            else if (_isEditing)
              // When editing existing SGTIN, status is read-only
              // Use decommission action to change status
              _buildInfoField(
                label: 'Status',
                value: _selectedStatus?.name ?? 'COMMISSIONED',
                color: _getStatusColor(_selectedStatus),
              )
            else
              _buildInfoField(
                label: 'Status',
                value: _selectedStatus?.name ?? 'N/A',
                color: _getStatusColor(_selectedStatus),
              ),
            const SizedBox(height: 16),
            
            // Regulatory Information
            _buildSectionHeader('Regulatory Information'),
            _buildValidatedField(
              label: 'Regulatory Market',
              controller: _regulatoryMarketController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildValidatedField(
              label: 'Regulatory Status',
              controller: _regulatoryStatusController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            
            // Decommission button (only shown for existing SGTINs in view mode)
            if (widget.sgtin != null && !_isEditing)
              _buildSectionHeader('Actions'),
            if (widget.sgtin != null && 
                !_isEditing &&
                _selectedStatus != ItemStatus.DECOMMISSIONED)
              ElevatedButton.icon(
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Decommission SGTIN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _decommissionSGTIN,
              ),
            
            const SizedBox(height: 24),
            
            // Add extra space at bottom for better scrolling
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  // _buildFormField has been replaced with _buildValidatedField

  Widget _buildValidatedField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    String? fieldName,
    String? helperText,
  }) {
    // Generate a field name if not provided
    final validationField = fieldName ?? label.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    
    return ValidatedTextFieldWrapper(
      controller: controller,
      fieldName: validationField,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
        helperText: helperText,
      ),
      readOnly: !enabled,
      setFieldError: setFieldError,
      validator: validator ?? (value) => null, // Provide a default validator that always passes
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
              color: color != null ? color.withOpacity(0.1) : null,
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color? _getStatusColor(ItemStatus? status) {
    if (status == null) return null;
    
    switch (status) {
      case ItemStatus.COMMISSIONED:
        return Colors.green;
      case ItemStatus.DECOMMISSIONED:
      case ItemStatus.RECALLED:
      case ItemStatus.STOLEN:
      case ItemStatus.DAMAGED:
      case ItemStatus.DESTROYED:
        return Colors.red;
      case ItemStatus.PACKED:
      case ItemStatus.SHIPPED:
      case ItemStatus.IN_TRANSIT:
        return Colors.blue;
      case ItemStatus.DISPENSED:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}