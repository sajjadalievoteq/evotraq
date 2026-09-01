import 'dart:async';

import 'package:flutter/material.dart';

abstract final class TraqAnimationManager {
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.of(context).disableAnimations;

  static Duration durationOf(BuildContext context, Duration normal) =>
      reduceMotion(context) ? Duration.zero : normal;

  static Future<bool> waitUntilReadyToPlay(BuildContext context) async {
    final binding = WidgetsBinding.instance;
    await binding.waitUntilFirstFrameRasterized;
    if (!context.mounted) return false;

    await binding.endOfFrame;
    if (!context.mounted) return false;

    if (!TickerMode.of(context)) return false;

    final route = ModalRoute.of(context);
    final animation = route?.animation;
    if (animation != null &&
        animation.status != AnimationStatus.completed &&
        animation.status != AnimationStatus.dismissed) {
      await _waitForAnimationSettled(animation, () => context.mounted);
      if (!context.mounted) return false;
    }

    if (route != null && !route.isCurrent) return false;
    return TickerMode.of(context);
  }

  static Future<void> _waitForAnimationSettled(
    Animation<double> animation,
    bool Function() isMounted,
  ) {
    if (animation.status == AnimationStatus.completed ||
        animation.status == AnimationStatus.dismissed) {
      return Future.value();
    }

    final completer = Completer<void>();
    late final VoidCallback tickListener;
    late final AnimationStatusListener statusListener;

    void finish() {
      animation.removeStatusListener(statusListener);
      animation.removeListener(tickListener);
      if (!completer.isCompleted) completer.complete();
    }

    statusListener = (status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        finish();
      }
    };
    tickListener = () {
      if (!isMounted()) finish();
    };

    animation.addStatusListener(statusListener);
    animation.addListener(tickListener);

    if (animation.status == AnimationStatus.completed ||
        animation.status == AnimationStatus.dismissed ||
        !isMounted()) {
      finish();
    }

    return completer.future;
  }
}

mixin TraqDeferredPlay<T extends StatefulWidget> on State<T> {
  bool _traqPlayStarted = false;
  bool _traqPlayQueued = false;

  bool get traqPlayStarted => _traqPlayStarted;

  void traqMarkPlayed() => _traqPlayStarted = true;

  void traqSchedulePlay(VoidCallback play, {bool defer = true}) {
    if (_traqPlayStarted || _traqPlayQueued) return;
    _traqPlayQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (defer) {
        unawaited(_runPlay(play));
      } else {
        _traqPlayQueued = false;
        if (mounted && !_traqPlayStarted) play();
      }
    });
  }

  Future<void> _runPlay(VoidCallback play) async {
    final ready = await TraqAnimationManager.waitUntilReadyToPlay(context);
    _traqPlayQueued = false;
    if (!ready || !mounted || _traqPlayStarted) return;
    play();
  }
}