import 'package:flutter/material.dart';

/// Wraps a tab's content so it survives being scrolled off-screen inside a
/// [TabBarView], letting each dashboard tab keep its already-fetched data
/// instead of rebuilding/refetching every time the user switches back to it.
class KeepAliveTabView extends StatefulWidget {
  final Widget child;

  const KeepAliveTabView({super.key, required this.child});

  @override
  State<KeepAliveTabView> createState() => _KeepAliveTabViewState();
}

class _KeepAliveTabViewState extends State<KeepAliveTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
