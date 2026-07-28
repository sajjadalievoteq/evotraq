import 'dart:typed_data';

import 'package:traqtrace_app/core/web/web_download_io.dart' as web_download;

/// Desktop/mobile fallback: save the image so the OS print flow can be used.
Future<void> printImageBytes({
  required List<int> bytes,
  String mimeType = 'image/png',
  String title = 'Barcode',
}) async {
  await web_download.downloadBytes(
    bytes: Uint8List.fromList(bytes),
    filename: '${title.toLowerCase().replaceAll(' ', '_')}.png',
    mimeType: mimeType,
  );
}
