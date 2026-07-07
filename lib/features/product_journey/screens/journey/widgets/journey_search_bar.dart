import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

import '../../../../../core/utils/responsive_utils.dart';

class JourneySearchBar extends StatelessWidget {
  const JourneySearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onChanged,
    required this.isSearching,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final bool isSearching;
  final VoidCallback onClear;

  static const double _fieldIconSize = 18;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fieldIconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Padding(
      padding: EdgeInsetsGeometry.only(left: context.padding.top,right: context.padding.top,top:context.padding.top),
      child: AppLayoutBuilder(
        builder: (context, layout) {
          return Card(

            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.primary,
                image: const DecorationImage(
                  image: AssetImage(AppAssets.traqBackgroundPng),
                  fit: BoxFit.cover,
                  opacity: 0.2,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.1),
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
                        TextField(
                          controller: controller,
                          onChanged: onChanged,
                          onSubmitted: onSubmitted,
                          decoration: InputDecoration(
                            hintText:
                                'Enter Serial Number, SGTIN, or SSCC...',
                            prefixIcon: TraqIcon(
                              AppAssets.iconSearch,
                              size: _fieldIconSize,
                              color: fieldIconColor,
                            ),
                            suffixIcon: controller.text.isNotEmpty
                                ? IconButton(
                                    onPressed: onClear,
                                    iconSize: _fieldIconSize,
                                    icon: TraqIcon(
                                      AppAssets.iconX,
                                      size: _fieldIconSize,
                                    ),
                                    color: fieldIconColor,
                                    tooltip: 'Clear',
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: c.borderVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: c.borderVariant),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: c.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: c.surface.withValues(alpha: 0.95),
                          ),
                        ),
                        if (isSearching)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(
                              minHeight: 2,
                              color: c.onPrimary,
                              backgroundColor:
                                  c.onPrimary.withValues(alpha: 0.25),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
