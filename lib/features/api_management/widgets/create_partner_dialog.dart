import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/api_management/cubit/api_management_cubit.dart';
import 'package:traqtrace_app/features/api_management/models/partner.dart';

/// Dialog for creating a new B2B partner
class CreatePartnerDialog extends StatefulWidget {
  const CreatePartnerDialog({super.key});

  @override
  State<CreatePartnerDialog> createState() => _CreatePartnerDialogState();
}

class _CreatePartnerDialogState extends State<CreatePartnerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _partnerCodeController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _glnController = TextEditingController();
  final _webhookUrlController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  
  PartnerType _selectedPartnerType = PartnerType.other;
  DataFormat _selectedDataFormat = DataFormat.epcisJson;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _partnerCodeController.dispose();
    _companyNameController.dispose();
    _glnController.dispose();
    _webhookUrlController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.business, size: 24),
          const SizedBox(width: 8),
          const Text('Create New Partner'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Basic Information'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _partnerCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Partner Code *',
                          hintText: 'e.g., PARTNER001',
                          prefixIcon: Icon(Icons.tag),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Partner code is required';
                          }
                          if (value.contains(' ')) {
                            return 'No spaces allowed';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _companyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name *',
                          hintText: 'e.g., Acme Corp',
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Company name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<PartnerType>(
                        value: _selectedPartnerType,
                        decoration: const InputDecoration(
                          labelText: 'Partner Type *',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: PartnerType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedPartnerType = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<DataFormat>(
                        value: _selectedDataFormat,
                        decoration: const InputDecoration(
                          labelText: 'Data Format *',
                          prefixIcon: Icon(Icons.data_object),
                        ),
                        items: DataFormat.values.map((format) {
                          return DropdownMenuItem(
                            value: format,
                            child: Text(format.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedDataFormat = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('GS1 Identification'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _glnController,
                  decoration: const InputDecoration(
                    labelText: 'GLN (Global Location Number)',
                    hintText: 'e.g., 0614141000012',
                    prefixIcon: Icon(Icons.location_on),
                    helperText: '13-digit GS1 Global Location Number',
                  ),
                  maxLength: 13,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length != 13) {
                      return 'GLN must be 13 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Integration Settings'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _webhookUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Webhook URL',
                    hintText: 'https://partner.example.com/webhooks/traqtrace',
                    prefixIcon: Icon(Icons.webhook),
                    helperText: 'URL for receiving event notifications',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!value.startsWith('http://') && !value.startsWith('https://')) {
                        return 'URL must start with http:// or https://';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Contact Information'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _contactEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Email',
                          hintText: 'integration@partner.com',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!value.contains('@')) {
                              return 'Invalid email format';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _contactPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Phone',
                          hintText: '+1 (555) 123-4567',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitForm,
          icon: _isSubmitting 
              ? const SizedBox(
                  width: 16, 
                  height: 16, 
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: const Text('Create Partner'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final cubit = context.read<ApiManagementCubit>();
      final partner = await cubit.createPartner(
        partnerCode: _partnerCodeController.text.trim().toUpperCase(),
        companyName: _companyNameController.text.trim(),
        partnerType: _selectedPartnerType,
        preferredDataFormat: _selectedDataFormat,
        gln: _glnController.text.trim().isNotEmpty ? _glnController.text.trim() : null,
        webhookUrl: _webhookUrlController.text.trim().isNotEmpty ? _webhookUrlController.text.trim() : null,
        contactEmail: _contactEmailController.text.trim().isNotEmpty ? _contactEmailController.text.trim() : null,
        contactPhone: _contactPhoneController.text.trim().isNotEmpty ? _contactPhoneController.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context);
        if (partner != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Partner "${partner.companyName}" created successfully')),
          );
        } else if (cubit.state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cubit.state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
