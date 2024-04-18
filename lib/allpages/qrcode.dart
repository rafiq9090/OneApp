import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class qrcode extends StatefulWidget {
  const qrcode({super.key});

  @override
  State<qrcode> createState() => _qrcodeState();
}

class _qrcodeState extends State<qrcode> {
  ScreenshotController screenshotControllers = ScreenshotController();
  final TextEditingController _controller = TextEditingController();
  final GlobalKey qrKey = GlobalKey();
  bool dirExists = false;
  dynamic externalDir = '/storage/Download/';
  String getVale = '';
 @protected
  late QrCode qrCode;

  @protected
  late QrImage qrImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final qrCode = QrCode(
      8,
      QrErrorCorrectLevel.L)..addData(getVale);
      qrImage = QrImage(qrCode);
  }
Future<Uint8List> generateQrCodeAsBytes(String data) async {
  final qrCode = QrCode.fromData(
    data: data,
    errorCorrectLevel: QrErrorCorrectLevel.H,
  );

  final qrImage = QrImage(qrCode);
  final image = await qrImage.toImageAsBytes(size: 512);
  

  if (image != null) {
      await ImageGallerySaver.saveImage(image.buffer.asUint8List());

    return image.buffer.asUint8List();
  } else {
    throw Exception('Failed to generate QR code image');
  }
}
  @protected
  late PrettyQrDecoration decoration;
  final bool _validator = false;
void _qR()async{
  final qrCode = QrCode.fromData(
  data: getVale,
  errorCorrectLevel: QrErrorCorrectLevel.H,
);
final qrImage = QrImage(qrCode);
final imageBytes = await qrImage.toImageAsBytes(
  size: 512,
  format: ImageByteFormat.png,
  decoration: const PrettyQrDecoration(),
);
 //await ImageGallerySaver.saveImage(qrImage as Uint8List);
}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            leading: InkWell(
              child: const Icon(Icons.arrow_back),
              onTap: () {
                // Navigator.of(context).pop(MaterialPageRoute(
                //   builder: (context) => const MainPage(),
                // ));
                Get.back();
              },
            ),
            title: const Text("QR code"),
          ),
          body: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 50),
                child: Text(
                  "Qr code Generate ",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: PrettyQrView.data(
                      data: getVale
                      
                    ),
                  )),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: 250,
                height: 50,
                child: TextField(
                  controller: _controller,
                  onChanged: (value) {},
                  decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.only(left: 8, right: 8, top: 10),
                      labelText: "Enter the Text",
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(5),
                            right: Radius.circular(5)),
                      ),
                      filled: true,
                      hintText: "Enter the Text",
                      isCollapsed: const bool.fromEnvironment("valo"),
                      errorText: _validator ? 'Please Enter the text' : null),
                ),
              ),

              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 20)),
                      elevation: MaterialStatePropertyAll(8)),
                  onPressed: () {
                    setState(() {
                      Permission.storage.request();
                      getVale = _controller.text;

                      // screenshotControllers
                      //     .capture(delay: Duration(milliseconds: 10))
                      //     .then((capturedImage) async {
                      //  // ShowCapturedWidget(context, capturedImage!);
                      //   //await _captureAndSavePng();
                      //  await  _saved(capturedImage!);
                      // }).catchError((onError) {
                      //   print(onError);
                      // });
                     _generateAndSaveQrCode() ;
                    });
                  },
                  child: const Text(
                    "Generate",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ]),
          )),
    );
  }

  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text("Capture the qr code"),
        ),
        body: Column(
          children: [
            Center(child: Image.memory(capturedImage)),
            ElevatedButton(
                onPressed: () async {
                //  await saveImage(capturedImage);
                },
                child: Text('Save'))
          ],
        ),
      ),
    );
  }

  _saved(Uint8List image) async {
    await ImageGallerySaver.saveImage(image);
  }


Future<void> _generateAndSaveQrCode() async {
    final qrCode = QrCode(
      8,
      QrErrorCorrectLevel.H,
    )..addData(getVale);

    final qrImage = QrImage(qrCode);

    // Convert the QR code to a Uint8List image
    final ByteData? byteData = await qrImage.toImageAsBytes(size:512);
    final Uint8List imageBytes = byteData!.buffer.asUint8List();

    // Save the image to the gallery
    await ImageGallerySaver.saveImage(imageBytes);
    
    // Show a confirmation message
    Get.snackbar('QR Code', '');
  }
 
}
