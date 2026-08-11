import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_state.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/widgets/aggregation_cbv_dropdown_field.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/widgets/aggregation_cbv_field_skeleton.dart';

class AggregationCbvPicker extends StatefulWidget {
  final String? action;
  final String? initialBizStep;
  final String? initialDisposition;
  final EPCISVersion epcisVersion;
  final ValueChanged<String?> onBizStepChanged;
  final ValueChanged<String?> onDispositionChanged;

  const AggregationCbvPicker({
    super.key,
    this.action,
    this.initialBizStep,
    this.initialDisposition,
    required this.epcisVersion,
    required this.onBizStepChanged,
    required this.onDispositionChanged,
  });

  @override
  State<AggregationCbvPicker> createState() => _AggregationCbvPickerState();
}

class _AggregationCbvPickerState extends State<AggregationCbvPicker> {
  String? _selectedBizStep;
  String? _selectedDisposition;

  String _version() => widget.epcisVersion == EPCISVersion.v2_0 ? '2.0' : '1.3';

  String _fmtBizStep(String urn) =>
      CbvVocabularyFormatter.formatBizStep(_version(), urn);

  String _fmtDisposition(String urn) =>
      CbvVocabularyFormatter.formatDisposition(_version(), urn);

  @override
  void initState() {
    super.initState();
    _selectedBizStep = widget.initialBizStep;
    _selectedDisposition = widget.initialDisposition;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Self-heal: ensure vocabulary is loaded on open (no-op if cached).
      context.read<CbvVocabularyCubit>().loadVocabulary();
      final state = context.read<CbvVocabularyCubit>().state;
      if (state.isLoaded) _applyDefaults(state);
    });
  }

  @override
  void didUpdateWidget(AggregationCbvPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.action != widget.action) {
      setState(() {
        _selectedBizStep = null;
        _selectedDisposition = null;
      });
      _applyDefaults(context.read<CbvVocabularyCubit>().state);
    }
  }

  void _applyDefaults(CbvVocabularyState state) {
    final bizSteps = _bizStepsFor(widget.action, state);
    if (bizSteps.isEmpty) return;

    final selectable = bizSteps.map((i) => _fmtBizStep(i.urn)).toList();
    String? bizVal =
        _selectedBizStep != null && selectable.contains(_selectedBizStep)
        ? _selectedBizStep
        : null;

    if (bizVal == null) {
      bizVal = selectable.first;
      setState(() => _selectedBizStep = bizVal);
      widget.onBizStepChanged(bizVal);
    }

    final bizCode = CbvVocabularyFormatter.shortName(
      CbvVocabularyFormatter.canonicalBizStepUrn(bizVal),
    );
    final dispositions = _dispositionsFor(bizCode, state);

    final dispSelectable = dispositions
        .map((d) => _fmtDisposition(d.urn))
        .toList();
    String? dispVal =
        _selectedDisposition != null &&
            dispSelectable.contains(_selectedDisposition)
        ? _selectedDisposition
        : null;

    if (dispVal == null && dispSelectable.isNotEmpty) {
      dispVal = dispSelectable.first;
      setState(() => _selectedDisposition = dispVal);
      widget.onDispositionChanged(dispVal);
    }
  }

  List<CbvVocabularyItem> _bizStepsFor(
    String? action,
    CbvVocabularyState state,
  ) {
    if (action == null) return state.bizSteps;
    final codes = state.actionBizStepCodes[action];
    if (codes == null || codes.isEmpty) return state.bizSteps;
    final byCode = {for (final b in state.bizSteps) b.code: b};
    return codes.map((c) => byCode[c]).whereType<CbvVocabularyItem>().toList();
  }

  List<CbvVocabularyItem> _dispositionsFor(
    String? bizCode,
    CbvVocabularyState state,
  ) {
    if (bizCode == null) return [];

    final liveCodes = state.bizStepValidDispositions[bizCode];
    if (liveCodes != null && liveCodes.isNotEmpty) {
      final byCode = {for (final d in state.dispositions) d.code: d};
      return liveCodes
          .map((c) => byCode[c])
          .whereType<CbvVocabularyItem>()
          .toList();
    }

    return state.dispositions;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CbvVocabularyCubit, CbvVocabularyState>(
      listenWhen: (prev, curr) => !prev.isLoaded && curr.isLoaded,
      listener: (_, state) => _applyDefaults(state),
      builder: (context, state) {
        if (state.isLoading || state.status == CbvVocabularyStatus.initial) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AggregationCbvFieldSkeleton(),
              const SizedBox(height: 16),
              const AggregationCbvFieldSkeleton(),
            ],
          );
        }

        if (state.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Could not load vocabulary. Please retry.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              TextButton.icon(
                onPressed: () => context.read<CbvVocabularyCubit>().refresh(),
                icon: TraqIcon(AppAssets.iconRefresh),
                label: const Text('Retry'),
              ),
            ],
          );
        }

        final bizSteps = _bizStepsFor(widget.action, state);
        final bizCode = _selectedBizStep == null
            ? null
            : CbvVocabularyFormatter.shortName(
                CbvVocabularyFormatter.canonicalBizStepUrn(_selectedBizStep!),
              );
        final dispositions = _dispositionsFor(bizCode, state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AggregationCbvDropdownField(
              items: bizSteps,
              selectedValue: _selectedBizStep,
              epcisVersion: widget.epcisVersion,
              isBusinessStep: true,
              label: 'Business Step *',
              hint: 'Select a business step',
              helperText:
                  'The business process step associated with this event',
              tooltip:
                  'Standard GS1 business steps from Core Business Vocabulary',
              emptyMessage: 'No business steps available.',
              disabled: false,
              onDefaultSelected: (selected) {
                if (!mounted) return;
                setState(() => _selectedBizStep = selected);
                widget.onBizStepChanged(selected);
                _applyDefaults(context.read<CbvVocabularyCubit>().state);
              },
              onChanged: (selected) {
                setState(() {
                  _selectedBizStep = selected;
                  _selectedDisposition = null;
                  widget.onBizStepChanged(selected);
                  widget.onDispositionChanged(null);
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _applyDefaults(context.read<CbvVocabularyCubit>().state);
                });
              },
            ),
            const SizedBox(height: 16),
            AggregationCbvDropdownField(
              items: dispositions,
              selectedValue: _selectedDisposition,
              epcisVersion: widget.epcisVersion,
              isBusinessStep: false,
              label: 'Disposition *',
              hint: 'Select a disposition',
              helperText: 'The business condition of the objects',
              tooltip:
                  'Standard GS1 dispositions from Core Business Vocabulary',
              emptyMessage:
                  'No disposition options for the selected business step.',
              disabled: _selectedBizStep == null,
              onDefaultSelected: (selected) {
                if (!mounted) return;
                setState(() => _selectedDisposition = selected);
                widget.onDispositionChanged(selected);
              },
              onChanged: (selected) {
                setState(() {
                  _selectedDisposition = selected;
                  widget.onDispositionChanged(selected);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
