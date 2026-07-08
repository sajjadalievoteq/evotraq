import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_step_style.dart';

class JourneyStepMarker extends StatelessWidget {
  const JourneyStepMarker({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.isSelected,
    required this.onTap,
  });

  final JourneyStep step;
  final int stepIndex;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = JourneyStepStyle.colorFor(context, step.businessStep);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isSelected ? 48 : 40,
              height: isSelected ? 48 : 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: TraqIcon(
                  JourneyStepStyle.iconFor(step.businessStep),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$stepIndex',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CustomPaint(
              size: const Size(12, 6),
              painter: _PinPointerPainter(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinPointerPainter extends CustomPainter {
  const _PinPointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PinPointerPainter old) => old.color != color;
}
