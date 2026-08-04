enum ValidationStatus {
  notValidated,
  valid,
  invalid,
}

extension ValidationStatusExtension on ValidationStatus {
  bool get isValid => this == ValidationStatus.valid;

  bool get isInvalid => this == ValidationStatus.invalid;

  bool get wasValidated => this != ValidationStatus.notValidated;
}
