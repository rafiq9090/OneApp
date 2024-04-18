
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
  
class texttoimage extends StatelessWidget {
 const texttoimage({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: pdfviewpage());
  }
}




class pdfviewpage extends StatefulWidget {
  @override
  State<pdfviewpage> createState() => _pdfviewpageState();
}

class _pdfviewpageState extends State<pdfviewpage> {
  // const pdfviewpage({super.key});

  Uint8List? _scannedImageBytes;
  Future<void> _scanDocument() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _scannedImageBytes = pickedFile.readAsBytes() as Uint8List?;
      });
    }
  }

     File? _scanImage;

    // void _scanFile(BuildContext context)async{
    //   try{
    //     var image  = await DocumentScannerFlutter.launch(context,source: ScannerFileSource.CAMERA);
    //   if(image != null){

      
    //     setState(() {
    //       _scanImage = image;
    //     });
    //   }
    //   } catch(e){
    //     print("Hello $e");
    //   }

     
    // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: InkWell(
              onTap: ()  {
                // await _controller.docpickerAndDisplay();
                // print(_controller.docPath.value);
             
              },
              child: Icon(Icons.compare_arrows_outlined),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(
              onTap: () async {},
              child: Icon(Icons.file_open),
            ),
          )
        ],
        title: Text('Pdf to Doc File'),
        leading: InkWell(
            onTap: () {
              // Get.back();
            },
            child: Icon(Icons.arrow_back)),
      ),
      body:Center(
          child: Column(
            children: [
              if(_scanImage != null)
              Image.file(_scanImage!,
              width: 500,
              height: 500,
              ),
              if(_scanImage == null)
              Text('No file')
            ],
          ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // getImageFromCamera();
       //  _scanFile(context);
          print('ok');
//      final picker = ImagePicker();
// final image = await picker.pickImage(source: ImageSource.camera);

// if (image == null) return;

// await _controller.findContoursFromExternalImage(
//   image: File(image.path),
// );
        },
        child: Icon(Icons.scanner),
      ),

    
    );
  }

}
