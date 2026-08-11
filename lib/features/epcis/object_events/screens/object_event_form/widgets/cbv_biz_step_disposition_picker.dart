import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_state.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/utils/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/object_event_cbv_biz_step_dropdown.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/object_event_cbv_disposition_dropdown.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/object_event_form_read_only_field.dart';
import 'package:traqtrace_app/features/epcis/object_events/widgets/object_event_form_section_card.dart';

class CbvBizStepDispositionPicker extends StatefulWidget {
  final String? action;
  final String? initialBizStep;
  final String? initialDisposition;
  final EPCISVersion epcisVersion;
  final bool isViewOnly;
  final bool isBizStepMandatory;
  final bool isDispositionMandatory;
  final ObjectEventFormValidationContext validation;
  final ValueChanged<String?> onBizStepChanged;
  final ValueChanged<String?> onDispositionChanged;

  const CbvBizStepDispositionPicker({
    super.key,
    required this.action,
    this.initialBizStep,
    this.initialDisposition,
    required this.epcisVersion,
    required this.isViewOnly,
    required this.isBizStepMandatory,
    required this.isDispositionMandatory,
    required this.validation,
    required this.onBizStepChanged,
    required this.onDispositionChanged,
  });

  @override
  State<CbvBizStepDispositionPicker> createState() =>
      _CbvBizStepDispositionPickerState();
}

