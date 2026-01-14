import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Controller/PdfController.dart';
import 'package:flutter_application_1/Controller/PdfTextController.dart';
import 'package:flutter_application_1/widgets/app_scaffold.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

const String _cloudConvertApiKey =
    String.fromEnvironment('CLOUDCONVERT_API_KEY');

class PdfToDocConvert extends StatefulWidget {
  const PdfToDocConvert({super.key});

  @override
  State<PdfToDocConvert> createState() => _PdfToDocConvertState();
}

class _PdfToDocConvertState extends State<PdfToDocConvert> {
  final PdfTextExtractorController _textController =
      Get.put(PdfTextExtractorController(), tag: 'pdf_to_doc');
  final PdfController _pdfController = Get.put(PdfController(), tag: 'pdf_doc');

  bool _saving = false;
  String? _lastSavedPath;
  bool _converting = false;
  String _status = '';
  final TextEditingController _fileNameController =
      TextEditingController(text: 'oneapp_doc');

  static const MethodChannel _channel = MethodChannel('oneapp/files');
  bool get _hasCloudKey => _cloudConvertApiKey.trim().isNotEmpty;

  @override
  void dispose() {
    Get.delete<PdfTextExtractorController>(tag: 'pdf_to_doc');
    Get.delete<PdfController>(tag: 'pdf_doc');
    _fileNameController.dispose();
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
    return AppScaffold(
      title: 'PDF to DOC',
      actions: [
        IconButton(
          icon: const Icon(Icons.file_open_rounded),
          onPressed: () async {
            await _pdfController.pickerAndDisplay();
          },
        ),
        IconButton(
          icon: const Icon(Icons.text_snippet_rounded),
          onPressed: () async {
            await _extractText();
          },
        ),
        IconButton(
          icon: const Icon(Icons.save_alt_rounded),
          onPressed: _saving || _converting ? null : _saveDoc,
        ),
        IconButton(
          icon: const Icon(Icons.cloud_upload_rounded),
          onPressed: _converting ? null : _convertWithCloudConvert,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final panelHeight = (constraints.maxHeight * 0.55).clamp(260.0, 520.0);
            return ListView(
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
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFF1D4ED8),
                          size: 20,
                        ),
                      ),
                      const Text(
                        'Convert PDF to DOCX',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      _StatusChip(
                        label: _hasCloudKey ? 'Cloud' : 'Local',
                        color: _hasCloudKey
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF1D4ED8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _hasCloudKey
                        ? 'Preserve layout using CloudConvert.'
                        : 'Extract text locally and save as DOC.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onSurfaceMuted,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 18,
                          color: onSurfaceMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _pdfController.pdfPath.isEmpty
                                ? 'No PDF selected.'
                                : p.basename(_pdfController.pdfPath.value),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _fileNameController,
                    decoration: InputDecoration(
                      labelText: 'Output file name',
                      hintText: 'oneapp_doc',
                      filled: true,
                      fillColor: surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _ActionButton(
                        icon: Icons.file_open_rounded,
                        label: 'Pick PDF',
                        onTap: _pdfController.pickerAndDisplay,
                      ),
                      _ActionButton(
                        icon: Icons.text_snippet_rounded,
                        label: 'Extract',
                        onTap: _extractText,
                      ),
                      _ActionButton(
                        icon: Icons.save_alt_rounded,
                        label: 'Save DOC',
                        onTap: _saving || _converting ? null : _saveDoc,
                      ),
                      _ActionButton(
                        icon: Icons.cloud_upload_rounded,
                        label: 'Cloud DOCX',
                        onTap: _converting ? null : _convertWithCloudConvert,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (!_hasCloudKey)
                    Text(
                      'Set CLOUDCONVERT_API_KEY with --dart-define to keep PDF layout.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: onSurfaceMuted,
                          ),
                    ),
                  if (_saving) const LinearProgressIndicator(minHeight: 3),
                  if (_converting)
                    Column(
                      children: [
                        const SizedBox(height: 6),
                        LinearProgressIndicator(minHeight: 3),
                        const SizedBox(height: 6),
                        Text(
                          _status,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: onSurfaceMuted,
                              ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: panelHeight,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(
                  () {
                    final text = _textController.pdfText.value;
                    final hasText = text.trim().isNotEmpty;
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.article_outlined,
                                size: 18,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                            Text(
                              'Extracted Text',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            if (hasText)
                              _StatusChip(
                                label: '${_wordCount(text)} words',
                                color: const Color(0xFF1D4ED8),
                              ),
                            if (hasText)
                              _StatusChip(
                                label: '${text.length} chars',
                                color: const Color(0xFF1D4ED8),
                              ),
                          ],
                        ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          SelectableText(
                            hasText
                                ? text
                                : 'Extracted text will appear here.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight:
                                  hasText ? FontWeight.w500 : FontWeight.w400,
                              color: hasText
                                  ? onSurface
                                  : onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _extractText() async {
    if (_pdfController.pdfPath.isEmpty) {
      Get.snackbar('PDF to DOC', 'Please select a PDF first.');
      return;
    }
    await _textController.extractTextFromPdf(_pdfController.pdfPath.value);
  }

  Future<void> _saveDoc() async {
    if (_pdfController.pdfPath.isEmpty) {
      _showToast('Please select a PDF first.');
      return;
    }
    if (_textController.pdfText.isEmpty) {
      await _extractText();
    }
    if (_textController.pdfText.isEmpty) {
      _showToast('No text to save.');
      return;
    }

    setState(() => _saving = true);
    try {
      final safeName = _safeFileName(_fileNameController.text);
      final fileName = safeName.isEmpty
          ? 'oneapp_${DateTime.now().millisecondsSinceEpoch}.doc'
          : '$safeName.doc';
      final bytes = Uint8List.fromList(utf8.encode(_textController.pdfText.value));
      final savedPath = await _saveBytesToDownloads(
        fileName,
        bytes,
        'application/msword',
      );
      if (savedPath != null) {
        setState(() => _lastSavedPath = savedPath);
        _showToast('Saved to Downloads');
      } else {
        _showToast('Failed to save DOC.');
      }
    } catch (e) {
      _showToast('Failed to save DOC.');
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _openSavedFile() async {
    final path = _lastSavedPath;
    if (path == null) return;
    await OpenFilex.open(path);
  }

  Future<void> _shareSavedFile() async {
    final path = _lastSavedPath;
    if (path == null) return;
    await Share.shareXFiles([XFile(path)], text: 'PDF to DOC');
  }

  Future<void> _convertWithCloudConvert() async {
    if (!_hasCloudKey) {
      _showToast('Missing CloudConvert API key.');
      return;
    }
    if (_pdfController.pdfPath.isEmpty) {
      _showToast('Please select a PDF first.');
      return;
    }

    setState(() {
      _converting = true;
      _status = 'Creating CloudConvert job...';
    });

    try {
      final jobId = await _createJob();
      setState(() => _status = 'Uploading PDF...');
      await _uploadFile(jobId);
      setState(() => _status = 'Converting to DOCX...');
      final fileUrl = await _waitForExport(jobId);
      setState(() => _status = 'Downloading result...');
      final savedPath = await _downloadResult(fileUrl);
      setState(() => _lastSavedPath = savedPath);
      _showToast('Saved to Downloads');
    } catch (e) {
      _showToast('Conversion failed.');
    } finally {
      setState(() {
        _converting = false;
        _status = '';
      });
    }
  }

  Future<String> _createJob() async {
    final response = await http.post(
      Uri.parse('https://api.cloudconvert.com/v2/jobs'),
      headers: {
        'Authorization': 'Bearer $_cloudConvertApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tasks': {
          'import-1': {'operation': 'import/upload'},
          'convert-1': {
            'operation': 'convert',
            'input': 'import-1',
            'input_format': 'pdf',
            'output_format': 'docx',
          },
          'export-1': {
            'operation': 'export/url',
            'input': 'convert-1',
          }
        }
      }),
    );
    if (response.statusCode >= 300) {
      throw Exception('Job create failed');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data']['id'] as String;
  }

  Future<void> _uploadFile(String jobId) async {
    final job = await _fetchJob(jobId);
    final importTask = _findTask(job, 'import/upload');
    final form = importTask['result']['form'] as Map<String, dynamic>;
    final url = form['url'] as String;
    final params = Map<String, dynamic>.from(form['parameters']);

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields.addAll(params.map((key, value) => MapEntry(key, '$value')));
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        _pdfController.pdfPath.value,
      ),
    );
    final response = await request.send();
    if (response.statusCode >= 300) {
      throw Exception('Upload failed');
    }
  }

  Future<String> _waitForExport(String jobId) async {
    for (int i = 0; i < 40; i++) {
      final job = await _fetchJob(jobId);
      final exportTask = _findTask(job, 'export/url');
      if (exportTask['status'] == 'finished') {
        final files = exportTask['result']['files'] as List<dynamic>;
        if (files.isEmpty) break;
        return files.first['url'] as String;
      }
      if (exportTask['status'] == 'error') {
        throw Exception('Export failed');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    throw Exception('Export timeout');
  }

  Future<String> _downloadResult(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode >= 300) {
      throw Exception('Download failed');
    }
    final safeName = _safeFileName(_fileNameController.text);
    final fileName = safeName.isEmpty
        ? 'oneapp_${DateTime.now().millisecondsSinceEpoch}.docx'
        : '$safeName.docx';
    final savedPath = await _saveBytesToDownloads(
      fileName,
      response.bodyBytes,
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
    if (savedPath == null) {
      throw Exception('Save failed');
    }
    return savedPath;
  }

  Future<Map<String, dynamic>> _fetchJob(String jobId) async {
    final response = await http.get(
      Uri.parse('https://api.cloudconvert.com/v2/jobs/$jobId'),
      headers: {
        'Authorization': 'Bearer $_cloudConvertApiKey',
      },
    );
    if (response.statusCode >= 300) {
      throw Exception('Job fetch failed');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  Map<String, dynamic> _findTask(
    Map<String, dynamic> job,
    String operation,
  ) {
    final tasks = job['tasks'] as List<dynamic>;
    return tasks
        .cast<Map<String, dynamic>>()
        .firstWhere((task) => task['operation'] == operation);
  }

  String _safeFileName(String name) {
    final cleaned = name.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    return cleaned.replaceAll(RegExp(r'_+'), '_');
  }

  int _wordCount(String text) {
    return text
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .length;
  }

  Future<String?> _saveBytesToDownloads(
    String fileName,
    Uint8List bytes,
    String mime,
  ) async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod<String>(
          'saveToDownloads',
          {'name': fileName, 'bytes': bytes, 'mime': mime},
        );
        return result;
      } catch (_) {
        return null;
      }
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
      ),
    );
  }
}
