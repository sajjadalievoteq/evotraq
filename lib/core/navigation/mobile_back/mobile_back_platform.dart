import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// True only for native iOS/Android app builds (never web or desktop).
bool get isIosOrAndroidApp {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
}
