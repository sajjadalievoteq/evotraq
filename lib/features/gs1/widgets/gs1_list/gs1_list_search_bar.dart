import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

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

  static const double _fieldIconSize = 18;

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
                )
            ),
            child:
            Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
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
                      if (onRefresh != null || onQuickFilters != null)
                        Row(
                          children: [

                            const Spacer(),
                            if (onRefresh != null)
                              IconButton(
                                onPressed: onRefresh,
                                iconSize: _fieldIconSize,
                                icon: TraqIcon(
                                  AppAssets.iconRefresh,
                                  size: _fieldIconSize,
                                ),
                                color: Colors.white,
                                tooltip: 'Refresh',
                              ),
                            if (onQuickFilters != null)
                              IconButton(
                                onPressed: onQuickFilters,
                                iconSize: _fieldIconSize,
                                icon: TraqIcon(
                                  AppAssets.iconFilter,
                                  size: _fieldIconSize,
                                ),
                                color: Colors.white,
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
                              IconButton(
                                onPressed: onToggleAdvancedFilters,
                                iconSize: _fieldIconSize,
                                icon: TraqIcon(
                                  AppAssets.iconAdvancedFilter,
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
}