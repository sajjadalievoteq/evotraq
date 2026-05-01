import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

class TechProductCodedGroupWidget extends StatefulWidget {
  const TechProductCodedGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialRegulatedProductName,
    required this.initialDosageFormTypeCode,
    required this.initialRouteOfAdministrationCode,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final String initialRegulatedProductName;
  final String initialDosageFormTypeCode;
  final String initialRouteOfAdministrationCode;
  final bool showFieldSkeleton;
  final void Function({
    required String regulatedProductName,
    required String dosageFormTypeCode,
    required String routeOfAdministrationCode,
  }) onChanged;

  @override
  State<TechProductCodedGroupWidget> createState() =>
      _TechProductCodedGroupWidgetState();
}

class _TechProductCodedGroupWidgetState extends State<TechProductCodedGroupWidget> {
  late final TextEditingController _regulatedProductNameController;
  late final TextEditingController _dosageFormTypeCodeController;
  late final TextEditingController _routeOfAdministrationCodeController;

  @override
  void initState() {
    super.initState();
    _regulatedProductNameController =
        TextEditingController(text: widget.initialRegulatedProductName);
    _dosageFormTypeCodeController =
        TextEditingController(text: widget.initialDosageFormTypeCode);
    _routeOfAdministrationCodeController =
        TextEditingController(text: widget.initialRouteOfAdministrationCode);
    _regulatedProductNameController.addListener(_emitChange);
    _dosageFormTypeCodeController.addListener(_emitChange);
    _routeOfAdministrationCodeController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant TechProductCodedGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRegulatedProductName != oldWidget.initialRegulatedProductName &&
        widget.initialRegulatedProductName != _regulatedProductNameController.text) {
      _regulatedProductNameController.text = widget.initialRegulatedProductName;
    }
    if (widget.initialDosageFormTypeCode != oldWidget.initialDosageFormTypeCode &&
        widget.initialDosageFormTypeCode != _dosageFormTypeCodeController.text) {
      _dosageFormTypeCodeController.text = widget.initialDosageFormTypeCode;
    }
    if (widget.initialRouteOfAdministrationCode != oldWidget.initialRouteOfAdministrationCode &&
        widget.initialRouteOfAdministrationCode != _routeOfAdministrationCodeController.text) {
      _routeOfAdministrationCodeController.text = widget.initialRouteOfAdministrationCode;
    }
  }

  @override
  void dispose() {
    _regulatedProductNameController.dispose();
    _dosageFormTypeCodeController.dispose();
    _routeOfAdministrationCodeController.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(
      regulatedProductName: _regulatedProductNameController.text,
      dosageFormTypeCode: _dosageFormTypeCodeController.text,
      routeOfAdministrationCode: _routeOfAdministrationCodeController.text,
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
            'Technical specification — product & coded attributes',
            padding: EdgeInsets.only(bottom: 12),
          ),
          Text(
            'Persisted with the pharmaceutical extension (same JSON keys). GS1 Section 5-aligned coded attributes.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          GtinValidatedField(
            controller: _regulatedProductNameController,
            fieldName: 'regulatedProductName',
            label: 'Regulated Product Name (Generic / INN) *',
            maxLength: 200,
            inputFormatters:  [LengthLimitingTextInputFormatter(200)],
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateRegulatedProductName,
          ),
          GtinValidatedField(
            controller: _dosageFormTypeCodeController,
            fieldName: 'dosageFormTypeCode',
            label: 'Dosage Form Type Code *',
            helperText: 'EDQM Standard Terms code (up to 30 chars)',
            maxLength: 30,
            inputFormatters:  [LengthLimitingTextInputFormatter(30)],
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateDosageFormTypeCode,
          ),
          GtinValidatedField(
            controller: _routeOfAdministrationCodeController,
            fieldName: 'routeOfAdministrationEdqmCode',
            label: 'Route of Administration Code *',
            helperText: 'EDQM Standard Terms code (up to 30 chars)',
            maxLength: 30,
            inputFormatters:  [LengthLimitingTextInputFormatter(30)],
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateRouteOfAdministrationCode,
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
                'Technical specification — product & coded attributes',
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
