import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/utils/cbv_vocabulary_search_utils.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_status_chip.dart';

class CbvVocabFlatTab extends StatelessWidget {
  const CbvVocabFlatTab({
    super.key,
    required this.items,
    required this.searchQuery,
    required this.isAdmin,
    required this.isBizStep,
    required this.togglingCodes,
    required this.deletingCodes,
    required this.onToggle,
    required this.onDelete,
  });

  final List<CbvVocabularyItem> items;
  final String searchQuery;
  final bool isAdmin;
  final bool isBizStep;
  final Set<String> togglingCodes;
  final Set<String> deletingCodes;
  final Future<void> Function(CbvVocabularyItem, bool) onToggle;
  final Future<void> Function(CbvVocabularyItem) onDelete;

  @override
  Widget build(BuildContext context) {
    final filtered = filterCbvVocabularyItems(
      items: items,
      searchQuery: searchQuery,
    );

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          searchQuery.isNotEmpty
              ? 'No items match "$searchQuery".'
              : 'No ${isBizStep ? 'biz steps' : 'dispositions'} found.',
          style: context.text.body.copyWith(color: context.colors.textMuted),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: context.padding.left,
        vertical: TraqSpacing.md,
      ),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final item = filtered[i];
        final isToggling = togglingCodes.contains(item.code);
        final isDeleting = deletingCodes.contains(item.code);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: TraqSpacing.xs,
          ),
          title: Row(
            children: [
              Text(item.label, style: context.text.body),
              const SizedBox(width: TraqSpacing.sm),
              if (item.isCustom)
                CbvStatusChip(
                  label: 'Custom',
                  color: context.colors.warning,
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.code,
                style: context.text.mono
                    .copyWith(fontSize: 11, color: context.colors.textMuted),
              ),
              if (item.group != null)
                Text(
                  item.group!,
                  style: context.text.cap
                      .copyWith(color: context.colors.textFaint, fontSize: 10),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAdmin)
                isToggling
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch.adaptive(
                        value: item.enabled,
                        onChanged: (v) => onToggle(item, v),
                      )
              else
                CbvStatusChip(
                  label: item.enabled ? 'Enabled' : 'Disabled',
                  color:
                      item.enabled ? context.colors.success : context.colors.error,
                ),
              if (isAdmin && item.isCustom) ...[
                const SizedBox(width: TraqSpacing.sm),
                isDeleting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: TraqIcon(
                          AppAssets.iconTrash,
                          color: context.colors.error,
                          size: 20,
                        ),
                        tooltip: 'Delete',
                        onPressed: () => onDelete(item),
                      ),
              ],
            ],
          ),
        );
      },
    );
  }
}
