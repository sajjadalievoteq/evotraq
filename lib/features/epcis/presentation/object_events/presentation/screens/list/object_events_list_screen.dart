import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/list/object_event_list_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/list/object_event_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/list/object_event_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/list/object_event_record_info_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/list/object_events_results_list.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/shared/object_event_route_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/shared/object_event_shared_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_search_debounce.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_sorting_controls.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';

class ObjectEventsListScreen extends StatefulWidget {
  const ObjectEventsListScreen({
    super.key,
    this.embedded = false,
    this.selectedEventId,
    this.onSelectEvent,
    this.onBindRefresh,
    this.onEmbeddedCreate,
  });

  final bool embedded;
  final String? selectedEventId;
  final ValueChanged<String>? onSelectEvent;
  final void Function(VoidCallback refresh)? onBindRefresh;
  final VoidCallback? onEmbeddedCreate;

  @override
  State<ObjectEventsListScreen> createState() =>
      _ObjectEventsListScreenState();
}

class _ObjectEventsListScreenState extends State<ObjectEventsListScreen> {
  final _searchController = TextEditingController();
  late Gs1ListSearchDebouncer _searchDebouncer;
  final _epcController = TextEditingController();
  final _locationGlnController = TextEditingController();
  final _scrollController = ScrollController();

  String? _selectedAction;
  String? _selectedBizStep;
  String? _selectedDisposition;
  DateTime? _eventTimeFrom;
  DateTime? _eventTimeTo;
  int _pageSize = 20;
  bool _showAdvancedFilters = false;
  bool _didRunPrimaryInitialFetch = false;

