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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Extract text from an image',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap the image button to choose a photo.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: media.size.height * 0.25,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5FF),
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
                        : const Center(
                            child: Icon(
                              Icons.image_search_rounded,
                              size: 48,
                              color: Colors.black38,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _scanningText.isEmpty
                        ? 'Recognized text will appear here.'
                        : _scanningText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();

    final buffer = StringBuffer();
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        buffer.writeln(line.text);
      }
    }

    setState(() {
      _textScanning = false;
      _scanningText = buffer.toString().trim();
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _scanningText));
    Get.snackbar('Copied', 'Text copied to clipboard.');
  }
}
