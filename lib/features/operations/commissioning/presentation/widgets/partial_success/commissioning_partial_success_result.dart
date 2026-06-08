import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/partial_success/commissioning_partial_success_choice.dart';

class CommissioningPartialSuccessResult {
  const CommissioningPartialSuccessResult({
    required this.choice,
    required this.serialsMarkedForRemoval,
  });

  final CommissioningPartialSuccessChoice choice;
  final Set<String> serialsMarkedForRemoval;
}
