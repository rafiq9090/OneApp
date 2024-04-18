import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Controller/PdfController.dart';
import 'package:flutter_application_1/Controller/PdfTextController.dart';
import 'package:get/get.dart';

final PdfTextExtractorController controller =
    Get.put(PdfTextExtractorController());
final PdfController cs = Get.put(PdfController());
//final ScrollControllerMixin scrollControllerMixin = Get.put(ScrollControllerMixin());

class PdfTOtextConvert extends StatelessWidget {
  const PdfTOtextConvert({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      appBar: AppBar(
        actions: [
           Padding(
            padding: const EdgeInsets.only(right: 30),
            child: InkWell(
              onTap: _copyToClipboard,
              child: Icon(Icons.copy_all),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: InkWell(
              onTap: () async {
                 await controller.extractTextFromPdf(cs.pdfPath.value);
              },
              child: Icon(Icons.text_fields),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(
              onTap: () async {
                await cs.pickerAndDisplay();
              },
              child: Icon(Icons.file_open),
            ),
          ),
         
        ],
        leading: InkWell(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            Get.back();
          },
        ),
        title: const Text("Pdf to Text"),
      ),
      
      body: SingleChildScrollView(
        child: Center(
          child: Column(
       
            children: [
              
              SizedBox(height: 20),
                Obx(() => controller.pdfText.isEmpty?
                  Center
                  (child: 
                  Icon(Icons.cabin_rounded,
                  size: 100,color: const Color.fromARGB(137, 100, 93, 93),),):
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      
                      child: Center(
                        
                        child: SelectableText(
                          controller.pdfText.value.replaceAll(RegExp(r'\s+'), ' '),
                          
                          style: 
                          TextStyle(
                          fontSize: 18
                        ),),
                      )),
                  )
                )
            ],
          ),
        ),
      ),
     
    );
  }
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text:controller.pdfText.value));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Text copied to clipboard')),
    // );
    Get.snackbar('Copy Text', 'Text copied to clipboard',snackPosition: SnackPosition.BOTTOM,margin: EdgeInsets.all(10));
  }

}
