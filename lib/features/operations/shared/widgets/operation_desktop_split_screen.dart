import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_split_layout.dart';

import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class OperationDesktopSplitScreen extends StatefulWidget {
  const OperationDesktopSplitScreen({
    super.key,
    required this.title,
    required this.createRoute,
    required this.listBuilder,
    required this.detailBuilder,
    this.readSelectedFromQuery = true,
    this.fabIconAsset = AppAssets.iconPlus,
  });

  final String title;
  final String createRoute;
  final bool readSelectedFromQuery;
  final String fabIconAsset;

  final Widget Function({
    required bool embedded,
    required String? selectedId,
    required ValueChanged<String> onSelect,
    required ValueChanged<bool> onLoadingChanged,
  }) listBuilder;

  final Widget Function({
    required String? selectedId,
    required bool embedded,
    required bool awaitingSelection,
    required bool listLoading,
  }) detailBuilder;

  @override
  State<OperationDesktopSplitScreen> createState() =>
      _OperationDesktopSplitScreenState();
}

class _OperationDesktopSplitScreenState extends State<OperationDesktopSplitScreen> {
  String? _selectedId;
  bool _isListLoading = true;

  @override
  void initState() {
    super.initState();
    if (!widget.readSelectedFromQuery) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final selected =
          GoRouterState.of(context).uri.queryParameters['selected'];
      if (selected != null && selected.isNotEmpty) {
        setState(() => _selectedId = selected);
      }
    });
  }

  void _onSelect(String id) {
    setState(() => _selectedId = id);
  }

  void _onListLoadingChanged(bool loading) {
    if (_isListLoading == loading) return;
    setState(() => _isListLoading = loading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TraqAppBar(context, title: Text(widget.title)),
      drawer: const AppDrawer(),
      body: MasterDetailSplitLayout(
        list: widget.listBuilder(
          embedded: true,
          selectedId: _selectedId,
          onSelect: _onSelect,
          onLoadingChanged: _onListLoadingChanged,
        ),
        detail: Scaffold(
          primary: false,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.go(widget.createRoute),
            label: TraqIcon(widget.fabIconAsset),
          ),
          body: widget.detailBuilder(
            selectedId: _selectedId,
            embedded: true,
            awaitingSelection: _selectedId == null,
            listLoading: _isListLoading,
          ),
        ),
      ),
    );
  }
}
