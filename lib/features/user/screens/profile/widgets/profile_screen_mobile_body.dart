import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';

class ProfileScreenMobileBody extends StatelessWidget {
  const ProfileScreenMobileBody({
    super.key,
    required this.tabController,
    required this.infoModule,
    required this.securityModule,
    required this.preferencesModule,
  });

  final TabController tabController;
  final Widget infoModule;
  final Widget securityModule;
  final Widget preferencesModule;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _KeepAliveTab(
          child: Padding(
            padding: ResponsiveUtils.paddingAll(context),
            child: infoModule,
          ),
        ),
        _KeepAliveTab(
          child: Padding(
            padding: ResponsiveUtils.paddingAll(context),
            child: securityModule,
          ),
        ),
        _KeepAliveTab(
          child: Padding(
            padding: ResponsiveUtils.paddingAll(context),
            child: preferencesModule,
          ),
        ),
      ],
    );
  }
}

class _KeepAliveTab extends StatefulWidget {
  const _KeepAliveTab({required this.child});

  final Widget child;

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
