import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Controller/PdfController.dart';
import 'package:flutter_application_1/Controller/PdfTextController.dart';
import 'package:flutter_application_1/widgets/app_scaffold.dart';
import 'package:get/get.dart';

final PdfTextExtractorController controller =
    Get.put(PdfTextExtractorController());
final PdfController cs = Get.put(PdfController());

class PdfTOtextConvert extends StatelessWidget {
  const PdfTOtextConvert({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final surface = colors.surface;
    final surfaceVariant = colors.surfaceVariant;
    final onSurface = colors.onSurface;
    final onSurfaceMuted = onSurface.withOpacity(0.7);
    return AppScaffold(
      title: 'PDF to Text',
      actions: [
        IconButton(
          icon: const Icon(Icons.copy_all_rounded),
          onPressed: () => _copyToClipboard(),
        ),
        IconButton(
          icon: const Icon(Icons.text_snippet_rounded),
          onPressed: () async {
            await controller.extractTextFromPdf(cs.pdfPath.value);
          },
        ),
        IconButton(
          icon: const Icon(Icons.file_open_rounded),
          onPressed: () async {
            await cs.pickerAndDisplay();
          },
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
                    'Extract text from PDF files',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Open a PDF, then tap the text icon to extract.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onSurfaceMuted,
                        ),
                  ),
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
                child: Obx(
                  () {
                    final rawText = controller.pdfText.value;
                    final hasText = rawText.trim().isNotEmpty;
                    return Column(
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
                                Icons.article_outlined,
                                size: 18,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Extracted Text',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (hasText)
                              _StatChip(
                                label: '${_wordCount(rawText)} words',
                              ),
                            if (hasText) const SizedBox(width: 8),
                            if (hasText)
                              _StatChip(
                                label: '${rawText.length} chars',
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: SelectableText(
                              hasText
                                  ? rawText
                                  : 'Extracted text will appear here.',
                              textAlign: TextAlign.left,
                              textWidthBasis: TextWidthBasis.longestLine,
                              showCursor: false,
                              autofocus: false,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                fontFamily: hasText ? 'monospace' : null,
                                fontWeight:
                                    hasText ? FontWeight.w400 : FontWeight.w400,
                                color: hasText ? onSurface : onSurfaceMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _wordCount(String text) {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.length;
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: controller.pdfText.value));
    Get.snackbar(
      'Copy Text',
      'Text copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
    );
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
