import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/shared/validation/gs1_identifier_validation.dart';
import 'package:traqtrace_app/features/validation_workbench/cubit/validation_workbench_state.dart';
import 'package:traqtrace_app/features/validation_workbench/models/validation_section.dart';

class ValidationWorkbenchCubit extends Cubit<ValidationWorkbenchState> {
  ValidationWorkbenchCubit({
    ValidationSection initialSection = ValidationSection.identifier,
  }) : super(ValidationWorkbenchState(selected: initialSection));

  void selectSection(ValidationSection section) {
    if (state.selected == section) return;
    emit(state.copyWith(selected: section));
  }

  void validateIdentifiers({
    String? gtin,
    String? gln,
    String? sscc,
    String? sgtin,
  }) {
    emit(
      state.withSlice(
        ValidationSection.identifier,
        Gs1IdentifierValidation.validate(
          gtin: gtin,
          gln: gln,
          sscc: sscc,
          sgtin: sgtin,
        ),
      ),
    );
  }
}
