import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

abstract final class EpcisEventUiUtils {
  static Color eventTypeColor(BuildContext context, String eventType) {
    return AppColorMapper.eventTypeColor(
      context,
      eventType,
      scheme: AppEventColorScheme.epcis,
    );
  }

  static Color supplyChainStatusColor(BuildContext context, String status) {
    return AppColorMapper.supplyChainStatus(context, status);
  }

  static Color supplyChainNodeColor(BuildContext context, String? type) {
    return AppColorMapper.supplyChainNodeColor(context, type);
  }

  static String supplyChainNodeIcon(String? type) {
    switch (type) {
      case 'manufacturer':
        return AppAssets.iconFactory;
      case 'distributor':
        return AppAssets.iconTruck;
      case 'retailer':
        return AppAssets.iconStore;
      case 'warehouse':
        return AppAssets.iconWarehouse;
      default:
        return AppAssets.iconBusiness;
    }
  }
}
