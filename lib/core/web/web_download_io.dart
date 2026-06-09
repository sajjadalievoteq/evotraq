import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<void> downloadBytes({
  required List<int> bytes,
  required String filename,
  String mimeType = 'application/octet-stream',
}) async {
  final path = await FilePicker.saveFile(
    fileName: filename,
    type: FileType.custom,
    allowedExtensions: _extensionsFor(filename),
  );
  if (path == null) return;
  await File(path).writeAsBytes(bytes);
}

List<String>? _extensionsFor(String filename) {
  final dot = filename.lastIndexOf('.');
  if (dot <= 0 || dot == filename.length - 1) return null;
  return [filename.substring(dot + 1).toLowerCase()];
}
