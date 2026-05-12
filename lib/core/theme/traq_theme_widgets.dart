part of 'traq_theme.dart';

class TraqCard extends StatelessWidget {
  const TraqCard({
    super.key,
    required this.child,
    this.padding = TraqSpacing.cardPad,
    this.brackets = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool brackets;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: TraqRadius.card,
      ),
      child: child,
    );
  }
}

/// Status / identifier chip — accepts a tone via [TraqChipTone].
enum TraqChipTone { gtin, gln, sgtin, sscc, event, ok, warn, err, muted, live }

class TraqChip extends StatelessWidget {
  final String label;
  final TraqChipTone tone;
  const TraqChip(this.label, {super.key, this.tone = TraqChipTone.muted});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color fg;
    Color bd;
    Color bg;
    switch (tone) {
      case TraqChipTone.gtin:
        fg = c.identifierGtin;
        bd = c.identifierGtin.withOpacity(.4);
        bg = c.identifierGtin.withOpacity(.1);
        break;
      case TraqChipTone.gln:
        fg = c.identifierGln;
        bd = c.identifierGln.withOpacity(.4);
        bg = c.identifierGln.withOpacity(.1);
        break;
      case TraqChipTone.sgtin:
        fg = c.identifierSgtin;
        bd = c.identifierSgtin.withOpacity(.4);
        bg = c.identifierSgtin.withOpacity(.1);
        break;
      case TraqChipTone.sscc:
        fg = c.identifierSscc;
        bd = c.identifierSscc.withOpacity(.4);
        bg = c.identifierSscc.withOpacity(.1);
        break;
      case TraqChipTone.event:
        fg = c.identifierEvent;
        bd = c.identifierEvent.withOpacity(.4);
        bg = c.identifierEvent.withOpacity(.1);
        break;
      case TraqChipTone.ok:
        fg = c.success;
        bd = c.success.withOpacity(.4);
        bg = c.success.withOpacity(.1);
        break;
      case TraqChipTone.warn:
        fg = c.warning;
        bd = c.warning.withOpacity(.4);
        bg = c.warning.withOpacity(.1);
        break;
      case TraqChipTone.err:
        fg = c.error;
        bd = c.error.withOpacity(.4);
        bg = c.error.withOpacity(.1);
        break;
      case TraqChipTone.live:
        fg = c.primary;
        bd = c.primary.withOpacity(.4);
        bg = c.primaryMuted;
        break;
      case TraqChipTone.muted:
        fg = c.textMuted;
        bd = c.border;
        bg = c.surfaceMuted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: TraqRadius.chip,
        border: Border.all(color: bd),
      ),
      child: Text(
        label.toUpperCase(),
        style: context.text.mono.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
