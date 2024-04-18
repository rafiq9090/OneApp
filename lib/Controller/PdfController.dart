
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class PdfController extends GetxController{
  RxString pdfPath = ''.obs;
   RxString docPath = ''.obs;

  Future<void> pickerAndDisplay()async{
    try{
      pdfPath.value = '';
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
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


  Future<void> docpickerAndDisplay()async{
    try{
      docPath.value = '';
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx'],
      );
      if(result != null){
        docPath.value = result.files.single.path!;
      }else{
        print('File picking canceled');
      }
    }catch(e){
        print('Error picking PDF file: $e');
    }
  }

  
}