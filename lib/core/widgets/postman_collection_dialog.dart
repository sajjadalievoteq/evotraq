import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/network/dio_service.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/web/web_download_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/web_download_web.dart'
    if (dart.library.io) 'package:traqtrace_app/core/web/web_download_io.dart'
    as web_download;
import 'package:traqtrace_app/data/services/postman_collection_service.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
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
      final file = await service.downloadCollection();
      web_download.downloadBytes(
        bytes: file.bytes,
        filename: file.filename,
        mimeType: _mimeTypeFor(file.filename),
      );
      if (context.mounted) {
        context.showSuccess('Downloaded ${file.filename}');
      }
    } catch (e) {
      if (context.mounted) {
        context.showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  static String _mimeTypeFor(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.zip')) return 'application/zip';
    if (lower.endsWith('.json')) return 'application/json';
    return 'application/octet-stream';
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
      final file = await _service.downloadCollection();
      web_download.downloadBytes(
        bytes: file.bytes,
        filename: file.filename,
        mimeType: PostmanCollectionDialog._mimeTypeFor(file.filename),
      );
      if (mounted) {
        context.showSuccess('Downloaded ${file.filename}');
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
          TraqIcon(AppAssets.iconGlobe, color: colors.primary),
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
              iconAsset: AppAssets.iconDownload,
              title: 'Download Collection',
              subtitle: 'Get the latest Postman collection zip',
              color: colors.primary,
              isLoading: _downloadStatus == _Status.loading,
              onTap: _downloadStatus == _Status.loading ? null : _onDownload,
            ),

            const SizedBox(height: 12),

            _ActionCard(
              iconAsset: AppAssets.iconUpload,
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
  final String iconAsset;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.iconAsset,
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
                    : TraqIcon(iconAsset, color: color, size: 22),
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
              TraqIcon(AppAssets.iconChevronR,
                color: onTap == null ? Colors.grey.shade400 : color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
