import 'dart:async';
import 'dart:html' as html;

/// Listens to `document.visibilitychange` so the camera releases when the tab
/// is hidden (Flutter lifecycle can be incomplete on web).
///
/// Returns an unsubscribe callback.
void Function()? subscribePageVisibility({
  required void Function() onHidden,
  required void Function() onVisible,
}) {
  late final StreamSubscription<html.Event> subscription;
  subscription = html.document.onVisibilityChange.listen((_) {
    if (html.document.hidden == true) {
      onHidden();
    } else {
      onVisible();
    }
  });
  return () {
    subscription.cancel();
  };
}
