import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  const CustomButtonWidget({
    super.key,
    required this.onTap,
    this.title,
    this.icon,
    this.iconOnly,
    this.height = 50,
    this.backgroundColor,
    this.foregroundColor,
    this.minimumWidth,
    this.tooltip,
  });

  final VoidCallback? onTap;
  final String? title;
  final IconData? icon;

  /// When true, renders an icon-only button.
  final bool? iconOnly;

  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? minimumWidth;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final resolvedIconOnly = iconOnly ?? false;
    final hasIcon = icon != null;
    final hasTitle = (title ?? '').trim().isNotEmpty;

    final buttonWidth = minimumWidth ?? (resolvedIconOnly ? height : null);

    assert(
    resolvedIconOnly ? hasIcon : hasTitle,
    'CustomButtonWidget requires `icon` when iconOnly=true, otherwise it requires a non-empty `title`.',
    );

    final button = SizedBox(
      height: height,
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          minimumSize: Size(buttonWidth ?? 0, height),

          // ✅ FIX: remove default padding & force perfect centering
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
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
              Icon(icon),
              const SizedBox(width: 8),
            ],
            Text(title!.trim()),
          ],
        ),
      ),
    );

    // Replace placeholder icon safely (avoids const issues)
    final finalButton = resolvedIconOnly
        ? SizedBox(
      height: height,
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          minimumSize: Size(buttonWidth ?? 0, height),
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
        ),
        child: SizedBox.expand(
          child: Center(
            child: Icon(icon),
          ),
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