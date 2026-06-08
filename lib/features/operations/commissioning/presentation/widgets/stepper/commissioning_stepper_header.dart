import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/stepper/commissioning_step_circle.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/stepper/commissioning_stepper_connector.dart';

/// Displays the 3-step progress header for the commissioning workflow.
///
/// On mobile the connector between steps animates left-to-right (fill) when
/// advancing and right-to-left (unfill) when going back.  The newly active
/// circle scales in to reinforce the "thumb travels to next step" feel.
class CommissioningStepperHeader extends StatefulWidget {
  const CommissioningStepperHeader({super.key, required this.currentStep});

  final int currentStep;

  @override
  State<CommissioningStepperHeader> createState() =>
      _CommissioningStepperHeaderState();
}

class _CommissioningStepperHeaderState
    extends State<CommissioningStepperHeader>
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
  void didUpdateWidget(CommissioningStepperHeader oldWidget) {
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
              CommissioningStepCircle(
                step: 0,
                label: 'Product',
                icon: Icons.inventory_2,
                currentStep: widget.currentStep,
                previousStep: _previousStep,
                progress: _progress.value,
              ),
              CommissioningStepperConnector(
                connectorIndex: 0,
                currentStep: widget.currentStep,
                previousStep: _previousStep,
                progress: _progress.value,
              ),
              CommissioningStepCircle(
                step: 1,
                label: 'Serials',
                icon: Icons.qr_code_scanner,
                currentStep: widget.currentStep,
                previousStep: _previousStep,
                progress: _progress.value,
              ),
              CommissioningStepperConnector(
                connectorIndex: 1,
                currentStep: widget.currentStep,
                previousStep: _previousStep,
                progress: _progress.value,
              ),
              CommissioningStepCircle(
                step: 2,
                label: 'Review',
                icon: Icons.checklist,
                currentStep: widget.currentStep,
                previousStep: _previousStep,
                progress: _progress.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
