import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';

class ProductHierarchyTreeErrorView extends StatelessWidget {
  const ProductHierarchyTreeErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      iconAsset: NavIcons.aggregationHierarchy,
      title: 'Unable to load hierarchy',
      subtitle: message,
    );
  }
}
