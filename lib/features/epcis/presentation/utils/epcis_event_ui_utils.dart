import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

abstract final class EpcisEventUiUtils {
  static Color eventTypeColor(String eventType) {
    return AppColorMapper.eventType(
      eventType,
      scheme: AppEventColorScheme.epcis,
    );
  }

  static Color supplyChainStatusColor(String status) {
    return AppColorMapper.supplyChainStatus(status);
  }

  static Color supplyChainNodeColor(String? type) {
    switch (type) {
      case 'manufacturer':
        return Colors.blue;
      case 'distributor':
        return Colors.green;
      case 'retailer':
        return Colors.orange;
      case 'warehouse':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
