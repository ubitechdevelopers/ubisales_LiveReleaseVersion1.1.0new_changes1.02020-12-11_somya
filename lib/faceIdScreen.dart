// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// this is testing
import 'dart:async';
import 'dart:convert';

import 'package:Shrine/model/user.dart';
import 'package:Shrine/page/camera.dart';
import 'package:Shrine/services/checklogin.dart';
import 'package:Shrine/services/saveimage.dart';
import 'package:Shrine/shared/widgets/focus_widget.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';

import 'globals.dart' as globals;
import 'globals.dart';
import 'home.dart';
//import 'localization/app_translations.dart';
//import 'localization/app_translations_delegate.dart';
//import 'localization/application.dart';
import 'home.dart';
import 'login.dart';
import 'model/timeinout.dart';
import 'otpvarify.dart';
import 'register_org.dart';

class FaceIdScreen extends StatefulWidget {
  @override
  _FaceIdScreenState createState() => _FaceIdScreenState();
}
class _FaceIdScreenState extends State<FaceIdScreen> {
  //AppTranslationsDelegate _newLocaleDelegate;

  String barcode = "";
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loader = false;
  String empid = "";
  FocusNode textSecondFocusNode = new FocusNode();
  String fname = "",
      lname = "";
  @override
  void initState() {
    super.initState();
    init();
  }
  init() async{
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      fname = prefs.getString('fname') ?? '';
      lname = prefs.getString('lname') ?? '';

    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _buildPage(context),

      /* localizationsDelegates: [
        _newLocaleDelegate,
        //provides localised strings
        GlobalMaterialLocalizations.delegate,
        //provides RTL support
        GlobalWidgetsLocalizations.delegate,
      ],

      supportedLocales: [
        const Locale("en", ""),
        const Locale("es", ""),
      ],

      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            print("supportedLocale.toString()");
            print(supportedLocale.toString());
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },*/

    );
  }

  @override
  Widget _buildPage(BuildContext context) {
    return new Scaffold(
      body: new Builder(
        builder: (BuildContext context) {
          return new Center(
            child: Form(
              key: _formKey,
              child: SafeArea(
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                Container(
                  // foregroundDecoration: BoxDecoration(color:Colors.red ),
                  height: MediaQuery.of(context).size.height * 0.80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).size.height * .06),

                     /*
                      new GestureDetector(
                        onTap: () {
                          // profile navigation
                          /* Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));*/
                        },
                        child: new Stack(children: <Widget>[
  /*                        Container(
                            //   foregroundDecoration: BoxDecoration(color:Colors.yellow ),
                              width: MediaQuery.of(context).size.height * .16,
                              height: MediaQuery.of(context).size.height * .16,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image:
                                        AssetImage('assets/avatar.png')

                                    //image: AssetImage('assets/avatar.png')
                                  ))),
*/


                          /*new Positioned(
                    left: MediaQuery.of(context).size.width*.14,
                    top: MediaQuery.of(context).size.height*.11,
                    child: new RawMaterialButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                      },
                      child: new Icon(
                        Icons.edit,
                        size: 18.0,
                      ),
                      shape: new CircleBorder(),
                      elevation: 0.5,
                      fillColor: Colors.teal,
                      padding: const EdgeInsets.all(1.0),
                    ),
                  ),*/
                        ]),
                      ),*/
                      SizedBox(height: MediaQuery.of(context).size.height * .02),
/*
                      Text(fname.toUpperCase() + " " + lname.toUpperCase(),

                          style: new TextStyle(
                            color: Colors.black87,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3.0,
                          )),
*/
                      SizedBox(height: MediaQuery.of(context).size.height * .24),

                      Image.asset("assets/facerecog.png",width: MediaQuery.of(context).size.width * .4,),
                      SizedBox(height: MediaQuery.of(context).size.height * .06),
                      //Text('Let\'s start with Face Recognition',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                      SizedBox(height: MediaQuery.of(context).size.height * .01),
                      RaisedButton(child: Text('Register my Face ID',style: TextStyle(color: Colors.white),),onPressed: (){
                           saveImageFaceId();
                      },color: buttoncolor,)
                      // SizedBox(height: MediaQuery.of(context).size.height*.01),

                    ],
                  ),
                ),
              ],
            )
              ),
            )
            ,
          );
        },
      ),
    );

  }
  saveImageFaceId() async {
    var imagei;
    var prefs = await SharedPreferences.getInstance();
    String orgid = prefs.getString("orgid") ?? "";
    String empid = prefs.getString("empid") ?? "";

    timeWhenButtonPressed = DateTime.now();

    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraExampleHome()),
      );*/

      if (globals.persistedface == '0' && globals.facerecognition == 1) {
        imagei = await Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) =>
          new Camera(
            mode: CameraMode.normal,
            imageMask: CameraFocus.circle(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          fullscreenDialog: true,)
        );
        if (imagei != null) {
          //print("---------------actionb   ----->"+mk.act);


          List<int> imageBytes = await imagei.readAsBytes();

          String PictureBase64 = base64.encode(imageBytes);

          /*
      final tempDir = await getTemporaryDirectory();
      String path = tempDir.path;
      int rand = new Math.Random().nextInt(10000);
      im.Image image1 = im.decodeImage(imagei.readAsBytesSync());
      imagei.deleteSync();
      im.Image smallerImage = im.copyResize(image1, 500); // choose the size here, it will maintain aspect ratio
      File compressedImage = new File('$path/img_$rand.jpg')..writeAsBytesSync(im.encodeJpg(smallerImage, quality: 50));
    */
          //// sending this base64image string +to rest api
          Dio dio = new Dio();

          FormData formData = new FormData.from({
            "uid": empid,
            "refid": orgid,
            "file": new UploadFileInfo(imagei, "image.png"),
          });
          print(formData);
          Response<String> response1 = await dio.post(
              globals.path + "saveImageFaceId", data: formData);
          print("Response from save image:" + response1.toString());
          //Response<String> response1=await dio.post("https://ubiattendance.ubihrm.com/index.php/services/saveImage",data:formData);
          //Response<String> response1=await dio.post("http://192.168.0.200/ubiattendance/index.php/services/saveImage",data:formData);
          //Response<String> response1 = await dio.post("https://ubitech.ubihrm.com/services/saveImage", data: formData);
          imagei.deleteSync();
          imageCache.clear();
          // globals.cameraChannel.invokeMethod("cameraClosed");
          /*getTempImageDirectory();*/
          Map MarkAttMap = json.decode(response1.data);
          print("facerecog");
          print(MarkAttMap["facerecog"].toString());
          if (MarkAttMap["facerecog"].toString() == 'FACE_DETECTED') {
            showDialog(
                context: context,
                // ignore: deprecated_member_use
                child: new AlertDialog(

                  content: new Text(
                      "Face ID registered successfully"),
                )
            );
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,);

          }else
          if (MarkAttMap["facerecog"].toString() == 'NO_FACE_DETECTED') {

            showDialog(
                context: context,
                // ignore: deprecated_member_use
                child: new AlertDialog(

                  content: new Text(
                      "Picture clicked should be a Selfie"),
                )
            );
            saveImageFaceId();

          }else
          if (MarkAttMap["facerecog"].toString() == 'NO_IMAGE_RECIEVED') {

            showDialog(
                context: context,
                // ignore: deprecated_member_use
                child: new AlertDialog(

                  content: new Text(
                      "No image recieved"),
                )
            );
            saveImageFaceId();

          }else
          if (MarkAttMap["facerecog"].toString() == 'FACE_ID_ALREADY_EXISTS') {

            showDialog(
                context: context,
                // ignore: deprecated_member_use
                child: new AlertDialog(

                  content: new Text(
                      "Face ID already exists"),
                )
            );
            saveImageFaceId();

          }
          print(MarkAttMap["status"].toString());

        }
      }
    }
  }

  markAttByQR(var qr, BuildContext context) async{
    Login dologin = Login();
    setState(() {
      loader = true;
    });
    var islogin = await dologin.markAttByQR(qr,0,context);
    print(islogin);
    if(islogin=="success"){
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Attendance marked successfully.")));
    }else if(islogin=="failure"){
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Invalid login credentials")));
    }else if(islogin=="imposed"){
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Attendance is already marked")));
    }else{
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Attendance is already marked")));
    }
  }

  login(var username,var userpassword, BuildContext context) async{
    var user = User(username,userpassword);
    Login dologin = Login();
    setState(() {
      loader = true;
    });
    var islogin = await dologin.checkLogin(user);
    print(islogin);
    if(islogin=="success"){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }else if(islogin=="failure"){
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Invalid login credentials")));
    }else{
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Poor network connection.")));
    }
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
      return barcode;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
        return "pemission denied";
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
        return "error";
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
      return "error";
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
      return "error";
    }
  }

/*void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
  }*/

}

// TODO: Add AccentColorOverride (103)