class _CbvBizStepDispositionPickerState
    extends State<CbvBizStepDispositionPicker> {
  String? _selectedBizStep;
  String? _selectedDisposition;

  bool _isActionChanging = false;

  String _versionString() =>
      widget.epcisVersion == EPCISVersion.v2_0 ? '2.0' : '1.3';

  String _fmtBizStep(String urn) =>
      CbvVocabularyFormatter.formatBizStep(_versionString(), urn);

  String _fmtDisposition(String urn) =>
      CbvVocabularyFormatter.formatDisposition(_versionString(), urn);

  @override
  void initState() {
    super.initState();
    _selectedBizStep = widget.initialBizStep;
    _selectedDisposition = widget.initialDisposition;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Self-heal: make sure vocabulary is loaded when the screen opens
      // (no-op if already cached; re-fetches if the singleton is stale/empty).
      context.read<CbvVocabularyCubit>().loadVocabulary();
      if (!widget.isViewOnly) {
        final state = context.read<CbvVocabularyCubit>().state;
        if (state.isLoaded) _applyActionDefaults(state);
      }
    });
  }

  @override
  void didUpdateWidget(CbvBizStepDispositionPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isViewOnly) return;

    if (oldWidget.epcisVersion != widget.epcisVersion) {
      _reformatSelectionsForVersion();
    }

    if (oldWidget.action != widget.action) {
      setState(() {
        _selectedBizStep = null;
        _selectedDisposition = null;
        _isActionChanging = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onBizStepChanged(null);
        widget.onDispositionChanged(null);
        final state = context.read<CbvVocabularyCubit>().state;
        if (state.isLoaded) _applyActionDefaults(state);
      });
    }
  }

  void _reformatSelectionsForVersion() {
    if (_selectedBizStep != null) {
      _selectedBizStep = _fmtBizStep(
        CbvVocabularyFormatter.canonicalBizStepUrn(_selectedBizStep!),
      );
      widget.onBizStepChanged(_selectedBizStep);
    }
    if (_selectedDisposition != null) {
      _selectedDisposition = _fmtDisposition(
        CbvVocabularyFormatter.canonicalDispUrn(_selectedDisposition!),
      );
      widget.onDispositionChanged(_selectedDisposition);
    }
  }

  void _applyActionDefaults(CbvVocabularyState state) {
    final allowed = _bizStepsFor(widget.action, state);

    final currentCode = _selectedBizStep == null
        ? null
        : CbvVocabularyFormatter.shortName(
            CbvVocabularyFormatter.canonicalBizStepUrn(_selectedBizStep!),
          );

    if (currentCode == null || !allowed.any((i) => i.code == currentCode)) {
      final defaultCode = state.actionBizStepCodes[widget.action]?.firstOrNull;
      CbvVocabularyItem? next;
      if (defaultCode != null) {
        for (final item in allowed) {
          if (item.code == defaultCode) {
            next = item;
            break;
          }
        }
      }
      next ??= allowed.isNotEmpty ? allowed.first : null;
      _selectedBizStep = next == null ? null : _fmtBizStep(next.urn);
      widget.onBizStepChanged(_selectedBizStep);
    }

    final bizCode = _selectedBizStep == null
        ? null
        : CbvVocabularyFormatter.shortName(
            CbvVocabularyFormatter.canonicalBizStepUrn(_selectedBizStep!),
          );
    final dispAllowed = _dispositionsFor(bizCode, state.dispositions);
    final currentDisp = _selectedDisposition == null
        ? null
        : CbvVocabularyFormatter.shortName(
            CbvVocabularyFormatter.canonicalDispUrn(_selectedDisposition!),
          );
    if (currentDisp == null || !dispAllowed.any((d) => d.code == currentDisp)) {
      final next = dispAllowed.isNotEmpty ? dispAllowed.first : null;
      _selectedDisposition = next == null ? null : _fmtDisposition(next.urn);
      widget.onDispositionChanged(_selectedDisposition);
    }

    setState(() {
      _isActionChanging = false;
    });
  }

  List<CbvVocabularyItem> _bizStepsFor(
    String? action,
    CbvVocabularyState state,
  ) {
    final codes = state.actionBizStepCodes[action];
    final all = state.bizSteps;
    if (codes == null || codes.isEmpty) {
      return all;
    }
    final system = all.where((b) => !b.isCustom && codes.contains(b.code));
    final custom = all.where((b) => b.isCustom);
    return [...system, ...custom];
  }

  List<CbvVocabularyItem> _dispositionsFor(
    String? bizCode,
    List<CbvVocabularyItem> all,
  ) {
    if (bizCode == null) return [];

    final liveCodes = context
        .read<CbvVocabularyCubit>()
        .state
        .bizStepValidDispositions[bizCode];

    if (liveCodes != null && liveCodes.isNotEmpty) {
      final byCode = {for (final d in all) d.code: d};
      return liveCodes
          .map((c) => byCode[c])
          .whereType<CbvVocabularyItem>()
          .toList();
    }

    return all;
  }

  @override
  Widget build(BuildContext context) {
    final titleIsRequired =
        widget.isBizStepMandatory || widget.isDispositionMandatory;

    if (widget.isViewOnly) {
      return ObjectEventFormSectionCard(
        title: 'Business Context',
        showTitleRequiredIndicator: titleIsRequired,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ObjectEventFormReadOnlyText(
              label: 'Business Step',
              value: _selectedBizStep != null
                  ? CbvVocabularyFormatter.shortName(_selectedBizStep!)
                  : null,
            ),
            const SizedBox(height: 16.0),
            ObjectEventFormReadOnlyText(
              label: 'Disposition',
              value: _selectedDisposition != null
                  ? CbvVocabularyFormatter.shortName(_selectedDisposition!)
                  : null,
            ),
          ],
        ),
      );
    }

    return BlocConsumer<CbvVocabularyCubit, CbvVocabularyState>(
      listenWhen: (prev, curr) => !prev.isLoaded && curr.isLoaded,
      listener: (context, state) => _applyActionDefaults(state),
      builder: (context, state) {
        final isLoading =
            _isActionChanging ||
            state.isLoading ||
            state.status == CbvVocabularyStatus.initial;
        final bizSteps = _bizStepsFor(widget.action, state);
        final bizCode = _selectedBizStep == null
            ? null
            : CbvVocabularyFormatter.shortName(
                CbvVocabularyFormatter.canonicalBizStepUrn(_selectedBizStep!),
              );
        final dispositions = _dispositionsFor(bizCode, state.dispositions);
        return ObjectEventFormSectionCard(
          title: 'Business Context',
          showTitleRequiredIndicator: titleIsRequired,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ObjectEventCbvBizStepDropdown(
                items: bizSteps,
                selectedValue: _selectedBizStep,
                epcisVersion: widget.epcisVersion,
                isMandatory: widget.isBizStepMandatory,
                validation: widget.validation,
                isLoading: isLoading,
                hasError: state.hasError,
                onRefresh: () {
                  context.read<CbvVocabularyCubit>().refresh();
                },
                onDefaultSelected: (selected) {
                  if (!mounted) return;
                  setState(() => _selectedBizStep = selected);
                  widget.onBizStepChanged(selected);
                  _applyActionDefaults(
                    context.read<CbvVocabularyCubit>().state,
                  );
                },
                onChanged: (selected) {
                  setState(() {
                    _selectedBizStep = selected;
                    _selectedDisposition = null;
                    widget.onBizStepChanged(selected);
                    widget.onDispositionChanged(null);
                    widget.validation.markFieldAsValid('businessStep');
                    _applyActionDefaults(
                      context.read<CbvVocabularyCubit>().state,
                    );
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ObjectEventCbvDispositionDropdown(
                items: dispositions,
                selectedValue: _selectedDisposition,
                epcisVersion: widget.epcisVersion,
                isMandatory: widget.isDispositionMandatory,
                validation: widget.validation,
                isLoading: isLoading,
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
                    widget.validation.markFieldAsValid('disposition');
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
