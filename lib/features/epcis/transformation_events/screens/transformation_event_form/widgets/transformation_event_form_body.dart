import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gln_entry_field.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_date_time_picker.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_dropdown_field.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_epc_row.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_form_section_header.dart';
import 'package:traqtrace_app/features/epcis/transformation_events/screens/transformation_event_form/widgets/transformation_event_validated_text_field.dart';
import 'package:traqtrace_app/features/epcis/validators/epcis_gln_validators.dart';

class TransformationEventFormBody extends StatelessWidget {
  const TransformationEventFormBody({
    required this.formKey,
    required this.hasTriedToSubmit,
    required this.transformationIdController,
    required this.inputEpcsController,
    required this.outputEpcsController,
    required this.bizStepController,
    required this.dispositionController,
    required this.locationGlnController,
    required this.certificateNumberController,
    required this.certificationStandardController,
    required this.certificationAgencyController,
    required this.certificationTypeController,
    required this.eventTime,
    required this.validDispositions,
    required this.onFieldError,
    required this.onGenerateSampleInput,
    required this.onGenerateBatchInput,
    required this.onGenerateSampleOutput,
    required this.onGenerateBatchOutput,
    required this.onBusinessStepChanged,
    required this.onDispositionChanged,
    required this.onEventTimeChanged,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final bool hasTriedToSubmit;
  final TextEditingController transformationIdController;
  final TextEditingController inputEpcsController;
  final TextEditingController outputEpcsController;
  final TextEditingController bizStepController;
  final TextEditingController dispositionController;
  final TextEditingController locationGlnController;
  final TextEditingController certificateNumberController;
  final TextEditingController certificationStandardController;
  final TextEditingController certificationAgencyController;
  final TextEditingController certificationTypeController;
  final DateTime eventTime;
  final List<String> validDispositions;
  final void Function(String fieldName, String? error) onFieldError;
  final VoidCallback onGenerateSampleInput;
  final VoidCallback onGenerateBatchInput;
  final VoidCallback onGenerateSampleOutput;
  final VoidCallback onGenerateBatchOutput;
  final ValueChanged<String> onBusinessStepChanged;
  final ValueChanged<String> onDispositionChanged;
  final ValueChanged<DateTime> onEventTimeChanged;

  @override
  Widget build(BuildContext context) {
    final cbvState = context.watch<CbvVocabularyCubit>().state;
    return Form(
      key: formKey,
      autovalidateMode: hasTriedToSubmit
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TransformationEventFormSectionHeader(
            title: 'Basic Information',
          ),
          TransformationEventValidatedTextField(
            controller: transformationIdController,
            label: 'Transformation ID *',
            helperText:
                'Simple ID (transform_12345) or a full URI with your own namespace.',
            fieldName: 'transformationId',
            onFieldError: onFieldError,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Transformation ID is required';
              }
              if (value.contains(' ')) {
                return 'Transformation ID should not contain spaces';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          const TransformationEventFormSectionHeader(
            title: 'Transformation Details',
          ),
          TransformationEventEpcRow(
            controller: inputEpcsController,
            label: 'Input EPCs *',
            helperText: 'Comma-separated list of input EPCs',
            fieldName: 'inputEpcs',
            onFieldError: onFieldError,
            onGenerateSample: onGenerateSampleInput,
            onGenerateBatch: onGenerateBatchInput,
          ),
          const SizedBox(height: 16),
          TransformationEventEpcRow(
            controller: outputEpcsController,
            label: 'Output EPCs *',
            helperText: 'Comma-separated list of output EPCs',
            fieldName: 'outputEpcs',
            onFieldError: onFieldError,
            onGenerateSample: onGenerateSampleOutput,
            onGenerateBatch: onGenerateBatchOutput,
          ),
          const SizedBox(height: 24),
          const TransformationEventFormSectionHeader(title: 'Business Context'),
          if (cbvState.isLoading && !cbvState.isLoaded)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(),
            )
          else if (cbvState.hasError && !cbvState.isLoaded)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const Expanded(child: Text('Failed to load CBV vocabulary.')),
                  TextButton(
                    onPressed: () =>
                        context.read<CbvVocabularyCubit>().refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          TransformationEventDropdownField(
            controller: bizStepController,
            label: 'Business Step',
            options: cbvState.bizSteps.map((item) => item.code).toList(),
            helperText: 'The type of business process step',
            onChanged: (value) {
              if (value != null && value.isNotEmpty) {
                onBusinessStepChanged(value);
              }
            },
          ),
          const SizedBox(height: 16),
          TransformationEventDropdownField(
            controller: dispositionController,
            label: 'Disposition',
            options: validDispositions,
            helperText: 'The business state of the objects',
            onChanged: (value) {
              if (value != null && value.isNotEmpty) {
                onDispositionChanged(value);
              }
            },
          ),
          const SizedBox(height: 16),
          GlnEntryField(
            controller: locationGlnController,
            label: 'Business Location GLN',
            helperText:
                'GLN code where the transformation occurred (must exist in master data)',
            fieldName: 'locationGLN',
            optional: true,
            validator: (value) =>
                EpcisGlnValidators.validateLocationGln(value, required: false),
          ),
          const SizedBox(height: 24),
          const TransformationEventFormSectionHeader(
            title: 'Certification Information (EPCIS 2.0)',
          ),
          TransformationEventValidatedTextField(
            controller: certificateNumberController,
            label: 'Certificate Number',
            helperText: 'Unique identifier for the certification',
            fieldName: 'certificateNumber',
            onFieldError: onFieldError,
          ),
          const SizedBox(height: 16),
          TransformationEventValidatedTextField(
            controller: certificationStandardController,
            label: 'Certification Standard',
            helperText: 'E.g., ISO 14001, HACCP, Organic, Fair Trade',
            fieldName: 'certificationStandard',
            onFieldError: onFieldError,
          ),
          const SizedBox(height: 16),
          TransformationEventValidatedTextField(
            controller: certificationAgencyController,
            label: 'Certification Agency',
            helperText: 'Name of the issuing organization',
            fieldName: 'certificationAgency',
            onFieldError: onFieldError,
          ),
          const SizedBox(height: 16),
          TransformationEventValidatedTextField(
            controller: certificationTypeController,
            label: 'Certification Type',
            helperText: 'Type or category of certification',
            fieldName: 'certificationType',
            onFieldError: onFieldError,
          ),
          const SizedBox(height: 24),
          const TransformationEventFormSectionHeader(title: 'Event Time'),
          TransformationEventDateTimePicker(
            value: eventTime,
            onChanged: onEventTimeChanged,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
