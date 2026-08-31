import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_route.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_split_layout.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/gs1_split_view_right_pane.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

typedef Gs1SplitCreateRequestHandler = Future<void> Function({
  required void Function({required bool commissionAfterCreate})
  openEmbeddedCreate,
});

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
    this.listRoute,
    this.fabNavigateRoute,
    this.onCreateRequested,
    this.isListLoading,
    this.showFloatingActionButton = true,
  }) : assert(
         fabNavigateRoute != null ||
             detailCreateBuilder != null ||
             onCreateRequested != null,
         'detailCreateBuilder or onCreateRequested is required when '
         'fabNavigateRoute is not set',
       );

  final String appBarTitle;

  final String fabHeroTag;
  final String fabAddTooltip;
  final String fabCloseTooltip;

  final String? fabNavigateRoute;

  final Gs1SplitCreateRequestHandler? onCreateRequested;

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
    required void Function(String id, {bool editing}) onSelect,
    required void Function(VoidCallback fn) bindRefresh,
    required VoidCallback onRequestCreate,
  })
  listBuilder;

  final Widget Function(
    BuildContext context,
    String id, {
    required bool editing,
  })
  detailViewBuilder;

  final String? listRoute;

  final Widget Function(
    BuildContext context,
    VoidCallback onEmbeddedActionSuccess, {
    bool commissionAfterCreate,
  })?
  detailCreateBuilder;

  final Widget Function(BuildContext context, {required bool listLoading})
  detailAwaitBuilder;

  final bool Function(TState state)? isListLoading;
  final bool showFloatingActionButton;

  @override
  State<Gs1SplitViewScreen<TCubit, TState>> createState() =>
      _Gs1SplitViewScreenState<TCubit, TState>();
}

class _Gs1SplitViewScreenState<TCubit extends StateStreamable<TState>, TState>
    extends State<Gs1SplitViewScreen<TCubit, TState>> {
  String? _selectedId;
  bool _detailEditing = false;
  bool _isCreateMode = false;
  bool _embeddedCreateWithCommission = false;
  VoidCallback? _refreshList;

  bool get _useEmbeddedCreate =>
      widget.fabNavigateRoute == null && widget.detailCreateBuilder != null;

  void _toggleFab() {
    setState(() => _isCreateMode = !_isCreateMode);
  }

  Future<void> _handleCreateRequest() async {
    if (widget.onCreateRequested != null) {
      await widget.onCreateRequested!(
        openEmbeddedCreate: ({required commissionAfterCreate}) {
          if (mounted) {
            setState(() {
              _isCreateMode = true;
              _embeddedCreateWithCommission = commissionAfterCreate;
            });
          }
        },
      );
      return;
    }

    final route = widget.fabNavigateRoute;
    if (route != null) {
      context.push(route);
      return;
    }
    setState(() => _isCreateMode = true);
  }

  void _onFabPressed() {
    if (_useEmbeddedCreate && _isCreateMode) {
      _toggleFab();
      return;
    }
    _handleCreateRequest();
  }

  void _onRequestCreate() {
    _handleCreateRequest();
  }

  void _onEmbeddedCreateSuccess() {
    final cubit = context.read<TCubit>();
    final state = cubit.state;
    final created = widget.createdIdFromState(state);
    setState(() {
      _isCreateMode = false;
      _embeddedCreateWithCommission = false;
      _detailEditing = false;
      if (created != null) {
        _selectedId = created;
      }
    });
    if (created != null && widget.listRoute != null) {
      MasterDetailRoute.applyListSelection(
        context,
        listRoute: widget.listRoute!,
        selectedId: created,
      );
    }
    _refreshList?.call();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSelectionFromRoute();
  }

  void _syncSelectionFromRoute() {
    if (widget.listRoute == null) return;
    final routerState = GoRouterState.of(context);
    if (routerState.uri.path != widget.listRoute) return;

    final selection = MasterDetailRoute.selectionFrom(routerState);
    if (selection == null) return;
    if (selection.selectedId == _selectedId &&
        selection.editing == _detailEditing) {
      return;
    }

    setState(() {
      _selectedId = selection.selectedId;
      _detailEditing = selection.editing;
      _isCreateMode = false;
    });
  }

  void _selectItem(String id, {required bool editing}) {
    if (id == _selectedId && !_isCreateMode && _detailEditing == editing) {
      return;
    }
    setState(() {
      _isCreateMode = false;
      _selectedId = id;
      _detailEditing = editing;
    });
    if (widget.listRoute != null) {
      MasterDetailRoute.applyListSelection(
        context,
        listRoute: widget.listRoute!,
        selectedId: id,
        editing: editing,
      );
    }
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
            if (widget.listRoute != null) {
              final routeSelection = MasterDetailRoute.selectionFrom(
                GoRouterState.of(context),
              );
              if (routeSelection != null) {
                setState(() {
                  _selectedId = routeSelection.selectedId;
                  _detailEditing = routeSelection.editing;
                });
                return;
              }
            }
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
            onSelect: (id, {editing = false}) => _selectItem(id, editing: editing),
            bindRefresh: (fn) => _refreshList = fn,
            onRequestCreate: _onRequestCreate,
          ),
          detail: Gs1SplitViewRightPane<TCubit, TState>(
            selectedId: _selectedId,
            useEmbeddedCreate: _useEmbeddedCreate,
            isCreateMode: _isCreateMode,
            isEmptyNoMatch: widget.isEmptyNoMatch,
            idsFromState: widget.idsFromState,
            detailViewBuilder: widget.detailViewBuilder,
            detailEditing: _detailEditing,
            detailAwaitBuilder: widget.detailAwaitBuilder,
            detailCreateBuilder: widget.detailCreateBuilder,
            embeddedCreateWithCommission: _embeddedCreateWithCommission,
            isListLoading: widget.isListLoading,
            createHeaderText: widget.createHeaderText,
            closeCreateTooltip: widget.closeCreateTooltip,
            onCloseCreate: () => setState(() {
              _isCreateMode = false;
              _embeddedCreateWithCommission = false;
              _detailEditing = false;
            }),
            onEmbeddedCreateSuccess: _onEmbeddedCreateSuccess,
          ),
        ),
      ),
    );
  }
}
