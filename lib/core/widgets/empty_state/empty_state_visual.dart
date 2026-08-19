import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/empty_state/empty_state_icon_aura.dart';
import 'package:traqtrace_app/core/widgets/empty_state/empty_state_action_row.dart';

export 'empty_state_hover_action.dart';

class EmptyStateVisualScaffold extends StatefulWidget {
  const EmptyStateVisualScaffold({
    super.key,
    required this.iconAsset,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.footer,
    this.density = EmptyStateDensity.auto,
    this.semanticsLabel,
  });

  final String iconAsset;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? footer;
  final EmptyStateDensity density;
  final String? semanticsLabel;

  @override
  State<EmptyStateVisualScaffold> createState() =>
      _EmptyStateVisualScaffoldState();
}

enum EmptyStateDensity { auto, compact, comfortable }

class _EmptyStateVisualScaffoldState extends State<EmptyStateVisualScaffold>
    with SingleTickerProviderStateMixin, TraqDeferredPlay {
  late final AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    traqSchedulePlay(_startBreath);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = TraqAnimationManager.reduceMotion(context);
    if (reduce) {
      _breathController.stop();
      _breathController.value = 0;
      return;
    }
    if (!traqPlayStarted) traqSchedulePlay(_startBreath);
  }

  void _startBreath() {
    if (!mounted || traqPlayStarted) return;
    if (TraqAnimationManager.reduceMotion(context)) {
      _breathController.value = 0;
      traqMarkPlayed();
      return;
    }
    traqMarkPlayed();
    _breathController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reduceMotion = TraqAnimationManager.reduceMotion(context);
    final metrics = _metricsFor(layout, widget.density);

    final content = Semantics(
      label: widget.semanticsLabel ?? widget.title,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: metrics.maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: layout.horizontalPadding,
            vertical: metrics.verticalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmptyStateIconAura(
                iconAsset: widget.iconAsset,
                size: metrics.iconSize,
                breath: reduceMotion ? null : _breathController,
              ),
              SizedBox(height: metrics.gapAfterIcon),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: metrics
                    .titleStyle(theme)
                    .copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (widget.subtitle != null &&
                  widget.subtitle!.trim().isNotEmpty) ...[
                SizedBox(height: metrics.gapAfterTitle),
                Text(
                  widget.subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
              if (widget.actions.isNotEmpty) ...[
                SizedBox(height: metrics.gapBeforeActions),
                EmptyStateActionRow(
                  actions: widget.actions,
                  fullWidth: layout.isCompact,
                ),
              ],
              if (widget.footer != null) ...[
                SizedBox(height: metrics.gapBeforeActions),
                widget.footer!,
              ],
            ],
          ),
        ),
      ),
    );

    // Overflow-safe: center when there's room, scroll when the region is
    // shorter than the content (prevents RenderFlex bottom-overflow in bounded
    // panel bodies). Works whether height is bounded or unbounded.
    final centered = LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 0.0;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(child: content),
          ),
        );
      },
    );

    if (reduceMotion) return centered;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 10),
            child: Transform.scale(scale: 0.97 + (0.03 * t), child: child),
          ),
        );
      },
      child: centered,
    );
  }

  static _EmptyMetrics _metricsFor(
    AppLayoutData layout,
    EmptyStateDensity density,
  ) {
    final effective = density == EmptyStateDensity.auto
        ? (layout.isCompact
              ? EmptyStateDensity.compact
              : EmptyStateDensity.comfortable)
        : density;

    if (effective == EmptyStateDensity.compact || layout.isCompact) {
      return _EmptyMetrics(
        iconSize: 56,
        maxWidth: 420,
        verticalPadding: 24,
        gapAfterIcon: 16,
        gapAfterTitle: 8,
        gapBeforeActions: 20,
        titleStyle: (t) => t.textTheme.titleMedium!,
      );
    }
    if (layout.isLarge) {
      return _EmptyMetrics(
        iconSize: 96,
        maxWidth: 520,
        verticalPadding: 32,
        gapAfterIcon: 24,
        gapAfterTitle: 10,
        gapBeforeActions: 28,
        titleStyle: (t) => t.textTheme.titleLarge!,
      );
    }
    return _EmptyMetrics(
      iconSize: 72,
      maxWidth: 480,
      verticalPadding: 28,
      gapAfterIcon: 20,
      gapAfterTitle: 8,
      gapBeforeActions: 24,
      titleStyle: (t) => t.textTheme.titleMedium!,
    );
  }
}

class _EmptyMetrics {
  const _EmptyMetrics({
    required this.iconSize,
    required this.maxWidth,
    required this.verticalPadding,
    required this.gapAfterIcon,
    required this.gapAfterTitle,
    required this.gapBeforeActions,
    required this.titleStyle,
  });

  final double iconSize;
  final double maxWidth;
  final double verticalPadding;
  final double gapAfterIcon;
  final double gapAfterTitle;
  final double gapBeforeActions;
  final TextStyle Function(ThemeData theme) titleStyle;
}

const kDefaultEmptyStateIcon = NavIcons.packaging;
