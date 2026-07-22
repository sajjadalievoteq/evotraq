import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';


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
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = TraqAnimationManager.reduceMotion(context);
    if (reduce) {
      _breathController.stop();
      _breathController.value = 0;
    } else if (!_breathController.isAnimating) {
      _breathController.repeat(reverse: true);
    }
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
              _IconAura(
                iconAsset: widget.iconAsset,
                size: metrics.iconSize,
                breath: reduceMotion ? null : _breathController,
              ),
              SizedBox(height: metrics.gapAfterIcon),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: metrics.titleStyle(theme).copyWith(
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
                _ActionRow(
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

    final centered = Center(child: content);

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
            child: Transform.scale(
              scale: 0.97 + (0.03 * t),
              child: child,
            ),
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

class _IconAura extends StatelessWidget {
  const _IconAura({
    required this.iconAsset,
    required this.size,
    this.breath,
  });

  final String iconAsset;
  final double size;
  final Animation<double>? breath;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ring = size * 1.7;

    Widget aura = Container(
      width: ring,
      height: ring,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            scheme.primary.withValues(alpha: 0.14),
            scheme.surfaceContainerHighest.withValues(alpha: 0.55),
            scheme.surface.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      alignment: Alignment.center,
      child: TraqIcon(
        iconAsset,
        size: size,
        color: scheme.primary.withValues(alpha: 0.85),
      ),
    );

    if (breath == null) return aura;

    return AnimatedBuilder(
      animation: breath!,
      builder: (context, child) {
        final t = breath!.value;
        final scale = 1.0 + (t * 0.03);
        final opacity = 0.92 + (t * 0.08);
        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: aura,
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.actions, required this.fullWidth});

  final List<Widget> actions;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();
    if (fullWidth) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            actions[i],
          ],
        ],
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: actions,
    );
  }
}


class EmptyStateHoverAction extends StatefulWidget {
  const EmptyStateHoverAction({super.key, required this.child});

  final Widget child;

  @override
  State<EmptyStateHoverAction> createState() => _EmptyStateHoverActionState();
}

class _EmptyStateHoverActionState extends State<EmptyStateHoverAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _hovered ? 1 : 0.98,
          duration: const Duration(milliseconds: 140),
          child: widget.child,
        ),
      ),
    );
  }
}


const kDefaultEmptyStateIcon = NavIcons.packaging;
