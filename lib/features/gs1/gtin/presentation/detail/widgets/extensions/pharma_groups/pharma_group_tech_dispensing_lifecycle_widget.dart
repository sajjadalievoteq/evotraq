import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/section_label.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

class TechDispensingLifecycleGroupWidget extends StatefulWidget {
  const TechDispensingLifecycleGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialPrescriptionStatus,
    required this.initialControlledSubstance,
    required this.initialControlledSubstanceSchedule,
    required this.initialAdditionalMonitoring,
    required this.initialShelfLifeMonths,
    required this.initialShelfLifeAfterOpenDays,
    required this.initialCountryOfManufacture,
    required this.initialPackSizeDescription,
    required this.initialActivePotencyAi7004,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final String initialPrescriptionStatus;
  final bool initialControlledSubstance;
  final String initialControlledSubstanceSchedule;
  final bool initialAdditionalMonitoring;
  final String initialShelfLifeMonths;
  final String initialShelfLifeAfterOpenDays;
  final String initialCountryOfManufacture;
  final String initialPackSizeDescription;
  final String initialActivePotencyAi7004;
  final bool showFieldSkeleton;
  final void Function({
    required String prescriptionStatus,
    required bool controlledSubstance,
    required String controlledSubstanceSchedule,
    required bool additionalMonitoring,
    required String shelfLifeMonths,
    required String shelfLifeAfterOpenDays,
    required String countryOfManufacture,
    required String packSizeDescription,
    required String activePotencyAi7004,
  }) onChanged;

  @override
  State<TechDispensingLifecycleGroupWidget> createState() =>
      _TechDispensingLifecycleGroupWidgetState();
}

