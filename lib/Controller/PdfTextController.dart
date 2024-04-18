import 'dart:io';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfTextExtractorController extends GetxController {
  RxString pdfText = ''.obs;

  @override
  void dispose() {
    pdfText.value = '';
    super.dispose();
    
  }

  Future<void> extractTextFromPdf(String pdfPath) async {
    try {
      final file = File(pdfPath);

      if (file.existsSync()) {
        final PdfDocument document =
            PdfDocument(inputBytes: file.readAsBytesSync());
           String Text  = PdfTextExtractor(document).extractText();

        final StringBuffer buffer = StringBuffer();

        for (int pageIndex = 0;
            pageIndex < document.pages.count;
            pageIndex++) {
          final PdfPage page = document.pages[pageIndex];
          buffer.write(await page.toString());
        }


        pdfText.value = Text;
      } else {
        pdfText.value = 'PDF file not found.';
      }
    } catch (e) {
      pdfText.value = 'Error extracting text: $e';
    }
  }
}
