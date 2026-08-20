import 'dart:async';
import 'package:traqtrace_app/core/widgets/anchored_snack_bar_positioned.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_content.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';

import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_types.dart';

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

class CustomSnackBarPresenter {
  CustomSnackBarPresenter._();

  static const Duration _defaultDuration = Duration(seconds: 4);
  static const double _edgePadding = 16;

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

    final content = CustomSnackbarContent(
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
    final anchored =
        anchorRect != null &&
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
        return AnchoredSnackBarPositioned(
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

extension CustomSnackBarExtension on BuildContext {
  void showSuccess(
    String message, {
    String? title,
    Duration? duration,
    BuildContext? anchor,
  }) => CustomSnackBarPresenter.show(
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
  }) => CustomSnackBarPresenter.show(
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
  }) => CustomSnackBarPresenter.show(
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
  }) => CustomSnackBarPresenter.show(
    this,
    variant: CustomSnackBarVariant.info,
    message: message,
    title: title,
    duration: duration,
    anchor: anchor,
  );

  void showSnackBar(SnackBar snackBar) {
    _AnchoredSnackBarLayer.dismiss();
    final messenger = ScaffoldMessenger.maybeOf(this);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(snackBar);
  }

  void dismissSnackBar() => CustomSnackBarPresenter.dismiss(this);
}
