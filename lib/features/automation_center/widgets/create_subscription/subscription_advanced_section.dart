import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/subscription_cbv_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_state.dart';
import 'package:traqtrace_app/features/automation_center/utils/notification_constants.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/subscription_enhanced_dropdown.dart';
import 'package:traqtrace_app/features/automation_center/widgets/create_subscription/subscription_multi_select_field.dart';

class SubscriptionAdvancedSection extends StatefulWidget {
  const SubscriptionAdvancedSection({super.key});

  @override
  State<SubscriptionAdvancedSection> createState() =>
      _SubscriptionAdvancedSectionState();
}

class _SubscriptionAdvancedSectionState
    extends State<SubscriptionAdvancedSection> {
  @override
  void initState() {
    super.initState();
    getIt<CbvVocabularyCubit>().loadVocabulary();
  }

  List<Map<String, String>> _bizStepOptions(CbvVocabularyState state) {
    return state.bizSteps
        .map(
          (item) => {
            'value': item.urn,
            'label': item.label,
            'description': CbvVocabularyFormatter.shortName(item.urn),
          },
        )
        .toList();
  }

  List<Map<String, String>> _dispositionOptions(
    CbvVocabularyState state,
    String? selectedBizStepUrn,
  ) {
    CbvVocabularyItem? selectedStep;
    if (selectedBizStepUrn != null) {
      for (final item in state.bizSteps) {
        if (item.urn == selectedBizStepUrn) {
          selectedStep = item;
          break;
        }
      }
    }
    final allowedCodes = selectedStep == null
        ? null
        : state.bizStepValidDispositions[selectedStep.code];
    final allowedSet = allowedCodes?.toSet();

    final filtered = (allowedSet == null || allowedSet.isEmpty)
        ? state.dispositions
        : state.dispositions.where((d) => allowedSet.contains(d.code));

    return filtered
        .map(
          (item) => {
            'value': item.urn,
            'label': item.label,
            'description': CbvVocabularyFormatter.shortName(item.urn),
          },
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<CbvVocabularyCubit>(),
      child: BlocBuilder<CbvVocabularyCubit, CbvVocabularyState>(
        builder: (context, cbvState) {
          final form = FormBuilder.of(context);
          final selectedBizStep = form?.instantValue['bizStep'] as String?;
          final bizStepOptions = _bizStepOptions(cbvState);
          final dispositionOptions = _dispositionOptions(
            cbvState,
            selectedBizStep,
          );

          return ExpansionTile(
            title: const Text('Event filters'),
            subtitle: const Text('Choose which EPCIS events trigger delivery'),
            children: [
              const SizedBox(height: 8),
              const SubscriptionMultiSelectField(
                name: 'eventTypes',
                label: 'Event Types',
                options: NotificationConstants.eventTypes,
                helperText: 'Select which EPCIS event types to monitor',
              ),
              const SizedBox(height: 12),
              SubscriptionCbvStatus(
                state: cbvState,
                onRetry: () => context.read<CbvVocabularyCubit>().refresh(),
              ),
              SubscriptionEnhancedDropdown(
                name: 'bizStep',
                label: 'Business Step',
                options: bizStepOptions,
                helperText: 'Filter by business process steps',
                isRequired: false,
              ),
              const SizedBox(height: 12),
              SubscriptionEnhancedDropdown(
                name: 'disposition',
                label: 'Disposition',
                options: dispositionOptions,
                helperText: 'Filter by item status or condition',
                isRequired: false,
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'readPoint',
                decoration: const InputDecoration(
                  labelText: 'Read Point (GLN)',
                  hintText: 'https://id.gs1.org/414/0614141123452',
                  border: OutlineInputBorder(),
                  helperText: 'Specific location identifier (optional)',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  helperStyle: TextStyle(),
                ),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'epcPattern',
                decoration: const InputDecoration(
                  labelText: 'EPC Pattern',
                  hintText: 'https://id.gs1.org/01/*',
                  border: OutlineInputBorder(),
                  helperText:
                      'Filter by EPC patterns using wildcards (optional)',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  helperStyle: TextStyle(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
