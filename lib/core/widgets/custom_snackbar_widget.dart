import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';

import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

enum CustomSnackBarVariant {
  success(AppAssets.iconCheck),
  error(AppAssets.iconAlert),
  warning(AppAssets.iconAlert),
  info(AppAssets.iconInfo);

  final String iconAsset;
  const CustomSnackBarVariant(this.iconAsset);

  Color color(BuildContext context) {
    final c = context.colors;
    return switch (this) {
      success => c.success,
      error => c.error,
      warning => c.warning,
      info => c.secondary,
    };
  }
}

/// Tracks the last pointer interaction on wide layouts so snackbars can anchor
/// to the control the user clicked without every call site passing a context.
class SnackBarAnchorTracker {
  SnackBarAnchorTracker._();

  static Rect? _lastInteractionRect;

  static void recordInteraction({
    required Offset globalPosition,
    required Size screenSize,
    required int viewId,
  }) {
    final result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(result, globalPosition, viewId);
    _lastInteractionRect = _resolveTargetRect(
      result,
      globalPosition: globalPosition,
      screenSize: screenSize,
    );
  }

  static Rect? get lastInteractionRect => _lastInteractionRect;

  static Rect _globalRect(RenderBox box) {
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }

  static Rect _resolveTargetRect(
    HitTestResult result, {
    required Offset globalPosition,
    required Size screenSize,
  }) {
    const minTarget = 32.0;
    final maxWidth = screenSize.width * 0.7;
    final maxHeight = screenSize.height * 0.3;

    RenderBox? seed;
    for (final entry in result.path) {
      final target = entry.target;
      if (target is! RenderBox) continue;
      final box = target;
      if (!box.hasSize || !box.attached) continue;

      final size = box.size;
      if (size.width < minTarget || size.height < minTarget) continue;
      if (!_globalRect(box).contains(globalPosition)) continue;

      seed = box;
      break;
    }

    if (seed == null) {
      return Rect.fromCenter(center: globalPosition, width: 1, height: 1);
    }

    var anchor = seed;
    var anchorRect = _globalRect(anchor);

    var parent = anchor.parent;
    while (parent is RenderBox) {
      final parentBox = parent;
      if (!parentBox.hasSize || !parentBox.attached) break;

      final parentRect = _globalRect(parentBox);
      if (!parentRect.contains(globalPosition)) break;
      if (parentRect.width > maxWidth || parentRect.height > maxHeight) break;

      final widthRatio = parentRect.width / anchorRect.width;
      final heightRatio = parentRect.height / anchorRect.height;
      if (widthRatio > 1.8 || heightRatio > 1.8) break;

      anchor = parentBox;
      anchorRect = parentRect;
      parent = anchor.parent;
    }

    return anchorRect;
  }

  @visibleForTesting
  static void clear() => _lastInteractionRect = null;
}

/// Wrap the app shell so desktop/web snackbars can anchor to recent interactions.
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

class CustomSnackBarPresenter {
  CustomSnackBarPresenter._();

  static const Duration _defaultDuration = Duration(seconds: 4);
  static const double _edgePadding = 16;
  static const double _anchorGap = 8;
  static const double _maxWidth = 420;
  static const double estimatedSnackBarHeight = 80;
  static const double _estimatedHeight = estimatedSnackBarHeight;

  static void dismiss(BuildContext context) {
    _AnchoredSnackBarLayer.dismiss();
    ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
  }

  static void show(
    BuildContext context, {
    required CustomSnackBarVariant variant,
    required String message,
    String? title,
    Duration? duration,
    BuildContext? anchor,
  }) {
    final resolvedDuration = duration ?? _defaultDuration;

    void onClose() => dismiss(context);

    final content = CustomSnackBarWidget(
      variant: variant,
      title: title,
      message: message,
      onClose: onClose,
    );

    dismiss(context);

    if (context.isMobile) {
      _showBottomSnackBar(
        context,
        content: content,
        duration: resolvedDuration,
        onClose: onClose,
      );
      return;
    }

    final anchorRect = _resolveAnchorRect(anchor);
    final anchored = anchorRect != null &&
        _AnchoredSnackBarLayer.show(
          context: context,
          content: content,
          duration: resolvedDuration,
          anchorRect: anchorRect,
        );

    if (!anchored) {
      _showBottomSnackBar(
        context,
        content: content,
        duration: resolvedDuration,
        onClose: onClose,
      );
    }
  }

  static Rect? _resolveAnchorRect(BuildContext? anchor) {
    final explicitRect = _renderRectForContext(anchor);
    if (explicitRect != null) return explicitRect;
    return SnackBarAnchorTracker.lastInteractionRect;
  }

