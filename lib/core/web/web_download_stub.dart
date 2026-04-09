void downloadBytes({
  required List<int> bytes,
  required String filename,
  String mimeType = 'application/octet-stream',
}) {
  throw UnsupportedError('File download is only supported on web.');
}

