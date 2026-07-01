import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CommissioningDetailAwaitingSelection extends StatelessWidget {
  const CommissioningDetailAwaitingSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TraqIcon(AppAssets.iconDownload, color: Colors.grey[300], size: 80),
          const SizedBox(height: 16),
          Text(
            'Select an operation to view details',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
