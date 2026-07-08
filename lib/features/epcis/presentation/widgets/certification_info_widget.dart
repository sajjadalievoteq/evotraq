import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/epcis/certification_info.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class CertificationInfoWidget extends StatefulWidget {
  final List<CertificationInfo> certifications;
  
  final void Function(List<CertificationInfo> certifications)? onCertificationsChanged;
  
  final bool isViewOnly;

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
        if (_certifications.isEmpty && widget.isViewOnly)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No certification information recorded for this event'),
          ),
        
        ..._certifications.map((certification) => _buildCertificationCard(certification)),
        if (!widget.isViewOnly)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton.icon(
              onPressed: _addCertification,
              icon: TraqIcon(AppAssets.iconPlus),
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
                        icon: TraqIcon(AppAssets.iconEdit),
                        onPressed: () => _editCertification(index),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: TraqIcon(AppAssets.iconTrash),
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

class CertificationInfoDialog extends StatefulWidget {
  final CertificationInfo? certification;
  
  final void Function(CertificationInfo certification) onSave;

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
