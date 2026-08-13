import 'package:flutter/material.dart';

/// Like [IndexedStack], but children are built only when first selected and then
/// kept alive so section state (cubits, scroll, filters) is preserved.
class LazyIndexedStack extends StatefulWidget {
  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.sizing = StackFit.loose,
  });

  final int index;
  final List<Widget> children;
  final AlignmentGeometry alignment;
  final StackFit sizing;

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late List<bool> _activated;

  @override
  void initState() {
    super.initState();
    _activated = List<bool>.filled(widget.children.length, false, growable: true);
    _activate(widget.index);
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != _activated.length) {
      // Replace the list — never [List.clear] a [List.filled] fixed-length list
      // (throws UnsupportedError: set length on web/JS).
      final next = List<bool>.filled(widget.children.length, false, growable: true);
      for (var i = 0; i < next.length && i < _activated.length; i++) {
        next[i] = _activated[i];
      }
      _activated = next;
    }
    _activate(widget.index);
  }

  void _activate(int index) {
    if (index < 0 || index >= _activated.length) return;
    if (!_activated[index]) {
      _activated[index] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      for (var i = 0; i < widget.children.length; i++)
        if (_activated[i]) widget.children[i] else const SizedBox.shrink(),
    ];

    return IndexedStack(
      index: widget.index.clamp(0, widget.children.length - 1),
      alignment: widget.alignment,
      sizing: widget.sizing,
      children: children,
    );
  }
}
