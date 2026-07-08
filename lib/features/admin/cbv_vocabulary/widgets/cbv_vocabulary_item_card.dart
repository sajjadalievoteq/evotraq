import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class CbvVocabularyItemCard extends StatelessWidget {
  const CbvVocabularyItemCard({
    super.key,
    required this.item,
    required this.isToggling,
    required this.isDeleting,
    required this.onToggle,
    required this.isAdmin,
    this.onDelete,
  });

  final CbvVocabularyItem item;
  final bool isToggling;
  final bool isDeleting;
  final ValueChanged<bool> onToggle;
  final bool isAdmin;

  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: TraqRadius.card,
        side: BorderSide(
          color: item.isCustom
              ? colors.secondary.withOpacity(0.4)
              : colors.border,
          width: item.isCustom ? 1.0 : 0.5,
        ),
      ),
      child: isDeleting
          ? _DeletingOverlay(label: item.label)
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TraqSpacing.lg,
                vertical: TraqSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _TypeChip(isCustom: item.isCustom),
                                const SizedBox(width: TraqSpacing.sm),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: context.text.body.copyWith(
                                      height: 0,
                                      fontWeight: FontWeight.w600,
                                      color: item.enabled
                                          ? colors.textPrimary
                                          : colors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: TraqSpacing.xs),
                            Text(
                              'Code: ${item.code}',
                              style: context.text.bodySm
                                  .copyWith(color: colors.textSecondary),
                            ),
                            Text(
                              item.urn,
                              style: context.text.bodySm.copyWith(
                                color: colors.textFaint,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.group != null) ...[
                              const SizedBox(height: TraqSpacing.sm),
                              _GroupBadge(group: item.group!),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: TraqSpacing.xs),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _ToggleControl(
                            enabled: item.enabled,
                            isToggling: isToggling,
                            onToggle: isAdmin ? onToggle : null,
                          ),
                          if (item.isCustom && isAdmin && onDelete != null)
                            _DeleteButton(onDelete: onDelete!),
                        ],
                      ),
                    ],
                  ),
                  if (item.isCustom &&
                      (item.createdAt != null || item.createdBy != null))
                    _AuditRow(item: item),
                ],
              ),
            ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.isCustom});

  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bg =
        isCustom ? colors.secondary.withOpacity(0.15) : colors.surfaceMuted;
    final fg = isCustom ? colors.secondary : colors.textMuted;
    final label = isCustom ? 'CUSTOM' : 'SYSTEM';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: TraqRadius.chip,
      ),
      child: Text(
        label,
        style: context.text.cap.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          fontSize: 10,
        ),
      ),
    );
  }
}


class _GroupBadge extends StatelessWidget {
  const _GroupBadge({required this.group});

  final String group;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TraqSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colors.primaryMuted,
        borderRadius: TraqRadius.chip,
      ),
      child: Text(
        group,
        style: context.text.cap.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}


class _ToggleControl extends StatelessWidget {
  const _ToggleControl({
    required this.enabled,
    required this.isToggling,
    required this.onToggle,
  });

  final bool enabled;
  final bool isToggling;

  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    if (isToggling) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Switch.adaptive(
      value: enabled,
      onChanged: onToggle,
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: TraqIcon(AppAssets.iconMoreVert, color: context.colors.textMuted, size: 18),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              TraqIcon(AppAssets.iconTrash, color: context.colors.error, size: 18),
              const SizedBox(width: TraqSpacing.sm),
              Text(
                'Delete',
                style: TextStyle(color: context.colors.error),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'delete') onDelete();
      },
    );
  }
}


final _dateFmt = DateFormat('yyyy-MM-dd HH:mm');

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.item});

  final CbvVocabularyItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final parts = <String>[];
    if (item.createdBy != null) parts.add('By ${item.createdBy}');
    if (item.createdAt != null) parts.add(_dateFmt.format(item.createdAt!));

    if (parts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: TraqSpacing.sm),
      child: Row(
        children: [
          TraqIcon(AppAssets.iconClock, size: 12, color: colors.textFaint),
          const SizedBox(width: 4),
          Text(
            parts.join(' · '),
            style: context.text.cap.copyWith(
              color: colors.textFaint,
              fontSize: 10,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}


class _DeletingOverlay extends StatelessWidget {
  const _DeletingOverlay({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: TraqSpacing.sm),
            Text(
              'Deleting "$label"…',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
                  