import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

class DashboardQuickAction {
  const DashboardQuickAction({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    this.route,
    this.isDisabled = false,
  });

  final IconData icon;
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

            final isMobile = width < 420;
            final isTablet = width >= 420 && width < 820;
            final isDesktop = width >= 820;

            final iconSize = isMobile ? 18.0 : isTablet ? 24.0 : 48.0;

            final iconPadding = isMobile ? 4.0 : isTablet ? 12.0 : 14.0;

            final titleFontSize = isMobile ? 10.0 : isTablet ? 16.0 : 28.0;

            final subtitleFontSize = isMobile ? 8.0 : isTablet ? 13.0 : 22.0;

            final spacing = isMobile ? 12.0 : isTablet ? 14.0 : 16.0;

            final padding = isMobile ? 12.0 : isTablet ? 18.0 : 22.0;
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
                                    borderRadius: BorderRadius.circular(2)
                    ),
                    child: Icon(
                      action.icon,
                      size: iconSize,
                      color: action.color,
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Text(
                        action.title,
                        style: context.text.bodySm.copyWith(
                          fontSize:titleFontSize,
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
