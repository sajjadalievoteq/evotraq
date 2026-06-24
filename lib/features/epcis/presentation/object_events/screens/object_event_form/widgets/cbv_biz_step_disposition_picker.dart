import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_formatter.dart';
import 'package:traqtrace_app/data/models/epcis/cbv_vocabulary_item.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_cubit.dart';
import 'package:traqtrace_app/features/epcis/cubit/cbv_vocabulary_state.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_validation_context.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/utils/object_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_error_banner.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_field_decoration.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_read_only_field.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/widgets/object_event_form_section_card.dart';

/// Biz-step + disposition dropdowns for an Object Event form.
///
/// Vocabulary is read from the app-wide [CbvVocabularyCubit] — no API call
/// is made here. The cubit is loaded once at the splash screen.
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

  /// True for exactly one frame after the action changes, while the new
  /// defaults are being resolved. Drives the skeleton loader.
  bool _isActionChanging = false;

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _versionString() =>
      widget.epcisVersion == EPCISVersion.v2_0 ? '2.0' : '1.3';

  String _fmtBizStep(String urn) =>
      CbvVocabularyFormatter.formatBizStep(_versionString(), urn);

  String _fmtDisposition(String urn) =>
      CbvVocabularyFormatter.formatDisposition(_versionString(), urn);

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _selectedBizStep = widget.initialBizStep;
    _selectedDisposition = widget.initialDisposition;
    if (!widget.isViewOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final state = context.read<CbvVocabularyCubit>().state;
          if (state.isLoaded) _applyActionDefaults(state);
        }
      });
    }
  }

  @override
  void didUpdateWidget(CbvBizStepDispositionPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isViewOnly) return;

    if (oldWidget.epcisVersion != widget.epcisVersion) {
      _reformatSelectionsForVersion();
    }

    if (oldWidget.action != widget.action) {
      // Clear local state and show skeleton. setState is safe in didUpdateWidget
      // because Flutter re-queues this widget in the same frame.
      setState(() {
        _selectedBizStep = null;
        _selectedDisposition = null;
        _isActionChanging = true;
      });
      // Parent callbacks must NOT be called here — didUpdateWidget runs inside
      // Flutter's build phase and calling the parent's onChanged would trigger
      // setState on an ancestor widget mid-build, causing the
      // "setState() called during build" assertion. Defer everything.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onBizStepChanged(null);
        widget.onDispositionChanged(null);
        final state = context.read<CbvVocabularyCubit>().state;
        if (state.isLoaded) _applyActionDefaults(state);
      });
    }
  }

  // ─── Selection logic ───────────────────────────────────────────────────────

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
      final defaultCode =
          state.actionBizStepCodes[widget.action]?.firstOrNull;
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

  // ─── Filtering ─────────────────────────────────────────────────────────────

  List<CbvVocabularyItem> _bizStepsFor(
      String? action, CbvVocabularyState state) {
    final codes = state.actionBizStepCodes[action];
    final all = state.bizSteps;
    if (codes == null || codes.isEmpty) {
      return all;
    }
    // System items follow the per-action allowlist from the backend.
    // Custom items (created by admin) are appended to every action's list
    // because they have no predefined action mapping.
    final system = all.where((b) => !b.isCustom && codes.contains(b.code));
    final custom = all.where((b) => b.isCustom);
    return [...system, ...custom];
  }

  List<CbvVocabularyItem> _dispositionsFor(
      String? bizCode, List<CbvVocabularyItem> all) {
    if (bizCode == null) return [];

    // Use the live pair matrix from the backend — the vocabulary management
    // screen is the single source of truth for bizStep × disposition pairings.
    final liveCodes = context
        .read<CbvVocabularyCubit>()
        .state
        .bizStepValidDispositions[bizCode];

    if (liveCodes != null && liveCodes.isNotEmpty) {
      // Preserve backend order; skip any code not in the enabled session list.
      final byCode = {for (final d in all) d.code: d};
      return liveCodes
          .map((c) => byCode[c])
          .whereType<CbvVocabularyItem>()
          .toList();
    }

    // No pairing data for this bizStep — show all enabled dispositions.
    return all;
  }

  // ─── Skeleton loader ───────────────────────────────────────────────────────

  Widget _buildFieldSkeleton(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown field placeholder
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white24),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Dropdown helpers ──────────────────────────────────────────────────────
  // Flat list only — group_name is for DB/admin grouping, not shown in the picker
  // (headers looked selectable, e.g. "Miscellaneous", "Creation & Commissioning").

  List<DropdownMenuItem<String>> _buildMenuItems({
    required List<CbvVocabularyItem> items,
    required String Function(String urn) formatter,
  }) {
    return items
        .map(
          (item) => DropdownMenuItem<String>(
            value: formatter(item.urn),
            child: Text(item.label),
          ),
        )
        .toList();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

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
        return ObjectEventFormSectionCard(
          title: 'Business Context',
          showTitleRequiredIndicator: titleIsRequired,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBizStepDropdown(state),
              const SizedBox(height: 16.0),
              _buildDispositionDropdown(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBizStepDropdown(CbvVocabularyState state) {
    if (_isActionChanging ||
        state.isLoading ||
        state.status == CbvVocabularyStatus.initial) {
      return _buildFieldSkeleton('Business Step');
    }

    if (state.hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ObjectEventFormErrorBanner(
            message: 'Could not load vocabulary. Please retry.',
            onDismiss: () {},
          ),
          TextButton.icon(
            onPressed: () => context.read<CbvVocabularyCubit>().refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      );
    }

    final bizSteps = _bizStepsFor(widget.action, state);
    if (bizSteps.isEmpty) {
      return const Text(
        'No business step options are available.',
        style: TextStyle(color: Colors.grey),
      );
    }

    final selectable = bizSteps.map((i) => _fmtBizStep(i.urn)).toList();
    String? dropdownValue =
        _selectedBizStep != null && selectable.contains(_selectedBizStep)
            ? _selectedBizStep
            : null;

    // Auto-select first item if nothing is chosen yet.
    if (dropdownValue == null && selectable.isNotEmpty) {
      dropdownValue = selectable.first;
      if (_selectedBizStep != dropdownValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _selectedBizStep = dropdownValue);
          widget.onBizStepChanged(dropdownValue);
          _applyActionDefaults(context.read<CbvVocabularyCubit>().state);
        });
      }
    }

    return DropdownButtonFormField<String>(
      value: dropdownValue,
      decoration: ObjectEventFormFieldDecoration.getFieldDecoration(
        context: context,
        fieldName: 'businessStep',
        label: 'Business Step',
        hintText: 'Select a business step',
        isMandatory: widget.isBizStepMandatory,
        validation: widget.validation,
      ),
      items: _buildMenuItems(items: bizSteps, formatter: _fmtBizStep),
      validator: (v) {
        final error = ObjectEventFormValidators.validateBusinessStepCbv(
          v,
          epcisVersion: widget.epcisVersion,
        );
        widget.validation.setFieldError('businessStep', error);
        return error;
      },
      onChanged: (selected) {
        if (selected == null) return;
        setState(() {
          _selectedBizStep = selected;
          _selectedDisposition = null;
          widget.onBizStepChanged(selected);
          widget.onDispositionChanged(null);
          widget.validation.markFieldAsValid('businessStep');
          _applyActionDefaults(context.read<CbvVocabularyCubit>().state);
        });
      },
    );
  }

  Widget _buildDispositionDropdown(CbvVocabularyState state) {
    if (_isActionChanging ||
        state.isLoading ||
        state.status == CbvVocabularyStatus.initial) {
      return _buildFieldSkeleton('Disposition');
    }

    final bizCode = _selectedBizStep == null
        ? null
        : CbvVocabularyFormatter.shortName(
            CbvVocabularyFormatter.canonicalBizStepUrn(_selectedBizStep!),
          );
    final dispositions = _dispositionsFor(bizCode, state.dispositions);
    final disabled = _selectedBizStep == null;

    if (!disabled && dispositions.isEmpty) {
      return const Text(
        'No disposition options for the selected business step.',
        style: TextStyle(color: Colors.grey),
      );
    }

    final selectable = dispositions.map((d) => _fmtDisposition(d.urn)).toList();
    String? dropdownValue =
        _selectedDisposition != null && selectable.contains(_selectedDisposition)
            ? _selectedDisposition
            : null;

    // Auto-select first item if nothing is chosen yet.
    if (dropdownValue == null && selectable.isNotEmpty) {
      dropdownValue = selectable.first;
      if (_selectedDisposition != dropdownValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _selectedDisposition = dropdownValue);
          widget.onDispositionChanged(dropdownValue);
        });
      }
    }

    return DropdownButtonFormField<String>(
      value: dropdownValue,
      decoration: ObjectEventFormFieldDecoration.getFieldDecoration(
        context: context,
        fieldName: 'disposition',
        label: 'Disposition',
        hintText: 'Select a disposition',
        isMandatory: widget.isDispositionMandatory,
        validation: widget.validation,
      ),
      items: _buildMenuItems(items: dispositions, formatter: _fmtDisposition),
      validator: (v) {
        final error = ObjectEventFormValidators.validateDispositionCbv(v);
        widget.validation.setFieldError('disposition', error);
        return error;
      },
      onChanged: disabled
          ? null
          : (selected) {
              if (selected == null) return;
              setState(() {
                _selectedDisposition = selected;
                widget.onDispositionChanged(selected);
                widget.validation.markFieldAsValid('disposition');
              });
            },
    );
  }
}
