import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_state.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_events_list/utils/object_event_list_ui_constants.dart';

class ObjectEventQuickFilterResult {
  const ObjectEventQuickFilterResult({
    this.action,
    this.bizStep,
    this.disposition,
    this.cleared = false,
  });

  final String? action;
  final String? bizStep;
  final String? disposition;
  final bool cleared;
}

class ObjectEventQuickFilterDialog extends StatefulWidget {
  const ObjectEventQuickFilterDialog({
    super.key,
    this.selectedAction,
    this.selectedBizStep,
    this.selectedDisposition,
  });

  final String? selectedAction;
  final String? selectedBizStep;
  final String? selectedDisposition;

  static Future<ObjectEventQuickFilterResult?> open(
    BuildContext context, {
    String? selectedAction,
    String? selectedBizStep,
    String? selectedDisposition,
  }) {
    return showDialog<ObjectEventQuickFilterResult>(
      context: context,
      builder: (_) => ObjectEventQuickFilterDialog(
        selectedAction: selectedAction,
        selectedBizStep: selectedBizStep,
        selectedDisposition: selectedDisposition,
      ),
    );
  }

  @override
  State<ObjectEventQuickFilterDialog> createState() =>
      _ObjectEventQuickFilterDialogState();
}

class _ObjectEventQuickFilterDialogState
    extends State<ObjectEventQuickFilterDialog> {
  String? _action;
  String? _bizStep;
  String? _disposition;

  static const _actions = ['ADD', 'OBSERVE', 'DELETE'];

  @override
  void initState() {
    super.initState();
    _action = widget.selectedAction;
    _bizStep = widget.selectedBizStep;
    _disposition = widget.selectedDisposition;
  }

  List<CbvVocabularyItem> _availableBizSteps(CbvVocabularyState state) {
    final codes = state.actionBizStepCodes[_action];
    final all = state.bizSteps;
    if (codes == null || codes.isEmpty) {
      return all;
    }
    final system = all.where((b) => !b.isCustom && codes.contains(b.code));
    final custom = all.where((b) => b.isCustom);
    return [...system, ...custom];
  }

  List<CbvVocabularyItem> _availableDispositions(CbvVocabularyState state) {
    final all = state.dispositions;
    if (_bizStep != null) {
      final bizCode = _bizStep!.split(':').last;
      final codes = state.bizStepValidDispositions[bizCode];
      if (codes != null && codes.isNotEmpty) {
        final byCode = {for (final d in all) d.code: d};
        return codes
            .map((c) => byCode[c])
            .whereType<CbvVocabularyItem>()
            .toList();
      }
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ObjectEventListUiConstants.dialogQuickFiltersTitle),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: BlocBuilder<CbvVocabularyCubit, CbvVocabularyState>(
            builder: (context, vocabState) {
              final bizSteps = _availableBizSteps(vocabState);
              final dispositions = _availableDispositions(vocabState);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Action',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _actions.map((a) {
                      final selected = _action == a;
                      return FilterChip(
                        label: Text(a),
                        selected: selected,
                        onSelected: (_) => setState(() {
                          if (selected) {
                            _action = null;
                          } else {
                            _action = a;
                            _bizStep = null;
                            _disposition = null;
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Biz Step',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 8),
                  if (vocabState.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: bizSteps.map((item) {
                        final selected = _bizStep == item.urn;
                        return FilterChip(
                          label: Text(item.label),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            if (selected) {
                              _bizStep = null;
                            } else {
                              _bizStep = item.urn;
                              _disposition = null;
                            }
                          }),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  Text('Disposition',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 8),
                  if (vocabState.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: dispositions.map((item) {
                        final selected = _disposition == item.urn;
                        return FilterChip(
                          label: Text(item.label),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            _disposition = selected ? null : item.urn;
                          }),
                        );
                      }).toList(),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context)
              .pop(const ObjectEventQuickFilterResult(cleared: true)),
          child: const Text('Clear'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            ObjectEventQuickFilterResult(
              action: _action,
              bizStep: _bizStep,
              disposition: _disposition,
            ),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
