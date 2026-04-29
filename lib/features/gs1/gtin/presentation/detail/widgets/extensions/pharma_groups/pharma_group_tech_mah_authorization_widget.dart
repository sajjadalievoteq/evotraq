import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/section_label.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';

class TechMahAuthorizationGroupWidget extends StatefulWidget {
  const TechMahAuthorizationGroupWidget({
    super.key,
    required this.isEditing,
    required this.initialMahGln,
    required this.initialMahName,
    required this.initialMahCountry,
    required this.initialLicensedAgentGlns,
    required this.initialMaNumber,
    required this.initialMaValidFrom,
    required this.initialMaValidTo,
    required this.initialRegulatoryStatus,
    required this.onChanged,
    this.showFieldSkeleton = false,
  });

  final bool isEditing;
  final String initialMahGln;
  final String initialMahName;
  final String initialMahCountry;
  final String initialLicensedAgentGlns;
  final String initialMaNumber;
  final DateTime? initialMaValidFrom;
  final DateTime? initialMaValidTo;
  final String initialRegulatoryStatus;
  final bool showFieldSkeleton;
  final void Function({
    required String mahGln,
    required String mahName,
    required String mahCountry,
    required String licensedAgentGlns,
    required String maNumber,
    required DateTime? maValidFrom,
    required DateTime? maValidTo,
    required String regulatoryStatus,
  }) onChanged;

  @override
  State<TechMahAuthorizationGroupWidget> createState() =>
      _TechMahAuthorizationGroupWidgetState();
}

