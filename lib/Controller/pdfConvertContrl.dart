// pdf_controller.dart

import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

class PdfControllers extends GetxController {
   RxString pdfPath = ''.obs;
 Future<void> pickerAndDisplays()async{
    try{
      pdfPath.value = '';
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc','docx'],
      );
      if(result != null){
        pdfPath.value = result.files.single.path!;
      }else{
        print('File picking canceled');
      }
    }catch(e){
        print('Error picking PDF file: $e');
    }
 }
 }
