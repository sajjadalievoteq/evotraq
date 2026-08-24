import 'package:flutter/widgets.dart';

double tatmeenKpiCardWidth(BuildContext context) {
  final screenWidth = MediaQuery.sizeOf(context).width;

  const horizontalPadding = 80.0; // 40 on each side
  const cardGap = 24.0;

  if (screenWidth >= 1200) {
    return (screenWidth - horizontalPadding - (cardGap * 3)) / 4;
  }
  if (screenWidth >= 760) {
    return (screenWidth - horizontalPadding - cardGap) / 2;
  }
  return double.infinity;
}