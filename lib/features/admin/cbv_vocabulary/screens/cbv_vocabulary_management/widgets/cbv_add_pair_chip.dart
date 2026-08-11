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

class CbvAddPairChip extends StatelessWidget {
  const CbvAddPairChip({required this.available, required this.onAdd});

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
                trailing: d.enabled
                    ? null
                    : const CbvStatusChip(label: 'Disabled'),
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
