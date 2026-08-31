import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/error_state/app_error_state.dart';

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
    return AppErrorState(
      title: 'Unable to load SSCC',
      message: errorMessage ?? SsccUiConstants.errorGeneric,
      iconAsset: NavIcons.sscc,
      onRetry: onRetry,
      retryLabel: 'Retry',
    );
  }
}
