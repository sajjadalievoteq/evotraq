import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_state.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

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


  String _version() =>
      widget.epcisVersion == EPCISVersion.v2_0 ? '2.0' : '1.3';

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
    String? bizVal = _selectedBizStep != null && selectable.contains(_selectedBizStep)
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

    final dispSelectable = dispositions.map((d) => _fmtDisposition(d.urn)).toList();
    String? dispVal =
        _selectedDisposition != null && dispSelectable.contains(_selectedDisposition)
            ? _selectedDisposition
            : null;

    if (dispVal == null && dispSelectable.isNotEmpty) {
      dispVal = dispSelectable.first;
      setState(() => _selectedDisposition = dispVal);
      widget.onDispositionChanged(dispVal);
    }
  }

  List<CbvVocabularyItem> _bizStepsFor(String? action, CbvVocabularyState state) {
    if (action == null) return state.bizSteps;
    final codes = state.actionBizStepCodes[action];
    if (codes == null || codes.isEmpty) return state.bizSteps;
    final byCode = {for (final b in state.bizSteps) b.code: b};
    return codes.map((c) => byCode[c]).whereType<CbvVocabularyItem>().toList();
  }


  List<CbvVocabularyItem> _dispositionsFor(
      String? bizCode, CbvVocabularyState state) {
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


  Widget _skeleton() => AppShimmer(
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white24),
          ),
        ),
      );


  List<DropdownMenuItem<String>> _menuItems({
    required List<CbvVocabularyItem> items,
    required String Function(String urn) formatter,
  }) =>
      items
          .map(
            (item) => DropdownMenuItem<String>(
              value: formatter(item.urn),
              child: Tooltip(message: item.urn, child: Text(item.label)),
            ),
          )
          .toList();


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
              _skeleton(),
              const SizedBox(height: 16),
              _skeleton(),
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBizStepDropdown(state),
            const SizedBox(height: 16),
            _buildDispositionDropdown(state),
          ],
        );
      },
    );
  }

  Widget _buildBizStepDropdown(CbvVocabularyState state) {
    final bizSteps = _bizStepsFor(widget.action, state);
    if (bizSteps.isEmpty) {
      return const Text(
        'No business steps available.',
        style: TextStyle(color: Colors.grey),
      );
    }

    final selectable = bizSteps.map((i) => _fmtBizStep(i.urn)).toList();
    String? value = _selectedBizStep != null && selectable.contains(_selectedBizStep)
        ? _selectedBizStep
        : null;

    if (value == null && selectable.isNotEmpty) {
      value = selectable.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedBizStep = value);
        widget.onBizStepChanged(value);
        _applyDefaults(context.read<CbvVocabularyCubit>().state);
      });
    }

    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Business Step *',
        border: OutlineInputBorder(),
        hintText: 'Select a business step',
        helperText: 'The business process step associated with this event',
        suffixIcon: Tooltip(
          message: 'Standard GS1 business steps from Core Business Vocabulary',
          child: TraqIcon(AppAssets.iconInfo, size: 16),
        ),
      ),
      items: _menuItems(items: bizSteps, formatter: _fmtBizStep),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please select a business step';
        return null;
      },
      onChanged: (selected) {
        if (selected == null) return;
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
    );
  }

  Widget _buildDispositionDropdown(CbvVocabularyState state) {
    final bizCode = _selectedBizStep == null
        ? null
        : CbvVocabularyFormatter.shortName(
            CbvVocabularyFormatter.canonicalBizStepUrn(_selectedBizStep!),
          );
    final dispositions = _dispositionsFor(bizCode, state);
    final disabled = _selectedBizStep == null;

    if (!disabled && dispositions.isEmpty) {
      return const Text(
        'No disposition options for the selected business step.',
        style: TextStyle(color: Colors.grey),
      );
    }

    final selectable = dispositions.map((d) => _fmtDisposition(d.urn)).toList();
    String? value =
        _selectedDisposition != null && selectable.contains(_selectedDisposition)
            ? _selectedDisposition
            : null;

    if (value == null && selectable.isNotEmpty) {
      value = selectable.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedDisposition = value);
        widget.onDispositionChanged(value);
      });
    }

    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Disposition *',
        border: OutlineInputBorder(),
        hintText: 'Select a disposition',
        helperText: 'The business condition of the objects',
        suffixIcon: Tooltip(
          message: 'Standard GS1 dispositions from Core Business Vocabulary',
          child: TraqIcon(AppAssets.iconInfo, size: 16),
        ),
      ),
      items: _menuItems(items: dispositions, formatter: _fmtDisposition),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please select a disposition';
        return null;
      },
      onChanged: disabled
          ? null
          : (selected) {
              if (selected == null) return;
              setState(() {
                _selectedDisposition = selected;
                widget.onDispositionChanged(selected);
              });
            },
    );
  }
}
