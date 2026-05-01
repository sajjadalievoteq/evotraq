import 'package:flutter/material.dart';

/// Multi-select GS1 GLN types (spec §2.3).
class GlnGlnTypeChipsField extends StatelessWidget {
  const GlnGlnTypeChipsField({
    super.key,
    required this.selection,
    required this.onChanged,
    required this.enabled,
    this.errorText,
  });

  final List<String> selection;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;
  final String? errorText;

  static const _options = <(String code, String label)>[
    ('LEGAL_ENTITY', 'Legal entity'),
    ('FUNCTION', 'Function'),
    ('FIXED_PHYSICAL', 'Fixed physical'),
    ('MOBILE_PHYSICAL', 'Mobile physical'),
    ('DIGITAL', 'Digital'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _options.map((o) {
            final selected = selection.contains(o.$1);
            return FilterChip(
              label: Text(o.$2),
              selected: selected,
              onSelected: enabled
                  ? (sel) {
                      final next = List<String>.from(selection);
                      if (sel) {
                        if (!next.contains(o.$1)) next.add(o.$1);
                      } else {
                        next.remove(o.$1);
                      }
                      onChanged(next);
                    }
                  : null,
              selectedColor: scheme.primaryContainer,
              checkmarkColor: scheme.onPrimaryContainer,
            );
          }).toList(),
        ),
        if (errorText != null && errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText!,
              style: TextStyle(color: scheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
