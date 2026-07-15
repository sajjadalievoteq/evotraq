import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';

abstract final class AggregationEventHierarchyUtils {
  static Widget actionIcon(String action) {
    switch (action) {
      case 'ADD':
        return TraqIcon(AppAssets.iconPlus, color: Colors.green);
      case 'DELETE':
        return TraqIcon(AppAssets.iconMinus, color: Colors.red);
      case 'OBSERVE':
        return TraqIcon(AppAssets.iconEye, color: Colors.blue);
      default:
        return TraqIcon(NavIcons.epcisEvents);
    }
  }
}
