import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class PartitionArchiveTab extends StatelessWidget {
  const PartitionArchiveTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TraqIcon(AppAssets.iconDownload, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Archive Management'),
          Text('Feature implementation in progress'),
        ],
      ),
    );
  }
}
