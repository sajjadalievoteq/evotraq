import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

class RegulatoryApprovalsGroupWidget extends StatefulWidget {
  const RegulatoryApprovalsGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialFdaApplicationNumber,
    required this.initialFdaApprovalDate,
    required this.initialEmaProcedureNumber,
    required this.initialEmaApprovalDate,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final String initialFdaApplicationNumber;
  final DateTime? initialFdaApprovalDate;
  final String initialEmaProcedureNumber;
  final DateTime? initialEmaApprovalDate;
  final bool showFieldSkeleton;
  final void Function({
    required String fdaApplicationNumber,
    required DateTime? fdaApprovalDate,
    required String emaProcedureNumber,
    required DateTime? emaApprovalDate,
  }) onChanged;

  @override
  State<RegulatoryApprovalsGroupWidget> createState() =>
      _RegulatoryApprovalsGroupWidgetState();
}

class _RegulatoryApprovalsGroupWidgetState
    extends State<RegulatoryApprovalsGroupWidget> {
  static final _docDateFmt = DateFormat('yyyy-MM-dd');

  late final TextEditingController _fdaApplicationNumberController;
  late final TextEditingController _emaProcedureNumberController;
  late final TextEditingController _fdaApprovalDateDisplay;
  late final TextEditingController _emaApprovalDateDisplay;
  DateTime? _fdaApprovalDate;
  DateTime? _emaApprovalDate;

  @override
  void initState() {
    super.initState();
    _fdaApplicationNumberController =
        TextEditingController(text: widget.initialFdaApplicationNumber);
    _emaProcedureNumberController =
        TextEditingController(text: widget.initialEmaProcedureNumber);
    _fdaApprovalDate = widget.initialFdaApprovalDate;
    _emaApprovalDate = widget.initialEmaApprovalDate;
    _fdaApprovalDateDisplay = TextEditingController(
      text: _fdaApprovalDate != null ? _docDateFmt.format(_fdaApprovalDate!) : '',
    );
    _emaApprovalDateDisplay = TextEditingController(
      text: _emaApprovalDate != null ? _docDateFmt.format(_emaApprovalDate!) : '',
    );

    _fdaApplicationNumberController.addListener(_emitChange);
    _emaProcedureNumberController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant RegulatoryApprovalsGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFdaApplicationNumber == oldWidget.initialFdaApplicationNumber &&
        widget.initialEmaProcedureNumber == oldWidget.initialEmaProcedureNumber &&
        widget.initialFdaApprovalDate == oldWidget.initialFdaApprovalDate &&
        widget.initialEmaApprovalDate == oldWidget.initialEmaApprovalDate) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.initialFdaApplicationNumber != oldWidget.initialFdaApplicationNumber &&
          widget.initialFdaApplicationNumber != _fdaApplicationNumberController.text) {
        _fdaApplicationNumberController.text = widget.initialFdaApplicationNumber;
      }
      if (widget.initialEmaProcedureNumber != oldWidget.initialEmaProcedureNumber &&
          widget.initialEmaProcedureNumber != _emaProcedureNumberController.text) {
        _emaProcedureNumberController.text = widget.initialEmaProcedureNumber;
      }
      _fdaApprovalDate = widget.initialFdaApprovalDate;
      _emaApprovalDate = widget.initialEmaApprovalDate;
      _fdaApprovalDateDisplay.text =
          _fdaApprovalDate != null ? _docDateFmt.format(_fdaApprovalDate!) : '';
      _emaApprovalDateDisplay.text =
          _emaApprovalDate != null ? _docDateFmt.format(_emaApprovalDate!) : '';
    });
  }

  @override
  void dispose() {
    _fdaApplicationNumberController.dispose();
    _emaProcedureNumberController.dispose();
    _fdaApprovalDateDisplay.dispose();
    _emaApprovalDateDisplay.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(
      fdaApplicationNumber: _fdaApplicationNumberController.text,
      fdaApprovalDate: _fdaApprovalDate,
      emaProcedureNumber: _emaProcedureNumberController.text,
      emaApprovalDate: _emaApprovalDate,
    );
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime?> setValue,
    required TextEditingController display,
  }) async {
    final initial = current ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (!mounted || picked == null) return;
    setState(() {
      setValue(picked);
      display.text = _docDateFmt.format(picked);
    });
    _emitChange();
  }

  Widget _dateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(
            'Regulatory approvals (FDA / EMA)',
            padding: EdgeInsets.only(bottom: 12),
          ),
          GtinValidatedField(
            controller: _fdaApplicationNumberController,
            fieldName: 'fdaApplicationNumber',
            label: 'FDA Application Number',
            maxLength: 50,
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateFdaApplicationNumber,
          ),
          _dateField(
            label: 'FDA Approval Date',
            controller: _fdaApprovalDateDisplay,
            onTap: widget.isEditing
                ? () => _pickDate(
                      current: _fdaApprovalDate,
                      setValue: (v) => _fdaApprovalDate = v,
                      display: _fdaApprovalDateDisplay,
                    )
                : null,
          ),
          const SizedBox(height: 8),
          GtinValidatedField(
            controller: _emaProcedureNumberController,
            fieldName: 'emaProcedureNumber',
            label: 'EMA Procedure Number',
            maxLength: 50,
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateEmaProcedureNumber,
          ),
          _dateField(
            label: 'EMA Approval Date',
            controller: _emaApprovalDateDisplay,
            onTap: widget.isEditing
                ? () => _pickDate(
                      current: _emaApprovalDate,
                      setValue: (v) => _emaApprovalDate = v,
                      display: _emaApprovalDateDisplay,
                    )
                : null,
          ),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: outline.withOpacity(0.45)),
      ),
      child: GtinFieldSkeletonMask(
        show: widget.showFieldSkeleton,
        child: content,
        skeletonBuilder: (c) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionLabel(
                'Regulatory approvals (FDA / EMA)',
                padding: EdgeInsets.only(bottom: 12),
              ),
              GtinSkeletonOutlineField(color: c, height: 56),
              const SizedBox(height: 8),
              GtinSkeletonOutlineField(color: c, height: 56),
            ],
          ),
        ),
      ),
    );
  }
}
