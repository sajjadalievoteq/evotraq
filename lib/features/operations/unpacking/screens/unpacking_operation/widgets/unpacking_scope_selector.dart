import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/operations/unpacking/utils/unpacking_scope.dart';

/// Segmented control for partial vs whole-container unpacking.
class UnpackingScopeSelector extends StatelessWidget {
  const UnpackingScopeSelector({
    super.key,
    required this.selectedScope,
    required this.onScopeChanged,
  });

  final UnpackingScope selectedScope;
  final ValueChanged<UnpackingScope> onScopeChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<UnpackingScope>(
      segments: const [
        ButtonSegment(
          value: UnpackingScope.partial,
          icon: TraqIcon(AppAssets.iconList),
          label: Text('Partial items'),
        ),
        ButtonSegment(
          value: UnpackingScope.wholeContainer,
          icon: TraqIcon(AppAssets.iconBox),
          label: Text('Whole container'),
        ),
      ],
      selected: {selectedScope},
      onSelectionChanged: (scopes) {
        if (scopes.isEmpty) return;
        onScopeChanged(scopes.first);
      },
    );
  }
}
