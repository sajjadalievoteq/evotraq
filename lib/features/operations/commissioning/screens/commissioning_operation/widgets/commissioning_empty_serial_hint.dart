import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class CommissioningEmptySerialHint extends StatelessWidget {
  const CommissioningEmptySerialHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TraqIcon(AppAssets.iconQr, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No serial numbers added yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.55),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan or enter serial numbers to commission',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.45),
                ),
          ),
        ],
      ),
    );
  }
}
