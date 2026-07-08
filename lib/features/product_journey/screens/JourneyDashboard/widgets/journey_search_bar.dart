import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDashboard/widgets/journey_search_bar_suffix_actions.dart';

import 'package:traqtrace_app/core/utils/responsive_utils.dart';

class JourneySearchBar extends StatelessWidget {
  const JourneySearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onChanged,
    required this.isSearching,
    required this.onClear,
    this.onScanResult,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final bool isSearching;
  final VoidCallback onClear;
  final ValueChanged<ScanResult>? onScanResult;

  static const double _fieldIconSize = 18;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Card(
      margin:  EdgeInsets.fromLTRB(
        context.padding.top,
        context.padding.top,
        context.padding.top,
        0,
      ),
        elevation: 2,
        color: context.colors.surface,
        clipBehavior: Clip.hardEdge,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.primary,
            image: DecorationImage(
              image: AssetImage(AppAssets.traqBackgroundPng),
              fit: BoxFit.cover,
              opacity: 0.2,
            ),
          ),
      child: Padding(
          padding:  EdgeInsets.fromLTRB(
            10,
            20,
           10,
            20,
          ),
        child: AppLayoutBuilder(
          builder: (context, layout) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Track Identifier',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                ),
                const SizedBox(height: TraqSpacing.sm),
                TextField(
                  controller: controller,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  decoration: InputDecoration(
                    hintText: 'EPC URI, GS1 barcode, SGTIN, SSCC, or serial…',
                    prefixIcon: TraqIcon(
                      AppAssets.iconSearch,
                      size: _fieldIconSize,
                      color: c.textMuted,
                    ),
                    suffixIcon: ListenableBuilder(
                      listenable: controller,
                      builder: (context, _) => JourneySearchBarSuffixActions(
                        controller: controller,
                        onClear: onClear,
                        onScanResult: onScanResult,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(TraqRadius.lg),
                      borderSide: BorderSide(color: c.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(TraqRadius.lg),
                      borderSide: BorderSide(color: c.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(TraqRadius.lg),
                      borderSide: BorderSide(color: c.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: c.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: layout.resolve(
                        compact: TraqSpacing.md,
                        medium: Constants.spacing.toDouble(),
                      ),
                      vertical: TraqSpacing.md,
                    ),
                  ),
                ),
                if (isSearching)
                  Padding(
                    padding: const EdgeInsets.only(top: TraqSpacing.sm),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      color: c.primary,
                      backgroundColor: c.primary.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ));
  }
}
