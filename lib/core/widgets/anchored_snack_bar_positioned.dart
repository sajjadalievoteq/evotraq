
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';


class AnchoredSnackBarPositioned extends StatefulWidget {
  const AnchoredSnackBarPositioned({
    required this.anchorRect,
    required this.child,
  });

  final Rect anchorRect;
  final Widget child;

  @override
  State<AnchoredSnackBarPositioned> createState() =>
      AnchoredSnackBarPositionedState();
}

class AnchoredSnackBarPositionedState
    extends State<AnchoredSnackBarPositioned> {
  final GlobalKey _measureKey = GlobalKey();
  double _measuredHeight = CustomSnackBarPresenter.estimatedSnackBarHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_updateMeasuredHeight);
  }

  void _updateMeasuredHeight(Duration _) {
    if (!mounted) return;
    final box = _measureKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final height = box.size.height;
    if ((height - _measuredHeight).abs() > 0.5) {
      setState(() => _measuredHeight = height);
      WidgetsBinding.instance.addPostFrameCallback(_updateMeasuredHeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final layout = CustomSnackBarPresenter.layoutForAnchor(
      anchorRect: widget.anchorRect,
      screenSize: mediaQuery.size,
      viewPadding: mediaQuery.padding,
      snackbarHeight: _measuredHeight,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: layout.top,
          left: layout.left,
          width: layout.width,
          child: KeyedSubtree(key: _measureKey, child: widget.child),
        ),
      ],
    );
  }
}
