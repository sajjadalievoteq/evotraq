import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/features/epcis/providers/validation_rule_provider.dart';
import 'package:traqtrace_app/features/epcis/screens/validation_rule_management_screen.dart';

/// Route to handle initialization for the validation rule management screen
class ValidationRuleManagementRoute extends StatelessWidget {
  /// Constructor
  const ValidationRuleManagementRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ValidationRuleProvider(
        appConfig: Provider.of<AppConfig>(context, listen: false),
      ),
      child: const ValidationRuleManagementScreen(),
    );
  }
  
  /// Create the route for navigation
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => const ValidationRuleManagementRoute(),
    );
  }
  
  /// Navigate to the validation rule management screen
  static void navigate(BuildContext context) {
    Navigator.of(context).push(route());
  }
}
