import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/validation_rules/screens/validation_rule_management_screen.dart';

class ValidationRuleManagementRoute extends StatelessWidget {
  const ValidationRuleManagementRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ValidationRuleManagementScreen();
  }

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => const ValidationRuleManagementRoute(),
    );
  }

  static void navigate(BuildContext context) {
    Navigator.of(context).push(route());
  }
}
