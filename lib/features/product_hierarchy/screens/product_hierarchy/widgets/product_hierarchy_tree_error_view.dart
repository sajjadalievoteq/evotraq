import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/error_state/app_error_state.dart';

class ProductHierarchyTreeErrorView extends StatelessWidget {
  const ProductHierarchyTreeErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      iconAsset: NavIcons.aggregationHierarchy,
      title: 'Unable to load hierarchy',
      message: message,
    );
  }
}
