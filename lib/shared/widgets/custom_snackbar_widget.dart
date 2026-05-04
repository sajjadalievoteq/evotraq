import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';

enum CustomSnackBarVariant {
  success(Icons.check_circle_rounded),
  error(Icons.error_rounded),
  warning(Icons.warning_rounded),
  info(Icons.info_rounded);

  final IconData icon;
  const CustomSnackBarVariant(this.icon);

  Color color(BuildContext context) {
    return switch (this) {
      success => AppTheme.successColor,
      error => AppTheme.errorColor,
      warning => AppTheme.warningColor,
      info => AppTheme.infoColor,
    };
  }
}

extension CustomSnackBarExtension on BuildContext {
  void showSuccess(String message, {String? title, Duration? duration}) =>
      _show(CustomSnackBarVariant.success, message, title, duration);

  void showError(String message, {String? title, Duration? duration}) =>
      _show(CustomSnackBarVariant.error, message, title, duration);

  void showWarning(String message, {String? title, Duration? duration}) =>
      _show(CustomSnackBarVariant.warning, message, title, duration);

  void showInfo(String message, {String? title, Duration? duration}) =>
      _show(CustomSnackBarVariant.info, message, title, duration);

  /// Plain [SnackBar] (e.g. with [SnackBarAction]) via the nearest scaffold messenger.
  void showSnackBar(SnackBar snackBar) {
    final messenger = ScaffoldMessenger.maybeOf(this);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(snackBar);
  }

  void dismissSnackBar() {
    ScaffoldMessenger.maybeOf(this)?.hideCurrentSnackBar();
  }

  void _show(CustomSnackBarVariant variant, String message, String? title, Duration? duration) {
    final messenger = ScaffoldMessenger.maybeOf(this);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: CustomSnackBarWidget(
          variant: variant,
          title: title,
          message: message,
          onClose: messenger.hideCurrentSnackBar,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }
}

class CustomSnackBarWidget extends StatelessWidget {
  final CustomSnackBarVariant variant;
  final String message;
  final String? title;
  final VoidCallback? onClose;

  const CustomSnackBarWidget({
    super.key,
    required this.variant,
    required this.message,
    this.title,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tone = variant.color(context);

    final surface = isDark ? AppTheme.cardColorDark : AppTheme.cardColor;
    final text = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final subText = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withOpacity(isDark ? 0.35 : 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tone.withOpacity(isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(variant.icon, color: tone, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null && title!.trim().isNotEmpty) ...[
                    Text(
                      title!.trim(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: text,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: title == null ? text : subText,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, size: 18),
              color: subText.withOpacity(0.9),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
