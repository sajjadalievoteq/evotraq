import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Lightweight local replacement for common `flutter_screenutil` usage.
///
/// Usage:
/// - Wrap the app with [AppScreenUtilInit] once.
/// - Then use extensions like: `16.w`, `12.h`, `14.sp`, `8.r`.
class AppScreenUtil {
  AppScreenUtil._();

  static Size _designSize = const Size(390, 844);
  static Size _screenSize = _designSize;
  static double _textScaleFactor = 1.0;
  static bool _initialized = false;
  static AppScreenDeviceType _deviceType = AppScreenDeviceType.mobile;

  static void configure({
    required Size screenSize,
    required Size designSize,
    double textScaleFactor = 1.0,
  }) {
    _screenSize = screenSize;
    _designSize = designSize;
    _textScaleFactor = textScaleFactor;
    _initialized = true;
  }

  static bool get isInitialized => _initialized;
  static AppScreenDeviceType get deviceType => _deviceType;
  static Size get designSize => _designSize;

  static Size get screenSize => _screenSize;
  static double get screenWidth => _screenSize.width;
  static double get screenHeight => _screenSize.height;
  static double get scaleWidth => _screenSize.width / _designSize.width;
  static double get scaleHeight => _screenSize.height / _designSize.height;
  static double get scaleLayout => math.min(scaleWidth, scaleHeight);
  static double get scaleText {
    switch (_deviceType) {
      case AppScreenDeviceType.web:
      case AppScreenDeviceType.desktop:
        return scaleWidth;
      case AppScreenDeviceType.mobile:
      case AppScreenDeviceType.tablet:
        return scaleLayout;
    }
  }

  static double setWidth(num width) => width.toDouble() * scaleWidth;
  static double setHeight(num height) => height.toDouble() * scaleHeight;
  static double radius(num value) => value.toDouble() * scaleLayout;
  static double setSp(num fontSize, {bool respectSystemTextScale = false}) {
    final scaled = fontSize.toDouble() * scaleText;
    return respectSystemTextScale ? scaled * _textScaleFactor : scaled;
  }

  static double widthPercent(num percent) =>
      _screenSize.width * (percent.toDouble() / 100);

  static double heightPercent(num percent) =>
      _screenSize.height * (percent.toDouble() / 100);
}

enum AppScreenDeviceType { mobile, tablet, desktop, web }

class AppScreenUtilInit extends StatelessWidget {
  final Widget child;
  final Size? mobileDesignSize;
  final Size? tabletDesignSize;
  final Size? desktopDesignSize;
  final Size? webDesignSize;
  final bool autoDetectDeviceType;

  const AppScreenUtilInit({
    super.key,
    required this.child,
    this.mobileDesignSize,
    this.tabletDesignSize,
    this.desktopDesignSize,
    this.webDesignSize,
    this.autoDetectDeviceType = true,
  });

  static const Size _defaultMobileDesign = Size(390, 844);
  static const Size _defaultTabletDesign = Size(768, 1024);
  static const Size _defaultDesktopDesign = Size(1440, 900);
  static const Size _defaultWebDesign = Size(1440, 900);

  AppScreenDeviceType _resolveDeviceType(Size size) {
    if (!autoDetectDeviceType) {
      return AppScreenDeviceType.mobile;
    }

    if (kIsWeb) {
      return AppScreenDeviceType.web;
    }

    final longestSide = math.max(size.width, size.height);
    if (longestSide >= 1200) {
      return AppScreenDeviceType.desktop;
    }

    final shortestSide = math.min(size.width, size.height);
    if (shortestSide >= 600) {
      return AppScreenDeviceType.tablet;
    }

    return AppScreenDeviceType.mobile;
  }

  Size _resolveDesignSize(AppScreenDeviceType deviceType) {
    switch (deviceType) {
      case AppScreenDeviceType.mobile:
        return mobileDesignSize ?? _defaultMobileDesign;
      case AppScreenDeviceType.tablet:
        return tabletDesignSize ?? _defaultTabletDesign;
      case AppScreenDeviceType.desktop:
        return desktopDesignSize ?? _defaultDesktopDesign;
      case AppScreenDeviceType.web:
        return webDesignSize ?? _defaultWebDesign;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mediaQuery.size.width;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : mediaQuery.size.height;
        final screenSize = Size(width, height);
        final deviceType = _resolveDeviceType(screenSize);
        final resolvedDesignSize = _resolveDesignSize(deviceType);

        AppScreenUtil._deviceType = deviceType;
        AppScreenUtil.configure(
          screenSize: screenSize,
          designSize: resolvedDesignSize,
          textScaleFactor: mediaQuery.textScaler.scale(1),
        );
        return child;
      },
    );
  }
}

extension AppScreenUtilNumExtension on num {
  double get w => AppScreenUtil.setWidth(this);
  double get h => AppScreenUtil.setHeight(this);
  double get sp => AppScreenUtil.setSp(this);
  double get r => AppScreenUtil.radius(this);

  /// Percentage of current screen width. Example: `50.sw`.
  double get sw => AppScreenUtil.widthPercent(this);

  /// Percentage of current screen height. Example: `50.sh`.
  double get sh => AppScreenUtil.heightPercent(this);
}

