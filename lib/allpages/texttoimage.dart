import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/widgets/app_scaffold.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class texttoimage extends StatefulWidget {
  const texttoimage({super.key});

  @override
  State<texttoimage> createState() => _texttoimageState();
}

class _texttoimageState extends State<texttoimage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _previewKey = GlobalKey();
  String _previewText = '';
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Text to Image',
      actions: [
        IconButton(
          icon: const Icon(Icons.download_rounded),
          onPressed: _saving ? null : _saveImage,
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            'Turn words into an image you can share.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                RepaintBoundary(
                  key: _previewKey,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      _previewText.isEmpty
                          ? 'Your text preview appears here.'
                          : _previewText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  maxLines: 3,
                  onChanged: (value) => setState(() => _previewText = value),
                  decoration: InputDecoration(
                    labelText: 'Text',
                    hintText: 'Type something to render',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _saveImage,
                    icon: const Icon(Icons.download_rounded),
                    label: Text(_saving ? 'Saving...' : 'Save to gallery'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImage() async {
    if (_previewText.trim().isEmpty) {
      Get.snackbar('Text to Image', 'Please enter some text.');
      return;
    }

    setState(() => _saving = true);
    try {
      final status = await _requestSavePermission();
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          _showToast(context, 'Permission denied. Enable it in Settings.');
          await openAppSettings();
        } else {
          _showToast(context, 'Storage permission denied.');
        }
        return;
      }

      final bytes = await _capturePreview();
      final result = await ImageGallerySaver.saveImage(
        bytes,
        name: 'oneapp_text_${DateTime.now().millisecondsSinceEpoch}',
        quality: 100,
      );
      final success = result is Map && (result['isSuccess'] == true);
      final error = result is Map ? result['errorMessage'] as String? : null;
      _showToast(
        context,
        success
            ? 'Image saved to gallery.'
            : (error?.isNotEmpty == true
                ? 'Failed to save: $error'
                : 'Failed to save image.'),
      );
    } catch (e) {
      _showToast(context, 'Failed to save image.');
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<Uint8List> _capturePreview() async {
    final boundary =
        _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<PermissionStatus> _requestSavePermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return PermissionStatus.granted;
    }

    var status = await Permission.photos.status;
    if (status.isGranted) {
      return status;
    }
    status = await Permission.photos.request();
    if (status.isGranted) {
      return status;
    }
    var storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) {
      return storageStatus;
    }
    storageStatus = await Permission.storage.request();
    return storageStatus;
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
