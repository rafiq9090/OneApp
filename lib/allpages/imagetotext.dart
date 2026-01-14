import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/widgets/app_scaffold.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class imagetotext extends StatefulWidget {
  const imagetotext({super.key});

  @override
  State<imagetotext> createState() => _imagetotextState();
}

class _imagetotextState extends State<imagetotext> {
  bool _textScanning = false;
  XFile? _imageFile;
  String _scanningText = '';

  @override
  void dispose() {
    _imageFile = null;
    _scanningText = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final surface = colors.surface;
    final surfaceVariant = colors.surfaceVariant;
    final onSurface = colors.onSurface;
    final onSurfaceMuted = onSurface.withOpacity(0.7);
    final media = MediaQuery.of(context);
    return AppScaffold(
      title: 'Image to Text',
      actions: [
        IconButton(
          icon: const Icon(Icons.image_rounded),
          onPressed: _pickImage,
        ),
        IconButton(
          icon: const Icon(Icons.copy_all_rounded),
          onPressed: _scanningText.isEmpty ? null : _copyToClipboard,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Extract text from an image',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Auto-detects multiple scripts for best result.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onSurfaceMuted,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: media.size.height * 0.25,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_imageFile!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.image_search_rounded,
                              size: 48,
                              color: onSurfaceMuted,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (_textScanning)
                    const LinearProgressIndicator(minHeight: 3),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            size: 18,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Recognized Text',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (_scanningText.isNotEmpty)
                          _StatChip(label: '${_wordCount(_scanningText)} words'),
                        if (_scanningText.isNotEmpty) const SizedBox(width: 8),
                        if (_scanningText.isNotEmpty)
                          _StatChip(label: '${_scanningText.length} chars'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _scanningText.isEmpty
                              ? 'Recognized text will appear here.'
                              : _formatOcrText(_scanningText),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: _scanningText.isEmpty
                                ? FontWeight.w400
                                : FontWeight.w500,
                            color: _scanningText.isEmpty
                                ? onSurfaceMuted
                                : onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickerImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickerImage == null) {
        return;
      }
      setState(() {
        _textScanning = true;
        _imageFile = pickerImage;
        _scanningText = '';
      });
      await _getRecognisedText(pickerImage);
    } catch (e) {
      setState(() {
        _textScanning = false;
        _imageFile = null;
        _scanningText = 'Error occurred while scanning.';
      });
    }
  }

  Future<void> _getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final scripts = [
      TextRecognitionScript.latin,
      TextRecognitionScript.chinese,
      TextRecognitionScript.devanagiri,
      TextRecognitionScript.japanese,
      TextRecognitionScript.korean,
    ];

    String bestText = '';
    int bestScore = 0;

    for (final script in scripts) {
      final recognizer = GoogleMlKit.vision.textRecognizer(script: script);
      final recognizedText = await recognizer.processImage(inputImage);
      await recognizer.close();

      final buffer = StringBuffer();
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          buffer.writeln(line.text);
        }
      }

      final text = buffer.toString().trim();
      final score = text.replaceAll(RegExp(r'\s+'), '').length;
      if (score > bestScore) {
        bestScore = score;
        bestText = text;
      }
    }

    setState(() {
      _textScanning = false;
      _scanningText = bestText;
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _scanningText));
    Get.snackbar('Copied', 'Text copied to clipboard.');
  }

  String _formatOcrText(String text) {
    final normalized = text.replaceAll('\r\n', '\n').replaceAll('\t', ' ');
    final collapsedSpaces = normalized.replaceAll(RegExp(r'[ ]{2,}'), ' ');
    return collapsedSpaces.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  int _wordCount(String text) {
    return text
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .length;
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface.withOpacity(0.7),
            ),
      ),
    );
  }
}
