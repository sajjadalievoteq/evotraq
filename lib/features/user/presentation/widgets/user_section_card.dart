import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';

class UserSectionCard extends StatelessWidget {
  const UserSectionCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: ResponsiveUtils.paddingAll(context),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: ResponsiveUtils.paddingAll(context),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
