import 'package:flutter/material.dart';

import 'MainPage.dart';
import 'myDrawer.dart';

class MainBoday extends StatelessWidget {
  const MainBoday({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("One App"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      drawer: const myDrawer(),
      body: const MainPage(),
    );
  }
}
