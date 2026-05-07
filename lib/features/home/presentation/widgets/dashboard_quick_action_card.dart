import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardQuickAction {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final String? route;
  final bool isDisabled;

  const DashboardQuickAction({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    this.route,
    this.isDisabled = false,
  });
}

class DashboardQuickActionCard extends StatelessWidget {
  const DashboardQuickActionCard({super.key, required this.action});

  final DashboardQuickAction action;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: action.isDisabled ? 0 : 2,
      color: action.isDisabled ? Colors.grey[100] : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: action.isDisabled || action.route == null
            ? null
            : () => context.push(action.route!),
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 120;
            final iconSize = isCompact ? 22.0 : 28.0;
            final iconPadding = isCompact ? 8.0 : 12.0;
            final fontSize = isCompact ? 11.0 : 13.0;
            final spacing = isCompact ? 6.0 : 12.0;
            final padding = isCompact ? 8.0 : 16.0;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: action.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        action.icon,
                        size: iconSize,
                        color: action.color,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),
                  Flexible(
                    child: Text(
                      action.title,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: action.isDisabled ? Colors.grey : null,
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
                      style: TextStyle(
                        fontSize: isCompact ? 8 : 10,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

