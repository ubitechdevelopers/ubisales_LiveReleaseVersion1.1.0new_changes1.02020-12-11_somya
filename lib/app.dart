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

import 'dart:async';

import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'check_update.dart';
import 'globals.dart';
import 'home.dart';
import 'login.dart';
class ShrineApp extends StatefulWidget {
  @override
  _ShrineAppState createState() => _ShrineAppState();
}
class _ShrineAppState extends State<ShrineApp> {
  Map<String, double> _currentLocation;
 // StreamSubscription<Map<String, double>> _locationSubscription;
 // Location _location = new Location();
  String streamlocationaddr="";
  String lat="";
  String long="";
  int response;
  int responsestate;
  int mand_login=0; // mandatory update is false by default.
  String cur_ver='1.1.3',new_ver='1.1.3';
  String updatestatus = "0";
  Widget _defaultHome = new LoginPage();
  @override
  void initState() {
    super.initState();
    appVersion=cur_ver;
    getShared();

    checkNow().then((res){
      setState(() {
        new_ver=res;
        print(new_ver);
        print("static new version of ubiSales fetched from database");
      });
    });

    UpdateStatus().then((res){
      setState(() {
        updatestatus = res;
        print(updatestatus);  // 1 for update , 0 for NO update
        print("updatestatus");
      });
    });

    platform.setMethodCallHandler(_handleMethod);
  }
  static const platform = const MethodChannel('location.spoofing.check');
  String address="";
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "navigateToPage":
        navigateToPageAfterNotificationClicked(call.arguments["page"].toString(),context);
        break;
      case "locationAndInternet":
      // print(call.arguments["internet"].toString()+"akhakahkahkhakha");
      // Map<String,String> responseMap=call.arguments;
        locationThreadUpdatedLocation=true;

        String long=call.arguments["longitude"].toString();
        String lat=call.arguments["latitude"].toString();
        assign_lat=double.parse(lat);
        assign_long=double.parse(long);
        address=await getAddressFromLati(lat, long);

        getAreaStatus().then((res) {
          // print('called again');
          print('app dot dart');
          if (mounted) {
            setState(() {
              areaSts = res.toString();
              print('response'+res.toString());
              if (areaId != 0 && geoFence == 1) {
                AbleTomarkAttendance = areaSts;
                print('insideable to markatt --------->>>>');
                print('insideabletoatt'+areaId.toString());
              }
            });
          }
        }).catchError((onError) {
          print('Exception occured in clling function.......');
          print(onError);
        });
        print(call.arguments["mocked"].toString());
        globalstreamlocationaddr=address;
        if(call.arguments["TimeSpoofed"].toString()=="Yes"){
          timeSpoofed=true;
        }
        break;

        return new Future.value("");
    }
  }
  getShared() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      response = prefs.getInt('response') ?? 0;
      //print("Response "+response.toString());
    });
  }
  // Set default home.
  // Get result of the login function.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ubiSales',
      home: ((cur_ver == new_ver||new_ver=="error") || updatestatus=='0')?HomePage():CheckUpdate(),
      //home: (true)?HomePage():CheckUpdate(),
     // home: CheckUpdate(),
      routes: {
        // When we navigate to the "/" route, build the FirstScreen Widget
        '/login': (context) => LoginPage(),
        // When we navigate to the "/second" route, build the SecondScreen Widget
        '/home': (context) => HomePage()

      },
    );
  }
  getUpdate(response){
    return (response==1) ? new HomePage() : new LoginPage();
  }
}