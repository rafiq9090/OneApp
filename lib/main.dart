

import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/App_Color/Appcolor.dart';
import 'package:flutter_application_1/MainBody.dart';
import 'package:get/get.dart';



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
  Widget build(BuildContext  context) {
    return GetMaterialApp(
     
      debugShowCheckedModeBanner: false,
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
          backgroundColor: Colors.white,
          showLoader: true,
          loadingText: const Text("Loading..."),
          navigator: const MainBoday(),
          durationInSeconds: 2,
        ),
      ),
    );
  }

  
}
