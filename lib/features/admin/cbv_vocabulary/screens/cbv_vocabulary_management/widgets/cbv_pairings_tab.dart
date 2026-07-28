import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/cubit/admin_cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/cubit/admin_cbv_vocabulary_state.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/utils/cbv_vocabulary_search_utils.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_status_chip.dart';

class CbvPairingsTab extends StatelessWidget {
  const CbvPairingsTab({
    super.key,
    required this.state,
    required this.searchQuery,
    required this.isAdmin,
  });

  final AdminCbvVocabularyState state;
  final String searchQuery;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final bizStepMap = {for (final b in state.bizSteps) b.code: b};
    final dispMap = {for (final d in state.dispositions) d.code: d};

    final filtered = filterBizStepCodes(
      bizSteps: state.bizSteps,
      searchQuery: searchQuery,
    );

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          searchQuery.isNotEmpty
              ? 'No biz steps match "$searchQuery".'
              : 'No biz steps found.',
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
        final bizCode = filtered[i];
        final bizItem = bizStepMap[bizCode];
        if (bizItem == null) return const SizedBox.shrink();
        final pairedCodes = state.pairMap[bizCode] ?? [];
        return _PairingRow(
          bizItem: bizItem,
          pairedCodes: pairedCodes,
          allDispositions: state.dispositions,
          dispMap: dispMap,
          pairingKeys: state.pairingKeys,
          isAdmin: isAdmin,
          onAdd: (dispCode) async {
            try {
              await context.read<AdminCbvVocabularyCubit>().addPair(bizCode, dispCode);
            } catch (_) {
              if (context.mounted) {
                context.showError('Failed to add pairing.');
              }
            }
          },
          onRemove: (dispCode) async {
            try {
              await context
                  .read<AdminCbvVocabularyCubit>()
                  .removePair(bizCode, dispCode);
            } catch (_) {
              if (context.mounted) {
                context.showError('Failed to remove pairing.');
              }
            }
          },
        );
      },
    );
  }
}

class _PairingRow extends StatelessWidget {
  const _PairingRow({
    required this.bizItem,
    required this.pairedCodes,
    required this.allDispositions,
    required this.dispMap,
    required this.pairingKeys,
    required this.isAdmin,
    required this.onAdd,
    required this.onRemove,
  });

  final CbvVocabularyItem bizItem;
  final List<String> pairedCodes;
  final List<CbvVocabularyItem> allDispositions;
  final Map<String, CbvVocabularyItem> dispMap;
  final Set<String> pairingKeys;
  final bool isAdmin;
  final Future<void> Function(String dispCode) onAdd;
  final Future<void> Function(String dispCode) onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unpairedDispositions =
        allDispositions.where((d) => !pairedCodes.contains(d.code)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TraqSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bizItem.label,
                  style: context.text.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: bizItem.enabled ? colors.primary : colors.textFaint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bizItem.code,
                  style: context.text.mono.copyWith(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
                if (!bizItem.enabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: CbvStatusChip(
                      label: 'Disabled',
                      color: colors.error,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: TraqSpacing.lg),
          Expanded(
            child: Wrap(
              spacing: TraqSpacing.sm,
              runSpacing: TraqSpacing.xs,
              children: [
                for (final dispCode in pairedCodes) ...[
                  _DispChip(
                    label: dispMap[dispCode]?.label ?? dispCode,
                    isPending: pairingKeys.contains('${bizItem.code}|$dispCode'),
                    isAdmin: isAdmin,
                    onRemove: () => onRemove(dispCode),
                  ),
                ],
                if (isAdmin && unpairedDispositions.isNotEmpty)
                  _AddPairChip(
                    available: unpairedDispositions,
                    onAdd: onAdd,
                  ),
                if (pairedCodes.isEmpty && !isAdmin)
                  Text(
                    'No pairings',
                    style: context.text.bodySm.copyWith(color: colors.textFaint),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DispChip extends StatelessWidget {
  const _DispChip({
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
            Text(label, style: context.text.cap.copyWith(color: colors.textSecondary)),
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

class _AddPairChip extends StatelessWidget {
  const _AddPairChip({
    required this.available,
    required this.onAdd,
  });

  final List<CbvVocabularyItem> available;
  final Future<void> Function(String dispCode) onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ActionChip(
      avatar: TraqIcon(AppAssets.iconPlus, size: 14, color: colors.primary),
      label: Text(
        'Add',
        style: context.text.cap.copyWith(color: colors.primary),
      ),
      backgroundColor: colors.surface,
      side: BorderSide(color: colors.primary.withOpacity(0.4)),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () => _showPicker(context),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Disposition Pairing'),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 340,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: available.length,
            itemBuilder: (_, i) {
              final d = available[i];
              return ListTile(
                dense: true,
                title: Text(d.label),
                subtitle: Text(d.code, style: const TextStyle(fontSize: 11)),
                trailing: d.enabled ? null : const CbvStatusChip(label: 'Disabled'),
                onTap: () => Navigator.of(ctx).pop(d.code),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (chosen != null) {
      await onAdd(chosen);
    }
  }
}
