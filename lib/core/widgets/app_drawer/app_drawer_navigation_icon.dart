import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class AppDrawerNavigationIcon extends StatelessWidget {
  const AppDrawerNavigationIcon(this.asset, {this.size = 16, super.key});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) => TraqIcon(asset, size: size);
}
