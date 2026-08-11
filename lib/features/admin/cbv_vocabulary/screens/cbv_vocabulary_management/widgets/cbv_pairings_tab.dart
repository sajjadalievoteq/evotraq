import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/cubit/admin_cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/cubit/admin_cbv_vocabulary_state.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/utils/cbv_vocabulary_search_utils.dart';
import 'package:traqtrace_app/features/admin/cbv_vocabulary/screens/cbv_vocabulary_management/widgets/cbv_pairing_row.dart';

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
        return CbvPairingRow(
          bizItem: bizItem,
          pairedCodes: pairedCodes,
          allDispositions: state.dispositions,
          dispMap: dispMap,
          pairingKeys: state.pairingKeys,
          isAdmin: isAdmin,
          onAdd: (dispCode) async {
            try {
              await context.read<AdminCbvVocabularyCubit>().addPair(
                bizCode,
                dispCode,
              );
            } catch (_) {
              if (context.mounted) {
                context.showError('Failed to add pairing.');
              }
            }
          },
          onRemove: (dispCode) async {
            try {
              await context.read<AdminCbvVocabularyCubit>().removePair(
                bizCode,
                dispCode,
              );
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
