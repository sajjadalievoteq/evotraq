import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/utils/journey_formatters.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/utils/journey_step_style.dart';

/// A coloured teardrop pin that represents one journey step on the canvas.
///
///     ╭────╮
///     │icon│    ← circle body
///     ╰──▼─╯    ← triangle tip
///   OPERATION   ← label pill
///   📍 Location
///   🕐 Time
///    [START]    ← optional badge
class JourneyPinMarker extends StatelessWidget {
  const JourneyPinMarker({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    this.pinRadius = 28.0,
  });

  final JourneyStep step;
  final int stepIndex;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final double pinRadius;

  @override
  Widget build(BuildContext context) {
    final color = JourneyStepStyle.colorFor(context, step.businessStep);
    final title = JourneyStepStyle.titleFor(step.businessStep);
    final icon = JourneyStepStyle.iconFor(step.businessStep);
    final location = step.locationName ?? step.locationGLN;
    final time = JourneyFormatters.shortDate(step.eventTime);
    final r = isSelected ? pinRadius * 1.18 : pinRadius;
    final tipH = r * 0.5;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Pin (circle + teardrop tip) ──────────────────────────────────
          SizedBox(
            width: r * 2,
            height: r * 2 + tipH,
            child: CustomPaint(
              painter: _PinBodyPainter(
                color: color,
                isSelected: isSelected,
                tipHeight: tipH,
              ),
              child: Align(
                alignment: const Alignment(0, -0.35),
                child: TraqIcon(
                  icon,
                  size: r * 0.92,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // ── Title pill (reference style) ─────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          // ── Location + time ────────────────────────────────────────────────
          if (location != null && location.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      TraqIcon(
                        AppAssets.iconGln,
                        size: 9,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      TraqIcon(
                        AppAssets.iconClock,
                        size: 9,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          time,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TraqIcon(
                    AppAssets.iconClock,
                    size: 9,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // ── START / LATEST badge ─────────────────────────────────────────
          if (isFirst || isLast) ...[
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isFirst
                      ? const Color(0xFF7BD389)
                      : const Color(0xFF6FB7DC),
                  width: 1,
                ),
              ),
              child: Text(
                isFirst ? 'START' : 'LATEST',
                style: TextStyle(
                  color: isFirst
                      ? const Color(0xFF7BD389)
                      : const Color(0xFF6FB7DC),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PinBodyPainter extends CustomPainter {
  const _PinBodyPainter({
    required this.color,
    required this.isSelected,
    required this.tipHeight,
  });

  final Color color;
  final bool isSelected;
  final double tipHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final cx = size.width / 2;
    final cy = r;
    final circleCenter = Offset(cx, cy);

    // Outer glow when selected
    if (isSelected) {
      canvas.drawCircle(
        circleCenter,
        r + 6,
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    // Shadow
    canvas.drawCircle(
      circleCenter.translate(0, 2),
      r,
      Paint()
        ..color = Colors.black38
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    final fill = Paint()..color = color;

    // Circle
    canvas.drawCircle(circleCenter, r, fill);

    // Teardrop tip
    final tipPath = Path()
      ..moveTo(cx - r * 0.45, cy + r * 0.70)
      ..quadraticBezierTo(cx, cy + r + tipHeight, cx, size.height)
      ..quadraticBezierTo(cx, cy + r + tipHeight, cx + r * 0.45, cy + r * 0.70)
      ..close();
    canvas.drawPath(tipPath, fill);

    // Shine highlight
    canvas.drawCircle(
      Offset(cx - r * 0.28, cy - r * 0.28),
      r * 0.28,
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(_PinBodyPainter old) =>
      old.color != color || old.isSelected != isSelected;
}
