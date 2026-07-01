import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/shared/hierarchy/utils/hierarchy_epc_utils.dart';

/// Single entry point for opening [HierarchyScreen] from any operation screen.
void openHierarchyScreen(
  BuildContext context, {
  required String epc,
  required String title,
}) {
  final normalized = normalizeHierarchyEpc(epc);
  context.go(
    '${Constants.hierarchyRoute}'
    '?rootEpc=${Uri.encodeComponent(normalized)}'
    '&title=${Uri.encodeComponent(title)}',
  );
}
