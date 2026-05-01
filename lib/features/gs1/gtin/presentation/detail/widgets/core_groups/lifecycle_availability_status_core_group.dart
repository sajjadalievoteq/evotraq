import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_date_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class LifecycleAvailabilityStatusCoreGroup extends StatefulWidget {
  const LifecycleAvailabilityStatusCoreGroup({
    super.key,
    required this.isReadOnly,
    required this.isUpdate,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final bool isUpdate;
  final bool showFieldSkeleton;

  @override
  State<LifecycleAvailabilityStatusCoreGroup> createState() =>
      LifecycleAvailabilityStatusCoreGroupState();
}

class LifecycleAvailabilityStatusCoreGroupState
    extends State<LifecycleAvailabilityStatusCoreGroup> {
  static final _dateFmt = DateFormat('yyyy-MM-dd');
  static final _dateTimeNoOffsetFmt = DateFormat('yyyy-MM-dd / HH:mm:ss');

  String? _tradeItemStatus; // ADD / CHN / COR
  DateTime? _effectiveDate;
  DateTime? _startAvailDate;
  DateTime? _endAvailDate;
  DateTime? _publicationDate;

  late final TextEditingController _effectiveDateDisplay;
  late final TextEditingController _startAvailDateDisplay;
  late final TextEditingController _endAvailDateDisplay;
  late final TextEditingController _publicationDateDisplay;

  @override
  void initState() {
    super.initState();
    _effectiveDateDisplay = TextEditingController();
    _startAvailDateDisplay = TextEditingController();
    _endAvailDateDisplay = TextEditingController();
    _publicationDateDisplay = TextEditingController();

    // Doc: Auto-set ADD on first save, CHN on subsequent edits.
    _tradeItemStatus = widget.isUpdate ? 'CHN' : 'ADD';

    // Doc: Effective Date / Time is mandatory (version effective instant).
    // Default to "now" for new records and local-only UI.
    _effectiveDate = DateTime.now();
    _effectiveDateDisplay.text = _formatDateTimeWithOffset(_effectiveDate!);
  }

  @override
  void dispose() {
    _effectiveDateDisplay.dispose();
    _startAvailDateDisplay.dispose();
    _endAvailDateDisplay.dispose();
    _publicationDateDisplay.dispose();
    super.dispose();
  }

  String? get tradeItemStatus => _tradeItemStatus;
  DateTime? get effectiveDate => _effectiveDate;
  DateTime? get startAvailDate => _startAvailDate;
  DateTime? get endAvailDate => _endAvailDate;
  DateTime? get publicationDate => _publicationDate;

  void setFromGtin({
    required String? tradeItemStatus,
    required DateTime? effectiveDate,
    required DateTime? startAvailDate,
    required DateTime? endAvailDate,
    required DateTime? publicationDate,
  }) {
    _tradeItemStatus = tradeItemStatus ?? _tradeItemStatus;

    if (effectiveDate != null) {
      _effectiveDate = effectiveDate;
      _effectiveDateDisplay.text = _formatDateTimeWithOffset(effectiveDate);
    }

    _startAvailDate = startAvailDate;
    _startAvailDateDisplay.text =
        startAvailDate == null ? '' : _formatDateTimeWithOffset(startAvailDate);

    _endAvailDate = endAvailDate;
    _endAvailDateDisplay.text =
        endAvailDate == null ? '' : _formatDateTimeWithOffset(endAvailDate);

    _publicationDate = publicationDate;
    _publicationDateDisplay.text =
        publicationDate == null ? '' : _dateFmt.format(publicationDate);

    if (mounted) setState(() {});
  }

  String _formatDateTimeWithOffset(DateTime dt) {
    final local = dt.toLocal();
    final base = _dateTimeNoOffsetFmt.format(local);
    final off = local.timeZoneOffset;
    final sign = off.isNegative ? '-' : '+';
    final abs = off.abs();
    final hh = abs.inHours.toString().padLeft(2, '0');
    final mm = (abs.inMinutes % 60).toString().padLeft(2, '0');
    return '$base$sign$hh:$mm';
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime?> setValue,
    required TextEditingController display,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    if (widget.isReadOnly) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(now.year + 50),
    );
    if (!mounted) return;
    if (picked == null) return;

    setValue(picked);
    display.text = _dateFmt.format(picked);
    setState(() {});
  }

  Future<void> _pickDateTime({
    required DateTime? current,
    required ValueChanged<DateTime?> setValue,
    required TextEditingController display,
  }) async {
    if (widget.isReadOnly) return;

    final now = DateTime.now();
    final base = current ?? now;

    final d = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 50),
    );
    if (!mounted) return;
    if (d == null) return;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (!mounted) return;
    if (t == null) return;

    final picked = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    setValue(picked);
    display.text = _formatDateTimeWithOffset(picked);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Lifecycle, Availability & Status'),
        DropdownButtonFormField<String>(
          initialValue: _tradeItemStatus,
          decoration: const InputDecoration(
            labelText: 'Trade Item Status',
            helperText: "ADD / CHN / COR",
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'ADD', child: Text('ADD')),
            DropdownMenuItem(value: 'CHN', child: Text('CHN')),
            DropdownMenuItem(value: 'COR', child: Text('COR')),
          ],
          validator: (v) => GtinFieldValidators.validateTradeItemStatus(v),
          onChanged: widget.isReadOnly ? null : (v) => setState(() => _tradeItemStatus = v),
        ),
        const SizedBox(height: 12),
        GtinDateField(
          controller: _effectiveDateDisplay,
          label: 'Effective Date / Time',
          enabled: !widget.isReadOnly,
          validator: widget.isReadOnly
              ? null
              : (v) => (v == null || v.trim().isEmpty)
                  ? 'effective_date is required'
                  : null,
          onPick: () => _pickDateTime(
            current: _effectiveDate,
            setValue: (v) => _effectiveDate = v,
            display: _effectiveDateDisplay,
          ),
        ),
        const SizedBox(height: 12),
        GtinDateField(
          controller: _startAvailDateDisplay,
          label: 'Start Availability Date / Time',
          enabled: !widget.isReadOnly,
          onPick: () => _pickDateTime(
            current: _startAvailDate,
            setValue: (v) => _startAvailDate = v,
            display: _startAvailDateDisplay,
          ),
        ),
        const SizedBox(height: 12),
        GtinDateField(
          controller: _endAvailDateDisplay,
          label: 'End Availability Date / Time',
          enabled: !widget.isReadOnly,
          onPick: () => _pickDateTime(
            current: _endAvailDate,
            setValue: (v) => _endAvailDate = v,
            display: _endAvailDateDisplay,
          ),
        ),
        const SizedBox(height: 12),
        GtinDateField(
          controller: _publicationDateDisplay,
          label: 'Publication Date',
          enabled: !widget.isReadOnly,
          validator: widget.isReadOnly
              ? null
              : (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return null;
                  final parsed = DateTime.tryParse(s);
                  if (parsed == null) return 'publication_date must be YYYY-MM-DD';
                  final today = DateTime.now();
                  final todayDate = DateTime(today.year, today.month, today.day);
                  final d = DateTime(parsed.year, parsed.month, parsed.day);
                  if (d.isAfter(todayDate)) return 'publication_date must be <= today';
                  return null;
                },
          onPick: () => _pickDate(
            current: _publicationDate,
            setValue: (v) => _publicationDate = v,
            display: _publicationDateDisplay,
            lastDate: DateTime.now(),
          ),
        ),
        FormField<void>(
          validator: (_) {
            if (widget.isReadOnly) return null;
            if (_startAvailDate != null &&
                _endAvailDate != null &&
                _endAvailDate!.isBefore(_startAvailDate!)) {
              return 'End Availability Date / Time must be >= Start Availability Date / Time';
            }
            return null;
          },
          builder: (state) {
            if (state.errorText == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                state.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          },
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: widget.showFieldSkeleton,
      child: body,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Lifecycle, Availability & Status'),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
          const SizedBox(height: 12),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
          const SizedBox(height: 12),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
          const SizedBox(height: 12),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
        ],
      ),
    );
  }
}

