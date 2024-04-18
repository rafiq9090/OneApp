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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/bg.png"),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                      Get.to(const qrcode());
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color:Appcolor.BoxColor1,
                    borderRadius: BorderRadius.all(Radius.circular(20.00)),
                    ),
                  child: const Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.qr_code_outlined,
                            color: AppIconColor.Icon1,
                            size: 35.00,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "QR code Generator",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 152, 141, 170),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) => const qrcodescanner(),
                  // ));
                  Get.to(const qrcodescanner());
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                     color:Appcolor.BoxColor2,
                    borderRadius: BorderRadius.all(Radius.circular(20.00)),
                   
                    
                    ),
                  child: const Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.qr_code_scanner,
                           color: AppIconColor.Icon2,
                            size: 35.00,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "QR code Scanner",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 152, 141, 170),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        
          
          const SizedBox(
            height: 30,
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) => const objectdetection(),
                  // ));
                  Get.to(const PdfTOtextConvert());
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration:const BoxDecoration(
                      color: Appcolor.BoxColor5,
                    borderRadius: BorderRadius.all(Radius.circular(20.00)),
                  
                    ),
                  child:const Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.data_object_sharp,
                            color: AppIconColor.Icon5,
                            size: 35.00,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "PDF to Text Convert",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                           color: Color.fromARGB(255, 152, 141, 170),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) => const imagelabel(),
                  // ));
                  Get.to(const imagelabel());
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                      color:Appcolor.BoxColor6,
                    borderRadius: BorderRadius.all(Radius.circular(20.00)),
                  
                    ),
                  child: const Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.label_important_outline,
                            color: AppIconColor.Icon6,
                            size: 35.00,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "Image Label",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                           color: Color.fromARGB(255, 152, 141, 170),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
            const SizedBox(
            height: 30,
          ),

       
             Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // InkWell(
              //   onTap: () {

              //    Get.to(const texttoimage()); 
                 
              //   },
              //   child: Container(
              //     width: 100,
              //     height: 100,
              //     decoration: const BoxDecoration(
              //      color: Appcolor.BoxColor3,
              //       borderRadius: BorderRadius.all(Radius.circular(20.00)),
                   
              //       ),
              //     child: const Column(
              //       children: [
              //         Padding(
              //           padding: EdgeInsets.all(8.0),
              //           child: Center(
              //             child: Icon(
              //               Icons.image_outlined,
              //              color: AppIconColor.Icon3,
              //               size: 35.00,
              //             ),
              //           ),
              //         ),
              //         Center(
              //           child: Text(
              //             "Text to Image Convert",
              //             textAlign: TextAlign.center,
              //             style: TextStyle(
              //                color: Color.fromARGB(255, 152, 141, 170),
              //               fontSize: 14,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),



              InkWell(
                onTap: () {
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) => const imagetotext(),
                  // ));
                  Get.to(const imagetotext());
                },
                child: Container(
                  width: 276,
                  height: 100,
                  decoration: const BoxDecoration(
                      color: Appcolor.BoxColor4,
                    borderRadius: BorderRadius.all(Radius.circular(20.00)),
               
                    ),
                  child: const Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.text_snippet_outlined,
                            color: AppIconColor.Icon4,
                            size: 35.00,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "Image to Text Convert",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                             color: Color.fromARGB(255, 152, 141, 170),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          
        ],
      ),
    );
  }
}
