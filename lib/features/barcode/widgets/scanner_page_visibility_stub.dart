/// Non-web stub for document visibility.
/// Returns an unsubscribe callback, or null when unsupported.
void Function()? subscribePageVisibility({
  required void Function() onHidden,
  required void Function() onVisible,
}) =>
    null;
