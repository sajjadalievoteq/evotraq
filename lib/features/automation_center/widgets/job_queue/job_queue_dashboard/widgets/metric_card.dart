import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/widgets/job_queue/job_queue_dashboard/widgets/sparkline_and_section.dart';

/// Metric tile aligned with home dashboard: soft accent surface, accent value,
/// muted label, [TraqIcon] + optional sparkline.
class JobQueueMetricCard extends StatefulWidget {
  const JobQueueMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconAsset,
    required this.accent,
    this.subtitle,
    this.sparkline = const [],
    this.onTap,
  });

  final String title;
  final String value;
  final String iconAsset;
  final Color accent;
  final String? subtitle;
  final List<double> sparkline;
  final VoidCallback? onTap;

  @override
  State<JobQueueMetricCard> createState() => _JobQueueMetricCardState();
}

class _JobQueueMetricCardState extends State<JobQueueMetricCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final soft = OperationPalette.soft(widget.accent);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : TraqDuration.normal,
        curve: TraqDuration.ease,
        decoration: BoxDecoration(
          color: soft,
          borderRadius: TraqRadius.card,
          border: Border.all(
            color: _hovered ? widget.accent.withValues(alpha: 0.45) : c.border,
          ),
          boxShadow: _hovered
              ? TraqShadows.sm(brightness: Theme.of(context).brightness)
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: TraqRadius.card,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: widget.accent,
                      borderRadius: const BorderRadius.horizontal(
                        left: TraqRadius.md,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: TraqSpacing.surfacePad,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TraqIcon(
                                widget.iconAsset,
                                size: 16,
                                color: widget.accent,
                              ),
                              const SizedBox(width: TraqSpacing.sm),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: context.text.cap.copyWith(
                                    color: c.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: TraqSpacing.sm),
                          Text(
                            widget.value,
                            style: context.text.h2.copyWith(
                              fontWeight: FontWeight.w700,
                              color: widget.accent,
                              height: 1.1,
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: TraqSpacing.xs),
                            Text(
                              widget.subtitle!,
                              style: context.text.bodySm.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                          ],
                          const SizedBox(height: TraqSpacing.sm),
                          JobQueueSparkline(
                            values: widget.sparkline,
                            color: widget.accent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
