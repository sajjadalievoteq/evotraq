import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';

/// Compact mode picker shared by the consolidated GS1 Tools panels.
///
/// Renders a [SegmentedButton] for three modes or fewer, otherwise falls
/// back to a [DropdownButtonFormField] so long lists stay usable.
class Gs1ToolModeSelector extends StatelessWidget {
  const Gs1ToolModeSelector({
    super.key,
    required this.modes,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.label = 'Mode',
  });

  final List<(String id, String label)> modes;
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String label;

  @override
  Widget build(BuildContext context) {
    final safeValue =
        modes.any((m) => m.$1 == value) ? value : modes.first.$1;
    if (modes.length <= 3) {
      return SegmentedButton<String>(
        segments: [
          for (final mode in modes)
            ButtonSegment(value: mode.$1, label: Text(mode.$2)),
        ],
        selected: {safeValue},
        emptySelectionAllowed: false,
        showSelectedIcon: false,
        onSelectionChanged: enabled ? (s) => onChanged(s.first) : null,
      );
    }
    return DropdownButtonFormField<String>(
      value: safeValue,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final mode in modes)
          DropdownMenuItem(value: mode.$1, child: Text(mode.$2)),
      ],
      onChanged: enabled
          ? (v) {
              if (v != null) onChanged(v);
            }
          : null,
    );
  }
}

/// Applies cubit [initialMode] once into local mode state.
mixin Gs1InitialModeMixin<T extends StatefulWidget> on State<T> {
  String? _appliedMode;

  void applyInitialMode(
    String? initialMode,
    List<String> allowed,
    void Function(String mode) apply, {
    VoidCallback? clear,
  }) {
    if (initialMode == null || initialMode == _appliedMode) return;
    final m = initialMode.toLowerCase();
    if (!allowed.contains(m)) return;
    _appliedMode = m;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      apply(m);
      clear?.call();
    });
  }
}

Widget gs1SubmitButton({
  required bool loading,
  required VoidCallback onPressed,
  String label = 'Run',
}) {
  return Padding(
    padding: const EdgeInsets.only(top: TraqSpacing.lg),
    child: CustomElevatedButton(
      label: label,
      isLoading: loading,
      isEnabled: !loading,
      onPressed: onPressed,
    ),
  );
}
