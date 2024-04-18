import 'package:flutter/material.dart';
import 'package:flutter_application_1/App_Color/Appcolor.dart';

import 'MainPage.dart';
import 'myDrawer.dart';

class MainBoday extends StatelessWidget {
  const MainBoday({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      appBar: AppBar(
        title: const Text("One Apps",),
      
      ),
      drawer: const myDrawer(),
      body:const MainPage()
    );
  }
}