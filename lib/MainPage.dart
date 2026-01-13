import 'package:flutter/material.dart';
import 'package:flutter_application_1/App_Color/Appcolor.dart';
import 'package:flutter_application_1/allpages/imagelabel.dart';
import 'package:flutter_application_1/allpages/imagetotext.dart';
import 'package:flutter_application_1/allpages/pdftotextconvert.dart';
import 'package:flutter_application_1/allpages/qrcode.dart';
import 'package:flutter_application_1/allpages/texttoimage.dart';
import 'package:get/get.dart';

import 'allpages/qrcodescanner.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});
  @override
  Widget build(BuildContext context) {
    final actions = <_HomeAction>[
      _HomeAction(
        title: 'QR Code Generator',
        subtitle: 'Create branded QR codes',
        icon: Icons.qr_code_rounded,
        cardColor: Appcolor.BoxColor1,
        iconColor: AppIconColor.Icon1,
        onTap: () => Get.to(const qrcode()),
      ),
      _HomeAction(
        title: 'QR Code Scanner',
        subtitle: 'Scan codes instantly',
        icon: Icons.qr_code_scanner,
        cardColor: Appcolor.BoxColor2,
        iconColor: AppIconColor.Icon2,
        onTap: () => Get.to(const qrcodescanner()),
      ),
      _HomeAction(
        title: 'PDF to Text',
        subtitle: 'Extract text from PDFs',
        icon: Icons.picture_as_pdf_rounded,
        cardColor: Appcolor.BoxColor5,
        iconColor: AppIconColor.Icon5,
        onTap: () => Get.to(const PdfTOtextConvert()),
      ),
      _HomeAction(
        title: 'Image Label',
        subtitle: 'Auto-tag objects',
        icon: Icons.label_important_outline,
        cardColor: Appcolor.BoxColor6,
        iconColor: AppIconColor.Icon6,
        onTap: () => Get.to(const imagelabel()),
      ),
      _HomeAction(
        title: 'Image to Text',
        subtitle: 'OCR from photos',
        icon: Icons.text_snippet_outlined,
        cardColor: Appcolor.BoxColor4,
        iconColor: AppIconColor.Icon4,
        onTap: () => Get.to(const imagetotext()),
      ),
      _HomeAction(
        title: 'Text to Image',
        subtitle: 'Export text as image',
        icon: Icons.image_outlined,
        cardColor: Appcolor.BoxColor3,
        iconColor: AppIconColor.Icon3,
        onTap: () => Get.to(const texttoimage()),
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF8FAFF),
            Color(0xFFFDF7F0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;
                  final crossAxisCount = isWide ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: actions.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: isWide ? 1.15 : 1.1,
                    ),
                    itemBuilder: (context, index) {
                      final action = actions[index];
                      return _ActionCard(action: action);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeAction {
  const _HomeAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.cardColor,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color cardColor;
  final Color iconColor;
  final VoidCallback onTap;
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One App',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Appcolor.LogColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Smart tools to scan, extract, and create with ease.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        "assets/bg.png",
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'One App',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Appcolor.LogColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Smart tools to scan, extract, and create with ease.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      "assets/bg.png",
                      width: 92,
                      height: 92,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});

  final _HomeAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: action.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(action.icon, color: action.iconColor, size: 26),
                ),
                const SizedBox(height: 6),
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        action.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Appcolor.LogColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        action.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
