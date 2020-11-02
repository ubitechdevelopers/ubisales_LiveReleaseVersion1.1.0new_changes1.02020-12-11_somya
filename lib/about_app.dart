import 'dart:ui';

import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'drawer.dart';
import 'globals.dart';
import 'home.dart';



void main() => runApp(new AboutApp());

class AboutApp extends StatefulWidget {
  @override
  _AboutApp createState() => _AboutApp();
}

class _AboutApp extends State<AboutApp> {
  String fname="";
  String lname="";
  String desination="";
  String profile="";
  String org_name="";
  bool _isButtonDisabled = false;
  String admin_sts='0';
  String buystatus = "";
  String new_ver='1.0.7';
  TextEditingController textsms = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    final prefs = await SharedPreferences.getInstance();
    checkNow().then((res){
      setState(() {
        new_ver=res;
        print("new_ver");
        print(new_ver);
      });
    });
    setState(() {
      admin_sts = prefs.getString('sstatus').toString();
      buystatus = prefs.getString('buysts') ?? '';
      fname = prefs.getString('fname') ?? '';
      lname = prefs.getString('lname') ?? '';
      desination = prefs.getString('desination') ?? '';
      profile = prefs.getString('profile') ?? '';
      org_name = prefs.getString('org_name') ?? '';
      // _animatedHeight = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: new AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(org_name, style: new TextStyle(fontSize: 20.0)),
            ],
          ),
          leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },),
          backgroundColor: appcolor,
        ),
        endDrawer: new AppDrawer(),
        body: userWidget()
    );
  }

  userWidget(){
    return ListView(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 60,),
              Center(
                child:Text(
                    "ubiSales",
                    style: new TextStyle(
                        fontSize: 32.0,
                        color:appcolor,
                      fontWeight: FontWeight.w600
                    )
                ),
              ),
              SizedBox(height: 15,),
              Center(
                child: Text(
                  'Installed Version '+appVersion,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Center(
                child: new_ver!=appVersion?Text(
                  'This is not the latest version of ubiSales.',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ):Text(
                  'The latest version is already installed.',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                )
              ),
            ],
          ),

        ),
      ],
    );
  }
}