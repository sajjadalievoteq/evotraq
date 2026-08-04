import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ConsistencyJobStatusIcon extends StatelessWidget {
  const ConsistencyJobStatusIcon(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return TraqIcon(
          AppAssets.iconCheck,
          color: AppColorMapper.successColor(context),
        );
      case 'RUNNING':
        return TraqIcon(
          AppAssets.iconArrowR,
          color: AppColorMapper.infoColor(context),
        );
      case 'FAILED':
        return TraqIcon(
          AppAssets.iconAlert,
          color: AppColorMapper.errorColor(context),
        );
      default:
        return TraqIcon(AppAssets.iconInfo, color: Colors.grey);
    }
  }
}
