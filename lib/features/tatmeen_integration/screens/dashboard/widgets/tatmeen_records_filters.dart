import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/use_tatmeen_records.dart';
import 'package:traqtrace_app/features/tatmeen_integration/screens/dashboard/widgets/tatmeen_records_date_field.dart';

class TatmeenRecordsFilters extends StatelessWidget {
  const TatmeenRecordsFilters({
    super.key,
    required this.records,
    required this.searchController,
  });

  final UseTatmeenRecords records;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: TraqSpacing.md,
      runSpacing: TraqSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TatmeenRecordsDateField(
          label: 'From Date',
          value: records.fromDate,
          onChanged: (value) => value == null
              ? records.setDraft(clearFrom: true)
              : records.setDraft(fromDate: value),
        ),
        TatmeenRecordsDateField(
          label: 'To Date',
          value: records.toDate,
          onChanged: (value) => value == null
              ? records.setDraft(clearTo: true)
              : records.setDraft(toDate: value),
        ),
        SizedBox(
          width: 240,
          height: 40,
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Search',
              hintText: 'Operation ID or type',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) => records.setDraft(search: value),
          ),
        ),
        SizedBox(
          height: 40,
          width: 90,
          child: FilledButton(
            onPressed: records.apply,
            child: const Text('Apply'),
          ),
        ),
        SizedBox(
          height: 40,
          child: TextButton(
            onPressed: () {
              searchController.clear();
              records.clear();
            },
            child: const Text('Clear'),
          ),
        ),
      ],
    );
  }
}
