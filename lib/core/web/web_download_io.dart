import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<void> downloadBytes({
  required List<int> bytes,
  required String filename,
  String mimeType = 'application/octet-stream',
}) async {
  await FilePicker.saveFile(
    fileName: filename,
    bytes: Uint8List.fromList(bytes),
    mimeType: mimeType,
    type: FileType.custom,
    allowedExtensions: _extensionsFor(filename),
  );
}

List<String>? _extensionsFor(String filename) {
  final dot = filename.lastIndexOf('.');
  if (dot <= 0 || dot == filename.length - 1) return null;
  return [filename.substring(dot + 1).toLowerCase()];
}
