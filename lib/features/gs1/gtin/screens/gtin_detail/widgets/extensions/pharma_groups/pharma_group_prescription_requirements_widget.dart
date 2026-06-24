import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
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
  })
  onChanged;

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
    _prescriptionTypeController = TextEditingController(
      text: widget.initialPrescriptionType,
    );
    _prescriptionTypeController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(
    covariant PrescriptionRequirementsGroupWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRequiresPrescription ==
            oldWidget.initialRequiresPrescription &&
        widget.initialPrescriptionType == oldWidget.initialPrescriptionType) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _requiresPrescription = widget.initialRequiresPrescription;
      });
      if (widget.initialPrescriptionType != oldWidget.initialPrescriptionType &&
          widget.initialPrescriptionType != _prescriptionTypeController.text) {
        _prescriptionTypeController.text = widget.initialPrescriptionType;
      }
    });
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
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              child: Gs1ValidatedField(
                controller: _prescriptionTypeController,
                fieldName: 'prescriptionType',
                label: 'Prescription Type',
                helperText: 'e.g., Standard, Special, Controlled',
                maxLength: 50,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                readOnly: !widget.isEditing,
                validator: PharmaFieldValidators.validatePrescriptionType,
              ),
            ),
        ],
      ),
    );

    return Gs1GroupCard(
      title: 'Prescription requirements',
      outlineColor: outline,
      showFieldSkeleton: widget.showFieldSkeleton,
      skeletonFieldCount: 2,
      child: content,
    );
  }
}
