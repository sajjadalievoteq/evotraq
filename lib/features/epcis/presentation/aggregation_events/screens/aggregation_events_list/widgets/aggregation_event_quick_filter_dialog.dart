import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_state.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utils/aggregation_event_ui_constants.dart';

class AggregationEventQuickFilterResult {
  const AggregationEventQuickFilterResult({
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

class AggregationEventQuickFilterDialog extends StatefulWidget {
  const AggregationEventQuickFilterDialog({
    super.key,
    this.selectedAction,
    this.selectedBizStep,
    this.selectedDisposition,
  });

  final String? selectedAction;
  final String? selectedBizStep;
  final String? selectedDisposition;

  static Future<AggregationEventQuickFilterResult?> open(
    BuildContext context, {
    String? selectedAction,
    String? selectedBizStep,
    String? selectedDisposition,
  }) {
    return showDialog<AggregationEventQuickFilterResult>(
      context: context,
      builder: (_) => AggregationEventQuickFilterDialog(
        selectedAction: selectedAction,
        selectedBizStep: selectedBizStep,
        selectedDisposition: selectedDisposition,
      ),
    );
  }

  @override
  State<AggregationEventQuickFilterDialog> createState() =>
      _AggregationEventQuickFilterDialogState();
}

class _AggregationEventQuickFilterDialogState
    extends State<AggregationEventQuickFilterDialog> {
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

  String _capitalizeLabel(String label) {
    if (label.isEmpty) return label;
    return label[0].toUpperCase() + label.substring(1);
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
      final codes = state.bizStepValidDispositions[_bizStep];
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
      title: const Text(AggregationEventUiConstants.dialogQuickFiltersTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: BlocBuilder<CbvVocabularyCubit, CbvVocabularyState>(
            builder: (context, vocabState) {
              final bizSteps = _availableBizSteps(vocabState);
              final dispositions = _availableDispositions(vocabState);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Action',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
                  const Text('Biz Step',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (vocabState.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: bizSteps.map((item) {
                        final selected = _bizStep == item.code;
                        return FilterChip(
                          label: Text(_capitalizeLabel(item.label)),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            if (selected) {
                              _bizStep = null;
                            } else {
                              _bizStep = item.code;
                              _disposition = null;
                            }
                          }),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  const Text('Disposition',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (vocabState.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dispositions.map((item) {
                        final selected = _disposition == item.code;
                        return FilterChip(
                          label: Text(_capitalizeLabel(item.label)),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            _disposition = selected ? null : item.code;
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
          onPressed: () => Navigator.of(context).pop(
            const AggregationEventQuickFilterResult(cleared: true),
          ),
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            AggregationEventQuickFilterResult(
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