class _TechDispensingLifecycleGroupWidgetState
    extends State<TechDispensingLifecycleGroupWidget> {
  late String _prescriptionStatus;
  late bool _controlledSubstance;
  late bool _additionalMonitoring;
  String? _controlledSubstanceSchedule;
  late final TextEditingController _shelfLifeMonthsController;
  late final TextEditingController _shelfLifeAfterOpenDaysController;
  late final TextEditingController _countryOfManufactureController;
  late final TextEditingController _packSizeDescriptionController;
  late final TextEditingController _activePotencyAi7004Controller;

  @override
  void initState() {
    super.initState();
    _prescriptionStatus = widget.initialPrescriptionStatus;
    _controlledSubstance = widget.initialControlledSubstance;
    _additionalMonitoring = widget.initialAdditionalMonitoring;
    _controlledSubstanceSchedule =
        widget.initialControlledSubstanceSchedule.trim().isEmpty
            ? null
            : widget.initialControlledSubstanceSchedule;
    _shelfLifeMonthsController =
        TextEditingController(text: widget.initialShelfLifeMonths);
    _shelfLifeAfterOpenDaysController =
        TextEditingController(text: widget.initialShelfLifeAfterOpenDays);
    _countryOfManufactureController =
        TextEditingController(text: widget.initialCountryOfManufacture);
    _packSizeDescriptionController =
        TextEditingController(text: widget.initialPackSizeDescription);
    _activePotencyAi7004Controller =
        TextEditingController(text: widget.initialActivePotencyAi7004);

    _shelfLifeMonthsController.addListener(_emitChange);
    _shelfLifeAfterOpenDaysController.addListener(_emitChange);
    _countryOfManufactureController.addListener(_emitChange);
    _packSizeDescriptionController.addListener(_emitChange);
    _activePotencyAi7004Controller.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant TechDispensingLifecycleGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prescriptionStatus = widget.initialPrescriptionStatus;
    _controlledSubstance = widget.initialControlledSubstance;
    _additionalMonitoring = widget.initialAdditionalMonitoring;
    _controlledSubstanceSchedule =
        widget.initialControlledSubstanceSchedule.trim().isEmpty
            ? null
            : widget.initialControlledSubstanceSchedule;
    if (widget.initialShelfLifeMonths != oldWidget.initialShelfLifeMonths &&
        widget.initialShelfLifeMonths != _shelfLifeMonthsController.text) {
      _shelfLifeMonthsController.text = widget.initialShelfLifeMonths;
    }
    if (widget.initialShelfLifeAfterOpenDays !=
            oldWidget.initialShelfLifeAfterOpenDays &&
        widget.initialShelfLifeAfterOpenDays !=
            _shelfLifeAfterOpenDaysController.text) {
      _shelfLifeAfterOpenDaysController.text = widget.initialShelfLifeAfterOpenDays;
    }
    if (widget.initialCountryOfManufacture != oldWidget.initialCountryOfManufacture &&
        widget.initialCountryOfManufacture != _countryOfManufactureController.text) {
      _countryOfManufactureController.text = widget.initialCountryOfManufacture;
    }
    if (widget.initialPackSizeDescription != oldWidget.initialPackSizeDescription &&
        widget.initialPackSizeDescription != _packSizeDescriptionController.text) {
      _packSizeDescriptionController.text = widget.initialPackSizeDescription;
    }
    if (widget.initialActivePotencyAi7004 != oldWidget.initialActivePotencyAi7004 &&
        widget.initialActivePotencyAi7004 != _activePotencyAi7004Controller.text) {
      _activePotencyAi7004Controller.text = widget.initialActivePotencyAi7004;
    }
  }

  @override
  void dispose() {
    _shelfLifeMonthsController.dispose();
    _shelfLifeAfterOpenDaysController.dispose();
    _countryOfManufactureController.dispose();
    _packSizeDescriptionController.dispose();
    _activePotencyAi7004Controller.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(
      prescriptionStatus: _prescriptionStatus,
      controlledSubstance: _controlledSubstance,
      controlledSubstanceSchedule: _controlledSubstanceSchedule ?? '',
      additionalMonitoring: _additionalMonitoring,
      shelfLifeMonths: _shelfLifeMonthsController.text,
      shelfLifeAfterOpenDays: _shelfLifeAfterOpenDaysController.text,
      countryOfManufacture: _countryOfManufactureController.text,
      packSizeDescription: _packSizeDescriptionController.text,
      activePotencyAi7004: _activePotencyAi7004Controller.text,
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
            'Technical specification — dispensing & lifecycle',
            padding: EdgeInsets.only(bottom: 12),
          ),
          DropdownButtonFormField<String>(
            initialValue: _prescriptionStatus,
            decoration: const InputDecoration(
              labelText: 'Prescription Status *',
              border: OutlineInputBorder(),
            ),
            items: PharmaFieldValidators.prescriptionStatusCodes
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: widget.isEditing
                ? (v) {
                    setState(() => _prescriptionStatus = v ?? 'RX');
                    _emitChange();
                  }
                : null,
            validator: widget.isEditing ? PharmaFieldValidators.validatePrescriptionStatus : null,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Controlled Substance Indicator'),
            value: _controlledSubstance,
            onChanged: widget.isEditing
                ? (v) {
                    setState(() => _controlledSubstance = v);
                    _emitChange();
                  }
                : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: _controlledSubstanceSchedule,
            decoration: const InputDecoration(
              labelText: 'Controlled Substance Schedule',
              helperText: 'Required when Controlled Substance Indicator = true',
              border: OutlineInputBorder(),
            ),
            items: PharmaFieldValidators.controlledSubstanceScheduleCodes
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: widget.isEditing && _controlledSubstance
                ? (v) {
                    setState(() => _controlledSubstanceSchedule = v);
                    _emitChange();
                  }
                : null,
            validator: (v) => PharmaFieldValidators.validateControlledSubstanceSchedule(
              v,
              controlled: _controlledSubstance,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Black Triangle / Additional Monitoring Indicator'),
            value: _additionalMonitoring,
            onChanged: widget.isEditing
                ? (v) {
                    setState(() => _additionalMonitoring = v);
                    _emitChange();
                  }
                : null,
          ),
          const SizedBox(height: 12),
          GtinValidatedField(
            controller: _shelfLifeMonthsController,
            fieldName: 'shelfLifeMonths',
            label: 'Shelf Life from Production (months) *',
            helperText: 'Numeric, 1–360',
            maxLength: 3,
            keyboardType: TextInputType.number,
            inputFormatters:  [LengthLimitingTextInputFormatter(3)],
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateShelfLifeMonths,
          ),
          GtinValidatedField(
            controller: _shelfLifeAfterOpenDaysController,
            fieldName: 'shelfLifeAfterOpeningDays',
            label: 'Shelf Life After Opening (days)',
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters:  [LengthLimitingTextInputFormatter(4)],
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateShelfLifeAfterOpenDays,
          ),
          GtinCountryCodePickerField(
            controller: _countryOfManufactureController,
            labelText: 'Country of Manufacture *',
            helperText: 'ISO 3166-1 numeric (3 digits)',
            enabled: widget.isEditing,
            validator: PharmaFieldValidators.validateCountryOfManufacture,
          ),
          GtinValidatedField(
            controller: _packSizeDescriptionController,
            fieldName: 'packSizeDescription',
            label: 'Pack Size Description (free text)',
            helperText: 'Up to 100 chars',
            maxLength: 100,
            inputFormatters:  [LengthLimitingTextInputFormatter(100)],
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validatePackSizeDescription,
          ),
          GtinValidatedField(
            controller: _activePotencyAi7004Controller,
            fieldName: 'activePotencyAi7004',
            label: 'Active potency (AI 7004 context)',
            helperText: 'Optional master-data potency note',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            maxLength: 20,
            inputFormatters:  [LengthLimitingTextInputFormatter(20)],
            readOnly: !widget.isEditing,
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
                'Technical specification — dispensing & lifecycle',
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