  @override
  void initState() {
    super.initState();
    _searchDebouncer = Gs1ListSearchDebouncer(
      onDebounced: () {
        if (!mounted) return;
        _search();
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onBindRefresh?.call(() {
        if (mounted) _searchImmediate();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRunPrimaryInitialFetch) return;
    final primary = PrimaryFetchScope.maybeOf(context)?.isPrimary ?? true;
    if (!primary) return;
    _didRunPrimaryInitialFetch = true;
    _loadList();
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _searchController.dispose();
    _epcController.dispose();
    _locationGlnController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadList() {
    context.read<ObjectEventsCubit>().loadObjectEvents(
          page: 0,
          size: _pageSize,
        );
  }

  void _search() {
    final searchText = _searchController.text.trim();
    context.read<ObjectEventsCubit>().loadObjectEvents(
          page: 0,
          size: _pageSize,
          action: _selectedAction,
          businessStep: _selectedBizStep,
          disposition: _selectedDisposition,
          epc: _epcController.text.isNotEmpty ? _epcController.text : null,
          locationGLN: _locationGlnController.text.isNotEmpty
              ? _locationGlnController.text
              : null,
          searchText: searchText.isNotEmpty ? searchText : null,
          startTime: _eventTimeFrom,
          endTime: _eventTimeTo,
        );
  }

  void _searchImmediate() {
    _searchDebouncer.cancel();
    _search();
  }

  void _onSearchTextChanged(String _) => _searchDebouncer.schedule();

  void _loadMore() => context.read<ObjectEventsCubit>().loadMore();

  Future<void> _refresh() async => _searchImmediate();

  void _clearFilters() {
    setState(() {
      _selectedAction = null;
      _selectedBizStep = null;
      _selectedDisposition = null;
      _epcController.clear();
      _locationGlnController.clear();
      _searchController.clear();
      _eventTimeFrom = null;
      _eventTimeTo = null;
    });
    context.read<ObjectEventsCubit>().clearFiltersAndReload();
  }

  void _showQuickFilterDialog() {
    ObjectEventQuickFilterDialog.open(
      context,
      selectedAction: _selectedAction,
      selectedDisposition: _selectedDisposition,
    ).then((result) {
      if (result == null) return;
      if (result.cleared) {
        setState(() {
          _selectedAction = null;
          _selectedDisposition = null;
        });
        _searchImmediate();
        return;
      }
      setState(() {
        _selectedAction = result.action;
        _selectedDisposition = result.disposition;
      });
      _searchImmediate();
    });
  }

  void _showAdvancedFiltersDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title:
            const Text(ObjectEventListUiConstants.dialogAdvancedFiltersTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            child: ObjectEventAdvancedFiltersPanel(
              epcController: _epcController,
              locationGlnController: _locationGlnController,
              selectedAction: _selectedAction,
              selectedBizStep: _selectedBizStep,
              selectedDisposition: _selectedDisposition,
              onActionChanged: (v) => setState(() => _selectedAction = v),
              onBizStepChanged: (v) => setState(() => _selectedBizStep = v),
              onDispositionChanged: (v) =>
                  setState(() => _selectedDisposition = v),
              eventTimeFrom: _eventTimeFrom,
              eventTimeTo: _eventTimeTo,
              onEventTimeFromChanged: (v) =>
                  setState(() => _eventTimeFrom = v),
              onEventTimeToChanged: (v) => setState(() => _eventTimeTo = v),
              onApply: () {
                Navigator.of(dialogContext).pop();
                _searchImmediate();
              },
              onClear: () {
                Navigator.of(dialogContext).pop();
                _clearFilters();
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _onSelectEvent(ObjectEvent event) {
    final id = event.eventId;
    if (widget.onSelectEvent != null) {
      widget.onSelectEvent!.call(id);
      return;
    }
    context.push(ObjectEventRouteConstants.detailLocation(id));
  }

  Widget _buildBody() {
    return BlocBuilder<ObjectEventsCubit, ObjectEventsState>(
      buildWhen: (prev, curr) => prev.sortOrder != curr.sortOrder,
      builder: (context, state) {
        final toolbar = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(context.padding.top,
                  context.padding.top, context.padding.top, 0),
              child: Gs1ListSearchBar(
                hintText: ObjectEventListUiConstants.searchHint,
                controller: _searchController,
                showAdvancedFilters: _showAdvancedFilters,
                onSearch: _searchImmediate,
                onQueryChanged: _onSearchTextChanged,
                onToggleAdvancedFilters: () {
                  setState(
                      () => _showAdvancedFilters = !_showAdvancedFilters);
                  if (_showAdvancedFilters) _showAdvancedFiltersDialog();
                },
                onClear: _clearFilters,
                onRefresh: _searchImmediate,
                onQuickFilters: _showQuickFilterDialog,
              ),
            ),
            const SizedBox(height: Constants.spacing),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  context.padding.top, 0, context.padding.top, 0),
              child: ObjectEventRecordInfoSection(
                pageSize: _pageSize,
                onPageSizeChanged: (size) {
                  setState(() => _pageSize = size);
                  context.read<ObjectEventsCubit>().updatePageSize(size);
                },
              ),
            ),
            const SizedBox(height: Constants.spacing),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  context.padding.top, 0, context.padding.top, 0),
              child: Gs1ListSortingControls(
                label: ObjectEventListUiConstants.sortLabelEventTime,
                sortOrder: state.sortOrder.toLowerCase(),
                onToggleSortOrder: () =>
                    context.read<ObjectEventsCubit>().toggleSortOrder(),
              ),
            ),
          ],
        );

        final results = ObjectEventsResultsList(
          scrollController: _scrollController,
          selectedEventId: widget.selectedEventId,
          onRefresh: _refresh,
          onClearFilters: _clearFilters,
          onTapEvent: _onSelectEvent,
          onLoadMore: _loadMore,
        );

        return Gs1MasterListBody(toolbar: toolbar, results: results);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildBody();

    return Scaffold(
      appBar: TraqAppBar(
        context,
        title: const Text(ObjectEventSharedUiConstants.appBarManagement),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        heroTag: ObjectEventSharedUiConstants.fabHeroTag,
        tooltip: ObjectEventSharedUiConstants.fabAddTooltip,
        onPressed: widget.onEmbeddedCreate ??
            () => context.push(Constants.epcisObjectEventNewRoute),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(),
    );
  }
}
