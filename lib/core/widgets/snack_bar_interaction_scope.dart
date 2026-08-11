
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';


class SnackBarInteractionScope extends StatelessWidget {
  const SnackBarInteractionScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) return child;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        SnackBarAnchorTracker.recordInteraction(
          globalPosition: box.localToGlobal(event.localPosition),
          screenSize: MediaQuery.sizeOf(context),
          viewId: View.of(context).viewId,
        );
      },
      child: child,
    );
  }
}
