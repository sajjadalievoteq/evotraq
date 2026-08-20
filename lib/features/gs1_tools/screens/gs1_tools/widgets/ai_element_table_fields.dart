import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_ai_table.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class AiElementTableFields extends StatelessWidget {
  const AiElementTableFields({
    required this.searchController,
    required this.onSearchChanged,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final rows = Gs1AiTable.search(searchController.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search AI code, title, or format',
            prefixIcon: Padding(
              padding: EdgeInsets.all(12),
              child: TraqIcon(AppAssets.iconSearch, size: 20),
            ),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: TraqSpacing.md),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TraqSpacing.lg),
            child: Text(
              'No matching Application Identifiers.',
              style: context.text.bodySm.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: rows.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: context.colors.border),
              itemBuilder: (context, index) {
                final row = rows[index];
                return ListTile(
                  dense: true,
                  title: Text('(${row.code}) ${row.title}'),
                  subtitle: Text(row.format),
                  trailing: row.fnc1
                      ? const Tooltip(
                          message: 'Variable length (FNC1 separated)',
                          child: TraqIcon(AppAssets.iconArrowR, size: 16),
                        )
                      : null,
                );
              },
            ),
          ),
      ],
    );
  }
}
