import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_animation_constants.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_formatters.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_step_style.dart';

class JourneyPinMarker extends StatefulWidget {
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
  State<JourneyPinMarker> createState() => _JourneyPinMarkerState();
}

class _JourneyPinMarkerState extends State<JourneyPinMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: JourneyAnimationConstants.pinSelectedPulse,
    );
    if (widget.isSelected) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(JourneyPinMarker old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isSelected && old.isSelected) {
      _pulseCtrl.stop();
      _pulseCtrl.value = 0.0;
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = JourneyStepStyle.colorFor(context, widget.step.businessStep);
    final title = JourneyStepStyle.titleFor(widget.step.businessStep);
    final icon = JourneyStepStyle.iconFor(widget.step.businessStep);
    final location = widget.step.locationName ?? widget.step.locationGLN;
    final time = JourneyFormatters.shortDate(widget.step.eventTime);
    final r = widget.pinRadius;
    final tipH = r * 0.5;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: widget.isSelected ? 1.18 : 1.0,
            duration: JourneyAnimationConstants.pinSelectedScale,
            curve: Curves.easeOutBack,
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: r * 2,
              height: r * 2 + tipH,
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  child: Align(
                    alignment: const Alignment(0, -0.35),
                    child: TraqIcon(
                      icon,
                      size: r * 0.92,
                      color: Colors.white,
                    ),
                  ),
                  builder: (context, child) => CustomPaint(
                    painter: _PinBodyPainter(
                      color: color,
                      isSelected: widget.isSelected,
                      tipHeight: tipH,
                      pulseValue: widget.isSelected ? _pulseCtrl.value : 0.0,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
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
                        NavIcons.gln,
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
          if (widget.isFirst || widget.isLast) ...[
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: widget.isFirst
                      ? const Color(0xFF7BD389)
                      : const Color(0xFF6FB7DC),
                  width: 1,
                ),
              ),
              child: Text(
                widget.isFirst ? 'START' : 'LATEST',
                style: TextStyle(
                  color: widget.isFirst
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
    this.pulseValue = 0.0,
  });

  final Color color;
  final bool isSelected;
  final double tipHeight;
  final double pulseValue;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final cx = size.width / 2;
    final cy = r;
    final circleCenter = Offset(cx, cy);

    if (isSelected) {
      // Pulse: glow radius oscillates between r+4 and r+14
      final glowR = r + 4 + pulseValue * 10;
      canvas.drawCircle(
        circleCenter,
        glowR,
        Paint()
          ..color = color.withValues(alpha: 0.18 + pulseValue * 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    canvas.drawCircle(
      circleCenter.translate(0, 2),
      r,
      Paint()
        ..color = Colors.black38
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    final fill = Paint()..color = color;

    canvas.drawCircle(circleCenter, r, fill);

    final tipPath = Path()
      ..moveTo(cx - r * 0.45, cy + r * 0.70)
      ..quadraticBezierTo(cx, cy + r + tipHeight, cx, size.height)
      ..quadraticBezierTo(cx, cy + r + tipHeight, cx + r * 0.45, cy + r * 0.70)
      ..close();
    canvas.drawPath(tipPath, fill);

    canvas.drawCircle(
      Offset(cx - r * 0.28, cy - r * 0.28),
      r * 0.28,
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(_PinBodyPainter old) =>
      old.color != color ||
      old.isSelected != isSelected ||
      old.pulseValue != pulseValue;
}
