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
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_disposition_chip.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_add_pair_chip.dart';

class CbvPairingRow extends StatelessWidget {
  const CbvPairingRow({
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
    final unpairedDispositions = allDispositions
        .where((d) => !pairedCodes.contains(d.code))
        .toList();

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
                  CbvDispositionChip(
                    label: dispMap[dispCode]?.label ?? dispCode,
                    isPending: pairingKeys.contains(
                      '${bizItem.code}|$dispCode',
                    ),
                    isAdmin: isAdmin,
                    onRemove: () => onRemove(dispCode),
                  ),
                ],
                if (isAdmin && unpairedDispositions.isNotEmpty)
                  CbvAddPairChip(available: unpairedDispositions, onAdd: onAdd),
                if (pairedCodes.isEmpty && !isAdmin)
                  Text(
                    'No pairings',
                    style: context.text.bodySm.copyWith(
                      color: colors.textFaint,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
