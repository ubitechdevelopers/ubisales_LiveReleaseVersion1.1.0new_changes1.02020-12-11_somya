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

import 'package:Shrine/model/user.dart';
import 'package:Shrine/services/checklogin.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'home.dart';
import 'localization/app_translations.dart';
import 'localization/app_translations_delegate.dart';
import 'localization/application.dart';
import 'login.dart';
import 'register_org.dart';

class AskRegisterationPage extends StatefulWidget {
  @override
  _AskRegisterationPageState createState() => _AskRegisterationPageState();
}
class _AskRegisterationPageState extends State<AskRegisterationPage> {
  AppTranslationsDelegate _newLocaleDelegate;

  String barcode = "";
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loader = false;
  FocusNode textSecondFocusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    _newLocaleDelegate = AppTranslationsDelegate(newLocale: null);
    application.onLocaleChanged = onLocaleChange;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _buildPage(context),

      localizationsDelegates: [
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
      },

    );
  }

  @override
  Widget _buildPage(BuildContext context) {
    return new Scaffold(
          body:new Builder(
            builder: (BuildContext context) {
              return new Center(
                child: Form(
                  key: _formKey,
                  child: SafeArea(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      children: <Widget>[
                        SizedBox(height: 25.0),
                        Center(child:Text(AppTranslations.of(context).text("key_surest_way_to_employee_attendance"),style: new TextStyle(color: Colors.black87,fontSize: 19.0,fontWeight: FontWeight.bold))),
                        SizedBox(height: 10.0),
                        Center(child:Text(AppTranslations.of(context).text("key_4_way_check"),style: new TextStyle(color: Colors.black54,fontWeight:FontWeight.bold,fontSize: 14.0,))),
                        Column(
                          children: <Widget>[
                            Image.asset(
                                'assets/landing.png', height: 300.0, width: 300.0),
                            (loader) ? Center(child : new CircularProgressIndicator()) : SizedBox(height: 2.0),
                            SizedBox(height: 60.0),
                          ],
                        ),



                        SizedBox(height: 5.0),
                        Row(

                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ButtonTheme(
                              minWidth: MediaQuery.of(context).size.width*0.8,
                              height: 45.0,
                              child:RaisedButton(
                                child: Text(AppTranslations.of(context).text("key_already_registered"),style: new TextStyle(color: Colors.white,fontSize: 15.0)),
                                color: Colors.orangeAccent,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginPage()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ButtonTheme(
                              minWidth: MediaQuery.of(context).size.width*0.8,
                              height: 45.0,
                              child:FlatButton(
                                shape: Border.all(color: Colors.orangeAccent),
                                child: Text(AppTranslations.of(context).text("key_not_registered"),style: new TextStyle(color: Colors.orangeAccent,fontSize: 14.6),),
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => MyApp()),
                                  );
                                /* Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AskRegisteration()),
                                   // MaterialPageRoute(builder: (context) => MyApp()),
                                  );*/
                                },
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                )
                ,
              );
            },
          ),
        );

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
          SnackBar(content: Text(AppTranslations.of(context).text("key_att_marked"))));
    }else if(islogin=="failure"){
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text(AppTranslations.of(context).text("key_invalid_credentials"))));
    }else if(islogin=="imposed"){
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text(AppTranslations.of(context).text("key_att_already_marked"))));
    }else{
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text(AppTranslations.of(context).text("key_att_already_marked"))));
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
          SnackBar(content: Text(AppTranslations.of(context).text("key_invalid_credentials"))));
    }else{
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text(AppTranslations.of(context).text("key_poor_network"))));
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

  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
  }

}

// TODO: Add AccentColorOverride (103)
