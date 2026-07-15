import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Builds [builder] only once the section intersects the scroll viewport
/// (plus a cache ahead), or immediately when [forceMount]/[eager] is true.
///
/// Values must live in screen-owned state so unmounting never loses input.
/// Do not use [AutomaticKeepAliveClientMixin] — ownership is the keep-alive.
class Gs1LazyViewportSection extends StatefulWidget {
  const Gs1LazyViewportSection({
    super.key,
    required this.builder,
    this.forceMount = false,
    this.eager = false,
    this.placeholderHeight = 220,
    this.cacheExtent = 480,
  });

  final WidgetBuilder builder;
  final bool forceMount;
  final bool eager;
  final double placeholderHeight;
  final double cacheExtent;

  @override
  State<Gs1LazyViewportSection> createState() => _Gs1LazyViewportSectionState();
}

class _Gs1LazyViewportSectionState extends State<Gs1LazyViewportSection> {
  bool _mountedChild = false;
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    if (widget.forceMount || widget.eager) {
      _mountedChild = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reattachScrollListener();
  }

  @override
  void didUpdateWidget(covariant Gs1LazyViewportSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_mountedChild && (widget.forceMount || widget.eager)) {
      _mountedChild = true;
      _detachScrollListener();
    }
  }

  @override
  void dispose() {
    _detachScrollListener();
    super.dispose();
  }

  void _reattachScrollListener() {
    if (_mountedChild) return;
    final next = Scrollable.maybeOf(context)?.position;
    if (identical(next, _scrollPosition)) return;
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = next;
    _scrollPosition?.addListener(_onScroll);
  }

  void _detachScrollListener() {
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = null;
  }

  void _onScroll() => _tryMount();

  bool _isInViewport(RenderBox box) {
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) return true;

    final revealTop = viewport.getOffsetToReveal(box, 0.0).offset;
    final revealBottom = viewport.getOffsetToReveal(box, 1.0).offset;
    final scrollOffset = _scrollPosition?.pixels ?? 0.0;
    final vpHeight = _viewportHeight(viewport);

    final visibleTop = scrollOffset - widget.cacheExtent;
    final visibleBottom = scrollOffset + vpHeight + widget.cacheExtent;
    return revealBottom >= visibleTop && revealTop <= visibleBottom;
  }

  double _viewportHeight(RenderAbstractViewport viewport) {
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      final box = scrollable.context.findRenderObject();
      if (box is RenderBox && box.hasSize) {
        return box.size.height;
      }
    }
    return MediaQuery.sizeOf(context).height;
  }

  void _tryMount() {
    if (_mountedChild || !mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    if (_isInViewport(box)) {
      _detachScrollListener();
      setState(() => _mountedChild = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mountedChild) {
      return widget.builder(context);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _mountedChild) return;
      _reattachScrollListener();
      _tryMount();
    });

    return SizedBox(
      height: widget.placeholderHeight,
      width: double.infinity,
    );
  }
}
