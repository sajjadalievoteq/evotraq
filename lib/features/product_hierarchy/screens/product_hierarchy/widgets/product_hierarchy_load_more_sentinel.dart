import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';

class ProductHierarchyLoadMoreSentinel extends StatefulWidget {
  const ProductHierarchyLoadMoreSentinel({
    super.key,
    required this.isLoading,
    required this.onVisible,
  });
  final bool isLoading;
  final VoidCallback onVisible;

  @override
  State<ProductHierarchyLoadMoreSentinel> createState() =>
      _ProductHierarchyLoadMoreSentinelState();
}

class _ProductHierarchyLoadMoreSentinelState
    extends State<ProductHierarchyLoadMoreSentinel> {
  @override
  void initState() {
    super.initState();
    _scheduleIfIdle();
  }

  @override
  void didUpdateWidget(ProductHierarchyLoadMoreSentinel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading && !widget.isLoading) _scheduleIfIdle();
  }

  void _scheduleIfIdle() {
    if (widget.isLoading) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !widget.isLoading) widget.onVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: TraqSpacing.xs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
