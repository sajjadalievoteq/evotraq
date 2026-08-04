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
                            if (onRefresh != null)
                              _Gs1ListToolbarIconButton(
                                onPressed: onRefresh!,
                                iconAsset: AppAssets.iconRefresh,
                                tooltip: 'Refresh',
                              ),
                            if (_hasSortControl)
                              _Gs1ListSortMenu(
                                sortTooltip: sortTooltip,
                                isAscending: _isAscending,
                                onSortOrderSelected: _applySortOrder,
                                onOpenOptions: onToggleAdvancedFilters,
                              ),
                            if (onPageSizeChanged != null)
                              _Gs1ListBatchMenu(
                                pageSize: pageSize,
                                pageSizeOptions: pageSizeOptions,
                                onPageSizeChanged: onPageSizeChanged!,
                              ),
                            if (onQuickFilters != null)
                              _Gs1ListToolbarIconButton(
                                onPressed: onQuickFilters!,
                                iconAsset: AppAssets.iconFilter,
                                tooltip: 'Quick Filters',
                              ),
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
}

class _Gs1ListToolbarIconButton extends StatelessWidget {
  const _Gs1ListToolbarIconButton({
    required this.onPressed,
    required this.iconAsset,
    required this.tooltip,
  });

  final VoidCallback onPressed;
  final String iconAsset;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: Gs1ListSearchBar._fieldIconSize,
      icon: TraqIcon(iconAsset, size: Gs1ListSearchBar._fieldIconSize),
      color: Gs1ListSearchBar._toolbarIconColor,
      tooltip: tooltip,
    );
  }
}

class _Gs1ListSortMenu extends StatelessWidget {
  const _Gs1ListSortMenu({
    required this.sortTooltip,
    required this.isAscending,
    required this.onSortOrderSelected,
    required this.onOpenOptions,
  });

  final String? sortTooltip;
  final bool isAscending;
  final ValueChanged<String> onSortOrderSelected;
  final VoidCallback onOpenOptions;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: sortTooltip ?? 'Sort',
      padding: EdgeInsets.zero,
      icon: TraqIcon(
        isAscending ? AppAssets.iconArrowUpR : AppAssets.iconArrowD,
        size: Gs1ListSearchBar._fieldIconSize,
      ),
      iconColor: Gs1ListSearchBar._toolbarIconColor,
      iconSize: Gs1ListSearchBar._fieldIconSize,
      onSelected: (value) {
        switch (value) {
          case 'asc':
          case 'desc':
            onSortOrderSelected(value);
          case 'options':
            onOpenOptions();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'asc',
          child: _Gs1ListSortMenuRow(
            label: 'Ascending',
            selected: isAscending,
          ),
        ),
        PopupMenuItem(
          value: 'desc',
          child: _Gs1ListSortMenuRow(
            label: 'Descending',
            selected: !isAscending,
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
}

class _Gs1ListSortMenuRow extends StatelessWidget {
  const _Gs1ListSortMenuRow({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: selected
              ? Icon(
                  Icons.check,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
        ),
        Expanded(child: Text(label)),
      ],
    );
  }
}

class _Gs1ListBatchMenu extends StatelessWidget {
  const _Gs1ListBatchMenu({
    required this.pageSize,
    required this.pageSizeOptions,
    required this.onPageSizeChanged,
  });

  final int? pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final selectedSize = pageSize ?? pageSizeOptions.first;
    return PopupMenuButton<int>(
      tooltip: 'Batch size ($selectedSize)',
      padding: EdgeInsets.zero,
      icon: TraqIcon(
        AppAssets.iconLayers,
        size: Gs1ListSearchBar._fieldIconSize,
      ),
      iconColor: Gs1ListSearchBar._toolbarIconColor,
      iconSize: Gs1ListSearchBar._fieldIconSize,
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
