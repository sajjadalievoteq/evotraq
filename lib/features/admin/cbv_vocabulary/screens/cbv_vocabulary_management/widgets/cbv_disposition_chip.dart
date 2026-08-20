import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CbvDispositionChip extends StatelessWidget {
  const CbvDispositionChip({super.key,
    required this.label,
    required this.isPending,
    required this.isAdmin,
    required this.onRemove,
  });

  final String label;
  final bool isPending;
  final bool isAdmin;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isPending) {
      return Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: context.text.cap.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: colors.primary,
              ),
            ),
          ],
        ),
        backgroundColor: colors.surfaceMuted,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }

    return Chip(
      label: Text(
        label,
        style: context.text.cap.copyWith(color: colors.textSecondary),
      ),
      deleteIcon: isAdmin
          ? TraqIcon(AppAssets.iconX, size: 14, color: colors.textMuted)
          : null,
      onDeleted: isAdmin ? onRemove : null,
      backgroundColor: colors.primaryMuted,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
