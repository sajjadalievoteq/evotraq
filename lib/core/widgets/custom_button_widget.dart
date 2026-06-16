import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class CustomButtonWidget extends StatelessWidget {
  const CustomButtonWidget({
    super.key,
    required this.onTap,
    this.title,
    this.icon,
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
  final Widget? iconWidget;

  /// When true, renders an icon-only button.
  final bool? iconOnly;

  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? minimumWidth;
  final String? tooltip;

  // height default matches TraqSpacing.buttonH = 36

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolvedIconOnly = iconOnly ?? false;
    final hasIcon = icon != null || iconWidget != null;
    final hasTitle = (title ?? '').trim().isNotEmpty;

    final buttonWidth = minimumWidth ?? (resolvedIconOnly ? height : null);
    final resolvedBackgroundColor = backgroundColor ?? scheme.primary;
    final resolvedForegroundColor = foregroundColor ?? scheme.onPrimary;

    assert(
    resolvedIconOnly ? hasIcon : hasTitle,
    'CustomButtonWidget requires `icon` or `iconWidget` when iconOnly=true, otherwise it requires a non-empty `title`.',
    );

    final resolvedIconWidget = iconWidget ?? (icon != null ? Icon(icon) : null);

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
            ? const SizedBox.expand(
                child: Center(
                  child: Icon(Icons.circle), // placeholder, replaced below
                ),
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

    final finalButton = resolvedIconOnly
        ? SizedBox(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: resolvedBackgroundColor,
                foregroundColor: resolvedForegroundColor,
                minimumSize: Size(buttonWidth ?? 0, height),
              ),
              child: SizedBox.expand(
                child: Center(child: resolvedIconWidget),
              ),
            ),
          )
        : button;

    if (tooltip != null && tooltip!.trim().isNotEmpty) {
      return Tooltip(
        message: tooltip!.trim(),
        child: finalButton,
      );
    }

    return finalButton;
  }
}