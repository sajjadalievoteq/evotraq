import 'package:traqtrace_app/core/animation/traq_entrance_slide.dart';
import 'package:traqtrace_app/core/animation/traq_staggered_entrance_widget.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';

/// One entrance controller for the branding panel (not one per section).
class AuthBrandingEntrance extends StatelessWidget {
  const AuthBrandingEntrance({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return TraqStaggeredEntrance(
      slide: TraqEntranceSlide.fromRight,
      slidePx: TraqAnimationConstants.brandingSlidePx,
      duration: TraqAnimationConstants.brandingEntrance,
      stagger: TraqAnimationConstants.brandingStagger,
      beginScale: 1,
      children: children,
    );
  }
}
