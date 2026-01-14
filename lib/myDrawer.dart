import 'package:flutter/material.dart';
import 'package:flutter_application_1/MainBody.dart';
import 'package:flutter_application_1/allpages/about.dart';
import 'package:flutter_application_1/allpages/imagelabel.dart';
import 'package:flutter_application_1/allpages/imagetotext.dart';
import 'package:flutter_application_1/allpages/pdftotextconvert.dart';
import 'package:flutter_application_1/allpages/qrcode.dart';
import 'package:flutter_application_1/allpages/qrcodescanner.dart';
import 'package:flutter_application_1/allpages/pdftodoc.dart';
import 'package:get/get.dart';

class myDrawer extends StatelessWidget {
  const myDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1F6FEB), Color(0xFF0EA5E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage("assets/splash.png"),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "One App",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Smart utilities in one place",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () => _goTo(context, const MainBoday()),
            ),
            _DrawerItem(
              icon: Icons.qr_code_rounded,
              label: 'QR Code Generator',
              onTap: () => _goTo(context, const qrcode()),
            ),
            _DrawerItem(
              icon: Icons.qr_code_scanner_rounded,
              label: 'QR Code Scanner',
              onTap: () => _goTo(context, const qrcodescanner()),
            ),
            _DrawerItem(
              icon: Icons.description_outlined,
              label: 'PDF to DOC',
              onTap: () => _goTo(context, const PdfToDocConvert()),
            ),
            _DrawerItem(
              icon: Icons.image_rounded,
              label: 'Image to Text',
              onTap: () => _goTo(context, const imagetotext()),
            ),
            _DrawerItem(
              icon: Icons.picture_as_pdf_rounded,
              label: 'PDF to Text',
              onTap: () => _goTo(context, const PdfTOtextConvert()),
            ),
            _DrawerItem(
              icon: Icons.label_important_rounded,
              label: 'Image Label',
              onTap: () => _goTo(context, const imagelabel()),
            ),
            _DrawerItem(
              icon: Icons.info_outline_rounded,
              label: 'About',
              onTap: () => _goTo(context, const about()),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}

void _goTo(BuildContext context, Widget page) {
  Navigator.of(context).pop();
  Get.to(() => page);
}
