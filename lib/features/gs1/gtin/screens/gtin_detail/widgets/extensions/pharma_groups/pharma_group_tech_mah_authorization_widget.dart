import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/services/gln_picker_catalog.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/pharmaceutical/utils/pharma_field_validators.dart';
import 'package:traqtrace_app/core/widgets/gln_selector.dart';

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
  })
  onChanged;

  @override
  State<TechMahAuthorizationGroupWidget> createState() =>
      _TechMahAuthorizationGroupWidgetState();
}

class _TechMahAuthorizationGroupWidgetState
    extends State<TechMahAuthorizationGroupWidget> {
  static final _docDateFmt = DateFormat('yyyy-MM-dd');

  GLN? _mahGln;
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
    _mahGln = _glnFromCode(widget.initialMahGln);
    _mahNameController = TextEditingController(text: widget.initialMahName);
    _mahCountryController = TextEditingController(
      text: widget.initialMahCountry,
    );
    _licensedAgentGlnsController = TextEditingController(
      text: widget.initialLicensedAgentGlns,
    );
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

    _mahNameController.addListener(_emitChange);
    _mahCountryController.addListener(_emitChange);
    _licensedAgentGlnsController.addListener(_emitChange);
    _maNumberController.addListener(_emitChange);
    if (widget.initialMahGln.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resolveMahGlnFromCatalog();
      });
    }
  }

  Future<void> _resolveMahGlnFromCatalog() async {
    if (_mahGln == null) return;
    try {
      final catalog =
          await getIt<GlnPickerCatalog>().ensureLoaded();
      if (!mounted) return;
      final resolved = resolveGlnForPicker(
        code: _mahGln!.glnCode,
        fallback: _mahGln,
        catalog: catalog,
      );
      if (resolved != null && resolved.glnCode == _mahGln!.glnCode) {
        setState(() => _mahGln = resolved);
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant TechMahAuthorizationGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMahGln == oldWidget.initialMahGln &&
        widget.initialMahName == oldWidget.initialMahName &&
        widget.initialMahCountry == oldWidget.initialMahCountry &&
        widget.initialLicensedAgentGlns == oldWidget.initialLicensedAgentGlns &&
        widget.initialMaNumber == oldWidget.initialMaNumber &&
        widget.initialMaValidFrom == oldWidget.initialMaValidFrom &&
        widget.initialMaValidTo == oldWidget.initialMaValidTo &&
        widget.initialRegulatoryStatus == oldWidget.initialRegulatoryStatus) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.initialMahGln != oldWidget.initialMahGln) {
        _mahGln = _glnFromCode(widget.initialMahGln);
        if (widget.initialMahGln.trim().isNotEmpty) {
          _resolveMahGlnFromCatalog();
        }
      }
      if (widget.initialMahName != oldWidget.initialMahName &&
          widget.initialMahName != _mahNameController.text) {
        _mahNameController.text = widget.initialMahName;
      }
      if (widget.initialMahCountry != oldWidget.initialMahCountry &&
          widget.initialMahCountry != _mahCountryController.text) {
        _mahCountryController.text = widget.initialMahCountry;
      }
      if (widget.initialLicensedAgentGlns !=
              oldWidget.initialLicensedAgentGlns &&
          widget.initialLicensedAgentGlns !=
              _licensedAgentGlnsController.text) {
        _licensedAgentGlnsController.text = widget.initialLicensedAgentGlns;
      }
      if (widget.initialMaNumber != oldWidget.initialMaNumber &&
          widget.initialMaNumber != _maNumberController.text) {
        _maNumberController.text = widget.initialMaNumber;
      }
      setState(() {
        _regulatoryStatus = widget.initialRegulatoryStatus.trim().isEmpty
            ? null
            : widget.initialRegulatoryStatus;
        _maValidFrom = widget.initialMaValidFrom;
        _maValidTo = widget.initialMaValidTo;
      });
      _maValidFromDisplay.text = _maValidFrom != null
          ? _docDateFmt.format(_maValidFrom!)
          : '';
      _maValidToDisplay.text = _maValidTo != null
          ? _docDateFmt.format(_maValidTo!)
          : '';
    });
  }

  @override
  void dispose() {
    _mahNameController.dispose();
    _mahCountryController.dispose();
    _licensedAgentGlnsController.dispose();
    _maNumberController.dispose();
    _maValidFromDisplay.dispose();
    _maValidToDisplay.dispose();
    super.dispose();
  }

  GLN? _glnFromCode(String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return null;
    return GLN.fromCode(trimmed);
  }

  void _onMahGlnChanged(GLN? gln) {
    setState(() {
      _mahGln = gln;
      if (gln != null && _mahNameController.text.trim().isEmpty) {
        _mahNameController.text = gln.locationName;
      }
    });
    _emitChange();
  }

  void _emitChange() {
    widget.onChanged(
      mahGln: _mahGln?.glnCode ?? '',
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
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isEditing)
            SgtinInfoRow(
              'Marketing Authorization Holder (MAH) GLN',
              _mahGln != null
                  ? '${_mahGln!.glnCode} â ${_mahGln!.locationName}'
                  : (widget.initialMahGln.trim().isEmpty
                      ? null
                      : widget.initialMahGln),
            )
          else
            GLNSelector(
              label: 'Marketing Authorization Holder (MAH) GLN',
              hintText: 'Search and select MAH location',
              initialValue: _mahGln,
              isRequired: true,
              onChanged: _onMahGlnChanged,
            ),
          const SizedBox(height: 12),
          Gs1ValidatedField(
            controller: _mahNameController,
            fieldName: 'mahName',
            label: 'MAH Name *',
            maxLength: 200,
            inputFormatters: [LengthLimitingTextInputFormatter(200)],
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
          Gs1ValidatedField(
            controller: _licensedAgentGlnsController,
            fieldName: 'licensedAgentGlns',
            label: 'Licensed Agent GLNs',
            helperText:
                'Comma, semicolon, or newline separated (13-digit GLNs)',
            maxLines: 3,
            maxLength: 500,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            readOnly: !widget.isEditing,
            validator: PharmaFieldValidators.validateLicensedAgentGlns,
          ),
          Gs1ValidatedField(
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

    return Gs1GroupCard(
      title: 'Technical specification of MAH & authorization',
      outlineColor: outline,
      showFieldSkeleton: widget.showFieldSkeleton,
      skeletonFieldCount: 2,
      child: content,
    );
  }
}
