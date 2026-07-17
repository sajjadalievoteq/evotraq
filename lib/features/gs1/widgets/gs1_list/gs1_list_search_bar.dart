import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';

class Gs1ListSearchBar extends StatelessWidget {
  const Gs1ListSearchBar({
    super.key,
    required this.hintText,
    required this.controller,
    required this.showAdvancedFilters,
    required this.onSearch,
    required this.onQueryChanged,
    required this.onToggleAdvancedFilters,
    required this.onClear,
    this.showAdvancedFilterIcon = true,
    this.onRefresh,
    this.onQuickFilters,
    this.sortTooltip,
    this.sortOrder,
    this.onToggleSortOrder,
    this.onSortOrderChanged,
    this.pageSize,
    this.pageSizeOptions = Gs1ListPageSizes.defaults,
    this.onPageSizeChanged,
  });

  final String hintText;
  final TextEditingController controller;
  final bool showAdvancedFilters;
  final VoidCallback onSearch;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onToggleAdvancedFilters;
  final VoidCallback onClear;
  final bool showAdvancedFilterIcon;
  final VoidCallback? onRefresh;
  final VoidCallback? onQuickFilters;
  final String? sortTooltip;
  final String? sortOrder;
  final VoidCallback? onToggleSortOrder;
  final ValueChanged<String>? onSortOrderChanged;
  final int? pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int>? onPageSizeChanged;

  static const double _fieldIconSize = 18;
  static const Color _toolbarIconColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        final c = context.colors;
        final fieldIconColor = Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
        return Card(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.primary,
              image: DecorationImage(
                image: AssetImage(AppAssets.traqBackgroundPng),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(
                    layout.resolve(
                      compact: 12.0,
                      medium: Constants.spacing.toDouble(),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_showToolbar)
                        Row(
                          children: [
                            const Spacer(),
                            if (onRefresh != null) _buildRefreshButton(),
                            if (_hasSortControl) _buildSortMenu(),
                            if (onPageSizeChanged != null) _buildBatchMenu(),
                            if (onQuickFilters != null) _buildQuickFiltersButton(),
                          ],
                        ),
                      TextField(
                        controller: controller,
                        onChanged: onQueryChanged,
                        decoration: InputDecoration(
                          hintText: hintText,
                          prefixIcon: TraqIcon(
                            AppAssets.iconSearch,
                            size: _fieldIconSize,
                            color: fieldIconColor,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (controller.text.isNotEmpty)
                                IconButton(
                                  onPressed: onClear,
                                  iconSize: _fieldIconSize,
                                  icon: TraqIcon(
                                    AppAssets.iconX,
                                    size: _fieldIconSize,
                                  ),
                                  color: fieldIconColor,
                                  tooltip: 'Clear',
                                ),
                              if (showAdvancedFilterIcon)
                                IconButton(
                                  onPressed: onToggleAdvancedFilters,
                                  iconSize: _fieldIconSize,
                                  icon: TraqIcon(
                                    NavIcons.advancedQuery,
                                    size: _fieldIconSize,
                                  ),
                                  color: fieldIconColor,
                                  tooltip: showAdvancedFilters
                                      ? 'Hide Advanced Filters'
                                      : 'Advanced Filters',
                                ),
                            ],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: c.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.95),
                        ),
                        onSubmitted: (_) => onSearch(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get _showToolbar =>
      onRefresh != null ||
      onQuickFilters != null ||
      _hasSortControl ||
      onPageSizeChanged != null;

  bool get _hasSortControl =>
      onSortOrderChanged != null || onToggleSortOrder != null;

  String get _normalizedSortOrder => sortOrder?.toLowerCase() ?? 'desc';

  bool get _isAscending => _normalizedSortOrder == 'asc';

  void _applySortOrder(String target) {
    final normalized = target.toLowerCase();
    if (_normalizedSortOrder == normalized) return;
    if (onSortOrderChanged != null) {
      onSortOrderChanged!(normalized);
      return;
    }
    onToggleSortOrder?.call();
  }

  Widget _buildRefreshButton() {
    return IconButton(
      onPressed: onRefresh,
      iconSize: _fieldIconSize,
      icon: TraqIcon(AppAssets.iconRefresh, size: _fieldIconSize),
      color: _toolbarIconColor,
      tooltip: 'Refresh',
    );
  }

  Widget _buildQuickFiltersButton() {
    return IconButton(
      onPressed: onQuickFilters,
      iconSize: _fieldIconSize,
      icon: TraqIcon(AppAssets.iconFilter, size: _fieldIconSize),
      color: _toolbarIconColor,
      tooltip: 'Quick Filters',
    );
  }

  Widget _buildSortMenu() {
    return PopupMenuButton<String>(
      tooltip: sortTooltip ?? 'Sort',
      padding: EdgeInsets.zero,
      icon: TraqIcon(
        _isAscending ? AppAssets.iconArrowUpR : AppAssets.iconArrowD,
        size: _fieldIconSize,
      ),
      iconColor: _toolbarIconColor,
      iconSize: _fieldIconSize,
      onSelected: (value) {
        switch (value) {
          case 'asc':
          case 'desc':
            _applySortOrder(value);
          case 'options':
            onToggleAdvancedFilters();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'asc',
          child: _sortMenuRow(
            context,
            label: 'Ascending',
            selected: _isAscending,
          ),
        ),
        PopupMenuItem(
          value: 'desc',
          child: _sortMenuRow(
            context,
            label: 'Descending',
            selected: !_isAscending,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'options',
          child: Text('Sort field & filters…'),
        ),
      ],
    );
  }

  Widget _sortMenuRow(
    BuildContext context, {
    required String label,
    required bool selected,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: selected
              ? Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary)
              : null,
        ),
        Expanded(child: Text(label)),
      ],
    );
  }

  Widget _buildBatchMenu() {
    final selectedSize = pageSize ?? pageSizeOptions.first;
    return PopupMenuButton<int>(
      tooltip: 'Batch size ($selectedSize)',
      padding: EdgeInsets.zero,
      icon: TraqIcon(AppAssets.iconLayers, size: _fieldIconSize),
      iconColor: _toolbarIconColor,
      iconSize: _fieldIconSize,
      initialValue: selectedSize,
      onSelected: onPageSizeChanged,
      itemBuilder: (context) => pageSizeOptions
          .map(
            (size) => PopupMenuItem<int>(
              value: size,
              child: Text('$size/batch'),
            ),
          )
          .toList(),
    );
  }
}
