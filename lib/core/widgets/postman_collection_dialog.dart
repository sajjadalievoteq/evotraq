import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/services/postman_collection_service.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';
class PostmanCollectionDialog extends StatefulWidget {
  const PostmanCollectionDialog({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context, {required bool isAdmin}) async {
    Navigator.of(context).pop();

    if (!isAdmin) {
      await _downloadDirect(context);
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const PostmanCollectionDialog(),
    );
  }

  static Future<void> _downloadDirect(BuildContext context) async {
    try {
      final service = PostmanCollectionService(dioService: DioService());
      final info = await service.getDownloadUrl();
      final uri = Uri.parse(info.url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          context.showError('Could not open download link.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  State<PostmanCollectionDialog> createState() =>
      _PostmanCollectionDialogState();
}

class _PostmanCollectionDialogState extends State<PostmanCollectionDialog> {
  late final PostmanCollectionService _service;

  _Status _downloadStatus = _Status.idle;
  _Status _uploadStatus = _Status.idle;

  @override
  void initState() {
    super.initState();
    _service = PostmanCollectionService(dioService: DioService());
  }

  Future<void> _onDownload() async {
    setState(() => _downloadStatus = _Status.loading);
    try {
      final info = await _service.getDownloadUrl();
      final uri = Uri.parse(info.url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not open download link.');
      }
      if (mounted) {
        context.showSuccess('Download started — check your browser.');
      }
    } catch (e) {
      if (mounted) {
        context.showError(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _downloadStatus = _Status.idle);
    }
  }

  Future<void> _onUpload() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip', 'json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final Uint8List? bytes = file.bytes;
    if (bytes == null) {
      if (mounted) context.showError('Could not read file bytes.');
      return;
    }

    setState(() => _uploadStatus = _Status.loading);
    try {
      await _service.uploadCollection(bytes, file.name);
      if (mounted) {
        context.showSuccess(
          '"${file.name}" uploaded successfully. New downloads will use this file.',
          title: 'Upload complete',
        );
      }
    } catch (e) {
      if (mounted) {
        context.showError(
          e.toString().replaceFirst('Exception: ', ''),
          title: 'Upload failed',
        );
      }
    } finally {
      if (mounted) setState(() => _uploadStatus = _Status.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.api, color: colors.primary),
          const SizedBox(width: 10),
          const Text('Postman Collection'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 340, maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Download the latest Traq API collection, or upload a new version to replace the hosted file.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            _ActionCard(
              icon: Icons.download_rounded,
              title: 'Download Collection',
              subtitle: 'Get the latest Postman collection zip',
              color: colors.primary,
              isLoading: _downloadStatus == _Status.loading,
              onTap: _downloadStatus == _Status.loading ? null : _onDownload,
            ),

            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.upload_rounded,
              title: 'Upload New Collection',
              subtitle: 'Replace the hosted file (.zip or .json)',
              color: Colors.orange.shade700,
              isLoading: _uploadStatus == _Status.loading,
              onTap: _uploadStatus == _Status.loading ? null : _onUpload,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }
}

enum _Status { idle, loading }

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: color,
                        ),
                      )
                    : Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: onTap == null
                            ? Colors.grey
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: onTap == null ? Colors.grey.shade400 : color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
