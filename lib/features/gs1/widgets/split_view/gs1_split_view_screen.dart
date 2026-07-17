import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_split_layout.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class Gs1SplitViewScreen<TCubit extends StateStreamable<TState>, TState>
    extends StatefulWidget {
  const Gs1SplitViewScreen({
    super.key,
    required this.appBarTitle,
    required this.fabHeroTag,
    required this.fabAddTooltip,
    required this.fabCloseTooltip,
    required this.createHeaderText,
    required this.closeCreateTooltip,
    required this.emptyNoMatchText,
    required this.listenWhenListChanged,
    required this.idsFromState,
    required this.createdIdFromState,
    required this.isEmptyNoMatch,
    required this.listBuilder,
    required this.detailViewBuilder,
    this.detailCreateBuilder,
    required this.detailAwaitBuilder,
    this.fabNavigateRoute,
    this.isListLoading,
    this.showFloatingActionButton = true,
  }) : assert(
          fabNavigateRoute != null || detailCreateBuilder != null,
          'detailCreateBuilder is required when fabNavigateRoute is not set',
        );

  final String appBarTitle;

  final String fabHeroTag;
  final String fabAddTooltip;
  final String fabCloseTooltip;

  final String? fabNavigateRoute;

  final String createHeaderText;
  final String closeCreateTooltip;
  final String emptyNoMatchText;

  final bool Function(TState previous, TState current) listenWhenListChanged;
  final Iterable<String>? Function(TState state) idsFromState;
  final String? Function(TState state) createdIdFromState;
  final bool Function(TState state) isEmptyNoMatch;

  final Widget Function(
    BuildContext context, {
    required String? selectedId,
    required ValueChanged<String> onSelect,
    required void Function(VoidCallback fn) bindRefresh,
    required VoidCallback onRequestCreate,
  }) listBuilder;

  final Widget Function(BuildContext context, String id) detailViewBuilder;

  final Widget Function(BuildContext context, VoidCallback onEmbeddedActionSuccess)?
      detailCreateBuilder;

  /// Await / empty detail pane. [listLoading] is true while the master list is
  /// loading (only when [isListLoading] selector is provided).
  final Widget Function(BuildContext context, {required bool listLoading})
      detailAwaitBuilder;

  /// Optional: when provided, drives [detailAwaitBuilder]'s `listLoading` and
  /// shows the await pane (skeleton) while the list is loading.
  final bool Function(TState state)? isListLoading;
  final bool showFloatingActionButton;

  @override
  State<Gs1SplitViewScreen<TCubit, TState>> createState() =>
      _Gs1SplitViewScreenState<TCubit, TState>();
}

class _Gs1SplitViewScreenState<TCubit extends StateStreamable<TState>, TState>
    extends State<Gs1SplitViewScreen<TCubit, TState>> {
  String? _selectedId;
  bool _isCreateMode = false;
  VoidCallback? _refreshList;

  bool get _useEmbeddedCreate => widget.fabNavigateRoute == null;

  void _toggleFab() {
    setState(() => _isCreateMode = !_isCreateMode);
  }

  void _onFabPressed() {
    final route = widget.fabNavigateRoute;
    if (route != null) {
      context.go(route);
      return;
    }
    _toggleFab();
  }

  void _onRequestCreate() {
    final route = widget.fabNavigateRoute;
    if (route != null) {
      context.go(route);
      return;
    }
    setState(() => _isCreateMode = true);
  }

  void _onEmbeddedCreateSuccess() {
    final cubit = context.read<TCubit>();
    final state = cubit.state;
    final created = widget.createdIdFromState(state);
    setState(() {
      _isCreateMode = false;
      if (created != null) {
        _selectedId = created;
      }
    });
    _refreshList?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TraqAppBar(context, title: Text(widget.appBarTitle)),
      drawer: const AppDrawer(),
      floatingActionButton: widget.showFloatingActionButton
          ? FloatingActionButton(
              heroTag: widget.fabHeroTag,
              onPressed: _onFabPressed,
              tooltip: _useEmbeddedCreate && _isCreateMode
                  ? widget.fabCloseTooltip
                  : widget.fabAddTooltip,
              child: TraqIcon(
                _useEmbeddedCreate && _isCreateMode
                    ? AppAssets.iconX
                    : AppAssets.iconPlus,
                color: Colors.white,
              ),
            )
          : null,
      body: BlocListener<TCubit, TState>(
        listenWhen: widget.listenWhenListChanged,
        listener: (context, state) {
          if (_isCreateMode) return;
          final ids = widget.idsFromState(state);
          if (ids == null) return;
          final list = ids.toList(growable: false);

          if (list.isEmpty) {
            if (_selectedId != null) setState(() => _selectedId = null);
            return;
          }

          if (_selectedId == null) {
            setState(() => _selectedId = list.first);
            return;
          }

          final stillInResults = list.contains(_selectedId);
          if (!stillInResults) {
            setState(() => _selectedId = list.first);
          }
        },
        child: MasterDetailSplitLayout(
          list: widget.listBuilder(
            context,
            selectedId: _selectedId,
            onSelect: (id) {
              if (id == _selectedId && !_isCreateMode) return;
              setState(() {
                _isCreateMode = false;
                _selectedId = id;
              });
            },
            bindRefresh: (fn) => _refreshList = fn,
            onRequestCreate: _onRequestCreate,
          ),
          detail: _buildRightPane(),
        ),
      ),
    );
  }

  Widget _buildRightPane() {
    final viewPane = BlocBuilder<TCubit, TState>(
      builder: (context, state) {
        final listLoading = widget.isListLoading?.call(state) ?? false;
        if (listLoading) {
          return widget.detailAwaitBuilder(context, listLoading: true);
        }

        if (widget.isEmptyNoMatch(state)) {
          // Empty / filtered-out list: keep the detail pane on the await
          // placeholder (Select a …), never a blank Center().
          return widget.detailAwaitBuilder(context, listLoading: false);
        }

        final ids = widget.idsFromState(state)?.toList(growable: false);
        final effective =
            _selectedId ?? (ids != null && ids.isNotEmpty ? ids.first : null);
        if (effective == null) {
          return widget.detailAwaitBuilder(context, listLoading: false);
        }
        return widget.detailViewBuilder(context, effective);
      },
    );

    if (!_useEmbeddedCreate) {
      return viewPane;
    }

    final createBuilder = widget.detailCreateBuilder!;
    final c = context.colors;
    final webTopInset = kIsWeb ? 12.0 : 0.0;
    final createPane = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          elevation: 2,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(2),
          ),
          color: c.primary,
          child: Padding(
            padding: EdgeInsets.only(
              top: webTopInset,
              left: context.gutter,
              right: context.gutter,
              bottom: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.createHeaderText,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: widget.closeCreateTooltip,
                  color: Colors.white,
                  onPressed: () => setState(() => _isCreateMode = false),
                  icon: TraqIcon(AppAssets.iconX),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: createBuilder(context, _onEmbeddedCreateSuccess),
        ),
      ],
    );

    return IndexedStack(
      index: _isCreateMode ? 1 : 0,
      children: [
        viewPane,
        createPane,
      ],
    );
  }
}