class _TechMahAuthorizationGroupWidgetState
    extends State<TechMahAuthorizationGroupWidget> {
  static final _docDateFmt = DateFormat('yyyy-MM-dd');

  late final TextEditingController _mahGlnController;
  late final TextEditingController _mahNameController;
  late final TextEditingController _mahCountryController;
  late final TextEditingController _licensedAgentGlnsController;
  late final TextEditingController _maNumberController;
  late final TextEditingController _maValidFromDisplay;
  late final TextEditingController _maValidToDisplay;
  String? _regulatoryStatus;
  DateTime? _maValidFrom;
  DateTime? _maValidTo;

  @override
  void initState() {
    super.initState();
    _mahGlnController = TextEditingController(text: widget.initialMahGln);
    _mahNameController = TextEditingController(text: widget.initialMahName);
    _mahCountryController = TextEditingController(text: widget.initialMahCountry);
    _licensedAgentGlnsController =
        TextEditingController(text: widget.initialLicensedAgentGlns);
    _maNumberController = TextEditingController(text: widget.initialMaNumber);
    _regulatoryStatus = widget.initialRegulatoryStatus.trim().isEmpty
        ? null
        : widget.initialRegulatoryStatus;
    _maValidFrom = widget.initialMaValidFrom;
    _maValidTo = widget.initialMaValidTo;
    _maValidFromDisplay = TextEditingController(
      text: _maValidFrom != null ? _docDateFmt.format(_maValidFrom!) : '',
    );
    _maValidToDisplay = TextEditingController(
      text: _maValidTo != null ? _docDateFmt.format(_maValidTo!) : '',
    );

    _mahGlnController.addListener(_emitChange);
    _mahNameController.addListener(_emitChange);
    _mahCountryController.addListener(_emitChange);
    _licensedAgentGlnsController.addListener(_emitChange);
    _maNumberController.addListener(_emitChange);
  }

  @override
  void didUpdateWidget(covariant TechMahAuthorizationGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMahGln != oldWidget.initialMahGln &&
        widget.initialMahGln != _mahGlnController.text) {
      _mahGlnController.text = widget.initialMahGln;
    }
    if (widget.initialMahName != oldWidget.initialMahName &&
        widget.initialMahName != _mahNameController.text) {
      _mahNameController.text = widget.initialMahName;
    }
    if (widget.initialMahCountry != oldWidget.initialMahCountry &&
        widget.initialMahCountry != _mahCountryController.text) {
      _mahCountryController.text = widget.initialMahCountry;
    }
    if (widget.initialLicensedAgentGlns != oldWidget.initialLicensedAgentGlns &&
        widget.initialLicensedAgentGlns != _licensedAgentGlnsController.text) {
      _licensedAgentGlnsController.text = widget.initialLicensedAgentGlns;
    }
    if (widget.initialMaNumber != oldWidget.initialMaNumber &&
        widget.initialMaNumber != _maNumberController.text) {
      _maNumberController.text = widget.initialMaNumber;
    }
    _regulatoryStatus = widget.initialRegulatoryStatus.trim().isEmpty
        ? null
        : widget.initialRegulatoryStatus;
    _maValidFrom = widget.initialMaValidFrom;
    _maValidTo = widget.initialMaValidTo;
    _maValidFromDisplay.text =
        _maValidFrom != null ? _docDateFmt.format(_maValidFrom!) : '';
    _maValidToDisplay.text = _maValidTo != null ? _docDateFmt.format(_maValidTo!) : '';
  }

  @override
  void dispose() {
    _mahGlnController.dispose();
    _mahNameController.dispose();
    _mahCountryController.dispose();
    _licensedAgentGlnsController.dispose();
    _maNumberController.dispose();
    _maValidFromDisplay.dispose();
    _maValidToDisplay.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(
      mahGln: _mahGlnController.text,
      mahName: _mahNameController.text,
      mahCountry: _mahCountryController.text,
      licensedAgentGlns: _licensedAgentGlnsController.text,
      maNumber: _maNumberController.text,
      maValidFrom: _maValidFrom,
      maValidTo: _maValidTo,
      regulatoryStatus: _regulatoryStatus ?? '',
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

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(
            'Technical specification — MAH & authorization',
            padding: EdgeInsets.only(bottom: 12),
          ),
          GtinValidatedField(
            controller: _mahGlnController,
            fieldName: 'mahGln',
            label: 'Marketing Authorization Holder (MAH) GLN *',
            helperText: '13 digits; Mod-10 check digit',
            maxLength: 13,
            keyboardType: TextInputType.number,
            inputFormatters:  [LengthLimitingTextInputFormatter(13)],
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateMahGln,
          ),
          GtinValidatedField(
            controller: _mahNameController,
            fieldName: 'mahName',
            label: 'MAH Name *',
            maxLength: 200,
            inputFormatters:  [LengthLimitingTextInputFormatter(200)],
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateMahName,
          ),
          GtinCountryCodePickerField(
            controller: _mahCountryController,
            labelText: 'MAH Country *',
            helperText: 'ISO 3166-1 numeric (3 digits)',
            enabled: widget.isEditing,
            validator: PharmaFieldValidators.validateMahCountry,
          ),
          GtinValidatedField(
            controller: _licensedAgentGlnsController,
            fieldName: 'licensedAgentGlns',
            label: 'Licensed Agent GLNs',
            helperText: 'Comma, semicolon, or newline separated (13-digit GLNs)',
            maxLines: 3,
            maxLength: 500,
            inputFormatters:  [LengthLimitingTextInputFormatter(500)],
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateLicensedAgentGlns,
          ),
          GtinValidatedField(
            controller: _maNumberController,
            fieldName: 'marketingAuthorizationNumber',
            label: 'Marketing Authorization Number',
            maxLength: 50,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateMaNumber,
          ),
          GestureDetector(
            onTap: widget.isEditing
                ? () => _pickDate(
                      current: _maValidFrom,
                      setValue: (v) => _maValidFrom = v,
                      display: _maValidFromDisplay,
                    )
                : null,
            child: AbsorbPointer(
              child: TextFormField(
                controller: _maValidFromDisplay,
                decoration: const InputDecoration(
                  labelText: 'Marketing Authorization Validity From Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: widget.isEditing
                ? () => _pickDate(
                      current: _maValidTo,
                      setValue: (v) => _maValidTo = v,
                      display: _maValidToDisplay,
                    )
                : null,
            child: AbsorbPointer(
              child: TextFormField(
                controller: _maValidToDisplay,
                decoration: const InputDecoration(
                  labelText: 'Marketing Authorization Validity To Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                validator: (_) {
                  if (_maValidFrom != null &&
                      _maValidTo != null &&
                      _maValidTo!.isBefore(_maValidFrom!)) {
                    return 'ma_valid_to must be >= ma_valid_from';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _regulatoryStatus,
            decoration: const InputDecoration(
              labelText: 'Regulatory Status *',
              border: OutlineInputBorder(),
            ),
            items: PharmaFieldValidators.regulatoryStatusCodes
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: widget.isEditing
                ? (v) {
                    setState(() => _regulatoryStatus = v);
                    _emitChange();
                  }
                : null,
            validator: PharmaFieldValidators.validateRegulatoryStatus,
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
                'Technical specification — MAH & authorization',
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
