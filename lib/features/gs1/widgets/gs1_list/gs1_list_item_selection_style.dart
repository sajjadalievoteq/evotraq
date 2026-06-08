import 'package:flutter/material.dart';

/// Selected list-row styling aligned with [CommissioningOperationListCard].
abstract final class Gs1ListItemSelectionStyle {
  static Color? cardBackground(BuildContext context, bool isSelected) =>
      isSelected ? Theme.of(context).colorScheme.primary : null;

  static Color? primaryTextColor(bool isSelected) =>
      isSelected ? Colors.white : null;

  static Color mutedColor(bool isSelected, Color fallback) =>
      isSelected ? Colors.white70 : fallback;
}
