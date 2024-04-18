import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

XFile? imageFile;
bool imageLabelingChecking = false;
String imageLabels = "";

class imagelabel extends StatefulWidget {
  const imagelabel({super.key});

  @override
  State<imagelabel> createState() => _imagelabelState();
}

class _imagelabelState extends State<imagelabel> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    imageFile = null;
    imageLabels = "";
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
                padding: const EdgeInsets.only(right: 20,left: 10),
                child: Icon(Icons.image),
              ),
              onTap: () {
                getImage();
              },
            ),
          
          ],
          leading: InkWell(
            child: const Icon(Icons.arrow_back),
            onTap: () {
         
              Get.back();
            },
          ),
          title: const Text("Image Label"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // if(!textScanning && imageFile == null)
              // if(textScanning)
              // CircularProgressIndicator(),

              //if (imageFile != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 
                    
                ],
              ),

              //  if(imageFile != null)
              //  Image.file(File(imageFile!.path)) ,

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: _mediaXY.size.width * 0.5,
                  height: _mediaXY.size.height * 0.3,
                   color: Colors.black12,
                  child: imageFile != null
                      ? Image.file(File(imageFile!.path))
                      : Container(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SelectableText(
                      imageLabels,
                      style: const TextStyle(
                          overflow: TextOverflow.fade,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                  
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
        imageLabelingChecking = true;
        imageFile = pickerImage;
        setState(() {});
        getImageLabel(pickerImage);
      }
    } catch (e) {
      imageLabelingChecking = false;
      imageFile = null;
      setState(() {});
      imageLabels = "Error occurred while getting image Label";
    }
  }

  void getImageLabel(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    ImageLabeler imageLabeler = ImageLabeler(options: ImageLabelerOptions());
    List<ImageLabel> label = await imageLabeler.processImage(inputImage);
    StringBuffer sb = StringBuffer();
    for (ImageLabel imageLabel in label) {
      String labelText = imageLabel.label;
      double confidence = imageLabel.confidence;
      sb.write(labelText);
      sb.write(" : ");
      sb.write((confidence * 100).toStringAsFixed(2));
      sb.write("%\n");
    }
    imageLabeler.close();
    imageLabels = sb.toString();
    imageLabelingChecking = false;
    setState(() {});
  }

}
