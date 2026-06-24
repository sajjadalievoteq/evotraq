import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation/widgets/commissioning_partial_success_choice.dart';

class CommissioningPartialSuccessResult {
  const CommissioningPartialSuccessResult({
    required this.choice,
    required this.serialsMarkedForRemoval,
  });

  final CommissioningPartialSuccessChoice choice;
  final Set<String> serialsMarkedForRemoval;
}
