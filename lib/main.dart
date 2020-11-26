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

import 'dart:convert';
import 'dart:math';

import 'package:Shrine/location_tracking/util/geospatial.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:Shrine/app.dart';
import 'package:Shrine/services/newservices.dart';
import 'package:firebase_database/firebase_database.dart' as firebaseDb;

import 'package:Shrine/app.dart';
import 'package:Shrine/globals.dart' as prefix0;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';

import 'config/env.dart';
import 'config/transistor_auth.dart';
import 'globals.dart';
import 'services/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:background_fetch/background_fetch.dart';
import 'package:vector_math/vector_math.dart' as vm;





JsonEncoder encoder = new JsonEncoder.withIndent("     ");

void backgroundGeolocationHeadlessTask(bg.HeadlessEvent headlessEvent) async {
  print('📬 --> $headlessEvent');

  switch(headlessEvent.name) {
    case bg.Event.TERMINATE:
      try {
        //bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition(samples: 1);
        print('[getCurrentPosition] Headless: $headlessEvent');
      } catch (error) {
        print('[getCurrentPosition] Headless ERROR: $error');
      }
      break;
    case bg.Event.HEARTBEAT:
    /* DISABLED getCurrentPosition on heartbeat
      try {
        bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition(samples: 1);
        print('[getCurrentPosition] Headless: $location');
      } catch (error) {
        print('[getCurrentPosition] Headless ERROR: $error');
      }
      */
      break;
    case bg.Event.LOCATION:
      bg.Location location = headlessEvent.event;
      print(location);
      break;
    case bg.Event.MOTIONCHANGE:
      bg.Location location = headlessEvent.event;
      print(location);
      break;
    case bg.Event.GEOFENCE:
      bg.GeofenceEvent geofenceEvent = headlessEvent.event;
      print(geofenceEvent);
      break;
    case bg.Event.GEOFENCESCHANGE:
      bg.GeofencesChangeEvent event = headlessEvent.event;
      print(event);
      break;
    case bg.Event.SCHEDULE:
      bg.State state = headlessEvent.event;
      print(state);
      break;
    case bg.Event.ACTIVITYCHANGE:
      bg.ActivityChangeEvent event = headlessEvent.event;
      print(event);
      break;
    case bg.Event.HTTP:
      bg.HttpEvent response = headlessEvent.event;
      print(response);
      break;
    case bg.Event.POWERSAVECHANGE:
      bool enabled = headlessEvent.event;
      print(enabled);
      break;
    case bg.Event.CONNECTIVITYCHANGE:
      bg.ConnectivityChangeEvent event = headlessEvent.event;
      print(event);
      break;
    case bg.Event.ENABLEDCHANGE:
      bool enabled = headlessEvent.event;
      print(enabled);
      break;
    case bg.Event.AUTHORIZATION:
      bg.AuthorizationEvent event = headlessEvent.event;
      print(event);
      bg.BackgroundGeolocation.setConfig(bg.Config(
          url: "${ENV.TRACKER_HOST}/api/locations"
      ));
      break;
  }
}

/// Receive events from BackgroundFetch in Headless state.
void backgroundFetchHeadlessTask(String taskId) async {
  // Get current-position from BackgroundGeolocation in headless mode.
  //bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition(samples: 1);
  print("[BackgroundFetch] HeadlessTask: $taskId");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int count = 0;
  if (prefs.get("fetch-count") != null) {
    count = prefs.getInt("fetch-count");
  }
  prefs.setInt("fetch-count", ++count);
  print('[BackgroundFetch] count: $count');

  BackgroundFetch.finish(taskId);
}


