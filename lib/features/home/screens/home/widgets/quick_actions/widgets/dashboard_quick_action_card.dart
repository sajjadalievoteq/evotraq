import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';

class DashboardQuickAction {
  const DashboardQuickAction({
    required this.iconAsset,
    required this.title,
    this.subtitle,
    required this.color,
    this.route,
    this.isDisabled = false,
  });

  final String iconAsset;
  final String title;
  final String? subtitle;
  final Color color;
  final String? route;
  final bool isDisabled;
}

class DashboardQuickActionCard extends StatelessWidget {
  const DashboardQuickActionCard({super.key, required this.action});

  final DashboardQuickAction action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          if (action.isDisabled) {
            context.showInfo(HomeStrings.quickActionUnavailable);
            return;
          }
          final route = action.route;
          if (route != null) {
            context.push(route);
          }
        },

        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            // Only genuinely narrow tiles scale down; wider tiles keep a
            // constant compact scale so the card fits its capped height.
            final isNarrow = width < 200;

            final iconSize = isNarrow ? 14.0 : 18.0;

            final iconPadding = isNarrow ? 2.0 : 2.0;

            final titleFontSize = isNarrow ? 10.0 : 12.0;

            final subtitleFontSize = isNarrow ? 10.0 : 12.0;

            final spacing = isNarrow ? 10.0 : 12.0;

            final padding = isNarrow ? 12.0 : 14.0;
            return Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: spacing,
                children: [
                  Container(
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: TraqIcon(
                      action.iconAsset,
                      size: iconSize,
                      color: action.color,
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          action.title,
                          style: context.text.bodySm.copyWith(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: action.isDisabled
                                ? context.colors.textMuted
                                : context.colors.textPrimary,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (action.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            action.subtitle!,
                            style: context.text.cap.copyWith(
                              fontSize: subtitleFontSize,
                              color: context.colors.textMuted,
                              fontStyle: FontStyle.italic,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
