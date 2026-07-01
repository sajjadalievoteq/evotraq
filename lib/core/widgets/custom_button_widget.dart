import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class CustomButtonWidget extends StatelessWidget {
  const CustomButtonWidget({
    super.key,
    required this.onTap,
    this.title,
    this.icon,
    this.iconAsset,
    this.iconWidget,
    this.iconOnly,
    this.height = TraqSpacing.buttonH,
    this.backgroundColor,
    this.foregroundColor,
    this.minimumWidth,
    this.tooltip,
  });

  final VoidCallback? onTap;
  final String? title;
  final IconData? icon;
  final String? iconAsset;
  final Widget? iconWidget;

  /// When true, renders an icon-only button.
  final bool? iconOnly;

  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? minimumWidth;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolvedIconOnly = iconOnly ?? false;
    final hasIcon = icon != null || iconAsset != null || iconWidget != null;
    final hasTitle = (title ?? '').trim().isNotEmpty;

    final buttonWidth = minimumWidth ?? (resolvedIconOnly ? height : null);
    final resolvedBackgroundColor = backgroundColor ?? scheme.primary;
    final resolvedForegroundColor = foregroundColor ?? scheme.onPrimary;

    assert(
      resolvedIconOnly ? hasIcon : hasTitle,
      'CustomButtonWidget requires `icon` or `iconWidget` when iconOnly=true, otherwise it requires a non-empty `title`.',
    );

    final resolvedIconWidget = iconWidget ??
        (iconAsset != null
            ? TraqIcon(iconAsset!, color: resolvedForegroundColor)
            : icon != null
                ? Icon(icon, color: resolvedForegroundColor)
                : null);

    final button = SizedBox(
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: resolvedBackgroundColor,
          foregroundColor: resolvedForegroundColor,
          minimumSize: Size(buttonWidth ?? 0, height),
        ),
        child: resolvedIconOnly
            ? SizedBox.expand(
                child: Center(child: resolvedIconWidget!),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasIcon) ...[
                    resolvedIconWidget!,
                    const SizedBox(width: 8),
                  ],
                  Text(title!.trim()),
                ],
              ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
