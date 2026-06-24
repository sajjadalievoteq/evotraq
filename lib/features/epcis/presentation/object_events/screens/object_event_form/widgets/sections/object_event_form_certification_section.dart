import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/epcis/certification_info.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_mandatory_fields.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_add_to_list_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_required_indicator.dart';

class ObjectEventFormCertificationSection extends StatefulWidget {
  final List<CertificationInfo> certifications;
  final bool isViewOnly;
  final ValueChanged<List<CertificationInfo>> onChanged;

  const ObjectEventFormCertificationSection({
    super.key,
    required this.certifications,
    required this.isViewOnly,
    required this.onChanged,
  });

  @override
  State<ObjectEventFormCertificationSection> createState() =>
      _ObjectEventFormCertificationSectionState();
}

class _ObjectEventFormCertificationSectionState
    extends State<ObjectEventFormCertificationSection> {
  final _typeController = TextEditingController();
  final _certificateIdController = TextEditingController();
  final _standardController = TextEditingController();
  final _agencyController = TextEditingController();
  final _documentUrlController = TextEditingController();
  final _remarksController = TextEditingController();
  DateTime? _issueDate;
  DateTime? _expirationDate;

  @override
  void dispose() {
    _typeController.dispose();
    _certificateIdController.dispose();
    _standardController.dispose();
    _agencyController.dispose();
    _documentUrlController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isIssueDate}) async {
    final initial =
        (isIssueDate ? _issueDate : _expirationDate) ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null) return;
    setState(() {
      if (isIssueDate) {
        _issueDate = selected;
      } else {
        _expirationDate = selected;
      }
    });
  }

  void _clearInput() {
    _typeController.clear();
    _certificateIdController.clear();
    _standardController.clear();
    _agencyController.clear();
    _documentUrlController.clear();
    _remarksController.clear();
    setState(() {
      _issueDate = null;
      _expirationDate = null;
    });
  }

  void _addCertification() {
    final type = _typeController.text.trim();
    final agency = _agencyController.text.trim();
    if (type.isEmpty || agency.isEmpty) return;

    widget.onChanged([
      ...widget.certifications,
      CertificationInfo(
        certificationType: type,
        certificateId: _certificateIdController.text.trim().isEmpty
            ? null
            : _certificateIdController.text.trim(),
        certificationStandard: _standardController.text.trim().isEmpty
            ? null
            : _standardController.text.trim(),
        certificationAgency: agency,
        issueDate: _issueDate,
        expirationDate: _expirationDate,
        documentUrl: _documentUrlController.text.trim().isEmpty
            ? null
            : _documentUrlController.text.trim(),
        remarks: _remarksController.text.trim().isEmpty
            ? null
            : _remarksController.text.trim(),
      ),
    ]);
    _clearInput();
  }

  void _remove(int index) {
    final updated = List<CertificationInfo>.from(widget.certifications)
      ..removeAt(index);
    widget.onChanged(updated);
  }

  void _clearAll() => widget.onChanged([]);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return ObjectEventFormAddToListSection(
      margin: const EdgeInsets.only(top: 16.0),
      title: 'Certification Information',
      requiredFieldNames: ObjectEventFormMandatoryFields.certificationFields,
      listLabel: 'Certifications',
      itemCount: widget.certifications.length,
      isViewOnly: widget.isViewOnly,
      emptyMessage: widget.isViewOnly
          ? 'No certifications recorded.'
          : 'No certifications added yet. Fill in the fields above and press Add.',
      inputArea: Column(
        children: [
          TextField(
            controller: _typeController,
            decoration: InputDecoration(
              label: objectEventFormFieldLabel(
                context,
                'Certification Type',
                true,
              ),
              hintText: 'e.g., Organic, Fair Trade',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _certificateIdController,
            decoration: const InputDecoration(
              labelText: 'Certificate ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _standardController,
            decoration: InputDecoration(
              label: objectEventFormFieldLabel(
                context,
                'Certification Standard',
                false,
              ),
              hintText: 'e.g., ISO, GS1 (optional if type is set)',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _agencyController,
            decoration: InputDecoration(
              label: objectEventFormFieldLabel(
                context,
                'Certifying Agency',
                true,
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(isIssueDate: true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Issue Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _issueDate != null
                          ? dateFormat.format(_issueDate!)
                          : 'Select date',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(isIssueDate: false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Expiration Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _expirationDate != null
                          ? dateFormat.format(_expirationDate!)
                          : 'Select date',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _documentUrlController,
            decoration: const InputDecoration(
              labelText: 'Document URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _remarksController,
            decoration: const InputDecoration(
              labelText: 'Remarks',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      onAdd: _addCertification,
      onClearAll: _clearAll,
      items: List.generate(widget.certifications.length, (index) {
        final entry = widget.certifications[index];
        final subtitleParts = <String>[
          if (entry.certificationAgency != null) entry.certificationAgency!,
          if (entry.certificateId != null) 'ID: ${entry.certificateId}',
        ];
        return ObjectEventFormListItemData(
          title: entry.certificationType ?? 'Certification',
          subtitle: subtitleParts.isEmpty ? null : subtitleParts.join(' · '),
          onRemove: widget.isViewOnly ? null : () => _remove(index),
        );
      }),
    );
  }
}
