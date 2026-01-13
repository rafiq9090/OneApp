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
                    'Extract text from PDF files',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Open a PDF, then tap the text icon to extract.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(
                  () => SingleChildScrollView(
                    child: SelectableText(
                      controller.pdfText.isEmpty
                          ? 'Extracted text will appear here.'
                          : controller.pdfText.value
                              .replaceAll(RegExp(r'\s+'), ' '),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
