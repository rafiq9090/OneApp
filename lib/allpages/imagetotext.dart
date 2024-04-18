// ignore_for_file: unused_local_variable
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

bool textScanning = false;
XFile? imageFile;
String scanningText = "";

class imagetotext extends StatefulWidget {
  const imagetotext({super.key});

  @override
  State<imagetotext> createState() => _imagetotextState();
}

class _imagetotextState extends State<imagetotext> {

@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    imageFile=null;
    scanningText ="";
  }

  @override
  Widget build(BuildContext context) {
    var _mediaXY = MediaQuery.of(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          actions: [
            InkWell(
              child: Padding(
                padding: const EdgeInsets.only(right: 10,left: 10),
                child: Icon(Icons.image),
              ),
              onTap: () {
                getImage();
              },
            ),
             InkWell(
              child: Padding(
                padding: const EdgeInsets.only(right: 20,left: 10),
                child: Icon(Icons.copy_all),
              ),
              onTap: () {
              Clipboard.setData(
                             ClipboardData(text: scanningText));
              },
            ),
          ],
          leading: InkWell(
            child: const Icon(Icons.arrow_back),
            onTap: () {
              // Navigator.of(context).pop(MaterialPageRoute(
              //   builder: (context) => const MainPage(),
              // ));
              Get.back();
            },
          ),
          title: const Text("Image to Text Convert"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(!textScanning && imageFile == null)
              if(textScanning)
              const CircularProgressIndicator(),


                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: _mediaXY.size.width * 0.5,
                    height: _mediaXY.size.height * 0.3,
                    color: Colors.black12,
                    child: imageFile != null ? Image.file(File (imageFile!.path)) : Container(),
                  )
                ),

               // if(imageFile != null)
               // Image.file(File(imageFile!.path)) ,

             
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20,left: 10,right: 10),
                    child: SelectableText(
                      scanningText,
                      style: const TextStyle(
                          overflow: TextOverflow.fade,
                        fontWeight: FontWeight.bold,
                        fontSize: 14
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getImage() async {
    try {
      final pickerImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickerImage != null) {
        textScanning = true;
        imageFile = pickerImage;
        setState(() {});
        getRecognisedText(pickerImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      setState(() {});
      scanningText = "Error occured while scanning";
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();

    RecognizedText recognizedText = await textDetector.processImage(inputImage);

    await textDetector.close();
    scanningText = "";

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scanningText = scanningText + line.text + "\n";
      }
    }
    textScanning = false;
    setState(() {});
  }


}