  static Rect? _renderRectForContext(BuildContext? target) {
    if (target == null) return null;
    final renderBox = target.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize || !renderBox.attached) {
      return null;
    }
    final offset = renderBox.localToGlobal(Offset.zero);
    return offset & renderBox.size;
  }

  static void _showBottomSnackBar(
    BuildContext context, {
    required Widget content,
    required Duration duration,
    required VoidCallback onClose,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: content,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(_edgePadding),
        padding: EdgeInsets.zero,
        duration: duration,
      ),
    );
  }

  /// Computes anchored snackbar position, preferring below the anchor and
  /// flipping above when the full [snackbarHeight] would not fit underneath.
  @visibleForTesting
  static ({double top, double left, double width}) layoutForAnchor({
    required Rect anchorRect,
    required Size screenSize,
    required EdgeInsets viewPadding,
    double snackbarHeight = _estimatedHeight,
  }) {
    final width = math.min(
      _maxWidth,
      screenSize.width - (_edgePadding * 2),
    );

    var left = anchorRect.left;
    if (left + width > screenSize.width - _edgePadding) {
      left = screenSize.width - _edgePadding - width;
    }
    left = left.clamp(_edgePadding, screenSize.width - _edgePadding - width);

    final minTop = viewPadding.top + _edgePadding;
    final maxBottom = screenSize.height - viewPadding.bottom - _edgePadding;
    final maxTop = math.max(minTop, maxBottom - snackbarHeight);

    final belowTop = anchorRect.bottom + _anchorGap;
    final spaceBelow = maxBottom - belowTop;
    final placeAbove = snackbarHeight > spaceBelow;

    final double top = placeAbove
        ? anchorRect.top - _anchorGap - snackbarHeight
        : belowTop;

    return (
      top: top.clamp(minTop, maxTop),
      left: left,
      width: width,
    );
  }
}

final class _AnchoredSnackBarLayer {
  _AnchoredSnackBarLayer._();

  static OverlayEntry? _entry;
  static Timer? _dismissTimer;

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _entry?.remove();
    _entry = null;
  }

  static bool show({
    required BuildContext context,
    required Widget content,
    required Duration duration,
    required Rect anchorRect,
  }) {
    final overlayState = Overlay.maybeOf(context, rootOverlay: true);
    if (overlayState == null) return false;

    dismiss();

    _entry = OverlayEntry(
      builder: (overlayContext) {
        return _AnchoredSnackBarPositioned(
          anchorRect: anchorRect,
          child: content,
        );
      },
    );

    overlayState.insert(_entry!);
    _dismissTimer = Timer(duration, dismiss);
    return true;
  }
}

/// Measures snackbar height after layout so positioning can flip above the
/// anchor when the full content would not fit below.
class _AnchoredSnackBarPositioned extends StatefulWidget {
  const _AnchoredSnackBarPositioned({
    required this.anchorRect,
    required this.child,
  });

  final Rect anchorRect;
  final Widget child;

  @override
  State<_AnchoredSnackBarPositioned> createState() =>
      _AnchoredSnackBarPositionedState();
}

class _AnchoredSnackBarPositionedState extends State<_AnchoredSnackBarPositioned> {
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
          child: KeyedSubtree(
            key: _measureKey,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

extension CustomSnackBarExtension on BuildContext {
  void showSuccess(
    String message, {
    String? title,
    Duration? duration,
    BuildContext? anchor,
  }) =>
      CustomSnackBarPresenter.show(
        this,
        variant: CustomSnackBarVariant.success,
        message: message,
        title: title,
        duration: duration,
        anchor: anchor,
      );

  void showError(
    String message, {
    String? title,
    Duration? duration,
    BuildContext? anchor,
  }) =>
      CustomSnackBarPresenter.show(
        this,
        variant: CustomSnackBarVariant.error,
        message: message,
        title: title,
        duration: duration,
        anchor: anchor,
      );

  void showWarning(
    String message, {
    String? title,
    Duration? duration,
    BuildContext? anchor,
  }) =>
      CustomSnackBarPresenter.show(
        this,
        variant: CustomSnackBarVariant.warning,
        message: message,
        title: title,
        duration: duration,
        anchor: anchor,
      );

  void showInfo(
    String message, {
    String? title,
    Duration? duration,
    BuildContext? anchor,
  }) =>
      CustomSnackBarPresenter.show(
        this,
        variant: CustomSnackBarVariant.info,
        message: message,
        title: title,
        duration: duration,
        anchor: anchor,
      );

  /// Plain [SnackBar] (e.g. with [SnackBarAction]) via the nearest scaffold messenger.
  void showSnackBar(SnackBar snackBar) {
    _AnchoredSnackBarLayer.dismiss();
    final messenger = ScaffoldMessenger.maybeOf(this);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(snackBar);
  }

  void dismissSnackBar() => CustomSnackBarPresenter.dismiss(this);
}

class CustomSnackBarWidget extends StatelessWidget {
  final CustomSnackBarVariant variant;
  final String message;
  final String? title;
  final VoidCallback? onClose;

  const CustomSnackBarWidget({
    super.key,
    required this.variant,
    required this.message,
    this.title,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tone = variant.color(context);
    final ec = context.colors;

    final surface = ec.surface;
    final text = ec.textPrimary;
    final subText = ec.textMuted;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withOpacity(isDark ? 0.35 : 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tone.withOpacity(isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TraqIcon(variant.iconAsset, color: tone, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null && title!.trim().isNotEmpty) ...[
                    Text(
                      title!.trim(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: text,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: title == null ? text : subText,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onClose,
              icon: TraqIcon(AppAssets.iconX, size: 18, color: subText.withOpacity(0.9)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
