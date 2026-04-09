import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/epcis/models/certification_info.dart';

/// Widget for displaying and editing certification information in EPCIS events
class CertificationInfoWidget extends StatefulWidget {
  /// List of certification info records to display/edit
  final List<CertificationInfo> certifications;
  
  /// Callback when certification info records are updated
  final void Function(List<CertificationInfo> certifications)? onCertificationsChanged;
  
  /// Whether the widget is in view-only mode
  final bool isViewOnly;

  /// Constructor
  const CertificationInfoWidget({
    Key? key,
    required this.certifications,
    this.onCertificationsChanged,
    this.isViewOnly = false,
  }) : super(key: key);

  @override
  State<CertificationInfoWidget> createState() => _CertificationInfoWidgetState();
}

class _CertificationInfoWidgetState extends State<CertificationInfoWidget> {
  late List<CertificationInfo> _certifications;
  
  @override
  void initState() {
    super.initState();
    _certifications = List.from(widget.certifications);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Certifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Standard empty state message
        if (_certifications.isEmpty && widget.isViewOnly)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No certification information recorded for this event'),
          ),
        
        // Regular certification cards
        ..._certifications.map((certification) => _buildCertificationCard(certification)),
        if (!widget.isViewOnly)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton.icon(
              onPressed: _addCertification,
              icon: const Icon(Icons.add),
              label: const Text('Add Certification'),
            ),
          ),
      ],
    );
  }
  
  Widget _buildCertificationCard(CertificationInfo certification) {
    final index = _certifications.indexOf(certification);
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    certification.certificationType ?? 'Certification',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!widget.isViewOnly)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editCertification(index),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeCertification(index),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (certification.certificateId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text('Certificate ID: ${certification.certificateId}'),
              ),              if (certification.certificationStandard != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text('Standard: ${certification.certificationStandard}'),
              ),              if (certification.certificationAgency != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text('Issuing Agency: ${certification.certificationAgency}'),
              ),
              
              // No need to render certificateId again as it's already shown above
              // NOTE: This was a duplicate rendering of certificateId that we've removed
              
            Row(
              children: [
                if (certification.issueDate != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0, right: 8.0),
                      child: Text('Issued: ${dateFormat.format(certification.issueDate!)}'),
                    ),
                  ),
                if (certification.expirationDate != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        'Expires: ${dateFormat.format(certification.expirationDate!)}',
                        style: TextStyle(
                          color: certification.expirationDate!.isBefore(DateTime.now())
                              ? Colors.red
                              : null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (certification.documentUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    const Text('Document: '),
                    Expanded(
                      child: Text(
                        certification.documentUrl!,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            if (certification.remarks != null && certification.remarks!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Remarks: ${certification.remarks}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            
            // Debug information to help diagnose issues
            if (widget.isViewOnly && _certifications.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Debug: ${certification.toJson()}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _addCertification() {
    if (widget.isViewOnly) return;
    
    // Show dialog to add a new certification
    showDialog(
      context: context,
      builder: (context) => CertificationInfoDialog(
        onSave: (certification) {
          setState(() {
            _certifications.add(certification);
          });
          widget.onCertificationsChanged?.call(_certifications);
        },
      ),
    );
  }
  
  void _editCertification(int index) {
    if (widget.isViewOnly) return;
    
    showDialog(
      context: context,
      builder: (context) => CertificationInfoDialog(
        certification: _certifications[index],
        onSave: (certification) {
          setState(() {
            _certifications[index] = certification;
          });
          widget.onCertificationsChanged?.call(_certifications);
        },
      ),
    );
  }
  
  void _removeCertification(int index) {
    if (widget.isViewOnly) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Certification'),
        content: const Text('Are you sure you want to remove this certification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _certifications.removeAt(index);
              });
              widget.onCertificationsChanged?.call(_certifications);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

/// Dialog for adding or editing certification information
class CertificationInfoDialog extends StatefulWidget {
  /// Certification to edit (null for adding new)
  final CertificationInfo? certification;
  
  /// Callback when a certification is saved
  final void Function(CertificationInfo certification) onSave;

  /// Constructor
  const CertificationInfoDialog({
    Key? key,
    this.certification,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CertificationInfoDialog> createState() => _CertificationInfoDialogState();
}

class _CertificationInfoDialogState extends State<CertificationInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _certificateIdController = TextEditingController();
  final _certificationStandardController = TextEditingController();
  final _certificationTypeController = TextEditingController();
  final _certificationAgencyController = TextEditingController();
  final _documentUrlController = TextEditingController();
  final _remarksController = TextEditingController();
  
  DateTime? _issueDate;
  DateTime? _expirationDate;
  
  @override
  void initState() {
    super.initState();
    
    // Pre-fill form if editing existing certification
    if (widget.certification != null) {
      _certificateIdController.text = widget.certification!.certificateId ?? '';
      _certificationStandardController.text = widget.certification!.certificationStandard ?? '';
      _certificationTypeController.text = widget.certification!.certificationType ?? '';
      _certificationAgencyController.text = widget.certification!.certificationAgency ?? '';
      _documentUrlController.text = widget.certification!.documentUrl ?? '';
      _remarksController.text = widget.certification!.remarks ?? '';
      _issueDate = widget.certification!.issueDate;
      _expirationDate = widget.certification!.expirationDate;
    }
  }
  
  @override
  void dispose() {
    _certificateIdController.dispose();
    _certificationStandardController.dispose();
    _certificationTypeController.dispose();
    _certificationAgencyController.dispose();
    _documentUrlController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.certification != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Certification' : 'Add Certification'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _certificationTypeController,
                decoration: const InputDecoration(
                  labelText: 'Certification Type *',
                  hintText: 'e.g., Organic, Fair Trade, etc.',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a certification type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _certificateIdController,
                decoration: const InputDecoration(
                  labelText: 'Certificate ID',
                  hintText: 'Unique identifier for this certificate',
                ),
              ),
              TextFormField(
                controller: _certificationStandardController,
                decoration: const InputDecoration(
                  labelText: 'Certification Standard',
                  hintText: 'e.g., ISO, GS1, etc.',
                ),
              ),
              TextFormField(
                controller: _certificationAgencyController,
                decoration: const InputDecoration(
                  labelText: 'Certifying Agency',
                  hintText: 'Organization that issued the certification',
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Issue Date'),
                        const SizedBox(height: 8.0),
                        InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _issueDate != null
                                  ? DateFormat('yyyy-MM-dd').format(_issueDate!)
                                  : 'Select Date',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Expiration Date'),
                        const SizedBox(height: 8.0),
                        InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _expirationDate != null
                                  ? DateFormat('yyyy-MM-dd').format(_expirationDate!)
                                  : 'Select Date',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _documentUrlController,
                decoration: const InputDecoration(
                  labelText: 'Document URL',
                  hintText: 'Link to certification document',
                ),
              ),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  hintText: 'Additional notes about this certification',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveForm,
          child: const Text('Save'),
        ),
      ],
    );
  }
  
  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final initialDate = isIssueDate ? _issueDate : _expirationDate;
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (selectedDate != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = selectedDate;
        } else {
          _expirationDate = selectedDate;
        }
      });
    }
  }
  
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final certification = CertificationInfo(
        certificateId: _certificateIdController.text.isNotEmpty 
            ? _certificateIdController.text 
            : null,
        certificationStandard: _certificationStandardController.text.isNotEmpty 
            ? _certificationStandardController.text 
            : null,
        certificationType: _certificationTypeController.text,
        certificationAgency: _certificationAgencyController.text.isNotEmpty 
            ? _certificationAgencyController.text 
            : null,
        issueDate: _issueDate,
        expirationDate: _expirationDate,
        documentUrl: _documentUrlController.text.isNotEmpty 
            ? _documentUrlController.text 
            : null,
        remarks: _remarksController.text.isNotEmpty 
            ? _remarksController.text 
            : null,
      );
      
      widget.onSave(certification);
      Navigator.of(context).pop();
    }
  }
}
