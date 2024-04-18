import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';


const bgColor = Color(0xfffafafa);

class qrcodescanner extends StatefulWidget {
  const qrcodescanner({super.key});

  @override
  State<qrcodescanner> createState() => _qrcodescannerState();
}

class _qrcodescannerState extends State<qrcodescanner> {
  final GlobalKey qrKey = GlobalKey();

  Barcode? result;
 

  QRViewController? controller;

  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();

    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: bgColor,
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
          title: const Text("QR code Scanner"),
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                  child: Container(
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Please the Qr code in the area",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Scanning will be started automatically",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    )
                  ],
                ),
              )),
              Expanded(
                flex: 4,
                child: QRView(
                  key: qrKey,

                  onQRViewCreated: onQRViewCamera,
                ),
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.center,
                child: (result != null)
                    ? InkWell(
                        onTap: () {
                            _copyToClipboard();
                        },
                        child: Text(
                          'Data:${result!.code
                          }',
                          style: const TextStyle(
                            color: Color.fromARGB(242, 155, 124, 124),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const Text("Scan Data"),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void onQRViewCamera(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller?.dispose;
    super.dispose();
  }
   void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text:result!.code.toString()));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Text copied to clipboard')),
    // );
    Get.snackbar('Copy Text', 'Text copied to clipboard');
  }
}
