import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

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
        onTap: action.isDisabled || action.route == null
            ? null
            : () => context.push(action.route!),

        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 120;
            final iconSize = isCompact ? 18.0 : 22.0;
            final iconPadding = isCompact ? 8.0 : 12.0;
            final fontSize = isCompact ? 11.0 : 11.0;
            final spacing = isCompact ? 16.0 : 18.0;
            final padding = isCompact ? 12.0 : 16.0;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Flexible(
                          child: Text(
                            action.title,
                            style: context.text.bodySm.copyWith(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                              color: action.isDisabled
                                  ? context.colors.textMuted
                                  : context.colors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (action.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            action.subtitle!,
                            style: context.text.cap.copyWith(
                              fontSize: isCompact ? 8 : 10,
                              color: context.colors.textMuted,
                              fontStyle: FontStyle.italic,
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
