import 'dart:async';
import 'dart:html' as html;





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
