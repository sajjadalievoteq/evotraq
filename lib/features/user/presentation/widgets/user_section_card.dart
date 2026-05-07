import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';

class UserSectionCard extends StatelessWidget {
  const UserSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: ResponsiveUtils.paddingAll(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

