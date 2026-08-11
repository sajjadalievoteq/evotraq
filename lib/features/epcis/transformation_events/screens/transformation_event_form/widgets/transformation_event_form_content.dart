import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/epcis/cubit/validation_cubit.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_form_error_card.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_form_info_card.dart';
import 'package:traqtrace_app/features/epcis/widgets/validation_error_widget.dart';

class TransformationEventFormContent extends StatelessWidget {
  const TransformationEventFormContent({
    required this.form,
    required this.onShowHelp,
    super.key,
  });

  final Widget form;
  final VoidCallback onShowHelp;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ValidationCubit, ValidationState>(
      builder: (context, validationState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TransformationEventFormInfoCard(onShowHelp: onShowHelp),
              const SizedBox(height: 16),
              if (validationState.error != null)
                TransformationEventFormErrorCard(
                  message: validationState.error!,
                ),
              if (validationState.lastValidationResult != null &&
                  !(validationState.lastValidationResult!['valid'] as bool? ??
                      true))
                ValidationErrorWidget(
                  validationErrors: context
                      .read<ValidationCubit>()
                      .validationErrors,
                  onDismiss: () {
                    context.read<ValidationCubit>().clearValidation();
                  },
                ),
              form,
            ],
          ),
        );
      },
    );
  }
}
