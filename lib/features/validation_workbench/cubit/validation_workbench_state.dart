import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';
import 'package:traqtrace_app/features/validation_workbench/models/validation_section.dart';

class ValidationWorkbenchState extends Equatable {
  const ValidationWorkbenchState({
    this.selected = ValidationSection.identifier,
    this.identifier = const WorkbenchSlice(),
    this.batch = const WorkbenchSlice(),
  });

  final ValidationSection selected;
  final WorkbenchSlice identifier;
  final WorkbenchSlice batch;

  WorkbenchSlice sliceFor(ValidationSection section) => switch (section) {
        ValidationSection.identifier => identifier,
        ValidationSection.batch => batch,
      };

  ValidationWorkbenchState copyWith({
    ValidationSection? selected,
    WorkbenchSlice? identifier,
    WorkbenchSlice? batch,
  }) {
    return ValidationWorkbenchState(
      selected: selected ?? this.selected,
      identifier: identifier ?? this.identifier,
      batch: batch ?? this.batch,
    );
  }

  ValidationWorkbenchState withSlice(
    ValidationSection section,
    WorkbenchSlice slice,
  ) {
    return switch (section) {
      ValidationSection.identifier => copyWith(identifier: slice),
      ValidationSection.batch => copyWith(batch: slice),
    };
  }

  @override
  List<Object?> get props => [selected, identifier, batch];
}
