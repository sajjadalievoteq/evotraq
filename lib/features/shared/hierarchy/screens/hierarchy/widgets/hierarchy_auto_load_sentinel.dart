import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/shared/hierarchy/screens/hierarchy/widgets/hierarchy_node_tile.dart';

class HierarchyAutoLoadSentinel extends StatefulWidget {
  const HierarchyAutoLoadSentinel({
    super.key,
    required this.depth,
    required this.isLoading,
    required this.onVisible,
  });

  final int depth;
  final bool isLoading;
  final VoidCallback onVisible;

  @override
  State<HierarchyAutoLoadSentinel> createState() =>
      _HierarchyAutoLoadSentinelState();
}

class _HierarchyAutoLoadSentinelState extends State<HierarchyAutoLoadSentinel> {
  @override
  void initState() {
    super.initState();
    if (!widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onVisible();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.depth * HierarchyNodeTile.indentWidth + 32,
        top: 4,
        bottom: 4,
      ),
      child: widget.isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const SizedBox.shrink(),
    );
  }
}
