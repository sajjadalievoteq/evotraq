import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class SsccDetailErrorPane extends StatelessWidget {
  const SsccDetailErrorPane({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TraqIcon(AppAssets.iconAlert, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? SsccUiConstants.errorGeneric,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: onRetry,
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
