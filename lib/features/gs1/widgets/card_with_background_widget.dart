import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class CardWithBackgroundWidget extends StatefulWidget {
  const CardWithBackgroundWidget({
    super.key,
    required this.child,
    this.isPrimary = true,
    this.shape,
    this.elevation,
    this.margin,
  });

  final Widget child;
  final bool? isPrimary;
  final ShapeBorder? shape;
  final double? elevation;
  final EdgeInsetsGeometry? margin;

  @override
  State<CardWithBackgroundWidget> createState() =>
      _CardWithBackgroundWidgetState();
}

class _CardWithBackgroundWidgetState extends State<CardWithBackgroundWidget> {
  static const AssetImage _backgroundImage =
      AssetImage(AppAssets.traqBackgroundPng);

  bool _precacheRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precacheRequested) {
      _precacheRequested = true;
      precacheImage(_backgroundImage, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: widget.shape,
      elevation: widget.elevation,
      margin: widget.margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.isPrimary == true
              ? context.colors.primary
              : context.colors.background,
          image: const DecorationImage(
            image: _backgroundImage,
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}
