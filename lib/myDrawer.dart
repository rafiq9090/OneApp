import 'package:flutter/material.dart';
import 'package:flutter_application_1/MainBody.dart';
import 'package:flutter_application_1/allpages/imagelabel.dart';
import 'package:flutter_application_1/allpages/imagetotext.dart';
import 'package:flutter_application_1/allpages/pdftotextconvert.dart';
import 'package:flutter_application_1/allpages/qrcode.dart';
import 'package:flutter_application_1/allpages/qrcodescanner.dart';
import 'package:flutter_application_1/allpages/texttoimage.dart';

import 'allpages/about.dart';

class myDrawer extends StatelessWidget {
  const myDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage("assets/splash.png"),
                ),
                accountName: Text(
                  "One App",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                accountEmail: Text("oneapp@gmai.com")),
            ListTile(
              onTap: () {
                Navigator.of(context).pop(MaterialPageRoute(builder: (context) => MainBoday(),));
              },
              title:
                  const Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const qrcode(),
                ));
              },
              title: const Text("Qr Code Generator",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const qrcodescanner(),
                ));
              },
              title: const Text("QR Code Scanner",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const texttoimage(),
                ));
              },
              title: const Text("Text to Image convert",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const imagetotext(),
                ));
              },
              title: const Text("Image to Text Convert",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PdfTOtextConvert(),
                ));
              },
              title: const Text("Object Detection",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const imagelabel(),
                ));
              },
              title: const Text("Image Label",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => about(),
                ));
              },
              title:
                  const Text("About", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
