import 'dart:convert';
import 'dart:html' as html;

Future<void> printImageBytes({
  required List<int> bytes,
  String mimeType = 'image/png',
  String title = 'Barcode',
}) async {
  final dataUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
  final htmlContent = '''
<!DOCTYPE html>
<html>
  <head>
    <title>$title</title>
    <style>
      html, body { margin: 0; padding: 0; background: #fff; }
      img { max-width: 100%; display: block; margin: 24px auto; }
    </style>
  </head>
  <body>
    <img src="$dataUrl" alt="$title" onload="window.focus(); window.print();" />
  </body>
</html>
''';

  final blob = html.Blob([htmlContent], 'text/html');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final opened = html.window.open(url, '_blank', 'noopener,noreferrer');
  if (opened is! html.Window) {
    html.Url.revokeObjectUrl(url);
    throw StateError('Unable to open print window (popup blocked)');
  }

  // Revoke after the print window has had a chance to load.
  Future<void>.delayed(const Duration(seconds: 60), () {
    html.Url.revokeObjectUrl(url);
  });
}
