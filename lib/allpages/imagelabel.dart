import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/widgets/app_scaffold.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class imagelabel extends StatefulWidget {
  const imagelabel({super.key});

  @override
  State<imagelabel> createState() => _imagelabelState();
}

class _imagelabelState extends State<imagelabel> {
  bool _labeling = false;
  bool _analyzing = false;
  XFile? _imageFile;
  List<ImageLabel> _results = [];
  double _minConfidence = 0.5;
  bool _showOverlays = true;
  String _ocrText = '';
  List<DetectedObject> _objects = [];
  List<Face> _faces = [];
  Map<String, IfdTag> _exif = {};
  String? _sha256;
  String? _fileName;
  int? _fileSizeBytes;
  DateTime? _modifiedAt;
  int? _width;
  int? _height;
  List<Color> _dominantColors = [];
  List<int> _brightnessBins = List<int>.filled(16, 0);
  String? _gpsText;

  @override
  void dispose() {
    _imageFile = null;
    _results = [];
    _ocrText = '';
    _objects = [];
    _faces = [];
    _exif = {};
    _sha256 = null;
    _fileName = null;
    _fileSizeBytes = null;
    _modifiedAt = null;
    _width = null;
    _height = null;
    _dominantColors = [];
    _brightnessBins = List<int>.filled(16, 0);
    _gpsText = null;
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
      title: 'Image Labeling',
      actions: [
        IconButton(
          icon: const Icon(Icons.image_rounded),
          onPressed: () => _pickImage(ImageSource.gallery),
        ),
        IconButton(
          icon: const Icon(Icons.photo_camera_rounded),
          onPressed: () => _pickImage(ImageSource.camera),
        ),
        PopupMenuButton<_LabelAction>(
          onSelected: _handleAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: _LabelAction.copyLabels,
              child: Text('Copy labels'),
            ),
            const PopupMenuItem(
              value: _LabelAction.copyReport,
              child: Text('Copy report'),
            ),
            const PopupMenuItem(
              value: _LabelAction.saveReport,
              child: Text('Save report'),
            ),
            const PopupMenuItem(
              value: _LabelAction.searchWeb,
              child: Text('Search web (Lens)'),
            ),
            PopupMenuItem(
              value: _LabelAction.toggleOverlays,
              child: Text(_showOverlays ? 'Hide overlays' : 'Show overlays'),
            ),
          ],
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: ListView(
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
                    'Identify objects in photos',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick an image to generate smart labels.',
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
                            child: GestureDetector(
                              onTap: _openLens,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.file(
                                      File(_imageFile!.path),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  if (_showOverlays)
                                    CustomPaint(
                                      painter: _OverlayPainter(
                                        imageSize: _imageSize(),
                                        objects: _objects,
                                        faces: _faces,
                                      ),
                                    ),
                                  Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: colors.primary.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Search Lens',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.label_important_rounded,
                              size: 48,
                              color: onSurfaceMuted,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (_labeling || _analyzing)
                    const LinearProgressIndicator(minHeight: 3),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildForensicsPanel(context),
            const SizedBox(height: 16),
            Container(
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
                      Text(
                        'Confidence filter',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(_minConfidence * 100).round()}%',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: onSurfaceMuted,
                            ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _minConfidence,
                    min: 0.2,
                    max: 0.9,
                    divisions: 7,
                    label: '${(_minConfidence * 100).round()}%',
                    onChanged: (value) {
                      setState(() => _minConfidence = value);
                    },
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 220,
                    child: _buildLabelList(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildOcrPanel(context),
            const SizedBox(height: 16),
            _buildObjectPanel(context),
            const SizedBox(height: 16),
            _buildFacePanel(context),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickerImage = await ImagePicker().pickImage(source: source);
      if (pickerImage == null) {
        return;
      }
      setState(() {
        _labeling = true;
        _imageFile = pickerImage;
        _results = [];
        _ocrText = '';
        _objects = [];
        _faces = [];
        _analyzing = true;
      });
      await _runVisionAnalysis(pickerImage);
      await _analyzeImage(pickerImage);
    } catch (e) {
      setState(() {
        _labeling = false;
        _imageFile = null;
        _results = [];
        _ocrText = '';
        _objects = [];
        _faces = [];
        _analyzing = false;
      });
      Get.snackbar('Image Label', 'Failed to analyze image.');
    }
  }

  Future<void> _runVisionAnalysis(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final imageLabeler = ImageLabeler(options: ImageLabelerOptions());
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final objectDetector = GoogleMlKit.vision.objectDetector(
      options: ObjectDetectorOptions(
        classifyObjects: true,
        multipleObjects: true,
        mode: DetectionMode.single,
      ),
    );
    final faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        enableClassification: true,
      ),
    );

    final labels = await imageLabeler.processImage(inputImage);
    final ocr = await textRecognizer.processImage(inputImage);
    final objects = await objectDetector.processImage(inputImage);
    final faces = await faceDetector.processImage(inputImage);

    await imageLabeler.close();
    await textRecognizer.close();
    await objectDetector.close();
    await faceDetector.close();

    setState(() {
      _results = labels..sort((a, b) => b.confidence.compareTo(a.confidence));
      _ocrText = _flattenText(ocr);
      _objects = objects;
      _faces = faces;
      _labeling = false;
    });
  }

  Future<void> _analyzeImage(XFile image) async {
    try {
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      final exif = await readExifFromBytes(bytes);
      final digest = sha256.convert(bytes);
      final decoded = img.decodeImage(bytes);
      final stat = await file.stat();
      final fileName = p.basename(image.path);

      final dims = decoded == null ? null : (decoded.width, decoded.height);
      final colors = decoded == null ? <Color>[] : _extractDominantColors(decoded);
      final bins = decoded == null ? List<int>.filled(16, 0) : _brightnessHistogram(decoded);
      final gpsText = _formatGps(exif);

      setState(() {
        _exif = exif;
        _sha256 = digest.toString();
        _fileName = fileName;
        _fileSizeBytes = stat.size;
        _modifiedAt = stat.modified;
        _width = dims?.$1;
        _height = dims?.$2;
        _dominantColors = colors;
        _brightnessBins = bins;
        _gpsText = gpsText;
        _analyzing = false;
      });
    } catch (e) {
      setState(() {
        _analyzing = false;
      });
      Get.snackbar('Image Analysis', 'Failed to read image details.');
    }
  }

  List<Color> _extractDominantColors(img.Image image) {
    final Map<int, int> counts = {};
    final stepX = (image.width / 80).clamp(1, image.width).floor();
    final stepY = (image.height / 80).clamp(1, image.height).floor();
    for (int y = 0; y < image.height; y += stepY) {
      for (int x = 0; x < image.width; x += stepX) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final key = ((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4);
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((entry) {
      final key = entry.key;
      final r = ((key >> 8) & 0xF) * 17;
      final g = ((key >> 4) & 0xF) * 17;
      final b = (key & 0xF) * 17;
      return Color.fromARGB(255, r, g, b);
    }).toList();
  }

  List<int> _brightnessHistogram(img.Image image) {
    final bins = List<int>.filled(16, 0);
    final stepX = (image.width / 120).clamp(1, image.width).floor();
    final stepY = (image.height / 120).clamp(1, image.height).floor();
    for (int y = 0; y < image.height; y += stepY) {
      for (int x = 0; x < image.width; x += stepX) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final luma = (0.2126 * r + 0.7152 * g + 0.0722 * b).round();
        final idx = (luma / 16).floor().clamp(0, 15);
        bins[idx] += 1;
      }
    }
    return bins;
  }

  String? _formatGps(Map<String, IfdTag> exif) {
    final latTag = exif['GPS GPSLatitude'];
    final latRef = exif['GPS GPSLatitudeRef'];
    final lonTag = exif['GPS GPSLongitude'];
    final lonRef = exif['GPS GPSLongitudeRef'];
    if (latTag == null || lonTag == null || latRef == null || lonRef == null) {
      return null;
    }
    final lat = _convertToDegrees(latTag.values);
    final lon = _convertToDegrees(lonTag.values);
    final latSign = latRef.printable.contains('S') ? -1 : 1;
    final lonSign = lonRef.printable.contains('W') ? -1 : 1;
    final latValue = lat * latSign;
    final lonValue = lon * lonSign;
    return '${latValue.toStringAsFixed(5)}, ${lonValue.toStringAsFixed(5)}';
  }

  double _convertToDegrees(dynamic values) {
    if (values is! List) return 0.0;
    final d = _ratioToDouble(values[0]);
    final m = _ratioToDouble(values[1]);
    final s = _ratioToDouble(values[2]);
    return d + (m / 60.0) + (s / 3600.0);
  }

  double _ratioToDouble(dynamic ratio) {
    if (ratio is Ratio) {
      return ratio.toDouble();
    }
    if (ratio is num) {
      return ratio.toDouble();
    }
    return 0.0;
  }

  Size? _imageSize() {
    if (_width == null || _height == null) return null;
    return Size(_width!.toDouble(), _height!.toDouble());
  }

  String _flattenText(RecognizedText recognizedText) {
    final buffer = StringBuffer();
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        buffer.writeln(line.text);
      }
    }
    return buffer.toString().trim();
  }

  Widget _buildForensicsPanel(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
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
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFF1D4ED8)),
              const SizedBox(width: 8),
              Text(
                'Forensic details',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_analyzing)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'File', value: _fileName ?? '—'),
          _InfoRow(
            label: 'Size',
            value: _fileSizeBytes == null
                ? '—'
                : '${(_fileSizeBytes! / 1024).toStringAsFixed(1)} KB',
          ),
          _InfoRow(
            label: 'Dimensions',
            value: _width == null ? '—' : '${_width} x ${_height}px',
          ),
          _InfoRow(
            label: 'Modified',
            value: _modifiedAt?.toLocal().toString() ?? '—',
          ),
          _InfoRow(
            label: 'SHA-256',
            value: _sha256 ?? '—',
          ),
          _InfoRow(
            label: 'GPS',
            value: _gpsText ?? 'Not available',
          ),
          if (_gpsText != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _openMap,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open in Maps'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Camera',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _InfoRow(label: 'Make', value: _exifValue('Image Make')),
          _InfoRow(label: 'Model', value: _exifValue('Image Model')),
          _InfoRow(label: 'Lens', value: _exifValue('EXIF LensModel')),
          _InfoRow(label: 'Date', value: _exifValue('EXIF DateTimeOriginal')),
          const SizedBox(height: 12),
          Text(
            'Dominant colors',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _dominantColors.isEmpty
              ? const Text('—')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _dominantColors
                      .map(
                        (color) => Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                        ),
                      )
                      .toList(),
                ),
          const SizedBox(height: 12),
          Text(
            'Brightness histogram',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _HistogramBar(bins: _brightnessBins),
        ],
      ),
    );
  }

  Widget _buildOcrPanel(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'Recognized text',
      child: Text(
        _ocrText.isEmpty ? 'No text detected.' : _ocrText,
        style: TextStyle(
          fontSize: 13,
          height: 1.5,
          color: _ocrText.isEmpty
              ? colors.onSurface.withOpacity(0.6)
              : colors.onSurface,
        ),
      ),
    );
  }

  Widget _buildObjectPanel(BuildContext context) {
    if (_objects.isEmpty) {
      return _SectionCard(
        title: 'Detected objects',
        child: const Text('No objects detected.'),
      );
    }
    return _SectionCard(
      title: 'Detected objects',
      child: Column(
        children: _objects.map((object) {
          final labels = object.labels
              .map((label) =>
                  '${label.text} ${(label.confidence * 100).toStringAsFixed(0)}%')
              .join(', ');
          return _InfoRow(
            label: 'Object',
            value: labels.isEmpty ? 'Detected' : labels,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFacePanel(BuildContext context) {
    if (_faces.isEmpty) {
      return _SectionCard(
        title: 'Face analysis',
        child: const Text('No faces detected.'),
      );
    }
    return _SectionCard(
      title: 'Face analysis',
      child: Column(
        children: _faces.map((face) {
          final smile = face.smilingProbability;
          final leftEye = face.leftEyeOpenProbability;
          final rightEye = face.rightEyeOpenProbability;
          return Column(
            children: [
              _InfoRow(
                label: 'Smile',
                value: smile == null ? '—' : '${(smile * 100).round()}%',
              ),
              _InfoRow(
                label: 'Left eye',
                value: leftEye == null ? '—' : '${(leftEye * 100).round()}%',
              ),
              _InfoRow(
                label: 'Right eye',
                value: rightEye == null ? '—' : '${(rightEye * 100).round()}%',
              ),
              const Divider(height: 12),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _exifValue(String key) {
    final tag = _exif[key];
    return tag?.printable ?? '—';
  }

  Widget _buildLabelList(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = _results
        .where((label) => label.confidence >= _minConfidence)
        .toList();
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          _results.isEmpty
              ? 'Labels will appear here.'
              : 'No labels above the selected confidence.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
              ),
        ),
      );
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final label = filtered[index];
        final confidence = (label.confidence * 100).round();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Text(
                  '$confidence%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _copyLabels() {
    final filtered = _results
        .where((label) => label.confidence >= _minConfidence)
        .map((label) =>
            '${label.label}: ${(label.confidence * 100).toStringAsFixed(1)}%')
        .join('\n');
    Clipboard.setData(ClipboardData(text: filtered));
    Get.snackbar('Image Label', 'Labels copied to clipboard.');
  }

  Future<void> _copyReport() async {
    final report = _buildReport();
    await Clipboard.setData(ClipboardData(text: report));
    Get.snackbar('Report', 'Report copied to clipboard.');
  }

  Future<void> _saveReport() async {
    final report = _buildReport();
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      p.join(
        dir.path,
        'oneapp_report_${DateTime.now().millisecondsSinceEpoch}.txt',
      ),
    );
    await file.writeAsString(report);
    Get.snackbar('Report', 'Saved to ${file.path}');
  }

  String _buildReport() {
    final buffer = StringBuffer();
    buffer.writeln('Image Forensic Report');
    buffer.writeln('File: ${_fileName ?? '—'}');
    buffer.writeln('Size: ${_fileSizeBytes ?? '—'} bytes');
    buffer.writeln('Dimensions: ${_width ?? '—'} x ${_height ?? '—'}');
    buffer.writeln('Modified: ${_modifiedAt ?? '—'}');
    buffer.writeln('SHA-256: ${_sha256 ?? '—'}');
    buffer.writeln('GPS: ${_gpsText ?? '—'}');
    buffer.writeln('Make: ${_exifValue('Image Make')}');
    buffer.writeln('Model: ${_exifValue('Image Model')}');
    buffer.writeln('Lens: ${_exifValue('EXIF LensModel')}');
    buffer.writeln('Date: ${_exifValue('EXIF DateTimeOriginal')}');
    buffer.writeln('');
    buffer.writeln('Labels:');
    final labels = _results
        .where((label) => label.confidence >= _minConfidence)
        .map((label) =>
            ' - ${label.label} ${(label.confidence * 100).toStringAsFixed(1)}%')
        .join('\n');
    buffer.writeln(labels.isEmpty ? ' - none' : labels);
    buffer.writeln('');
    buffer.writeln('OCR:');
    buffer.writeln(_ocrText.isEmpty ? ' - none' : _ocrText);
    buffer.writeln('');
    buffer.writeln('Objects:');
    if (_objects.isEmpty) {
      buffer.writeln(' - none');
    } else {
      for (final object in _objects) {
        final labelText = object.labels
            .map((label) =>
                '${label.text} ${(label.confidence * 100).toStringAsFixed(0)}%')
            .join(', ');
        buffer.writeln(' - ${labelText.isEmpty ? 'Detected' : labelText}');
      }
    }
    buffer.writeln('');
    buffer.writeln('Faces: ${_faces.length}');
    return buffer.toString();
  }

  Future<void> _openMap() async {
    final gps = _gpsText;
    if (gps == null || gps.isEmpty) return;
    final uri = Uri.parse('https://maps.google.com/?q=$gps');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Maps', 'Unable to open map.');
    }
  }

  void _handleAction(_LabelAction action) {
    switch (action) {
      case _LabelAction.copyLabels:
        if (_results.isNotEmpty) _copyLabels();
        break;
      case _LabelAction.copyReport:
        _copyReport();
        break;
      case _LabelAction.saveReport:
        _saveReport();
        break;
      case _LabelAction.searchWeb:
        _openLens();
        break;
      case _LabelAction.toggleOverlays:
        setState(() => _showOverlays = !_showOverlays);
        break;
    }
  }
}

enum _LabelAction { copyLabels, copyReport, saveReport, searchWeb, toggleOverlays }

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurface.withOpacity(0.7),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistogramBar extends StatelessWidget {
  const _HistogramBar({required this.bins});

  final List<int> bins;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final maxVal = bins.isEmpty ? 1 : bins.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bins.map((value) {
          final height = maxVal == 0 ? 0.0 : (value / maxVal) * 60;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: height,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.45),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  _OverlayPainter({
    required this.imageSize,
    required this.objects,
    required this.faces,
  });

  final Size? imageSize;
  final List<DetectedObject> objects;
  final List<Face> faces;

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize == null) return;
    final scale = min(size.width / imageSize!.width, size.height / imageSize!.height);
    final dx = (size.width - imageSize!.width * scale) / 2;
    final dy = (size.height - imageSize!.height * scale) / 2;

    final objectPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 2;
    final facePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF16A34A)
      ..strokeWidth = 2;

    for (final object in objects) {
      final rect = _scaleRect(object.boundingBox, scale, dx, dy);
      canvas.drawRect(rect, objectPaint);
    }
    for (final face in faces) {
      final rect = _scaleRect(face.boundingBox, scale, dx, dy);
      canvas.drawRect(rect, facePaint);
    }
  }

  Rect _scaleRect(Rect rect, double scale, double dx, double dy) {
    return Rect.fromLTWH(
      dx + rect.left * scale,
      dy + rect.top * scale,
      rect.width * scale,
      rect.height * scale,
    );
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize ||
        oldDelegate.objects != objects ||
        oldDelegate.faces != faces;
  }
}

Future<void> _openLens() async {
  if (Get.isSnackbarOpen) {
    Get.closeCurrentSnackbar();
  }
  Get.snackbar(
    'Google Lens',
    'Browser will open. Upload the image there to search.',
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
  );
  const lensUrl = 'https://lens.google.com/';
  final uri = Uri.parse(lensUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    Get.snackbar('Search web', 'Unable to open browser.');
  }
}
