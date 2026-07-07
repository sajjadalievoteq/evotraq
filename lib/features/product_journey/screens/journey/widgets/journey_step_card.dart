import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/utils/journey_formatters.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/utils/journey_step_style.dart';

/// A single step in the operations timeline (used in the right-panel list view
/// and the mobile draggable sheet).
///
/// Layout:
///   [Icon bubble] ─── [Card: operation name · location · date · disposition]
///         │
///         ↓  directional arrow
///         │
///   (next step)
class JourneyStepCard extends StatelessWidget {
  const JourneyStepCard({
    super.key,
    required this.step,
    required this.index,
    required this.total,
    required this.isSelected,
    required this.onTap,
    this.previousStep,
  });

  final JourneyStep step;
  final int index;
  final int total;
  final bool isSelected;
  final VoidCallback onTap;
  final JourneyStep? previousStep;

  bool get _isFirst => index == 0;
  bool get _isLast  => index == total - 1;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _IconBubble(step: step, color: color, isSelected: isSelected),
              const SizedBox(width: 12),
              Expanded(
                child: _StepCard(
                  step: step,
                  color: color,
                  isSelected: isSelected,
                  isFirst: _isFirst,
                  isLast: _isLast,
                  onTap: onTap,
                ),
              ),
            ],
          ),
        ),
        if (!_isLast)
          const Padding(
            padding: EdgeInsets.only(left: 37), // centres on the 48 px icon
            child: _DirectionalConnector(),
          ),
      ],
    );
  }
}

// ─── Icon bubble ──────────────────────────────────────────────────────────────

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.step,
    required this.color,
    required this.isSelected,
  });

  final JourneyStep step;
  final Color color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? color : color.withValues(alpha: 0.14),
        border: Border.all(color: color, width: isSelected ? 0 : 2),
        boxShadow: isSelected
            ? [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 10)]
            : null,
      ),
      child: Center(
        child: TraqIcon(
          JourneyStepStyle.iconFor(step.businessStep),
          size: 22,
          color: isSelected ? Colors.white : color,
        ),
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.color,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final JourneyStep step;
  final Color color;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textColor  = isSelected ? Colors.white      : c.textPrimary;
    final mutedColor = isSelected ? Colors.white70    : c.textMuted;
    final faintColor = isSelected ? Colors.white54    : c.textFaint;

    return Card(
      elevation: isSelected ? 6 : 1,
      color: isSelected ? color : c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : color.withValues(alpha: 0.30),
          width: isSelected ? 0 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: operation name + badges + date ──────────────────────
              Row(
                children: [
                  // Operation name chip (colour-coded)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white24
                          : color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white38
                            : color.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TraqIcon(
                          JourneyStepStyle.iconFor(step.businessStep),
                          size: 13,
                          color: isSelected ? Colors.white : color,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          JourneyStepStyle.titleFor(step.businessStep),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isFirst) _Badge('START',  const Color(0xFF7BD389), isSelected),
                  if (isLast)  _Badge('LATEST', const Color(0xFF6FB7DC), isSelected),
                  const Spacer(),
                  Text(
                    JourneyFormatters.shortDate(step.eventTime),
                    style: TextStyle(fontSize: 11, color: mutedColor),
                  ),
                ],
              ),
              // ── Row 2: location ────────────────────────────────────────────
              if (step.locationName != null || step.locationGLN != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    TraqIcon(AppAssets.iconGln, size: 13, color: mutedColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        step.locationName ?? step.locationGLN ?? '',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              // ── Row 3: disposition ─────────────────────────────────────────
              if (step.dispositionLabel.isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(
                  children: [
                    TraqIcon(AppAssets.iconCheckCircle,
                        size: 12, color: faintColor),
                    const SizedBox(width: 4),
                    Text(
                      step.dispositionLabel,
                      style: TextStyle(fontSize: 11, color: faintColor),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Small badge ──────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color, this.onSelected);

  final String label;
  final Color color;
  final bool onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: onSelected
            ? Colors.white24
            : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: onSelected
              ? Colors.white38
              : color.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: onSelected ? Colors.white : color,
        ),
      ),
    );
  }
}

// ─── Directional connector ────────────────────────────────────────────────────

class _DirectionalConnector extends StatelessWidget {
  const _DirectionalConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 30,
      child: CustomPaint(
        painter: _ArrowPainter(color: context.colors.border),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    canvas.drawLine(
      Offset(cx, 0),
      Offset(cx, size.height - 9),
      Paint()
        ..color = color.withValues(alpha: 0.6)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, size.height)
        ..lineTo(cx - 5, size.height - 9)
        ..lineTo(cx + 5, size.height - 9)
        ..close(),
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color;
}
