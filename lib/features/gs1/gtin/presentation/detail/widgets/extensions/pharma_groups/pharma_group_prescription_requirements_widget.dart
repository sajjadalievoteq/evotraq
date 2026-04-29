import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/section_label.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

class PrescriptionRequirementsGroupWidget extends StatefulWidget {
  const PrescriptionRequirementsGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialRequiresPrescription,
    required this.initialPrescriptionType,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final bool initialRequiresPrescription;
  final String initialPrescriptionType;
  final bool showFieldSkeleton;
  final void Function({
    required bool requiresPrescription,
    required String prescriptionType,
  }) onChanged;

  @override
  State<PrescriptionRequirementsGroupWidget> createState() =>
      _PrescriptionRequirementsGroupWidgetState();
}

class _PrescriptionRequirementsGroupWidgetState
    extends State<PrescriptionRequirementsGroupWidget> {
  late bool _requiresPrescription;
  late final TextEditingController _prescriptionTypeController;

  @override
  void initState() {
    super.initState();
    _requiresPrescription = widget.initialRequiresPrescription;
    _prescriptionTypeController =
        TextEditingController(text: widget.initialPrescriptionType);
    _prescriptionTypeController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant PrescriptionRequirementsGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _requiresPrescription = widget.initialRequiresPrescription;
    if (widget.initialPrescriptionType != oldWidget.initialPrescriptionType &&
        widget.initialPrescriptionType != _prescriptionTypeController.text) {
      _prescriptionTypeController.text = widget.initialPrescriptionType;
    }
  }

  @override
  void dispose() {
    _prescriptionTypeController.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(
      requiresPrescription: _requiresPrescription,
      prescriptionType: _prescriptionTypeController.text,
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
            'Prescription requirements',
            padding: EdgeInsets.only(bottom: 12),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Requires Prescription'),
            value: _requiresPrescription,
            onChanged: widget.isEditing
                ? (value) {
                    setState(() => _requiresPrescription = value);
                    _emitChange();
                  }
                : null,
          ),
          if (_requiresPrescription)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GtinValidatedField(
                controller: _prescriptionTypeController,
                fieldName: 'prescriptionType',
                label: 'Prescription Type',
                helperText: 'e.g., Standard, Special, Controlled',
                maxLength: 50,
                inputFormatters:  [LengthLimitingTextInputFormatter(50)],
                readOnly: !widget.isEditing,
                validator: PharmaFieldValidators.validatePrescriptionType,
              ),
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
                'Prescription requirements',
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
