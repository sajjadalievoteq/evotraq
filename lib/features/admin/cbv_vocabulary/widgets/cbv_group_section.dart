import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'cbv_vocabulary_item_card.dart';

class CbvGroupSection extends StatelessWidget {
  const CbvGroupSection({
    super.key,
    required this.groupName,
    required this.items,
    required this.togglingCodes,
    required this.deletingCodes,
    required this.onToggle,
    required this.isAdmin,
    required this.onDelete,
    required this.controller,
  });

  final String groupName;
  final List<CbvVocabularyItem> items;
  final Set<String> togglingCodes;
  final Set<String> deletingCodes;
  final void Function(CbvVocabularyItem item, bool enabled) onToggle;
  final bool isAdmin;
  final void Function(CbvVocabularyItem item) onDelete;
  final ExpansionTileController controller;

  static const double _minCardWidth = 280.0;
  static const double _cardGap = 8.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabledCount = items.where((i) => i.enabled).length;

    return ExpansionTile(
      expandedAlignment: Alignment.topLeft,
      controller: controller,
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.symmetric(

        vertical: TraqSpacing.xs,
      ),
      childrenPadding: const EdgeInsets.only(

        bottom: TraqSpacing.md,
      ),
      title: Row(
        children: [
          Text(
            groupName,
            style: context.text.h3.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(width: TraqSpacing.sm),
          _CountBadge(total: items.length, enabled: enabledCount),
        ],
      ),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final available = constraints.maxWidth;
            final cols = max(
              1,
              ((available + _cardGap) / (_minCardWidth + _cardGap)).floor(),
            );
            final cardWidth =
                (available - (cols - 1) * _cardGap) / cols;

            return Wrap(

              spacing: _cardGap,
              runSpacing: _cardGap,
              alignment: WrapAlignment.start,
              children: items.map((item) {
                return SizedBox(
                  width: cardWidth,
                  child: CbvVocabularyItemCard(
                    item: item,
                    isToggling: togglingCodes.contains(item.code),
                    isDeleting: deletingCodes.contains(item.code),
                    isAdmin: isAdmin,
                    onToggle: (enabled) => onToggle(item, enabled),
                    onDelete: (item.isCustom && isAdmin)
                        ? () => onDelete(item)
                        : null,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.total, required this.enabled});

  final int total;
  final int enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: BorderRadius.all(TraqRadius.pill),
      ),
      child: Text(
        '$enabled / $total',
        style: context.text.cap.copyWith(
          color: context.colors.textSecondary,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
