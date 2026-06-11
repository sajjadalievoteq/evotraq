import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/epcis/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_event_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/widgets/aggregation_event_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/widgets/aggregation_event_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/widgets/aggregation_event_record_info_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/widgets/aggregation_events_results_list.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_search_debounce.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_sorting_controls.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';

class AggregationEventsListScreen extends StatefulWidget {
  const AggregationEventsListScreen({
    super.key,
    this.embedded = false,
    this.selectedEventId,
    this.onSelectEvent,
    this.onBindRefresh,
    this.onEmbeddedCreate,
  });

  /// When [embedded] is true this screen sits inside the split-view left pane.
  final bool embedded;
  final String? selectedEventId;
  final ValueChanged<String>? onSelectEvent;
  final void Function(VoidCallback refresh)? onBindRefresh;
  final VoidCallback? onEmbeddedCreate;

  @override
  State<AggregationEventsListScreen> createState() =>
      _AggregationEventsListScreenState();
}

class _AggregationEventsListScreenState
    extends State<AggregationEventsListScreen> {
  final _searchController = TextEditingController();
  late Gs1ListSearchDebouncer _searchDebouncer;
  final _parentEpcController = TextEditingController();
  final _childEpcController = TextEditingController();
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
    _parentEpcController.dispose();
    _childEpcController.dispose();
    _locationGlnController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadList() {
    context.read<AggregationEventsCubit>().loadAggregationEvents(
          page: 0,
          size: _pageSize,
        );
  }

  void _search() {
    final searchText = _searchController.text.trim();
    context.read<AggregationEventsCubit>().loadAggregationEvents(
          page: 0,
          size: _pageSize,
          action: _selectedAction,
          businessStep: _selectedBizStep,
          disposition: _selectedDisposition,
          searchText: searchText.isNotEmpty ? searchText : null,
          parentEPC: _parentEpcController.text.isNotEmpty
              ? _parentEpcController.text
              : null,
          childEPC: _childEpcController.text.isNotEmpty
              ? _childEpcController.text
              : null,
          locationGLN: _locationGlnController.text.isNotEmpty
              ? _locationGlnController.text
              : null,
          startTime: _eventTimeFrom,
          endTime: _eventTimeTo,
        );
  }

  void _searchImmediate() {
    _searchDebouncer.cancel();
    _search();
  }

  void _onSearchTextChanged(String _) => _searchDebouncer.schedule();

  void _loadMore() => context.read<AggregationEventsCubit>().loadMore();

  Future<void> _refresh() async => _searchImmediate();

  void _clearFilters() {
    setState(() {
      _selectedAction = null;
      _selectedBizStep = null;
      _selectedDisposition = null;
      _parentEpcController.clear();
      _childEpcController.clear();
      _locationGlnController.clear();
      _searchController.clear();
      _eventTimeFrom = null;
      _eventTimeTo = null;
    });
    context.read<AggregationEventsCubit>().clearFiltersAndReload();
  }

  void _showQuickFilterDialog() {
    AggregationEventQuickFilterDialog.open(
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
            const Text(AggregationEventUiConstants.dialogAdvancedFiltersTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            child: AggregationEventAdvancedFiltersPanel(
              parentEpcController: _parentEpcController,
              childEpcController: _childEpcController,
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

  void _onSelectEvent(AggregationEvent event) {
    final id = event.id ?? event.eventId;
    if (widget.onSelectEvent != null) {
      widget.onSelectEvent!.call(id);
      return;
    }
    context.push('${Constants.epcisAggregationEventsRoute}/$id');
  }

  Widget _buildBody() {
    return BlocBuilder<AggregationEventsCubit, AggregationEventsState>(
      buildWhen: (prev, curr) => prev.sortOrder != curr.sortOrder,
      builder: (context, state) {
        final toolbar = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(context.padding.top, context.padding.top, context.padding.top, 0),
              child: Gs1ListSearchBar(
                hintText: AggregationEventUiConstants.searchHint,
                controller: _searchController,
                showAdvancedFilters: _showAdvancedFilters,
                onSearch: _searchImmediate,
                onQueryChanged: _onSearchTextChanged,
                onToggleAdvancedFilters: () {
                  setState(() => _showAdvancedFilters = !_showAdvancedFilters);
                  if (_showAdvancedFilters) _showAdvancedFiltersDialog();
                },
                onClear: _clearFilters,
                onRefresh: _searchImmediate,
                onQuickFilters: _showQuickFilterDialog,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(context.padding.top, 0, context.padding.top, 0),
              child: AggregationEventRecordInfoSection(
                pageSize: _pageSize,
                onPageSizeChanged: (size) {
                  setState(() => _pageSize = size);
                  context.read<AggregationEventsCubit>().updatePageSize(size);
                },
              ),
            ),
            const SizedBox(height: Constants.spacing),
            Padding(
              padding: EdgeInsets.fromLTRB(context.padding.top, 0, context.padding.top, 0),
              child: Gs1ListSortingControls(
                label: AggregationEventUiConstants.sortLabelEventTime,
                sortOrder: state.sortOrder.toLowerCase(),
                onToggleSortOrder: () =>
                    context.read<AggregationEventsCubit>().toggleSortOrder(),
              ),
            ),
          ],
        );

        final results = AggregationEventsResultsList(
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
        title: const Text(AggregationEventUiConstants.appBarManagement),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        heroTag: AggregationEventUiConstants.fabHeroTag,
        tooltip: AggregationEventUiConstants.fabAddTooltip,
        onPressed: widget.onEmbeddedCreate ??
            () => context.push(Constants.epcisAggregationEventNewRoute),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(),
    );
  }
}
