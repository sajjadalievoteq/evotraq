/// User choice after a partial-success commissioning response.
enum CommissioningPartialSuccessChoice {
  /// Remove selected failed serials and submit a retry for the rest.
  removeSelectedAndRetry,

  /// Keep all failed serials on the wizard and stay (no retry).
  continueWithoutRemoving,

  /// Accept the partial batch and leave the wizard.
  acceptPartialSuccess,
}
