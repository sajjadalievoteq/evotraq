import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

class DrugClassificationGroupWidget extends StatefulWidget {
  const DrugClassificationGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialDrugClass,
    required this.initialTherapeuticClass,
    required this.initialPharmacologicalClass,
    required this.initialAtcCode,
    required this.initialAdditionalAtcCodes,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final String initialDrugClass;
  final String initialTherapeuticClass;
  final String initialPharmacologicalClass;
  final String initialAtcCode;
  final String initialAdditionalAtcCodes;
  final bool showFieldSkeleton;
  final void Function({
    required String drugClass,
    required String therapeuticClass,
    required String pharmacologicalClass,
    required String atcCode,
    required String additionalAtcCodes,
  }) onChanged;

  @override
  State<DrugClassificationGroupWidget> createState() =>
      _DrugClassificationGroupWidgetState();
}

class _DrugClassificationGroupWidgetState
    extends State<DrugClassificationGroupWidget> {
  late final TextEditingController _drugClassController;
  late final TextEditingController _therapeuticClassController;
  late final TextEditingController _pharmacologicalClassController;
  late final TextEditingController _atcCodeController;
  late final TextEditingController _additionalAtcCodesController;

  @override
  void initState() {
    super.initState();
    _drugClassController = TextEditingController(text: widget.initialDrugClass);
    _therapeuticClassController =
        TextEditingController(text: widget.initialTherapeuticClass);
    _pharmacologicalClassController =
        TextEditingController(text: widget.initialPharmacologicalClass);
    _atcCodeController = TextEditingController(text: widget.initialAtcCode);
    _additionalAtcCodesController =
        TextEditingController(text: widget.initialAdditionalAtcCodes);

    _drugClassController.addListener(_emitChange);
    _therapeuticClassController.addListener(_emitChange);
    _pharmacologicalClassController.addListener(_emitChange);
    _atcCodeController.addListener(_emitChange);
    _additionalAtcCodesController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant DrugClassificationGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDrugClass == oldWidget.initialDrugClass &&
        widget.initialTherapeuticClass == oldWidget.initialTherapeuticClass &&
        widget.initialPharmacologicalClass == oldWidget.initialPharmacologicalClass &&
        widget.initialAtcCode == oldWidget.initialAtcCode &&
        widget.initialAdditionalAtcCodes == oldWidget.initialAdditionalAtcCodes) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.initialDrugClass != oldWidget.initialDrugClass &&
          widget.initialDrugClass != _drugClassController.text) {
        _drugClassController.text = widget.initialDrugClass;
      }
      if (widget.initialTherapeuticClass != oldWidget.initialTherapeuticClass &&
          widget.initialTherapeuticClass != _therapeuticClassController.text) {
        _therapeuticClassController.text = widget.initialTherapeuticClass;
      }
      if (widget.initialPharmacologicalClass != oldWidget.initialPharmacologicalClass &&
          widget.initialPharmacologicalClass != _pharmacologicalClassController.text) {
        _pharmacologicalClassController.text = widget.initialPharmacologicalClass;
      }
      if (widget.initialAtcCode != oldWidget.initialAtcCode &&
          widget.initialAtcCode != _atcCodeController.text) {
        _atcCodeController.text = widget.initialAtcCode;
      }
      if (widget.initialAdditionalAtcCodes != oldWidget.initialAdditionalAtcCodes &&
          widget.initialAdditionalAtcCodes != _additionalAtcCodesController.text) {
        _additionalAtcCodesController.text = widget.initialAdditionalAtcCodes;
      }
    });
  }

  @override
  void dispose() {
    _drugClassController.dispose();
    _therapeuticClassController.dispose();
    _pharmacologicalClassController.dispose();
    _atcCodeController.dispose();
    _additionalAtcCodesController.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(
      drugClass: _drugClassController.text,
      therapeuticClass: _therapeuticClassController.text,
      pharmacologicalClass: _pharmacologicalClassController.text,
      atcCode: _atcCodeController.text,
      additionalAtcCodes: _additionalAtcCodesController.text,
    );
  }

  Widget _buildValidatedField(
    TextEditingController controller,
    String fieldName,
    String label, {
    String? helperText,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GtinValidatedField(
        controller: controller,
        fieldName: fieldName,
        label: label,
        helperText: helperText,
        maxLength: maxLength,
        inputFormatters: maxLength != null
            ? [LengthLimitingTextInputFormatter(maxLength)]
            : null,
        readOnly: !widget.isEditing,
        validator: validator,
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
            'Drug classification',
            padding: EdgeInsets.only(bottom: 12),
          ),
          _buildValidatedField(
            _drugClassController,
            'drugClass',
            'Drug Class',
            helperText: 'e.g., Antibiotic, Analgesic',
            maxLength: 100,
            validator: PharmaFieldValidators.validateDrugClass,
          ),
          _buildValidatedField(
            _therapeuticClassController,
            'therapeuticClass',
            'Therapeutic Class',
            maxLength: 100,
            validator: PharmaFieldValidators.validateTherapeuticClass,
          ),
          _buildValidatedField(
            _pharmacologicalClassController,
            'pharmacologicalClass',
            'Pharmacological Class',
            maxLength: 100,
            validator: PharmaFieldValidators.validatePharmacologicalClass,
          ),
          _buildValidatedField(
            _atcCodeController,
            'atcCode',
            'ATC Code',
            helperText: 'Anatomical Therapeutic Chemical code',
            maxLength: 10,
            validator: PharmaFieldValidators.validateAtcCode,
          ),
          _buildValidatedField(
            _additionalAtcCodesController,
            'additionalAtcCodes',
            'Additional ATC Codes',
            helperText: 'Comma-separated WHO ATC codes (beyond primary ATC)',
            maxLength: 200,
            validator: PharmaFieldValidators.validateAdditionalAtcCodes,
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
                'Drug classification',
                padding: EdgeInsets.only(bottom: 12),
              ),
              GtinSkeletonOutlineField(color: c, height: 56),
              const SizedBox(height: 8),
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
