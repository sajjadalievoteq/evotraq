import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/data/models/gs1/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/utilities/sscc_ui_constants.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/shared/widgets/custom_outlined_button_widget.dart';

class SsccAdvancedFiltersPanel extends StatelessWidget {
  const SsccAdvancedFiltersPanel({
    super.key,
    required this.sourceLocationController,
    required this.destinationLocationController,
    required this.companyPrefixController,
    required this.selectedStatus,
    required this.selectedContainerType,
    required this.onStatusChanged,
    required this.onContainerTypeChanged,
    this.packingDateFrom,
    this.packingDateTo,
    this.shippingDateFrom,
    this.shippingDateTo,
    this.receivingDateFrom,
    this.receivingDateTo,
    this.onPackingDateFromChanged,
    this.onPackingDateToChanged,
    this.onShippingDateFromChanged,
    this.onShippingDateToChanged,
    this.onReceivingDateFromChanged,
    this.onReceivingDateToChanged,
    required this.onApply,
    required this.onClearAll,
  });

  final TextEditingController sourceLocationController;
  final TextEditingController destinationLocationController;
  final TextEditingController companyPrefixController;
  final String? selectedStatus;
  final String? selectedContainerType;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onContainerTypeChanged;
  final DateTime? packingDateFrom;
  final DateTime? packingDateTo;
  final DateTime? shippingDateFrom;
  final DateTime? shippingDateTo;
  final DateTime? receivingDateFrom;
  final DateTime? receivingDateTo;
  final ValueChanged<DateTime?>? onPackingDateFromChanged;
  final ValueChanged<DateTime?>? onPackingDateToChanged;
  final ValueChanged<DateTime?>? onShippingDateFromChanged;
  final ValueChanged<DateTime?>? onShippingDateToChanged;
  final ValueChanged<DateTime?>? onReceivingDateFromChanged;
  final ValueChanged<DateTime?>? onReceivingDateToChanged;
  final VoidCallback onApply;
  final VoidCallback onClearAll;

  static final _dateFormat = DateFormat.yMMMd();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SsccUiConstants.advancedFiltersHeader,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          SsccUiConstants.advancedFiltersNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: sourceLocationController,
          decoration: const InputDecoration(
            labelText: SsccUiConstants.labelSourceLocationField,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: destinationLocationController,
          decoration: const InputDecoration(
            labelText: SsccUiConstants.labelDestinationLocationField,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: companyPrefixController,
          decoration: const InputDecoration(
            labelText: SsccUiConstants.labelCompanyPrefixField,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        _DateRangeRow(
          label: 'Packing date',
          from: packingDateFrom,
          to: packingDateTo,
          onFromChanged: onPackingDateFromChanged,
          onToChanged: onPackingDateToChanged,
        ),
        const SizedBox(height: 12),
        _DateRangeRow(
          label: 'Shipping date',
          from: shippingDateFrom,
          to: shippingDateTo,
          onFromChanged: onShippingDateFromChanged,
          onToChanged: onShippingDateToChanged,
        ),
        const SizedBox(height: 12),
        _DateRangeRow(
          label: 'Receiving date',
          from: receivingDateFrom,
          to: receivingDateTo,
          onFromChanged: onReceivingDateFromChanged,
          onToChanged: onReceivingDateToChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedStatus,
          decoration: const InputDecoration(
            labelText: SsccUiConstants.labelStatusField,
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All'),
            ),
            ...LogisticUnitStatus.values.map(
              (s) => DropdownMenuItem(
                value: s.name,
                child: Text(s.name.replaceAll('_', ' ')),
              ),
            ),
          ],
          onChanged: onStatusChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedContainerType,
          decoration: const InputDecoration(
            labelText: SsccUiConstants.labelContainerTypeField,
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All'),
            ),
            ...UnitType.values.map(
              (t) => DropdownMenuItem(value: t.name, child: Text(t.name)),
            ),
          ],
          onChanged: onContainerTypeChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomOutlinedButtonWidget(
                title: SsccUiConstants.buttonClearAll,
                onTap: onClearAll,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButtonWidget(
                title: SsccUiConstants.buttonApplyFilters,
                onTap: onApply,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateRangeRow extends StatelessWidget {
  const _DateRangeRow({
    required this.label,
    required this.from,
    required this.to,
    required this.onFromChanged,
    required this.onToChanged,
  });

  final String label;
  final DateTime? from;
  final DateTime? to;
  final ValueChanged<DateTime?>? onFromChanged;
  final ValueChanged<DateTime?>? onToChanged;

  Future<void> _pick(
    BuildContext context,
    DateTime? initial,
    ValueChanged<DateTime?>? onChanged,
  ) async {
    if (onChanged == null) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onChanged(DateTime(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pick(context, from, onFromChanged),
                child: Text(
                  from == null
                      ? 'From'
                      : SsccAdvancedFiltersPanel._dateFormat.format(from!),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pick(context, to, onToChanged),
                child: Text(
                  to == null
                      ? 'To'
                      : SsccAdvancedFiltersPanel._dateFormat.format(to!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
