import 'dart:html' as html;



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
