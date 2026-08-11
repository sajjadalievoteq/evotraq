import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_config.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_step_circle.dart';
import 'package:traqtrace_app/core/widgets/operation_wizard/operation_stepper_connector.dart';

class OperationStepperHeader extends StatefulWidget {
  const OperationStepperHeader({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  final int currentStep;
  final List<OperationStepConfig> steps;

  @override
  State<OperationStepperHeader> createState() => _OperationStepperHeaderState();
}

class _OperationStepperHeaderState extends State<OperationStepperHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  int _previousStep = 0;

  @override
  void initState() {
    super.initState();
    _previousStep = widget.currentStep;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..value = 1.0;
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(OperationStepperHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      setState(() => _previousStep = oldWidget.currentStep);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              for (var i = 0; i < widget.steps.length; i++) ...[
                if (i > 0)
                  OperationStepperConnector(
                    connectorIndex: i - 1,
                    currentStep: widget.currentStep,
                    previousStep: _previousStep,
                    progress: _progress.value,
                  ),
                OperationStepCircle(
                  step: i,
                  label: widget.steps[i].label,
                  iconAsset: widget.steps[i].iconAsset,
                  currentStep: widget.currentStep,
                  previousStep: _previousStep,
                  progress: _progress.value,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
