import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';

/// Shared standalone Scaffold used by notification-center and
/// subscription-management list screens.
class SubscriptionStandaloneScaffold extends StatelessWidget {
  const SubscriptionStandaloneScaffold({
    super.key,
    required this.title,
    required this.actions,
    required this.header,
    required this.body,
    this.floatingActionButton,
  });

  final String title;
  final List<Widget> actions;
  final Widget header;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: TraqSpacing.surfacePad,
            child: header,
          ),
          Divider(height: 1, color: c.border),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
