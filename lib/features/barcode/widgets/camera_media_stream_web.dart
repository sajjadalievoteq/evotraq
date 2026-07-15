import 'dart:html' as html;

/// Belt-and-suspenders for Flutter web: stop any leftover camera tracks on
/// video elements after mobile_scanner stop/dispose (clears LED / recording).
void forceStopActiveCameraTracks() {
  try {
    final videos = html.document.querySelectorAll('video');
    for (final node in videos) {
      if (node is! html.VideoElement) continue;
      final stream = node.srcObject;
      if (stream == null) continue;
      for (final track in stream.getTracks()) {
        track.stop();
      }
      node.srcObject = null;
    }
  } catch (_) {}
}
