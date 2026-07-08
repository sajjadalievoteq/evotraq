import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class JourneyStepCardDirectionalConnector extends StatelessWidget {
  const JourneyStepCardDirectionalConnector({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 30,
      child: CustomPaint(
        painter: JourneyStepCardArrowPainter(color: context.colors.border),
      ),
    );
  }
}

class JourneyStepCardArrowPainter extends CustomPainter {
  const JourneyStepCardArrowPainter({required this.color});

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
  bool shouldRepaint(JourneyStepCardArrowPainter old) => old.color != color;
}
