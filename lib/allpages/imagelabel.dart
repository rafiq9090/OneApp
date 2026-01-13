import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/app_scaffold.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class imagelabel extends StatefulWidget {
  const imagelabel({super.key});

  @override
  State<imagelabel> createState() => _imagelabelState();
}

class _imagelabelState extends State<imagelabel> {
  bool _labeling = false;
  XFile? _imageFile;
  String _labels = '';

  @override
  void dispose() {
    _imageFile = null;
    _labels = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return AppScaffold(
      title: 'Image Labeling',
      actions: [
        IconButton(
          icon: const Icon(Icons.image_rounded),
          onPressed: _pickImage,
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
                    'Identify objects in photos',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick an image to generate smart labels.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: media.size.height * 0.25,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1FFF5),
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
                              Icons.label_important_rounded,
                              size: 48,
                              color: Colors.black38,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (_labeling)
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
                  child: Text(
                    _labels.isEmpty
                        ? 'Labels will appear here.'
                        : _labels,
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
        _labeling = true;
        _imageFile = pickerImage;
        _labels = '';
      });
      await _getImageLabel(pickerImage);
    } catch (e) {
      setState(() {
        _labeling = false;
        _imageFile = null;
        _labels = 'Error occurred while labeling.';
      });
      Get.snackbar('Image Label', 'Failed to label image.');
    }
  }

  Future<void> _getImageLabel(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final imageLabeler = ImageLabeler(options: ImageLabelerOptions());
    final labels = await imageLabeler.processImage(inputImage);
    await imageLabeler.close();

    final buffer = StringBuffer();
    for (final imageLabel in labels) {
      buffer.write(imageLabel.label);
      buffer.write(' : ');
      buffer.write((imageLabel.confidence * 100).toStringAsFixed(2));
      buffer.writeln('%');
    }

    setState(() {
      _labels = buffer.toString().trim();
      _labeling = false;
    });
  }
}
