import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

enum TraqChipTone { gtin, gln, sgtin, sscc, event, ok, warn, err, muted, live }

class TraqChip extends StatelessWidget {
  const TraqChip(this.label, {super.key, this.tone = TraqChipTone.muted});
  final String label;
  final TraqChipTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (foreground, border, background) = switch (tone) {
      TraqChipTone.gtin => (
        colors.identifierGtin,
        colors.identifierGtin.withOpacity(.4),
        colors.identifierGtin.withOpacity(.1),
      ),
      TraqChipTone.gln => (
        colors.identifierGln,
        colors.identifierGln.withOpacity(.4),
        colors.identifierGln.withOpacity(.1),
      ),
      TraqChipTone.sgtin => (
        colors.identifierSgtin,
        colors.identifierSgtin.withOpacity(.4),
        colors.identifierSgtin.withOpacity(.1),
      ),
      TraqChipTone.sscc => (
        colors.identifierSscc,
        colors.identifierSscc.withOpacity(.4),
        colors.identifierSscc.withOpacity(.1),
      ),
      TraqChipTone.event => (
        colors.identifierEvent,
        colors.identifierEvent.withOpacity(.4),
        colors.identifierEvent.withOpacity(.1),
      ),
      TraqChipTone.ok => (
        colors.success,
        colors.success.withOpacity(.4),
        colors.success.withOpacity(.1),
      ),
      TraqChipTone.warn => (
        colors.warning,
        colors.warning.withOpacity(.4),
        colors.warning.withOpacity(.1),
      ),
      TraqChipTone.err => (
        colors.error,
        colors.error.withOpacity(.4),
        colors.error.withOpacity(.1),
      ),
      TraqChipTone.live => (
        colors.primary,
        colors.primary.withOpacity(.4),
        colors.primaryMuted,
      ),
      TraqChipTone.muted => (
        colors.textMuted,
        colors.border,
        colors.surfaceMuted,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: TraqRadius.chip,
        border: Border.all(color: border),
      ),
      child: Text(
        label.toUpperCase(),
        style: context.text.mono.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: foreground,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