void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      new MaterialApp(
    home: new MyApp(),
  ));


  TransistorAuth.registerErrorHandler();
  /// Register BackgroundGeolocation headless-task.
  bg.BackgroundGeolocation.registerHeadlessTask(backgroundGeolocationHeadlessTask);
  /// Register BackgroundFetch headless-task.
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool _isMoving;
  bool _enabled;
  String _motionActivity;
  String _odometer;
  String _content;
  String areaStatus = '0';
  bool status= false;



  void initState() {


    //checknetonpage(context);
    // StreamLocation sl = new StreamLocation();
    // sl.startStreaming(10);
    // cameraChannel.invokeMethod("showNotification",{"title":"Welcome to ubiAttendance","description":"Cleck out help videos!"});
    platform.setMethodCallHandler(_handleMethod);
    firebaseHandler();
    _content = "    Enable the switch to begin tracking.";
    _isMoving = false;
    _enabled = false;
    _content = '';
    _motionActivity = 'UNKNOWN';
    _odometer = '0';
    _initPlatformState();

  }
  Future<Null> _initPlatformState() async {

    await FirebaseAuth.instance.signInAnonymously();

    SharedPreferences prefs = await _prefs;
    String orgname = prefs.getString("orgname");
    String username = prefs.getString("username");

    // Sanity check orgname & username:  if invalid, go back to HomeApp to re-register device.
    // Fetch a Transistor demo server Authorization token for tracker.transistorsoft.com.
    bg.TransistorAuthorizationToken token = await bg.TransistorAuthorizationToken.findOrCreate(orgname, username, ENV.TRACKER_HOST);

    // 1.  Listen to events (See docs for all 12 available events).
    bg.BackgroundGeolocation.onLocation(_onLocation, _onLocationError);
    bg.BackgroundGeolocation.onMotionChange(_onMotionChange);
    bg.BackgroundGeolocation.onActivityChange(_onActivityChange);
    bg.BackgroundGeolocation.onProviderChange(_onProviderChange);
    bg.BackgroundGeolocation.onConnectivityChange(_onConnectivityChange);
    bg.BackgroundGeolocation.onHttp(_onHttp);
    bg.BackgroundGeolocation.onAuthorization(_onAuthorization);

    // 2.  Configure the plugin
    bg.BackgroundGeolocation.ready(bg.Config(
        reset: true,
        debug: false,                 //to off
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        url: "${ENV.TRACKER_HOST}/api/locations",
        authorization: bg.Authorization(  // <-- demo server authenticates with JWT
            strategy: bg.Authorization.STRATEGY_JWT,
            accessToken: token.accessToken,
            refreshToken: token.refreshToken,
            refreshUrl: "${ENV.TRACKER_HOST}/api/refresh_token",
            refreshPayload: {
              'refresh_token': '{refreshToken}'
            }
        ),
        encrypt: false,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        speedJumpFilter: 25     //25 metre/sec

    )).then((bg.State state) {
      print("[ready] ${state.toMap()}");
      setState(() {
        _enabled = state.enabled;
        _isMoving = state.isMoving;
      });
    }).catchError((error) {
      print('[ready] ERROR: $error');
    });


  }

  void _onClickEnable(enabled) {
    if (enabled) {
      // Reset odometer.
      bg.BackgroundGeolocation.start().then((bg.State state) {
        print('[start] success $state');
        setState(() {
          _enabled = state.enabled;
          _isMoving = state.isMoving;
        });
      }).catchError((error) {
        print('[start] ERROR: $error');
      });
    } else {
      bg.BackgroundGeolocation.stop().then((bg.State state) {
        print('[stop] success: $state');

        setState(() {
          _enabled = state.enabled;
          _isMoving = state.isMoving;
        });
      });
    }
  }

  // Manually toggle the tracking state:  moving vs stationary
  void _onClickChangePace() {
    setState(() {
      _isMoving = !_isMoving;
    });
    print("[onClickChangePace] -> $_isMoving");

    bg.BackgroundGeolocation.changePace(_isMoving).then((bool isMoving) {
      print('[changePace] success $isMoving');
    }).catchError((e) {
      print('[changePace] ERROR: ' + e.code.toString());
    });
  }

  // Manually fetch the current position.
  void _onClickGetCurrentPosition() {
    bg.BackgroundGeolocation.getCurrentPosition(
        persist: true,      // <-- do persist this location
        desiredAccuracy: 0, // <-- desire best possible accuracy
        timeout: 30000,     // <-- wait 30s before giving up.
        samples: 10          // <-- sample 3 location before selecting best.
    ).then((bg.Location location) {
      print('[getCurrentPosition] - $location');
    }).catchError((error) {
      print('[getCurrentPosition] ERROR: $error');
    });
  }



  ////
  // Event handlers
  //

  Future<double> bearingBetween(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {

    var startLongtitudeRadians = vm.radians(startLongitude);
    var startLatitudeRadians = vm.radians(startLatitude);

    var endLongtitudeRadians = vm.radians(endLongitude);
    var endLattitudeRadians = vm.radians(endLatitude);

    var y = sin(endLongtitudeRadians - startLongtitudeRadians) *
        cos(endLattitudeRadians);
    var x = cos(startLatitudeRadians) * sin(endLattitudeRadians) -
        sin(startLatitudeRadians) *
            cos(endLattitudeRadians) *
            cos(endLongtitudeRadians - startLongtitudeRadians);

    return Future.value(vm.degrees(atan2(y, x)));
  }
  var lastLati=0.0,lastLongi=0.0;

  void _onLocation(bg.Location location) async{



    if (location.sample) { return; }
    print("onlocation.........................." + location.toString());
    print(await bearingBetween(lastLati, lastLongi, double.parse(location.coords.latitude.toString()), double.parse(location.coords.longitude.toString())));
    print(await Geospatial.getBearing(LatLng(lastLati, lastLongi), LatLng(double.parse(location.coords.latitude.toString()), double.parse(location.coords.longitude.toString()))));

    print('[location] - $location');
   print(location.mock);
   print("mock location status");
    firebaseDb.FirebaseDatabase database;
    var currDate=DateTime.now();
    SharedPreferences prefs = await _prefs;
    String orgname = "";
    String username = "";
    prefs.setString("username", username);
    prefs.setString("orgname", orgname);
    String employeeId=prefs.getString("empid");
    String orgId=prefs.getString("orgid");
    var eName = prefs.getString('fname') ?? 'User';

    database = new firebaseDb.FirebaseDatabase();
    database.setPersistenceEnabled(true);

    //if(location.coords.accuracy<10)
    //database.setPersistenceCacheSizeBytes(10000);
     //{
      firebaseDb.DatabaseReference _locRef=database.reference().child('Locations');
      _locRef.child(orgId).child(employeeId).child(
          currDate.toString().split(".")[0].split(" ")[0]).child(
          currDate.toString().split(" ")[1].split(".")[0]).set(<String, String>{
        "is_moving": location.isMoving.toString(),
        "uuid": location.uuid.toString(),
        "odometer": location.odometer.toString(),
        "activity": location.activity.type.toString(),
        "is_charging": location.battery.isCharging.toString(),
        "battery_level": location.battery.level.toString(),
        "altitude": location.coords.altitude.toString(),
        "heading": location.coords.heading.toString(),
        "latitude": location.coords.latitude.toString(),
        "speed": location.coords.speed.toString(),
        "longitude": location.coords.longitude.toString(),
        "accuracy": location.coords.accuracy.toString(),
        "mock": location.mock==true?"true":"false",


      }).then((_) {
        print('Transaction  committed.');
      });
    //}

    print('[${bg.Event.LOCATION}] - $location');


    /*getAreaStatusForPushNotification(location.coords.latitude,location.coords.longitude).then((res) {

      areaStatus = res.toString();
      double accuracy = location.coords.accuracy;

      print(location.coords.accuracy);
      print("main dor dart");
      print(areaStatus);
      print(areaId);

      if (areaStatus == '0' && accuracy <= 20.0 && areaId!=0) {

        if (status == false) {
          sendPushNotification(
              eName + ' has gone outside the geofence.', '',
              '(\'' + prefix0.globalOrgTopic +
                  '\' in topics) && (\'admin\' in topics)');
          status = true;
        }
      }
      else{
        if(accuracy <= 20.0)
        status = false;
        print('Within Geofence_homeview');
      }

      print(areaStatus);
      print("areaStatus123123");
    }).catchError((onError) {
      print('Exception occured in clling function.......');
      print(onError);
    });
*/


    print(_content);
    print("string of location");

   /* serverConnected= await checkConnectionToServer();
    if(serverConnected==1) {
      print("inside server connected");
      var date = DateTime.now().toString();
      var currentTime = date.toString().split(" ")[1].split(".")[0];
      prefs.setString("InternetOnTime", currentTime);
      var InternetOffTime1;
      InternetOffTime1 = prefs.getString('InternetOffTime') ?? '';
      if(InternetOffTime1!='')
        getGPSinformation("InternetOnOffTime");



      var geoLocator = Geolocator();
      var status = await geoLocator.checkGeolocationPermissionStatus();

      print(status);
      print("status of gps inside serverconnected");

    }
    else{
      var date = DateTime.now().toString();
      var currentTime = date.toString().split(" ")[1].split(".")[0];
      var InternetOffTime = prefs.setString("InternetOffTime", currentTime);
      var InternetOffTime1;
      InternetOffTime1 = prefs.getString('InternetOffTime') ?? '';
      print(InternetOffTime1);
      print("InternetOffTime123");


      var geoLocator = Geolocator();
      var status = await geoLocator.checkGeolocationPermissionStatus();

      print(status);
      print("status of gps inside notserverconnected");



    }*/


    String odometerKM = (location.odometer / 1000.0).toStringAsFixed(1);
    // if(mounted)
    // setState(() {
    _content = encoder.convert(location.toMap());
    _odometer = odometerKM;
    //  });
  }

  void _onLocationError(bg.LocationError error) {
    print('[location] ERROR - $error');
  }

  void _onMotionChange(bg.Location location) {
    print('[motionchange] - $location');
  }

  void _onActivityChange(bg.ActivityChangeEvent event) {
    print('[activitychange] - $event');
    if(mounted)
      setState(() {
        _motionActivity = event.activity;
      });
  }

  void _onHttp(bg.HttpEvent event) async {
    print('[${bg.Event.HTTP}] - $event');
  }

  void _onAuthorization(bg.AuthorizationEvent event) async {
    print('[${bg.Event.AUTHORIZATION}] = $event');

    bg.BackgroundGeolocation.setConfig(bg.Config(
        url: ENV.TRACKER_HOST + '/api/locations'
    ));
  }



  void _onProviderChange(bg.ProviderChangeEvent event) async {

    print("....");
    print(event);

    print("ProviderChangeEvent");
    print(event.gps);
    var prefs = await SharedPreferences.getInstance();
    var date = DateTime.now().toString();
    var currentTime = date.toString().split(" ")[1].split(".")[0];
    print("inside main iss");
    print(DateTime.now());
    var GpsOffTime;

    if(event.gps == false){                            //gps is off
      prefs.setString("gpsOffTime", currentTime);
     var get2= prefs.setString("gpsOffTimeOffline", currentTime);
     var gpsOffTimeOffline = prefs.getString('gpsOffTimeOffline') ?? '';
     print(gpsOffTimeOffline);
     print("gpsOffTimeOffline");

      //serverConnected= await checkConnectionToServer();
     GpsOffTime = prefs.getString('gpsOffTime') ?? '';

     /* if(serverConnected==1) {
        getGPSinformation("gpsOffTime");
      }*/
    }

    else{
     // prefs.setString("gpsOnTime", "gpsOnTime");
     var get1 = prefs.setString("gpsOnTimeOffline", currentTime);
     print(get1);
     print("gpsOnTimeOffline");
     // serverConnected= await checkConnectionToServer();
     // GpsOffTime = prefs.getString('gpsOnTime') ?? '';
     GpsOffTime = prefs.getString('gpsOffTime') ?? '';
      if(GpsOffTime!=''){
       // getGPSinformation("gpsOnOffTime");
      }
    }

    if(mounted)
      setState(() {
        _content = encoder.convert(event.toMap());
        print(_content);
      });
  }



  void _onConnectivityChange(bg.ConnectivityChangeEvent event) async {  //when internet is on/off
    print('$event');
    print("hgvjhgbkjhbk");
    var prefs = await SharedPreferences.getInstance();
    var date = DateTime.now().toString();
    print(event.connected);

    if(event.connected == false){
      var date = DateTime.now().toString();
      var currentTime = date.toString().split(" ")[1].split(".")[0];
     var InternetOffTime = prefs.setString("InternetOffTime", currentTime);
      var InternetOffTime1;
      InternetOffTime1 = prefs.getString('InternetOffTime') ?? '';
     print(InternetOffTime1);
     print("InternetOffTime123");

    }
    else{

      var date = DateTime.now().toString();
      var currentTime = date.toString().split(" ")[1].split(".")[0];
      prefs.setString("InternetOnTime", currentTime);
      var InternetOffTime1;
      InternetOffTime1 = prefs.getString('InternetOffTime') ?? '';
     // if(InternetOffTime1!='')
    //  getGPSinformation("InternetOnOffTime");

    }
    print("connectivity change");
  }

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
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
        prefix0.locationThreadUpdatedLocation=true;
        if(call.arguments["TimeSpoofed"].toString()=="Yes"){
          timeSpoofed=true;
        }
        String long=call.arguments["longitude"].toString();
        String lat=call.arguments["latitude"].toString();
        assign_lat=double.parse(lat);
        assign_long=double.parse(long);
        address=await getAddressFromLati(lat, long);
        print(call.arguments["mocked"].toString());
        getAreaStatus().then((res) {
          // print('called again');
          print('main dot dart');
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

        globalstreamlocationaddr=address;

        break;

        return new Future.value("");
    }
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body:new Builder(
        builder: (BuildContext context) {
          return new SplashScreen(
            seconds: 2,
            navigateAfterSeconds: new ShrineApp(),
            title: new Text('',style: TextStyle(fontSize: 32.0),),
            loaderColor: Colors.blueGrey[100],
            image:   Image.asset('assets/splash.png'),
            backgroundColor: Colors.white,
            styleTextUnderTheLoader: new TextStyle(color: Colors.grey[500]),
            photoSize: MediaQuery.of(context).size.width*0.45
            /*onClick: ()=>print("Flutter Egypt"),*/
          );
        }),);
  }
  void firebaseHandler() async{
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message'+message['data'].isEmpty.toString());
//{notification: {title: ABC has marked his Time In, body: null}, data: {}}
      //  cameraChannel.invokeMethod("showNotification",{"title":message['notification']['title']==null?'':message['notification']['title'].toString(),"description":message['notification']['body']==null?'':message['notification']['body'].toString(),"pageToOpenOnClick":message['data'].isEmpty?'':message['data']['pageToNavigate']});

      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        var navigate=message['data'].isEmpty?'':message['data']['pageToNavigate'];
        //navigateToPageAfterNotificationClicked(navigate, context);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        var navigate=message['data'].isEmpty?'':message['data']['pageToNavigate'];
        //navigateToPageAfterNotificationClicked(navigate, context);
      },
    );
  }
}
