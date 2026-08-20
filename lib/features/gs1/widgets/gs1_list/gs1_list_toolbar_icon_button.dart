import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_toolbar_constants.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class Gs1ListToolbarIconButton extends StatelessWidget {
  const Gs1ListToolbarIconButton({
    required this.onPressed,
    required this.iconAsset,
    required this.tooltip,
  });

  final VoidCallback onPressed;
  final String iconAsset;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: kGs1ListFieldIconSize,
      icon: TraqIcon(iconAsset, size: kGs1ListFieldIconSize),
      color: kGs1ListToolbarIconColor,
      tooltip: tooltip,
    );
  }
}
