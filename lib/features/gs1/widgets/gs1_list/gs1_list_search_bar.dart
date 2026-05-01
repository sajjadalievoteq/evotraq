import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/color_manager.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

/// Search field + optional refresh / quick-filters row (GTIN/GLN list “tile”).
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
    this.onRefresh,
    this.onQuickFilters,
  });

  final String hintText;
  final TextEditingController controller;
  final bool showAdvancedFilters;
  final VoidCallback onSearch;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onToggleAdvancedFilters;
  final VoidCallback onClear;
  final VoidCallback? onRefresh;
  final VoidCallback? onQuickFilters;

  @override
  Widget build(BuildContext context) {
    return AppLayoutBuilder(
      builder: (context, layout) {
        return Container(
          padding: EdgeInsets.all(
            layout.resolve(
              compact: 12.0,
              medium: Constants.spacing.toDouble(),
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onRefresh != null || onQuickFilters != null)
                Row(
                  children: [
                    const Spacer(),
                    if (onRefresh != null)
                      IconButton(
                        onPressed: onRefresh,
                        icon: const Icon(Icons.refresh),
                        color: ColorManager.primary(context),
                        tooltip: 'Refresh',
                      ),
                    if (onQuickFilters != null)
                      IconButton(
                        onPressed: onQuickFilters,
                        icon: const Icon(Icons.filter_list),
                        color: ColorManager.primary(context),
                        tooltip: 'Quick Filters',
                      ),
                  ],
                ),
              TextField(
                controller: controller,
                onChanged: onQueryChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.text.isNotEmpty)
                        IconButton(
                          onPressed: onClear,
                          icon: const Icon(Icons.clear),
                          color: ColorManager.primary(context),
                          tooltip: 'Clear',
                        ),
                      IconButton(
                        onPressed: onToggleAdvancedFilters,
                        icon: const Icon(Icons.tune),
                        color: ColorManager.primary(context),
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
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                onSubmitted: (_) => onSearch(),
              ),
            ],
          ),
        );
      },
    );
  }
}
