import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_animation_manager.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class TraqExpansionTile extends StatefulWidget {
  const TraqExpansionTile({
    super.key,
    this.leading,
    required this.title,
    this.children = const <Widget>[],
    this.tilePadding,
    this.childrenPadding,
    this.initiallyExpanded = false,
    this.shape,
    this.collapsedShape,
    this.backgroundColor,
    this.collapsedBackgroundColor,
    this.onExpansionChanged,
    this.enabled = true,
    this.maintainState = false,
    this.controlAffinity,
    this.visualDensity,
    this.minTileHeight,
    this.dense,
  });

  final Widget? leading;
  final Widget title;
  final List<Widget> children;
  final EdgeInsetsGeometry? tilePadding;
  final EdgeInsetsGeometry? childrenPadding;
  final bool initiallyExpanded;
  final ShapeBorder? shape;
  final ShapeBorder? collapsedShape;
  final Color? backgroundColor;
  final Color? collapsedBackgroundColor;
  final ValueChanged<bool>? onExpansionChanged;
  final bool enabled;
  final bool maintainState;
  final ListTileControlAffinity? controlAffinity;
  final VisualDensity? visualDensity;
  final double? minTileHeight;
  final bool? dense;

  @override
  State<TraqExpansionTile> createState() => _TraqExpansionTileState();
}

class _TraqExpansionTileState extends State<TraqExpansionTile> {
  static const double _chevronTurnsExpanded = 0.5;
  static const double _chevronSize = 14;

  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant TraqExpansionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _expanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final animationDuration = TraqAnimationManager.durationOf(
      context,
      const Duration(
        milliseconds: TraqAnimationConstants.formDurationMs,
      ),
    );

    return ExpansionTile(
      leading: widget.leading,
      title: widget.title,
      children: widget.children,
      tilePadding: widget.tilePadding,
      childrenPadding: widget.childrenPadding,
      initiallyExpanded: widget.initiallyExpanded,
      shape: widget.shape,
      collapsedShape: widget.collapsedShape,
      backgroundColor: widget.backgroundColor,
      collapsedBackgroundColor: widget.collapsedBackgroundColor,
      enabled: widget.enabled,
      maintainState: widget.maintainState,
      controlAffinity: widget.controlAffinity,
      visualDensity: widget.visualDensity,
      minTileHeight: widget.minTileHeight,
      dense: widget.dense,
      expansionAnimationStyle: AnimationStyle(
        duration: animationDuration,
        curve: TraqAnimationConstants.curve,
        reverseCurve: TraqAnimationConstants.reverseCurve,
      ),
      onExpansionChanged: (expanded) {
        setState(() {
          _expanded = expanded;
        });
        widget.onExpansionChanged?.call(expanded);
      },
      trailing: AnimatedRotation(
        turns: _expanded ? _chevronTurnsExpanded : 0.0,
        duration: animationDuration,
        curve: TraqAnimationConstants.curve,
        child: const TraqIcon(AppAssets.iconChevronD, size: _chevronSize),
      ),
    );
  }
}
