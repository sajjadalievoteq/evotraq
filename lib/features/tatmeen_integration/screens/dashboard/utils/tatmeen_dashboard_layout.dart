import 'package:flutter/widgets.dart';

double tatmeenKpiCardWidth(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= 1200) return (width - 520) / 4;
  if (width >= 760) return (width - 460) / 2;
  return double.infinity;
}
