import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

Future<void> precacheSplashAssets(BuildContext context) {
  return Future.wait([
    precacheImage(const AssetImage(AppAssets.traqBackgroundPng), context),
    precacheImage(const AssetImage(AppAssets.logo), context),
  ]);
}
