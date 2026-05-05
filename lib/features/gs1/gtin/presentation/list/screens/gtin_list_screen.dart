import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/widgets/gtin_quick_filter_dialog.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/widgets/gtin_advanced_filters_panel.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/widgets/gtin_results_list.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/list/widgets/gtin_record_info_section.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_filter_value.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_search_debounce.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/split_or_list_indexed_stack.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_master_list_body.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_search_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_sorting_controls.dart';
import 'package:traqtrace_app/shared/widgets/custom_text_button_widget.dart';

class GTINListScreen extends StatefulWidget {
  const GTINListScreen({super.key, this.embedded = false, this.onSelectGtin});

  /// When true, renders only the content (no Scaffold/AppDrawer/FAB).
  final bool embedded;

  /// If provided, tapping an item will call this instead of navigating.
  final ValueChanged<String>? onSelectGtin;

  @override
  State<GTINListScreen> createState() => _GTINListScreenState();
}

class _GTINListScreenState extends State<GTINListScreen> {
  final _searchController = TextEditingController();
  late Gs1ListSearchDebouncer _searchDebouncer;
  final _productNameController = TextEditingController();
  final _gtinCodeController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _registrationDateFromController = TextEditingController();
  final _registrationDateToController = TextEditingController();
  final _scrollController = ScrollController();

  String? _selectedStatus;
  String? _selectedPackagingLevel;
  DateTime? _registrationDateFrom;
  DateTime? _registrationDateTo;
  int _pageSize = 25;

