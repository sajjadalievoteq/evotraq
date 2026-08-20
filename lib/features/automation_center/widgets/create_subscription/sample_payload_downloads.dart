import 'package:flutter/material.dart';

class SamplePayloadDownloads extends StatelessWidget {
  const SamplePayloadDownloads({
    super.key,
    required this.onDownloadJson,
    required this.onDownloadXml,
  });

  final VoidCallback onDownloadJson;
  final VoidCallback onDownloadXml;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sample payload for the receiving system',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onDownloadJson,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download Sample JSON'),
            ),
            OutlinedButton.icon(
              onPressed: onDownloadXml,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download Sample XML'),
            ),
          ],
        ),
      ],
    );
  }
}
