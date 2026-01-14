import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/MainBody.dart';
import 'package:flutter_application_1/Controller/theme_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());
    return Obx(() {
      final mode = themeController.mode.value;
      final platformBrightness = MediaQuery.platformBrightnessOf(context);
      final themeBrightness = mode == ThemeMode.system
          ? platformBrightness
          : (mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F7FB),
          textTheme: GoogleFonts.spaceGroteskTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF7F7FB),
            surfaceTintColor: Colors.transparent,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF60A5FA),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0B1020),
          textTheme:
              GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0B1020),
            surfaceTintColor: Colors.transparent,
          ),
        ),
        themeMode: mode,
        home: SafeArea(
          child: EasySplashScreen(
            logo: Image.asset('assets/splash.png'),
            logoWidth: 200,
            title: const Text(
              "One App",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: themeBrightness == Brightness.dark
                ? const Color(0xFF0B1020)
                : const Color(0xFFF7F7FB),
            showLoader: true,
            loadingText: const Text("Loading..."),
            navigator: const MainBoday(),
            durationInSeconds: 2,
          ),
        ),
      );
    });
  }
}