  /// Avoid duplicate list fetch: [SplitOrListIndexedStack] keeps split + list mounted.
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRunPrimaryInitialFetch) return;
    final primary = PrimaryFetchScope.maybeOf(context)?.isPrimary ?? true;
    if (!primary) return;
    _didRunPrimaryInitialFetch = true;
    context.read<GTINCubit>().fetchGTINList();
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _searchController.dispose();
    _productNameController.dispose();
    _gtinCodeController.dispose();
    _manufacturerController.dispose();
    _registrationDateFromController.dispose();
    _registrationDateToController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? _getAdvancedFilterValue(String filterType) {
    switch (filterType) {
      case 'productName':
        return _productNameController.text.isEmpty
            ? null
            : _productNameController.text;
      case 'gtinCode':
        return _gtinCodeController.text.isEmpty
            ? null
            : _gtinCodeController.text;
      case 'manufacturer':
        return _manufacturerController.text.isEmpty
            ? null
            : _manufacturerController.text;
      default:
        return null;
    }
  }

  void _loadMore() {
    final cubitState = context.read<GTINCubit>().state;
    if (!cubitState.hasMoreData || cubitState.isFetchingMore) return;

    context.read<GTINCubit>().fetchGTINList(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      productName: _getAdvancedFilterValue('productName'),
      gtinCode: _getAdvancedFilterValue('gtinCode'),
      manufacturer: _getAdvancedFilterValue('manufacturer'),
      status: gs1ValueUnlessAll(_selectedStatus)?.toLowerCase(),
      packagingLevel: gs1ValueUnlessAll(_selectedPackagingLevel),
      registrationDateFrom: _registrationDateFrom?.toIso8601String().split(
        'T',
      )[0],
      registrationDateTo: _registrationDateTo?.toIso8601String().split('T')[0],
      page: cubitState.currentPage + 1,
      size: _pageSize,
    );
  }

  Future<void> _refresh() async {
    _searchImmediate();
  }

  void _search() {
    context.read<GTINCubit>().fetchGTINList(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      productName: _getAdvancedFilterValue('productName'),
      gtinCode: _getAdvancedFilterValue('gtinCode'),
      manufacturer: _getAdvancedFilterValue('manufacturer'),
      status: gs1ValueUnlessAll(_selectedStatus)?.toLowerCase(),
      packagingLevel: gs1ValueUnlessAll(_selectedPackagingLevel),
      registrationDateFrom: _registrationDateFrom?.toIso8601String().split(
        'T',
      )[0],
      registrationDateTo: _registrationDateTo?.toIso8601String().split('T')[0],
      page: 0,
      size: _pageSize,
    );
  }

  /// Cancels pending debounce and runs search now (Enter, refresh, filters, clear).
  void _searchImmediate() {
    _searchDebouncer.cancel();
    _search();
  }

  void _onSearchTextChanged(String _) {
    _searchDebouncer.schedule();
  }

  void _showFilterDialog() {
    GtinQuickFilterDialog.open(
      context,
      manufacturerController: _manufacturerController,
      selectedStatus: _selectedStatus,
      selectedPackagingLevel: _selectedPackagingLevel,
    ).then((result) {
      if (result == null) return;

      if (result.cleared) {
        setState(() {
          _manufacturerController.clear();
          _selectedStatus = GtinUiConstants.filterAll;
          _selectedPackagingLevel = GtinUiConstants.filterAll;
        });
        _searchImmediate();
        return;
      }

      setState(() {
        _selectedStatus = result.status;
        _selectedPackagingLevel = result.packaging;
      });
      _searchImmediate();
    });
  }

  void _showAdvancedFiltersDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(GtinUiConstants.dialogAdvancedFiltersTitle),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              child: GtinAdvancedFiltersPanel(
                productNameController: _productNameController,
                gtinCodeController: _gtinCodeController,
                manufacturerController: _manufacturerController,
                registrationDateFromController: _registrationDateFromController,
                registrationDateToController: _registrationDateToController,
                selectedPackagingLevel: _selectedPackagingLevel,
                onPackagingLevelChanged: (value) {
                  setState(() {
                    _selectedPackagingLevel = value;
                  });
                },
                onPickFromDate: () => _selectDate(dialogContext, true),
                onPickToDate: () => _selectDate(dialogContext, false),
                onApply: () {
                  Navigator.of(dialogContext).pop();
                  _searchImmediate();
                },
                onClearAll: () {
                  Navigator.of(dialogContext).pop();
                  _clearAllFilters();
                },
              ),
            ),
          ),
          actions: [
            CustomTextButtonWidget(
              title: GtinUiConstants.buttonClose,
              onTap: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  void _navigateToGTINDetails(String gtinCode) {
    if (widget.onSelectGtin != null) {
      widget.onSelectGtin!(gtinCode);
      return;
    }
    context
        .push('${Constants.gs1GtinsRoute}/$gtinCode')
        .then((_) => _searchImmediate());
  }

  void _navigateToCreateGTIN() {
    context.push(Constants.gs1GtinNewRoute).then((_) => _searchImmediate());
  }

  @override
  Widget build(BuildContext context) {
    final content = AppLayoutBuilder(
      builder: (context, layout) {
        return Gs1MasterListBody(
          toolbar: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top:context.padding.left,right: context.padding.left,left: context.padding.left),
                child: Column(
                  children: [
                    ListenableBuilder(
                      listenable: _searchController,
                      builder: (context, _) {
                        return Gs1ListSearchBar(
                          hintText: GtinUiConstants.listSearchHint,
                          controller: _searchController,
                          showAdvancedFilters: false,
                          onSearch: _searchImmediate,
                          onQueryChanged: _onSearchTextChanged,
                          onRefresh: _searchImmediate,
                          onQuickFilters: _showFilterDialog,
                          onToggleAdvancedFilters: _showAdvancedFiltersDialog,
                          onClear: () {
                            _searchDebouncer.cancel();
                            _searchController.clear();
                            _search();
                          },
                        );
                      },
                    ),
                    GtinRecordInfoSection(
                      pageSize: _pageSize,
                      onPageSizeChanged: (newSize) {
                        setState(() {
                          _pageSize = newSize;
                        });
                        _searchImmediate();
                      },
                    ),
                    SizedBox(height: Constants.spacing),
                    BlocBuilder<GTINCubit, GTINState>(
                      buildWhen: (prev, current) =>
                      prev.gtinListSortAscending !=
                          current.gtinListSortAscending,
                      builder: (context, cubitState) {
                        return Gs1ListSortingControls(
                          label: GtinUiConstants.sortByProductNameLine(
                            cubitState.gtinListSortAscending,
                          ),
                          sortOrder: cubitState.gtinListSortAscending
                              ? 'asc'
                              : 'desc',
                          onToggleSortOrder: () => context
                              .read<GTINCubit>()
                              .toggleGtinListProductNameSort(),
                        );
                      },
                    ),
                  ],
                ),
              ),

            ],
          ),
          results: GtinResultsList(
            scrollController: _scrollController,
            onRefresh: _refresh,
            onClearFilters: () {
              _searchController.clear();
              _clearAllFilters();
            },
            onTapGtin: _navigateToGTINDetails,
            onLoadMore: _loadMore,
          ),
        );
      },
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text(GtinUiConstants.appBarManagement)),
      drawer: const AppDrawer(),
      body: content,
      floatingActionButton: FloatingActionButton(
        heroTag: 'gtin_list_standalone_add_fab',
        onPressed: _navigateToCreateGTIN,
        tooltip: GtinUiConstants.fabAddNew,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _registrationDateFrom = picked;
          _registrationDateFromController.text =
              '${picked.year.toString().padLeft(4, '0')}-'
              '${picked.month.toString().padLeft(2, '0')}-'
              '${picked.day.toString().padLeft(2, '0')}';
        } else {
          _registrationDateTo = picked;
          _registrationDateToController.text =
              '${picked.year.toString().padLeft(4, '0')}-'
              '${picked.month.toString().padLeft(2, '0')}-'
              '${picked.day.toString().padLeft(2, '0')}';
        }
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedStatus = GtinUiConstants.filterAll;
      _selectedPackagingLevel = GtinUiConstants.filterAll;
      _registrationDateFrom = null;
      _registrationDateTo = null;
      _registrationDateFromController.clear();
      _registrationDateToController.clear();
      _searchController.clear();
      _productNameController.clear();
      _gtinCodeController.clear();
      _manufacturerController.clear();
    });
    _searchImmediate();
  }
}
