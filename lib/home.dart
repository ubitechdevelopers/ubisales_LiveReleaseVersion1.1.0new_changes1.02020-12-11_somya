// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;
import 'dart:math';
import 'dart:typed_data';
import 'package:Shrine/UserShiftCalendar.dart';
import 'package:Shrine/addEmployee.dart';
import 'package:Shrine/askregister.dart';
import 'package:Shrine/avatar_glow.dart';
import 'package:Shrine/covid19servey.dart';
import 'package:Shrine/database_models/qr_offline.dart';
import 'package:Shrine/database_models/visits_offline.dart';
import 'package:Shrine/drawer.dart';
import 'package:Shrine/every7dayscovidsurvey.dart';
import 'package:Shrine/faceIdScreen.dart';
import 'package:Shrine/home.dart';
import 'package:Shrine/location_tracking/home_view.dart';
import 'package:Shrine/model/timeinout.dart';
import 'package:Shrine/myleave.dart';
import 'package:Shrine/offline_home.dart';
import 'package:Shrine/payment.dart';
import 'package:Shrine/profile.dart';
import 'package:Shrine/punchlocation_summaryOld.dart';
import 'package:Shrine/reports.dart';
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/saveimage.dart';
import 'package:Shrine/settings.dart';
//import 'package:Shrine/punchlocation_summary.dart';
import 'package:Shrine/timeoff_summary.dart';
import 'package:Shrine/userviewShiftPlanner.dart';
import 'package:background_geolocation_firebase/background_geolocation_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
//import 'package:circular_menu/circular_menu.dart';
import 'package:dio/dio.dart';
import 'package:Shrine/visits_list_emp.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
//import 'package:flutter_boom_menu/flutter_boom_menu.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:launch_review/launch_review.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
//import 'package:search_map_place/search_map_place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Bottomnavigationbar.dart';
//import 'Search.dart';
import 'attendance_summary.dart';
import 'bulkatt.dart';
import 'database_models/attendance_offline.dart';
import 'globals.dart';
import 'location_tracking/map_pin_pill.dart';
import 'location_tracking/pin_pill_info.dart';
import 'login.dart';
import 'services/services.dart';
import 'dart:ui' as ui;
import 'package:Shrine/globals.dart' as globals;
import 'package:image/image.dart' as image;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
// This app is a stateful, it tracks the user's current choice.

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(26.19675, 78.1970444);
const LatLng DEST_LOCATION = LatLng(26.19675, 78.1970424);
double pinPillPosition = -470;
PinInformation currentlySelectedPin = PinInformation(pinPath: '', avatarPath: '', location: LatLng(0, 0), client: '',description: '', labelColor: Colors.grey,in_time: '',out_time: '');
PinInformation sourcePinInfo;
PinInformation destinationPinInfo;
var cameraSource=LatLng(26.19675, 78.1970424);


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class Locations {
  String longitude;
  String latitude;
  String accuracy;
  String activity;
  String altitude;
  String battery_level;
  String heading;
  String is_charging;
  String is_moving;
  String odometer;
  String speed;
  String uuid;
  String time;
  String mock;
  Locations.fromFireBase1(Map<String,dynamic> map) {
    var snapshot;
    var key;
    map.forEach((k,v){
      this.time=k;
      snapshot=v;
    });

    this.longitude = snapshot["longitude"] ?? '0.0';
    this.latitude = snapshot["latitude"] ?? '0.0';
    this.accuracy = snapshot["accuracy"] ?? '.0';
    this.activity = snapshot["activity"] ?? 'Unknown user';
    this.altitude = snapshot["altitude"] ?? 'Unknown user';
    this.battery_level = snapshot["battery_level"] ?? 'Unknown user';
    this.heading = snapshot["heading"] ?? 'Unknown user';
    this.is_charging = snapshot["is_charging"] ?? 'Unknown user';
    this.is_moving = snapshot["is_moving"] ?? 'Unknown user';
    this.odometer = snapshot["odometer"] ?? 'Unknown user';
    this.speed = snapshot["speed"] ?? 'Unknown user';
    this.uuid = snapshot["uuid"] ?? 'Unknown user';
    this.mock = snapshot["mock"] ?? 'false';
  }

  Locations.fromFireBase(DataSnapshot snapshot) {
    this.longitude = snapshot.value["longitude"] ?? '0.0';
    this.latitude = snapshot.value["latitude"] ?? '0.0';
    this.accuracy = snapshot.value["accuracy"] ?? '.0';
    this.activity = snapshot.value["activity"] ?? 'Unknown user';
    this.altitude = snapshot.value["altitude"] ?? 'Unknown user';
    this.battery_level = snapshot.value["battery_level"] ?? 'Unknown user';
    this.heading = snapshot.value["heading"] ?? 'Unknown user';
    this.is_charging = snapshot.value["is_charging"] ?? 'Unknown user';
    this.is_moving = snapshot.value["is_moving"] ?? 'Unknown user';
    this.odometer = snapshot.value["odometer"] ?? 'Unknown user';
    this.speed = snapshot.value["speed"] ?? 'Unknown user';
    this.uuid = snapshot.value["uuid"] ?? 'Unknown user';
    this.mock = snapshot.value["mock"] ?? 'false';
    this.time = snapshot.key ?? '00:00:00';

  }

  Locations.fromFireStore(data) {
    //var data=json.decode(data1.toString());
    print(data["location"].toString()+"shhshshgsgjg");
    try{


      this.longitude = data['location']["coords"]["longitude"] .toString()?? '0.0';
      this.latitude = data['location']["coords"]["latitude"] .toString()?? '0.0';
      this.accuracy = data['location']["coords"]["accuracy"].toString() ?? '.0';
      this.activity = data['location']["coords"]["activity"].toString() ?? 'Unknown user';
      this.altitude = data['location']["coords"]["altitude"].toString() ?? 'Unknown user';
      this.battery_level = data['location']["battery"]["level"].toString() ?? 'Unknown user';
      this.heading = data['location']["coords"]["heading"].toString() ?? 'Unknown user';
      this.is_charging = data['location']["battery"]["is_charging"].toString() ?? 'Unknown user';
      this.is_moving = data['location']["is_moving"].toString() ?? 'Unknown user';
      this.odometer = data['location']["odometer"].toString() ?? 'Unknown user';
      this.speed = data['location']["coords"]["speed"].toString() ?? 'Unknown user';
      this.uuid = data['location']["uuid"].toString() ?? 'Unknown user';
      this.mock = 'false';
      this.time = data['location']["extras"]["timestamp"].toString().split("T")[1] ?? '00:00:00';



    }catch(e){
      print("jhkjhkkjhk"+e.toString());
    }

  }
}


class _HomePageState extends State<HomePage>  with WidgetsBindingObserver{
  Completer<GoogleMapController> _controller = Completer();
  static const platform = const MethodChannel('location.spoofing.check');

  // this set will hold my markers
  Set<Marker> _markers = {};
  Set<Marker> _markers1 = {};
  Set<Marker> _markers2 = {};
  bool selected = true;
  String _colorName = 'No';
  String profile ="";
  String fname ="";
  String lname ="";
  bool scrollVisible = true;
  Color _color = Colors.black;
  List<LatLng> latlng = List();
  bool dialVisible = true;
  LatLng _new = SOURCE_LOCATION;
  LatLng _news = DEST_LOCATION ;
  double opacityLevel = 1.0;
  double opacityLevel1 = 0.0;
  bool visible = false;
  Map<String, dynamic> StoreLocation ={};
  List<List<dynamic>> insideGeo = new List();
  var distinctIds;
  var currlat;
  var currlong;
  String streamlocationaddr1 ="";
  String clat='';
  String clong='';
  bool search = false;
  String empname = "";
  bool res = true;
  TextEditingController _textController = TextEditingController();
  static List<dynamic> Name = new List();
  static List<dynamic> NameList = new List();
  // List<dynamic> newDataList;
  List<dynamic> newDataList1=[];
  List<dynamic> searchedName=[];
  var First;
  var Last;
  var initials;
  bool _checkLoaded = false;
  bool _checkLoaded1 = false;
  bool profileLoaded = false;

  List popupLocations= new List();
  var closeEmp = false;
  PersistentBottomSheetController controller;
  bool setLoader=false;
  bool mapLoader = false;
  var _shifts;
  // this will hold the generated polylines
  Set<Polyline> _polylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];

  List <Locations> locationList = [];
  String _orgName = "";
  var ContainerWidth =0.0;
  var ContainerHeight =0.0;
  StreamSubscription <Event> updates;
  final GlobalKey<FabCircularMenuState> fabKey1 = GlobalKey();
  final GlobalKey<FabCircularMenuState> fabKey2 = GlobalKey();
  var childButtons = List<UnicornButton>();
  Completer<GoogleMapController> controller2 = Completer();
  bool _IsSearching;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;
  bool Tap = false;
  var profileImage;
  var count1=0;
  String kms="0.0";
  var recentEmployeeId;
  List<Attendance> attList = [];



  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyDYh77SKpI6kAD1jiILwbiISZEwEOyJLtM";
  // for my custom icons
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  String empId;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var profileimage;
  var Rating;
  bool FirstAttendance=false;
  bool RateusDialogShown=false;
  bool FeedbackDialogShown=false;
  bool FiveStarRating=false;
  String datetoShowFeedbackDialog='';
  String dateShowedFeedbackDialog='';
  String datetoShowRatingDialog='';
  String dateShowedRatingDialog='';
  int _currentIndex = 1;
  String userpwd = "new";
  String newpwd = "new";
  int Is_Delete = 0;
  bool _visible = true;
  String buysts = '0';
  String admin_sts = '0';
  bool glow = true;
  String mail_varified = '1';
  //String AbleTomarkAttendance = '0';
  String act = "";
  String act1 = "";
  int alertdialogcount = 0;
  Timer timer;
  Timer timer1;
  Timer timerrefresh;
  int response;
  String Password_sts='';
  String changepasswordStatus ='';
  String covid_first="0";
  String covid_second="0";
  // var workingHoursTimer;
  final Widget removedChild = Center();
  String empid = "",
      email = "",
      status = "",
      orgid = "",
      orgdir = "",
      sstatus = "",
      org_name = "",
      desination = "",
      desinationId = "";
  bool issave = false;
  String areaStatus = '0';
  String aid = "";
  String shiftId = "";
  List<Widget> widgets;
  bool refreshsts = false;
  bool fakeLocationDetected = false;
  bool offlineDataSaved = false;
  bool internetAvailable = true;
  String address = '';
  String createdDate = "";
  String dateShowed = "";
  String dateShowedCovidSurvey='';
  String datetoShowCovidSurvey='';
  var currDate = DateTime.now();
  var now = new DateTime.now();
  var formatter = new intl.DateFormat('yyyy-MM-dd');
  var ReferrerNotificationList = new List(5);
  var ReferrerenceMessagesList = new List(7);
  var token = "";
  final _formKey = GlobalKey<FormState>();
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  FocusNode __oldPass = new FocusNode();
  FocusNode __newPass = new FocusNode();
  bool companyFreshlyRegistered = false;
  bool attendanceNotMarkedButEmpAdded = false;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var firstTimeinPopup;
  var occurences=0;
  bool fabOpen = false;
  var childExist = false;
  TextEditingController today;
  int _selectedIndex = null;

  @override
  void initState() {
    Name.clear();
    NameList.clear();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
    getOrgName();
    _getLocation();
    today = new TextEditingController();
    today.text = formatter.format(DateTime.now());
    platform.setMethodCallHandler(_handleMethod);  //add

  //  example();


    //opacityLevel=2.0;
  }

  /*example(){
    String a ="abcdefghijklmnopqrstuvwxyz";
    String s ="abczgdprstubg";
    List l1 = new List();

    for(int i=0;i<s.length;i++){

     String a  = s[i];
     String b = a.in;

     if(a==b){
       l1.add(a);
       continue;
     }
     else{

     }

    }

  }*/

  void _getLocation() async {




    var location = new Location();
    try {
      await location.getLocation().then((onValue) {
        setState(() {
          currlat = onValue.latitude.toDouble();
          currlong =  onValue.longitude.toDouble();

        });
      });
    } catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
      }
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  getOrgName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName = prefs.getString('org_name') ?? '';
    });
  }
  TabController _controller1;

  syncOfflineQRData() async {
    address = await getAddressFromLati(
        globals.assign_lat.toString(), globals.assign_long.toString());
    print(address +
        "xnjjjjjjlllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll");

    int serverAvailable = await checkConnectionToServer();
    if (serverAvailable == 1) {
      /*****************************For Attendances***********************************************/

      QROffline qrOffline = new QROffline.empty();

      List<QROffline> qrs = await qrOffline.select();

      List<Map> jsonList = [];
      if (qrs.isNotEmpty) {
        for (int i = 0; i < qrs.length; i++) {
          var address = await getAddressFromLati(qrs[i].Latitude, qrs[i].Longitude);
          print(address);
          jsonList.add({
            "Id": qrs[i].Id,
            "SupervisorId": qrs[i].SupervisorId,
            "Action": qrs[i].Action, // 0 for time in and 1 for time out
            "Date": qrs[i].Date,
            "OrganizationId": qrs[i].OrganizationId,
            "PictureBase64": qrs[i].PictureBase64,
            "Latitude": qrs[i].Latitude,
            "Longitude": qrs[i].Longitude,
            "Time": qrs[i].Time,
            "UserName": qrs[i].UserName,
            "Password": qrs[i].Password,
            "FakeLocationStatus": qrs[i].FakeLocationStatus,
            "FakeTimeStatus": qrs[i].FakeTimeStatus,
            "Address": address,
            "appName": "ubiSales"
          });
        }
        var jsonList1 = json.encode(jsonList);
        //LogPrint('response1: ' + jsonList1.toString());
        //LogPrint(attendances);
        FormData formData = new FormData.from({"data": jsonList1});

        Dio dioForSavingOfflineAttendance = new Dio();
        dioForSavingOfflineAttendance
            .post(path + "saveOfflineQRData", data: formData)
            .then((responseAfterSavingOfflineData) async {
          var response = json.decode(responseAfterSavingOfflineData.toString());

          print(
              '--------------------- Data Syncing Response--------------------------------');
          print(responseAfterSavingOfflineData);

          print(
              '--------------------- Data Syncing Response--------------------------------');
          for (int i = 0; i < response.length; i++) {
            var map = response[i];
            map.forEach((localDbId, status) {
              QROffline qrOffline = QROffline.empty();
              print(status);
              qrOffline.delete(int.parse(localDbId));
            });
          }
        });
      } else {
        if (mounted) {
          setState(() {
            //  offlineDataSaved=true;
          });
        }
      }
    }

    /*****************************For Attendances***********************************************/
  }

  syncVisits(visits) async {
    for (int i = 0; i < visits.length; i++) {
      if (visits[i].VisitInLatitude.isEmpty) visits[i].VisitInLatitude = "0.0";
      if (visits[i].VisitOutLatitude.isEmpty)
        visits[i].VisitOutLatitude = "0.0";
      if (visits[i].VisitInLongitude.isEmpty)
        visits[i].VisitInLongitude = "0.0";
      if (visits[i].VisitOutLongitude.isEmpty)
        visits[i].VisitOutLongitude = "0.0";

      var VisitInaddress = await getAddressFromLati_offline(
          double.parse(visits[i].VisitInLatitude),
          double.parse(visits[i].VisitInLongitude));
      print("-------------------------------jhkhk--------------------------");
      print(visits[i].VisitOutLatitude + "   ");
      print(visits[i].VisitOutLongitude);
      var VisitOutaddress = await getAddressFromLati_offline(
          double.parse(visits[i].VisitOutLatitude),
          double.parse(visits[i].VisitOutLongitude));
      // print(address);
      List<Map> jsonList = [];
      jsonList.add({
        'Id': visits[i].Id,
        'EmployeeId': visits[i].EmployeeId,
        'VisitInLatitude': visits[i].VisitInLatitude,
        'VisitInLongitude': visits[i].VisitInLongitude,
        'VisitInTime': visits[i].VisitInTime,
        'VisitInDate': visits[i].VisitInDate,
        'VisitOutLatitude': visits[i].VisitOutLatitude,
        'VisitOutLongitude': visits[i].VisitOutLongitude,
        'VisitOutTime': visits[i].VisitOutTime,
        'VisitOutDate': visits[i].VisitOutDate,
        'ClientName': visits[i].ClientName,
        'VisitInDescription': visits[i].VisitInDescription,
        'VisitOutDescription': visits[i].VisitOutDescription,
        'OrganizationId': visits[i].OrganizationId,
        'Skipped': visits[i].Skipped,
        'VisitInImage': visits[i].VisitInImage,
        'VisitOutImage': visits[i].VisitOutImage,
        'VisitInAddress': VisitInaddress,
        'VisitOutAddress': VisitOutaddress,
        'FakeLocationStatusVisitIn': visits[i].FakeLocationStatusVisitIn,
        'FakeLocationStatusVisitOut': visits[i].FakeLocationStatusVisitOut,
        'FakeVisitInTimeStatus': visits[i].FakeVisitInTimeStatus,
        'FakeVisitOutTimeStatus': visits[i].FakeVisitOutTimeStatus
      });

      var jsonList1 = json.encode(jsonList);
      LogPrint('response1: ' + jsonList1.toString());
      //LogPrint(attendances);
      FormData formData = new FormData.from({"data": jsonList1});

      Dio dioForSavingOfflineAttendance = new Dio();
      dioForSavingOfflineAttendance
          .post(globals.path + "saveOfflineVisits", data: formData)
          .then((responseAfterSavingOfflineData) async {
        var response = json.decode(responseAfterSavingOfflineData.toString());

        print(
            '--------------------- Visit Syncing Response--------------------------------');
        LogPrint(responseAfterSavingOfflineData);

        print(
            '--------------------- Visit Syncing Response--------------------------------');
        for (int i = 0; i < response.length; i++) {
          var map = response[i];
          map.forEach((localDbId, status) {
            VisitsOffline visitsOffline = VisitsOffline.empty();
            print(status);
            visitsOffline.delete(int.parse(localDbId));
          });
        }
        setState(() {
          offlineDataSaved = true;
        });
      });
    }
  }

  static void LogPrint(Object object) async {
    int defaultPrintLength = 1020;
    if (object == null || object.toString().length <= defaultPrintLength) {
      print(object);
    } else {
      String log = object.toString();
      int start = 0;
      int endIndex = defaultPrintLength;
      int logLength = log.length;
      int tmpLogLength = log.length;
      while (endIndex < logLength) {
        print(log.substring(start, endIndex));
        endIndex += defaultPrintLength;
        start += defaultPrintLength;
        tmpLogLength -= defaultPrintLength;
      }
      if (tmpLogLength > 0) {
        print(log.substring(start, logLength));
      }
    }
  }

  syncOfflineData() async {

    int serverAvailable = await checkConnectionToServer();
    if (serverAvailable == 1) {

      /*  sync only  image code  */
      SaveImage saveImage = new SaveImage();
      saveImage.SendTempimage(context , false);

      /*****************************For Attendances***********************************************/
      await syncOfflineQRData();

      AttendanceOffline attendanceOffline = new AttendanceOffline.empty();
      VisitsOffline visitsOffline = VisitsOffline.empty();

      List<AttendanceOffline> attendances = await attendanceOffline.select();
      List<VisitsOffline> visits = await visitsOffline.select();

      List<Map> jsonList = [];
      List<Map> jsonListVisits = [];
      if (visits.isNotEmpty) {
        await syncVisits(visits);
      } else {
        offlineDataSaved = true;
      }
      if (attendances.isNotEmpty) {
        for (int i = 0; i < attendances.length; i++) {
          var address = await getAddressFromLati_offline(
              double.parse(attendances[i].Latitude),
              double.parse(attendances[i].Longitude));
          print(address);
          jsonList.add({
            "Id": attendances[i].Id,
            "UserId": attendances[i].UserId,
            "Action": attendances[i].Action, // 0 for time in and 1 for time out
            "Date": attendances[i].Date,
            "OrganizationId": attendances[i].OrganizationId,
            "PictureBase64": attendances[i].PictureBase64,
            "Latitude": attendances[i].Latitude,
            "Longitude": attendances[i].Longitude,
            "Time": attendances[i].Time,
            "FakeLocationStatus": attendances[i].FakeLocationStatus,
            "FakeTimeStatus": attendances[i].FakeTimeStatus,
            "Address": address,
            "appVersion": globals.appVersion,
            "appName":"ubiSales"
          });
        }
        var jsonList1 = json.encode(jsonList);
        //LogPrint('response1: ' + jsonList1.toString());
        //LogPrint(attendances);
        FormData formData = new FormData.from({"data": jsonList1});

        Dio dioForSavingOfflineAttendance = new Dio();
        dioForSavingOfflineAttendance
            .post(globals.path + "saveOfflineData", data: formData)
            .then((responseAfterSavingOfflineData) async {
          var response = json.decode(responseAfterSavingOfflineData.toString());

          print(
              '--------------------- Data Syncing Response--------------------------------');
          LogPrint(responseAfterSavingOfflineData);

          print(
              '--------------------- Data Syncing Response--------------------------------');
          for (int i = 0; i < response.length; i++) {
            var map = response[i];
            map.forEach((localDbId, status) {
              AttendanceOffline attendanceOffline = AttendanceOffline.empty();
              print(status);
              attendanceOffline.delete(int.parse(localDbId));
            });
          }
          setState(() {
            offlineDataSaved = true;
          });

          Home ho = new Home();

          act = await ho.checkTimeIn(empid, orgdir,context);
          print("Action from check time in");
          ho.managePermission(empid, orgdir, desinationId);

          setState(() {
            act1 = act;
          });
        });
      } else {
        if (mounted) {
          setState(() {
            offlineDataSaved = true;
          });
        }
      }
    }

    Home ho = new Home();
    act = await ho.checkTimeIn(empid, orgdir,context);
    print("Action from check time in1");
    if (timeoutdate == 'nextdate' && act == 'TimeOut') dialogwidget(context);
    ho.managePermission(empid, orgdir, desinationId);
    if (mounted) {
      setState(() {
        act1 = act;
      });
    }

    /*****************************For Attendances***********************************************/
  }


  void firebaseCloudMessaging_Listeners() async {
    var serverConnected = await checkConnectionToServer();

    if (serverConnected == 1) {
      var prefs = await SharedPreferences.getInstance();
      var country = prefs.getString("CountryName") ?? '';
      var orgTopic = prefs.getString("OrgTopic") ?? '';
      var isAdmin = admin_sts = prefs.getString('sstatus').toString() ?? '0';
      var employeeTopic = prefs.getString("EmployeeTopic") ?? '';

      //   _firebaseMessaging.subscribeToTopic('geofenceStatus');

      //_firebaseMessaging.subscribeToTopic('101');
      // _firebaseMessaging.subscribeToTopic('testtopic');



      if (isAdmin == '1') {
        _firebaseMessaging.subscribeToTopic('admin');
        print("Admin topic subscribed");
      } else {
        print("employee topic subscribed");
        if (orgTopic.isNotEmpty)
          _firebaseMessaging.subscribeToTopic('employee');
      }
      if (globals.globalEmployeeTopic.isNotEmpty) {
        // _firebaseMessaging.unsubscribeFromTopic(employeeTopic.replaceAll(' ', ''));
        _firebaseMessaging
            .subscribeToTopic(globals.globalEmployeeTopic.replaceAll(' ', ''));

        print('globals.globalEmployeeTopic' + globals.globalEmployeeTopic.toString());

        prefs.setString("EmployeeTopic", globals.globalEmployeeTopic);
      } else {
        if (employeeTopic.isNotEmpty)
          _firebaseMessaging.subscribeToTopic(employeeTopic.replaceAll(' ', ''));
        print('globals.globalEMployeeTopic11111' + employeeTopic);
      }

      if (globals.globalOrgTopic.isNotEmpty) {
        _firebaseMessaging.unsubscribeFromTopic(orgTopic.replaceAll(' ', ''));
        _firebaseMessaging
            .subscribeToTopic(globals.globalOrgTopic.replaceAll(' ', ''));

        print('globals.globalOrgTopic' + globals.globalOrgTopic.toString());

        prefs.setString("OrgTopic", globals.globalOrgTopic);
      } else {
        if (orgTopic.isNotEmpty)
          _firebaseMessaging.subscribeToTopic(orgTopic.replaceAll(' ', ''));
        print('globals.globalOrgTopic11111' + orgTopic);
      }

      if (globals.globalCountryTopic.isNotEmpty) {
        _firebaseMessaging.unsubscribeFromTopic(country.replaceAll(' ', ''));
        _firebaseMessaging
            .subscribeToTopic(globals.globalCountryTopic.replaceAll(' ', ''));
        prefs.setString("CountryName", globals.globalCountryTopic);
      } else {
        if (country.isNotEmpty)
          _firebaseMessaging.subscribeToTopic(country.replaceAll(' ', ''));
      }

      if (globals.currentOrgStatus.isNotEmpty) {
        var previousOrgStatus = prefs.get("CurrentOrgStatus") ?? '';
        if (previousOrgStatus.isNotEmpty)
          _firebaseMessaging
              .unsubscribeFromTopic(previousOrgStatus.replaceAll(' ', ''));
        _firebaseMessaging
            .subscribeToTopic(globals.currentOrgStatus.replaceAll(' ', ''));

        prefs.setString("CurrentOrgStatus", globals.currentOrgStatus);
        globals.currentOrgStatus = '';
      }
      _firebaseMessaging.getToken().then((token) {
        _firebaseMessaging.subscribeToTopic("AllOrg");
        // _firebaseMessaging.subscribeToTopic("UBI101");
        _firebaseMessaging.subscribeToTopic("AllCountry");

        // print('country subscribed'+country);

        this.token = token;

        // sendPushNotification("https://fcm.googleapis.com/fcm/send", token.toString(),"This is notification from mobile","Mobile Notification");

        // print("token--------------->"+token.toString()+"-------------"+country);
      });

      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message' + message['data'].isEmpty.toString());
//{notification: {title: ABC has marked his Time In, body: null}, data: {}}
          cameraChannel.invokeMethod("showNotification", {
            "title": message['notification']['title'] == null
                ? ''
                : message['notification']['title'].toString(),
            "description": message['notification']['body'] == null
                ? ''
                : message['notification']['body'].toString(),
            "pageToOpenOnClick":
            message['data'].isEmpty ? '' : message['data']['pageToNavigate']
          });
        },
        onResume: (Map<String, dynamic> message) async {
          print('on resume $message');
          var navigate =
          message['data'].isEmpty ? '' : message['data']['pageToNavigate'];
          navigateToPageAfterNotificationClicked(navigate, context);

        },
        onLaunch: (Map<String, dynamic> message) async {
          print('on launch $message');
          var navigate =
          message['data'].isEmpty ? '' : message['data']['pageToNavigate'];
          navigateToPageAfterNotificationClicked(navigate, context);

        },
      );

/*
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message'+message['data'].isEmpty.toString());
//{notification: {title: ABC has marked his Time In, body: null}, data: {}}
          cameraChannel.invokeMethod("showNotification",{"title":message['notification']['title']==null?'':message['notification']['title'].toString(),"description":message['notification']['body']==null?'':message['notification']['body'].toString(),"pageToOpenOnClick":message['data'].isEmpty?'':message['data']['pageToNavigate']});

        },
        onResume: (Map<String, dynamic> message) async {
          print('on resume $message');
//        var navigate=message['data'].isEmpty?'':message['data']['pageToNavigate'];
//        navigateToPageAfterNotificationClicked(navigate, context);
          /*
        navigatorKey.currentState.push(
            MaterialPageRoute(builder: (_) => Reports())
        );
        */
          setState(() {
            id=message['data']['body'];
          });
          if(id=='123'){
            navigatorKey.currentState.push(
                MaterialPageRoute(builder: (_) =>
                    TimeOffList()
                )
            );
          }else{
            navigatorKey.currentState.push(
                MaterialPageRoute(builder: (_) =>
                    Reports()
                )
            );

          }
        },
        onLaunch: (Map<String, dynamic> message) async {
          print('on launch $message');
//        var navigate=message['data'].isEmpty?'':message['data']['pageToNavigate'];
//        navigateToPageAfterNotificationClicked(navigate, context);
          setState(() {
            id=message['data']['id'];
          });
          if(id=='123'){
            navigatorKey.currentState.push(
                MaterialPageRoute(builder: (_) =>
                    TimeOffList()
                )
            );
          }else{
            navigatorKey.currentState.push(
                MaterialPageRoute(builder: (_) =>
                    Reports()
                )
            );

          }
        },
      );
      */
    }
  }


  initPlatformState() async {

    checknetonpage(context);

    //checkLocationEnabled(context);
    appResumedPausedLogic(context);
    timerResumePause();
    cameraChannel.invokeMethod("openLocationDialog");
    //sendPushNotification('ABC has marked his Time In','','ALL_ORG');

    //showEmailVerificationReminder();





    //showAddingShiftReminder();
    var prefs = await SharedPreferences.getInstance();
    var orgid11= prefs.getString("orgid")??"0";
    var empid11 = prefs.getString("empid")??'0';
    var gpsOnTimeOffline;
    var gpsOffTimeOffline;



    var date11 = new DateTime.now().toString();

    var dateParse = DateTime.parse(date11);

    var formattedDate = "${dateParse.day.toString().padLeft(2, '0')}-${dateParse.month.toString().padLeft(2, '0')}-${dateParse.year}";

    var finalDate = formattedDate.toString() ;

    DateTime now = DateTime.now();

    var curtime = now.hour.toString() + ":" + now.minute.toString() + ":" + now.second.toString();

    BackgroundGeolocationFirebase.configure(BackgroundGeolocationFirebaseConfig(
        locationsCollection: "locations/$orgid11/$empid11/$finalDate/latest",
        geofencesCollection: "geofences",
        updateSingleDocument: false
    ));

  /*  gpsOnTimeOffline = prefs.getString('gpsOnTimeOffline') ?? '';
    gpsOffTimeOffline = prefs.getString('gpsOffTimeOffline') ?? '';//unset prefs imp

    if(gpsOnTimeOffline!='' && gpsOffTimeOffline!='') {
      getGPSinformationOffline(gpsOnTimeOffline, gpsOffTimeOffline);
      prefs.remove('gpsOnTimeOffline');
      prefs.remove('gpsOffTimeOffline');
    }

    var InternetOffTime;
    InternetOffTime = prefs.getString('InternetOffTime') ?? '';
    if(InternetOffTime!='') {
      getGPSinformation("InternetOnOffTime");
    }

    print(InternetOffTime);
    print("InternetOffTime");*/


    firstTimeinPopup=prefs.getInt("firstTimein")??0;
    // occurences++;

    if(firstTimeinPopup<10){
      print(firstTimeinPopup);
      print("gjkmgjkgkjgkjgkgju");
      selected = true;
      opacityLevel = 1.0;
      opacityLevel1 = 0.0;
    }
    else{
      selected = false;
      opacityLevel = 0.0;
      opacityLevel1 = 0.0;
    }

    // startWorkingHoursTimer();

    setState(() {
      companyFreshlyRegistered =
          prefs.getBool("companyFreshlyRegistered") ?? false;
      FirstAttendance =
          prefs.getBool("FirstAttendance") ?? false;
      FiveStarRating =
          prefs.getBool("FiveStarRating") ?? false;
      RateusDialogShown =
          prefs.getBool("RateusDialogShown") ?? false;
      FeedbackDialogShown =
          prefs.getBool("FeedbackDialogShown") ?? false;
      Rating= prefs.getDouble('Rating') ?? 0.0;
      DateTime date = new DateTime(currDate.year, currDate.month, currDate.day);
      datetoShowFeedbackDialog=prefs.getString("datetoShowFeedbackDialog") ?? date.toString();
      dateShowedFeedbackDialog=prefs.getString("dateShowedFeedbackDialog") ?? '';
      datetoShowRatingDialog=prefs.getString("datetoShowRatingDialog") ?? date.toString();
      dateShowedRatingDialog=prefs.getString("dateShowedRatingDialog") ?? '';
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
// Here you can write your code
      if (mounted)
        setState(() {
          locationThreadUpdatedLocation = locationThreadUpdatedLocation;
        });
    });
    SystemChannels.lifecycle.setMessageHandler((msg) async {});

    setState(() {
      glow = prefs.getBool('glow') ?? true;
      attendanceNotMarkedButEmpAdded =
          prefs.getBool('attendanceNotMarkedButEmpAdded') ?? false;
      print('is tool tip status' + glow.toString());
    });

    empid = prefs.getString('empid') ?? '';
    orgdir = prefs.getString('orgdir') ?? '';
    desinationId = prefs.getString('desinationId') ?? '';
    response = prefs.getInt('response') ?? 0;
    buysts = prefs.getString('buysts') ?? '0';


    getAreaStatus().then((res) {
      // print('called again');
      if (mounted) {
        setState(() {
          areaSts = res.toString();
          if (areaId != 0 && geoFence == 1)
            AbleTomarkAttendance = areaSts;
        });
      }
    }).catchError((onError) {
      print('Exception occured in clling function.......');
      print(onError);
    });
    if (response == 1) {
      // Loc lock = new Loc();

      await syncOfflineData();
      // //print(act);
      ////print("this is-----> "+act);
      ////print("this is main "+location_addr);
      prefs = await SharedPreferences.getInstance();
      var netAvailable = 0;
      netAvailable = await checkNet();
      if (mounted && netAvailable == 1) {
        setState(() {
          Is_Delete = prefs.getInt('Is_Delete') ?? 0;
          newpwd = prefs.getString('newpwd') ?? "";
          userpwd = prefs.getString('usrpwd') ?? "";
          print("New pwd" + newpwd + "  User ped" + userpwd);

          admin_sts = prefs.getString('sstatus').toString() ?? '0';
          print(admin_sts);
          covid_second = prefs.getString('covid_second') ?? '';
          covid_first = prefs.getString('covid_first') ?? '0';
          //glow= prefs.getBool('tool');
          mail_varified = prefs.getString('mail_varified').toString() ?? '0';
          alertdialogcount = globalalertcount;
          print('aid again');
          response = prefs.getInt('response') ?? 0;
          fname = prefs.getString('fname') ?? '';
          lname = prefs.getString('lname') ?? '';
          empid = prefs.getString('empid') ?? '';
          email = prefs.getString('email') ?? '';
          status = prefs.getString('status') ?? '';
          orgid = prefs.getString('orgid') ?? '';
          orgdir = prefs.getString('orgdir') ?? '';
          org_name = prefs.getString('org_name') ?? '';
          desination = prefs.getString('desination') ?? '';
          profile = prefs.getString('profile') ?? '';
          createdDate = prefs.getString('CreatedDate') ?? '';


          if (referralNotificationShown == false && admin_sts == '1') {
            showReferralPopup(context, createdDate);
            referralNotificationShown = true;
          }
          showReferralReminder();
          print("Profile Image" + profile);
          profileimage = new NetworkImage(profile);
          setaddress();
          // _checkLoaded = false;
          // //print("1-"+profile);
          profileimage.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((_, __) {
            if (mounted) {
              setState(() {
                _checkLoaded = false;
              });
            }
          }));
          // //print("2-"+_checkLoaded.toString());
          shiftId = prefs.getString('shiftId') ?? "";
          aid = prefs.getString('aid') ?? "";
          print('aid again' + aid);
          print('act again' + aid);
          ////print("this is set state "+location_addr1);
          act1 = act;
          print(act1);
        });
      }
    }
    appResumedPausedLogic(context);

    if ((admin_sts == '1' || admin_sts == '2') && (istooltiponeshown != true)) {
      //if(istooltiponeshown!=true){
      //Future.delayed(Duration(seconds: 1), () => tooltipone.show(context));
      //Future.delayed(Duration(seconds: 1), () => tooltiptimein.show(context));
      print(istooltiponeshown);
      // istooltiponeshown=true;
      print(istooltiponeshown);
    }
    // glow= prefs.getBool('tool');
    //if(glow!=true){
    //Future.delayed(Duration(seconds: 1), () => tooltiptimein.show(context));
    //}
    deviceverification();

    firebaseCloudMessaging_Listeners();
    Password_sts = prefs.getString('password_sts') ?? '0';
    changepasswordStatus = prefs.getString('admin_password_sts') ?? '0';
    print(changepasswordStatus);
    print(Password_sts);
    print("changepasswordStatus");
    FirstAttendance= prefs.getBool('FirstAttendance')?? false;
    FiveStarRating= prefs.getBool('FiveStarRating')?? false;
    RateusDialogShown = prefs.getBool('RateusDialogShown')?? false;
    FeedbackDialogShown = prefs.getBool("FeedbackDialogShown") ?? false;
    Rating= prefs.getDouble('Rating') ?? 0.0;
    String date = formatter.format(now);
    datetoShowFeedbackDialog=prefs.getString("datetoShowFeedbackDialog") ?? date.toString();
    //datetoShowFeedbackDialog='2020-09-16';

    dateShowedFeedbackDialog=prefs.getString("dateShowedFeedbackDialog") ?? '';
    datetoShowRatingDialog=prefs.getString("datetoShowRatingDialog") ?? date.toString();
    dateShowedRatingDialog=prefs.getString("dateShowedRatingDialog") ?? '';
    //dateShowedFeedbackDialog='2020-09-15';
    print('Over here--------------->>>>>>>>>>>>>>');
    print(FirstAttendance.toString()+'------------>>>>one');
    print(FiveStarRating.toString()+'-------->>>second');
    print((FirstAttendance && !FiveStarRating).toString()+'------->>>third');
    print((FirstAttendance&& RateusDialogShown && !FiveStarRating).toString()+'--------->>>>>fourth');
    print(RateusDialogShown.toString()+'five---------->>>>>>');
    print(datetoShowFeedbackDialog.toString()+'six---------->>>>>>');
    print(dateShowedFeedbackDialog.toString()+'seven---------->>>>>>');
    print(FirstAttendance&& RateusDialogShown && !FiveStarRating && dateShowedFeedbackDialog!=date.toString()+'------->>>>>eight');
    print((datetoShowFeedbackDialog.toString()==date.toString()).toString()+'--------->>>Nine');
    print(date.toString()+'Ten');
    print(datetoShowRatingDialog.toString()+'Eleven<----------');
    print(dateShowedRatingDialog.toString()+'Twelve<----------');
    if(FirstAttendance && !FiveStarRating && !RateusDialogShown && dateShowedRatingDialog!=date.toString()) {
      if(datetoShowRatingDialog.toString()==date.toString()) {
        showRateUsDialog();
      }
    }else if(FirstAttendance&& RateusDialogShown && !FiveStarRating && dateShowedFeedbackDialog!=date.toString()){
      if(datetoShowFeedbackDialog.toString()==date.toString()) {
        showfeedbackDialog();
      }
    }









    ///////////////////////////////////////////////////merging work /////////////////////////////////////////////////////////

    //  print("adsadadadsadadadadsadsadadsadad");
    //_controller1 = new TabController(length: 2, vsync: this);

    var orgId=prefs.get("orgid");
    profile = prefs.getString('profile') ?? '';
    fname = prefs.getString('fname') ?? '';
    lname = prefs.getString('lname') ?? '';
    profileImage = NetworkImage(profile);


    var fullName = fname + lname;

    if((fullName.trim()).contains(" ")) {
      var name=fullName.split(" ");
      print('print(name);');
      print(name);
      First=name[0][0].trim();
      print(First);
      Last=name[1][0].trim().toString().toUpperCase();
      print(Last);
      initials =  First+Last;
      print(initials);
      print("initials ");
    }else{
      First=fullName.substring(0,1);
      print('print(First)else');
      print(First);
      initials =  First;
      print(initials);
    }


    print(profileImage);

    profileImage.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((_, __) {
      if (mounted) {
        setState(() {
          profileLoaded = true;
        });
      }
    }));

    print(profileImage);

    print(profileLoaded);
    print(initials);
    print("initials platformstate");
    String todayDate = DateTime.now().toString().split(".")[0].split(" ")[0];



    final GoogleMapController controller = await _controller.future;

   /* if(admin_sts == '1' || admin_sts == '2') {

      var p=97;
      var ii=0;
      var lastCurrentLocation;
      int markerPoint = 0;
      List TimeInOutLocations = new List();
      final Uint8List TimeInMapIcon = await getBytesFromAsset('assets/TimeInMapIcon.png', 140);
      final Uint8List currentLocationPinMapIcon = await getBytesFromAsset('assets/mapPinPointMarker.png', 140);
      final Uint8List fakeLocation = await getBytesFromAsset('assets/fakeLocation.png', 140);
      int ID = 1;
      setLoader = false;

      getAttendance(todayDate).then((res) async {
        attList = res;

        for(int i = 0; i<attList.length;i++ ) {

          Name.add([attList[i].EmployeeId.toString()]);
          print("names are");
          print(Name);
          NameList.add(("(" + attList[i].EmployeeId.toString() + ") "+attList[i].name.toString()));
          print(NameList);
          print("gvjkgkghkj");

        }


        updates = await FirebaseDatabase.instance.reference().child("Locations").child(orgId).child(attList[0].EmployeeId.toString()).child(todayDate).onChildAdded
            .listen((data) async {

              var currentLoc=  Locations.fromFireBase(data.snapshot);

              if(currentLoc.mock == "true") {  //if user uses mock locations

            ID++;
            var m1=Marker(
              markerId: MarkerId('fakeLocation$ID'),
              position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
              // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
              icon:BitmapDescriptor.fromBytes(fakeLocation),

              infoWindow: InfoWindow(
                  title: "Fake location found: ",
                  snippet: "         "+data.snapshot.key
                // anchor: Offset(0.1, 0.1)
              ),
            );
            Future.delayed(Duration(seconds: 1),() {
              setState(() {
                _markers.add(m1);
                //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
              });
            });
          }

          TimeInOutLocations.add([currentLoc.latitude,currentLoc.longitude,data.snapshot.key]);

          var firstLocation = TimeInOutLocations[0];
          //timeIn location
          if(TimeInOutLocations.length>1){
            lastCurrentLocation = TimeInOutLocations[TimeInOutLocations.length - 1];

            var m1=Marker(
              markerId: MarkerId('sourcePinCurrentLocationIcon'),
              position: LatLng(double.parse(lastCurrentLocation[0]),double.parse(lastCurrentLocation[1])),
              // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
              icon:BitmapDescriptor.fromBytes(currentLocationPinMapIcon),

              infoWindow: InfoWindow(
                title: "Last known location: "+data.snapshot.key,
              ),
            );
            Future.delayed(Duration(seconds: 1),(){
              setState(() {
                _markers.add(m1);
                setLoader = true;
                //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
              });
            });
          }
          var m=Marker(
            markerId: MarkerId('sourcePinTimeInIcon'),
            position: LatLng(double.parse(firstLocation[0]),double.parse(firstLocation[1])),
            // icon: await getMarkerIconForTimeIn("https://cdn0.iconfinder.com/data/icons/map-and-navigation-2-1/48/100-512.png", Size(150.0, 250.0),0),
            icon: BitmapDescriptor.fromBytes(TimeInMapIcon),
            // icon:pinLocationIcon,
            infoWindow: InfoWindow(
              title: "Start Time: "+firstLocation[2],
            ),
          );
          Future.delayed(Duration(seconds: 1),(){
            setState(() {
              _markers.add(m);
              //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
            });
          });




          //  setState(() {
          // create a Polyline instance
          // with an id, an RGB color and the list of LatLng pairs
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 0,
              target: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
              zoom: 13.0,
            ),
          ));

          end= double.parse(currentLoc.odometer);
          print(latlng.toString());

          // if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy)<20.0) ) {
          if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy) < 20.0)) {

            start=end;
            p++;
            //print("shashankmmmmmmmmmm"+(end-start>200.0).toString());
            //add position number marker
            // Future.delayed(Duration(seconds: 2),(){
            markerPoint++;

            getMarkerNew(markerPoint,double.parse(currentLoc.latitude),double.parse(currentLoc.longitude),data.snapshot.key);

            setState(() {

              if(ii==0) {
                startM=double.parse(currentLoc.odometer);
                print("current loc odo"+startM.toString());
              }

              endM=double.parse(currentLoc.odometer);
              print("end loc odo"+startM.toString());

              kms=((endM-startM)/1000).toStringAsFixed(2)+" kms";
              print("sgksshhskhs   "+kms);
              // if(endM-startM<0)
              //  kms='0.0';
            });
            //});

            ii++;
            *//* var m=Marker(
          markerId: MarkerId('sourcePin$p'),
          position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
          //icon: await getMarkerIcon("https://i.dlpng.com/static/png/6865249_preview.png", Size(150.0, 150.0),0),
          icon:BitmapDescriptor.fromBytes(markerIcon),

          infoWindow: InfoWindow(
            title: data.snapshot.key,
          ),
        );
        Future.delayed(Duration(seconds: 1),(){
          setState(() {
            _markers.add(m);
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });*//*
          }

          print(currentLoc.accuracy);
          print("currentLoc.accuracy");



          setState(() {
            // if(double.parse(currentLoc.accuracy)<20.0)           //07oct
            //   {
            latlng.add(LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)));
            //  print(latlng);
            // print("latlong iss");
            _polylines.add(Polyline(
              polylineId: PolylineId('1'),
              visible: true,
              width: 3,
              patterns:  <PatternItem>[PatternItem.dash(20), PatternItem.gap(10)] ,
              //latlng is List<LatLng>
              points: latlng,
              color: Colors.blue,
            ));
            // }
          });

        });

        var date=DateTime.now().toString().split(".")[0].split(" ")[0];
        var visits =  await  getVisitsDataList(date.toString(),attList[0].EmployeeId.toString());
        print("aaa");
        var generatedIcon;
        List<BitmapDescriptor> generatedIcons=new List<BitmapDescriptor>();
        var j=visits.length;
        print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj"+j.toString());
        if(j>0)
          await Future.forEach(visits, (Punch visit) async {

            print("marker added............");
            var m=Marker(
              markerId: MarkerId('sourcePin$j'),
              position: LatLng(double.parse(visit.pi_latit),double.parse(visit.pi_longi)),
              icon: await getMarkerIconNew("https://i.dlpng.com/static/png/6865249_preview.png", Size(140.0, 140.0),j),
              onTap: () {
                setState(() {
                  currentlySelectedPin = PinInformation(pinPath: 'assets/friend1.jpg', avatarPath: visit.pi_img, location: LatLng(0, 0), client: visit.client,description: visit.desc,in_time: visit.pi_time,out_time: visit.po_time, labelColor: Colors.grey);
                  pinPillPosition = 100;
                });
                print(visit.po_time);

              },

              infoWindow: InfoWindow(
                  title: visit.client,
                  snippet:visit.desc
              ),
            );
            Future.delayed(Duration(seconds: 1),(){
              setState(() {
                _markers.add(m);
                //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
              });
            });

            j--;
          });
      });
    }

    Future.delayed(Duration(seconds: 3), () async {

      if(childExist == false){
        _markers1.clear();
        var j=0;
        j++;


        print("inside childExist");
        setLoader = false;

        _markers.clear();
        latlng.clear();
        _polylines.clear();
        print(childExist);
        var p=97;
        var ii=0;
        var lastCurrentLocation;
        int markerPoint = 0;
        List TimeInOutLocations = new List();
        final Uint8List TimeInMapIcon = await getBytesFromAsset('assets/TimeInMapIcon.png', 140);
        final Uint8List currentLocationPinMapIcon = await getBytesFromAsset('assets/mapPinPointMarker.png', 140);
        final Uint8List fakeLocation = await getBytesFromAsset('assets/fakeLocation.png', 140);
        int ID = 1;
        setLoader = false;
        updates = await FirebaseDatabase.instance.reference().child("Locations").child(orgId).child(empid).child(todayDate).onChildAdded
            .listen((data) async {

          var currentLoc=  Locations.fromFireBase(data.snapshot);

          if(currentLoc.mock == "true") {  //if user uses mock locations

            ID++;
            var m1=Marker(
              markerId: MarkerId('userLocation$ID'),
              position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
              // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
              icon:BitmapDescriptor.fromBytes(fakeLocation),

              infoWindow: InfoWindow(
                  title: "Fake location found: ",
                  snippet: "         "+data.snapshot.key
                // anchor: Offset(0.1, 0.1)
              ),
            );
            Future.delayed(Duration(seconds: 1),() {
              setState(() {
                _markers1.add(m1);
                //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
              });
            });
          }

          TimeInOutLocations.add([currentLoc.latitude,currentLoc.longitude,data.snapshot.key]);

          var firstLocation = TimeInOutLocations[0];
          //timeIn location
          if(TimeInOutLocations.length>1){
            lastCurrentLocation = TimeInOutLocations[TimeInOutLocations.length - 1];

            var m1=Marker(
              markerId: MarkerId('sourcePinCurrentLocationIconUserLocation'),
              position: LatLng(double.parse(lastCurrentLocation[0]),double.parse(lastCurrentLocation[1])),
              // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
              icon:BitmapDescriptor.fromBytes(currentLocationPinMapIcon),

              infoWindow: InfoWindow(
                title: "Your last known location: "+data.snapshot.key,
              ),
            );
            Future.delayed(Duration(seconds: 1),(){
              setState(() {
                _markers1.add(m1);
                setLoader = true;
                //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
              });
            });
          }
          var m=Marker(
            markerId: MarkerId('sourcePinTimeInIconUserLocation'),
            position: LatLng(double.parse(firstLocation[0]),double.parse(firstLocation[1])),
            // icon: await getMarkerIconForTimeIn("https://cdn0.iconfinder.com/data/icons/map-and-navigation-2-1/48/100-512.png", Size(150.0, 250.0),0),
            icon: BitmapDescriptor.fromBytes(TimeInMapIcon),
            // icon:pinLocationIcon,
            infoWindow: InfoWindow(
              title: "Your start Time: "+firstLocation[2],
            ),
          );
          Future.delayed(Duration(seconds: 1),(){
            setState(() {
              _markers1.add(m);
              //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
            });
          });




          //  setState(() {
          // create a Polyline instance
          // with an id, an RGB color and the list of LatLng pairs
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 0,
              target: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
              zoom: 13.0,
            ),
          ));

          end= double.parse(currentLoc.odometer);
          print(latlng.toString());

          // if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy)<20.0) ) {
          if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy) < 20.0)) {

            start=end;
            p++;
            //print("shashankmmmmmmmmmm"+(end-start>200.0).toString());
            //add position number marker
            // Future.delayed(Duration(seconds: 2),(){
            markerPoint++;

            getMarkerNew(markerPoint,double.parse(currentLoc.latitude),double.parse(currentLoc.longitude),data.snapshot.key);

            setState(() {

              if(ii==0) {
                startM=double.parse(currentLoc.odometer);
                print("current loc odo"+startM.toString());
              }

              endM=double.parse(currentLoc.odometer);
              print("end loc odo"+startM.toString());

              kms=((endM-startM)/1000).toStringAsFixed(2)+" kms";
              print("sgksshhskhs   "+kms);
              // if(endM-startM<0)
              //  kms='0.0';
            });
            //});

            ii++;
            *//* var m=Marker(
          markerId: MarkerId('sourcePin$p'),
          position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
          //icon: await getMarkerIcon("https://i.dlpng.com/static/png/6865249_preview.png", Size(150.0, 150.0),0),
          icon:BitmapDescriptor.fromBytes(markerIcon),

          infoWindow: InfoWindow(
            title: data.snapshot.key,
          ),
        );
        Future.delayed(Duration(seconds: 1),(){
          setState(() {
            _markers.add(m);
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });*//*
          }

          print(currentLoc.accuracy);
          print("currentLoc.accuracy");



          setState(() {
            // if(double.parse(currentLoc.accuracy)<20.0)           //07oct
            //   {
            latlng.add(LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)));
            //  print(latlng);
            // print("latlong iss");
            _polylines.add(Polyline(
              polylineId: PolylineId(currentLoc.latitude),
              visible: true,
              width: 3,
              patterns:  <PatternItem>[PatternItem.dash(20), PatternItem.gap(10)] ,
              //latlng is List<LatLng>
              points: latlng,
              color: Colors.blue,
            ));
            // }
          });

        });


      *//*  controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 0,
            target: LatLng(double.parse(globals.assign_lat.toString()), double.parse(globals.assign_long.toString())),
            zoom: 13.0,
          ),
        ));

        var m1 = Marker(
            markerId: MarkerId('noChildExist$j'),
            position: LatLng(double.parse(globals.assign_lat.toString()), double.parse(globals.assign_long.toString())),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: "You are here",
              //  snippet:globals.assign_lat.toString()+","+globals.assign_long.toString()
            )

        );

        Future.delayed(Duration(seconds: 1),(){
          setState(() {
            _markers1.add(m1);
          });
        });*//*

      }


    });*/
    setSourceAndDestinationIcons();

  }

  logout() async{
    final prefs = await SharedPreferences.getInstance();
    String countryTopic=prefs.get('CountryName')??'admin';
    String orgTopic=prefs.get('OrgTopic')??'admin';
    String currentOrgStatus=prefs.get('CurrentOrgStatus')??'admin';
    String employeeTopic = prefs.getString("EmployeeTopic") ?? '';
    prefs.remove('response');
    prefs.remove('fname');
    prefs.remove('lname');
    prefs.remove('empid');
    prefs.remove('email');
    prefs.remove('status');
    prefs.remove('sstatus');
    prefs.remove('orgid');
    prefs.remove('orgdir');
    prefs.remove('sstatus');
    prefs.remove('org_name');
    prefs.remove('destination');
    prefs.remove('profile');
    prefs.remove('latit');
    prefs.remove('longi');
    prefs.remove('aid');
    prefs.remove('shiftId');
    prefs.remove('OfflineModePermission');
    prefs.remove('ImageRequired');
    prefs.remove('glow');
    prefs.remove('OrgTopic');
    prefs.remove('CountryName');
    prefs.remove('CurrentOrgStatus');
    prefs.remove('date');
    prefs.remove('firstAttendanceMarked');
    prefs.remove('EmailVerifacitaionReminderShown');
    prefs.remove('companyFreshlyRegistered');
    prefs.remove('fname');
    prefs.remove('empid');
    prefs.remove('orgid');
    prefs.remove('ReferralValidFrom');
    prefs.remove('glow');
    prefs.remove('ReferralValidTo');
    prefs.remove('referrerAmt');
    prefs.remove('referrenceAmt');
    prefs.remove('referrerId');
    prefs.remove('TimeInTime');
    prefs.remove('showAppInbuiltCamera');
    prefs.remove('ShiftAdded');
    prefs.remove('EmployeeAdded');
    prefs.remove('attendanceNotMarkedButEmpAdded');
    prefs.remove('tool');
    prefs.remove('companyFreshlyRegistered');
    prefs.remove('showAppInbuiltCamera');
    prefs.remove('showPhoneCamera');

    _firebaseMessaging.unsubscribeFromTopic(employeeTopic.replaceAll(' ', ''));
    _firebaseMessaging.unsubscribeFromTopic("admin");
    _firebaseMessaging.unsubscribeFromTopic("employee");
    _firebaseMessaging.unsubscribeFromTopic(countryTopic.replaceAll(' ', ''));
    _firebaseMessaging.unsubscribeFromTopic(orgTopic.replaceAll(' ', ''));
    _firebaseMessaging.unsubscribeFromTopic(currentOrgStatus.replaceAll(' ', ''));




    //prefs.remove("TimeInToolTipShown");
    department_permission = 0;
    designation_permission = 0;
    leave_permission = 0;
    shift_permission = 0;
    timeoff_permission = 0;
    punchlocation_permission = 0;
    employee_permission = 0;
    permission_module_permission = 0;
    report_permission = 0;
    /* Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );*/
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false,
    );
    //Navigator.pushNamed(context, '/home');
    // Navigator.pushNamed(context, '/home');
  }


  void deviceverification() async{

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.brand}');
    print('Running on ${androidInfo.model}');
    String devicename= androidInfo.model;
    String devicebrand= androidInfo.brand;
    devicenamebrand = devicebrand+' '+devicename;


   print("DEVICENAME->"+devicename);
   print("DEVICEBRAND->"+devicebrand);
   print("ANDROIDID->"+androidInfo.androidId);

    var prefs = await SharedPreferences.getInstance();
    //deviceid= prefs.getString("deviceid") ?? '';
    print('thisisdeviceid'+deviceid);
    String deviceidmobile=prefs.getString("deviceid")??"";
    bool deviceVerifyPopupShown=prefs.getBool("deviceVerifyPopupShown")??false;
    print('thisisdeviceidmobile'+deviceidmobile);
    if(deviceidmobile=='' && globals.deviceverification==1){
      const chars = "abcdefghijklmnopqrstuvwxyz0123456789";

      String RandomString(int strlen) {
        Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
        String result = "";
        for (var i = 0; i < strlen; i++) {
          result += chars[rnd.nextInt(chars.length)];
        }
        return result;
      }


      print("RandomString:"+RandomString(60));
      //deviceidmobile= RandomString(60);
      deviceidmobile= androidInfo.androidId;
      prefs.setString("deviceid",deviceidmobile);

    }

    print("DEVICE VERIFY POPUP SHOWN"+deviceVerifyPopupShown.toString());
    print("DEVICE ID FROM DATABASE"+deviceid);
    print("EMPLOYEE DEVICE VERIFICATION STATUS"+globals.deviceverification.toString());
    print((globals.deviceandroidid!=deviceidmobile) || (deviceid=='' && deviceVerifyPopupShown==true));
    print((globals.deviceandroidid!=deviceidmobile));
    print((deviceid=='' && deviceVerifyPopupShown==true));
    print(globals.deviceid);
    print(deviceidmobile);
    if((deviceid=='' && deviceVerifyPopupShown==false) && globals.deviceverification==1){

      const chars = "abcdefghijklmnopqrstuvwxyz0123456789";

      String RandomString(int strlen) {
        Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
        String result = "";
        for (var i = 0; i < strlen; i++) {
          result += chars[rnd.nextInt(chars.length)];
        }
        return result;
      }


      print("RandomString:"+RandomString(60));
      //deviceidmobile= RandomString(60);
      deviceidmobile= androidInfo.androidId;

      if(deviceVerifyPopupShown==false && deviceid=='') {
        // if(deviceid=='') {
        //
        EasyDialog(
            title: Text(
              'This Mobile Device has been registered as your Device ID',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            description: Text(
              devicebrand+" "+devicename,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            height: 180,
            contentList: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),

                  SizedBox(
                    width: 10,
                    height: 10,
                  ),
                ],
              )
            ]).show(context);

        prefs.setBool("deviceVerifyPopupShown",true);
        prefs.setString("deviceid",deviceidmobile);
        storeDeviceInfo(empid, deviceidmobile, devicebrand+' '+devicename);
      }
    }
    else if(((globals.deviceid!=deviceidmobile) || (deviceid=='' && deviceVerifyPopupShown==true)) && globals.deviceverification==1)
    {
      prefs.setBool("deviceVerifyPopupShown",false);
      EasyDialog(
          closeButton: false,
          title: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 17,
              ),
              children: [
                WidgetSpan(
                  child: Icon(Icons.info_outline),
                ),
                TextSpan(
                  text: 'Alert',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
          description: Text(
            "Your registered device has been disapproved. Please login again to register new device.",
            textScaleFactor: 1.1,
            textAlign: TextAlign.center,
          ),

          height: 180,
          contentList: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new FlatButton(
                  padding: const EdgeInsets.only(top: 8.0),
                  textColor: Colors.lightBlue,
                  onPressed: () {
                    logout();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: new Text(
                    "OK",
                    textScaleFactor: 1.2,
                  ),
                ),
              ],
            )
          ]).show(context);
    }
  }

  showRateUsDialog()async{
    var prefs= await SharedPreferences.getInstance();
    String date = formatter.format(now);
    var twoDaysFromNow = currDate.add(new Duration(days: 2));
    String date1 = formatter.format(twoDaysFromNow);
    dateShowedRatingDialog = date.toString();
    datetoShowRatingDialog = date1.toString();
    prefs.setString('dateShowedRatingDialog', dateShowedRatingDialog);
    prefs.setString('datetoShowRatingDialog', datetoShowRatingDialog);
    prefs.remove("FirstAttendance");
    //prefs.setBool('RateusDialogShown', true);
    return showDialog(context: context, builder:(context) {

      return new AlertDialog(



          title: new Text(
            "Rate your Experience",textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.0),),
          content: RatingBar(
            initialRating: Rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) async{
              print(rating);
              prefs.setBool('RateusDialogShown', true);
              if(rating>3.0){
                print("you are good");
                prefs.setBool("FiveStarRating", true);
                setState(() {
                  Rating=rating;
                  prefs.setDouble('Rating',Rating);
                });
                print(Rating);
                Navigator.pop(context);
                storeRating(empid,orgid,Rating,'');
                await showDialog(
                    context: context,
                    // ignore: deprecated_member_use
                    child: new AlertDialog(
                      //title: new Text("Warning!"),
                      content: Container(
                        height: MediaQuery.of(context).size.height*0.11,
                        child: Column(
                            children: <Widget>[
                              new Text(
                                  "Rate us on Play Store"),
                              Padding(
                                padding: const EdgeInsets.only(top:5.0),
                                child: RaisedButton(elevation: 2.0,
                                  highlightElevation: 5.0,
                                  highlightColor: Colors.transparent,
                                  disabledElevation: 0.0,
                                  focusColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  color: buttoncolor,
                                  child: Text('Go',style: TextStyle(color: Colors.white),),
                                  onPressed: (){

                                    globals.facebookChannel.invokeMethod("logRateEvent");
                                    LaunchReview.launch(
                                        androidAppId: "org.ubitech.sales"
                                    );
                                  },
                                ),
                              )
                            ]),
                      ),
                    ));

              }else{
                print("you are bad");
                setState(() {
                  Rating=rating;
                  prefs.setDouble('Rating',Rating);
                  prefs.remove("FirstAttendance");
                });
                print(Rating);
                Navigator.pop(context);
                Future.delayed(Duration(seconds: 2), () => showfeedbackDialog());
                //showfeedbackDialog();

              }
            },
          )
      );
    }
    );
  }


  showfeedbackDialog()async {
    var prefs= await SharedPreferences.getInstance();
    String date = formatter.format(now);
    var twoDaysFromNow = currDate.add(new Duration(days: 2));
    String date1 = formatter.format(twoDaysFromNow);
    dateShowedFeedbackDialog = date.toString();
    datetoShowFeedbackDialog = date1.toString();
    prefs.setString('dateShowedFeedbackDialog', dateShowedFeedbackDialog);
    prefs.setString('datetoShowFeedbackDialog', datetoShowFeedbackDialog);
    final FocusNode myFocusNodeFeedback = FocusNode();
    TextEditingController feedbackController = new TextEditingController();
    return showDialog(context: context, builder:(context) {

      return new AlertDialog(
        title: new Text(
          'Help us resolve your Query',textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15.0),),
        content: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          child: new Container(

            decoration: new BoxDecoration(
                color: globals.buttoncolor.withOpacity(0.1),
                borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(0.0),
                    topRight: const Radius.circular(0.0))),


            alignment: Alignment.topCenter,
            child: Wrap(
                children: <Widget>[
                  RatingBar(
                    initialRating: Rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) async{
                      print(rating);
//                      String date = formatter.format(now);
//                      var twoDaysFromNow = currDate.add(new Duration(days: 2));
//                      String date1 = formatter.format(twoDaysFromNow);
//                      dateShowedFeedbackDialog = date.toString();
//                      datetoShowFeedbackDialog = date1.toString();
//                      prefs.setString('dateShowedFeedbackDialog', dateShowedFeedbackDialog);
//                      prefs.setString('datetoShowFeedbackDialog', datetoShowFeedbackDialog);
                      if(rating>3.0){
                        print("you are good");
                        prefs.setBool("FiveStarRating", true);
                        setState(() {
                          Rating=rating;
                          prefs.setDouble('Rating',Rating);
                        });
                        print(Rating);
                        storeRating(empid,orgid,Rating,feedbackController.text);

                        /*
                        Navigator.pop(context);
                        await showDialog(
                            context: context,
                            // ignore: deprecated_member_use
                            child: new AlertDialog(
                              //title: new Text("Warning!"),
                              content: new Text(
                                  "Thanks for Rating Us"),
                            ));

                         */
                      }else{
                        print("you are bad");
                        setState(() {
                          Rating=rating;
                          prefs.setDouble('Rating',Rating);
                          prefs.remove("FirstAttendance");
                        });
                        print(Rating);
                        //Navigator.pop(context);
                        // Future.delayed(Duration(seconds: 3), () => showfeedbackDialog());
                        //showfeedbackDialog();

                      }
                    },
                  ),
                  Container(
                    child: Wrap(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                        child: TextFormField(
                          focusNode: myFocusNodeFeedback,
                          controller: feedbackController,
                          keyboardType: TextInputType.emailAddress,
                          onFieldSubmitted: (String value) {
                            FocusScope.of(context).requestFocus(myFocusNodeFeedback);
                          },
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              height: 1.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            fillColor: Colors.white, filled: true,
                            hintText: "Write here",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 15.0 ),
                          ),

                          maxLines: 3,
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, bottom: 0.0, left: 75.0, right: 7.0),
                          child:  ButtonTheme(
                            minWidth: 50.0,
                            child: new RaisedButton(
                              child: new Text('Submit',style: TextStyle(color: Colors.white),),
                              elevation: 2.0,
                              highlightElevation: 5.0,
                              highlightColor: Colors.transparent,
                              disabledElevation: 0.0,
                              focusColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),

                              color: buttoncolor,

                              onPressed: () async  {
                                print(feedbackController.text);
                                storeRating(empid,orgid,Rating,feedbackController.text);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomePage()),
                                );
                                /*
                                showDialog(
                                    context: context,
                                    // ignore: deprecated_member_use
                                    child: new AlertDialog(
                                      content: new Text("Thanks for Rating us!"),
                                    ));

                                 */
                                if(Rating>3.0){
                                  await showDialog(
                                      context: context,
                                      // ignore: deprecated_member_use
                                      child: new AlertDialog(
                                        //title: new Text("Warning!"),
                                        content: Container(
                                          height: MediaQuery.of(context).size.height*0.11,
                                          child: Column(
                                              children: <Widget>[
                                                new Text(
                                                    "Rate us on Play Store"),
                                                Padding(
                                                  padding: const EdgeInsets.only(top:5.0),
                                                  child: RaisedButton(elevation: 2.0,
                                                    highlightElevation: 5.0,
                                                    highlightColor: Colors.transparent,
                                                    disabledElevation: 0.0,
                                                    focusColor: Colors.transparent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    color: buttoncolor,
                                                    child: Text('Go',style: TextStyle(color: Colors.white),),
                                                    onPressed: (){

                                                      globals.facebookChannel.invokeMethod("logRateEvent");
                                                      LaunchReview.launch(
                                                          androidAppId: "org.ubitech.sales"
                                                      );
                                                    },
                                                  ),
                                                )
                                              ]),
                                        ),
                                      ));}



                              },),
                            //borderSide: BorderSide(color: Colors.green[700],),

                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0),),

                          )


                      )

                    ],),
                  )
                  ,
                ]),
          ),
        ),

      );
    }
    );
  }


  timerResumePause() async {
    //print("app resumed paused home");
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      print("app resumed paused home");
      if (msg == 'AppLifecycleState.resumed') {
        //startWorkingHoursTimer();
        print("app resumed and timer started");
      }

      if (msg == 'AppLifecycleState.paused') {
        //stopWorkingHoursTimer();
        print("app paused and timer stopped");
      }
    });
  }

  void dialogwidget(BuildContext context) async{
    print("Sohan patel");
    showDialog(
        context: context,
        barrierDismissible: false,
        // ignore: deprecated_member_use
        child: new AlertDialog(
          content: new Text('Your Time Out was not punched Yesterday. Kindly contact Admin to regularize Attendance'),
          actions: <Widget>[

          ],

        ));
    Home ho = new Home();
    await ho.updateTimeOut(empid, orgdir);
  }

  showReferralPopup(BuildContext context, String cDateS) async {


    if(globals.currentOrgStatus=="TrialOrg"){

      showTrialReferralPopup(context,cDateS);

    }

    else
    if(globals.currentOrgStatus=="PremiumCustomizedOrg")
    {
      int dateToSend = 0;


      var prefs = await SharedPreferences.getInstance();
      var buyStatus = int.parse(prefs.get("buysts") ?? "123455");
      var createdDate = DateTime.parse("2019-12-26");

      //print(">>>>----- current org status"+globals.currentOrgStatus);


      var startDate =
      DateTime.parse(prefs.get("ReferralValidFrom") ?? "2019-12-26");
      var endDate = DateTime.parse(prefs.get("ReferralValidTo") ?? "2019-12-26");

/*
        var startDate =
        DateTime.parse( "2020-02-22");
        var endDate = DateTime.parse("2020-02-29");
*/


      var currDate = DateTime.now();
      dateShowed = prefs.getString('date') ?? "2010-10-10";

      var referralValidForDays=endDate.difference(currDate).inDays;


      print("datetime.parse" + dateShowed);
      // print("hello"+dateShowed);
      var referrerAmt = prefs.getString("ReferrerDiscount") ?? "1%";
      var referrenceAmt = prefs.getString("ReferrenceDiscount") ?? "1%";
      ReferrerNotificationList[0] = {
        "title": "Win Win Deal",
        "description":
        "Refer our App and get ${referrerAmt} off on your next payment. Hurry! Offer ends in ${referralValidForDays} days"
      };
      ReferrerNotificationList[1] = {
        "title": "Refer and Earn",
        "description":
        "Invite your friends to try ubiSales. Get ${referrerAmt} Off when they pay.. Hurry! Offer ends in ${referralValidForDays} days"
      };
      ReferrerNotificationList[2] = {
        "title": "Discounts that count",
        "description":
        "For every organization you refer which pays up for our Premium plan, we will give you both ${referrerAmt}/ ${referrenceAmt} off. Hurry! Offer ends in ${referralValidForDays} days"
      };
      ReferrerNotificationList[3] = {
        "title": "${referrerAmt} Off every Payment",
        "description":
        "Tell Your friends about ubiSales & get ${referrerAmt} Discount when he pays. Hurry! Offer ends in ${referralValidForDays} days"
      };
      ReferrerNotificationList[4] = {
        "title": "Discounts to smile about",
        "description":
        "Give managers the gift of ease in recording attendance and get ${referrerAmt} off on your next purchase. Hurry! Offer ends in ${referralValidForDays} days"
      };

      var referrerName = "";
      var validity = prefs.getString("ReferralValidity");

      var rng = new Random();
      var referrerRandom = rng.nextInt(4);
      double height = 220;
      if (referrerRandom == 2 || referrerRandom == 4) height = 260;
      if (referrerRandom == 0) height = 170;

      print("----> currdate" + currDate.toString());

      if (createdDate == '') {
        dateToSend = 12;
      }
      // if(buyStatus!=0){  // for trial popup that should show on the seventh day of purchase

      //print("difference dates"+currDate.difference(cDate).inDays.toString());
      //print("created date"+createdDate);

      // } // for other organizations i.e pop up for every created date day of the month
      // else{
      dateToSend = createdDate.day;
      print('startDate');
      print(startDate);
//      print(currDate);
//      print(prefs.getString('date'));
      //print("----> currdate"+((DateTime.parse(dateShowed).day==startDate.day)&&(DateTime.parse(dateShowed).month==startDate.month)&&(DateTime.parse(dateShowed).year==startDate.year)).toString());
      if (//currDate.isAfter(startDate) && currDate.isBefore(endDate) ||
      (currDate.day == startDate.day &&
          currDate.month == startDate.month &&
          currDate.year == startDate.year) ||
          (currDate.day == endDate.subtract(new Duration(days: 2)).day &&
              currDate.month == endDate.month &&
              currDate.year == endDate.year)) {

        print("inside referral check");
        //        prefs.setString('date',currDate.toString());
        // var newDate = new DateTime(startDate.year, startDate.month, startDate.day+3);
        //if (currDate.isAfter(newDate) && currDate.isBefore(endDate)) {
//        prefs.setString('date', newDate.toString());
//        print("hello");
//        print(prefs.getString('date'));
        print(currDate);
        //if(((DateTime.parse(dateShowed).day==currDate.day)&&(DateTime.parse(dateShowed).month==currDate.month)&&(DateTime.parse(dateShowed).year==currDate.year))){
        //var newDate = new DateTime(currDate.year, currDate.month, currDate.day+3);
        //var newDate = currDate.add(new Duration(days: 3));
        dateShowed = currDate.toString();
        prefs.setString('date', dateShowed);
        print("hello" + currDate.toString());
        EasyDialog(
            title: Text(
              ReferrerNotificationList[referrerRandom]['title'].toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            ),
            description: Text(
              ReferrerNotificationList[referrerRandom]['description']
                  .toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            height: height,
            contentList: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  RaisedButton(
                    child: Text(
                      "GO!",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      generateAndShareReferralLink();
                    },
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 10,
                    height: 10,
                  ),
                ],
              )
            ]).show(context);
      }
    }
    else{
      // showOtherReferralPopup(context,cDateS);
    }
    // }
  }


  void showTrialReferralPopup(BuildContext context, String cDateS) async {
    int dateToSend = 0;
    var prefs = await SharedPreferences.getInstance();

    var createdDate = DateTime.parse(cDateS);

    //print(">>>>----- current org status"+globals.currentOrgStatus);

    var currDate = DateTime.now();
    dateShowed = prefs.getString('TrailReferralShownDate') ?? "2010-10-10";

    print("datetime.parse" + dateShowed);
    // print("hello"+dateShowed);
    var referrerAmt = prefs.getString("ReferrerDiscount") ?? "1%";
    var referrenceAmt = prefs.getString("ReferrenceDiscount") ?? "1%";
    ReferrerNotificationList[0] = {
      "title": "Win Win Deal",
      "description":
      "Refer our App and get ${referrerAmt} off on your next payment. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[1] = {
      "title": "Refer and Earn",
      "description":
      "Invite your friends to try ubiSales. Get ${referrerAmt} Off when they pay. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[2] = {
      "title": "Discounts that count",
      "description":
      "For every organization you refer which pays up for our Premium plan, we will give you both ${referrerAmt}/ ${referrenceAmt} off. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[3] = {
      "title": "${referrerAmt} Off every Payment",
      "description":
      "Tell Your friends about ubiSales & get ${referrerAmt} Discount when he pays. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[4] = {
      "title": "Discounts to smile about",
      "description":
      "Give managers the gift of ease in recording attendanceand get ${referrerAmt} off on your next purchase. Hurry! Offer ends in 10 days"
    };

    var referrerName = "";
    var validity = prefs.getString("ReferralValidity");

    var rng = new Random();
    var referrerRandom = rng.nextInt(4);
    double height = 220;
    if (referrerRandom == 2 || referrerRandom == 4) height = 260;
    if (referrerRandom == 0) height = 170;

    print("----> currdate" + currDate.toString());

    if (createdDate == '') {
      dateToSend = 12;
    }
    // if(buyStatus!=0){  // for trial popup that should show on the seventh day of purchase

    //print("difference dates"+currDate.difference(cDate).inDays.toString());
    //print("created date"+createdDate);

    // } // for other organizations i.e pop up for every created date day of the month
    // else{
    dateToSend = createdDate.day;
    print('startDate');

//      print(currDate);
//      print(prefs.getString('date'));
    //print("----> currdate"+((DateTime.parse(dateShowed).day==startDate.day)&&(DateTime.parse(dateShowed).month==startDate.month)&&(DateTime.parse(dateShowed).year==startDate.year)).toString());
    if (currDate.day!=DateTime.parse(dateShowed).day&&
        (currDate.day == (createdDate.add(Duration(days: 7)).day) &&
            currDate.month == createdDate.month &&
            currDate.year == createdDate.year) ) {
      print(">>>--- inside trial popup condition check");
      var nextValidity=new DateTime(currDate.year, currDate.month, currDate.add(Duration(days: 10)).day);
      //        prefs.setString('date',currDate.toString());
      // var newDate = new DateTime(startDate.year, startDate.month, startDate.day+3);
      //if (currDate.isAfter(newDate) && currDate.isBefore(endDate)) {
//        prefs.setString('date', newDate.toString());
//        print("hello");
//        print(prefs.getString('date'));

      //if(((DateTime.parse(dateShowed).day==currDate.day)&&(DateTime.parse(dateShowed).month==currDate.month)&&(DateTime.parse(dateShowed).year==currDate.year))){
      //var newDate = new DateTime(currDate.year, currDate.month, currDate.day+3);

      dateShowed = currDate.toString();
      prefs.setString('TrailReferralShownDate', dateShowed);
      prefs.setString("ReferralValidFrom", cDateS);
      prefs.setString("ReferralValidTo", intl.DateFormat("yyyy-MM-dd").format(nextValidity));

      print("hello" + currDate.toString());

      EasyDialog(
          title: Text(
            ReferrerNotificationList[referrerRandom]['title'].toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
          description: Text(
            ReferrerNotificationList[referrerRandom]['description']
                .toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          height: height,
          contentList: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                RaisedButton(
                  child: Text(
                    "GO!",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    generateAndShareReferralLink();
                  },
                  color: Colors.green,
                ),
                SizedBox(
                  width: 10,
                  height: 10,
                ),
              ],
            )
          ]).show(context);
    }

  }

  void showOtherReferralPopup(BuildContext context, String cDateS) async{
    int dateToSend = 0;
    var prefs = await SharedPreferences.getInstance();

    var createdDate = DateTime.parse(cDateS);

    //print(">>>>----- current org status"+globals.currentOrgStatus);




    var currDate = DateTime.now();
    dateShowed = prefs.getString('TrailReferralShownDate') ?? "2010-10-10";

    print("datetime.parse" + dateShowed);
    // print("hello"+dateShowed);
    var referrerAmt = prefs.getString("ReferrerDiscount") ?? "1%";
    var referrenceAmt = prefs.getString("ReferrenceDiscount") ?? "1%";
    ReferrerNotificationList[0] = {
      "title": "Win Win Deal",
      "description":
      "Refer our App and get ${referrerAmt} off on your next payment. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[1] = {
      "title": "Refer and Earn",
      "description":
      "Invite your friends to try ubiSales. Get ${referrerAmt} Off when they pay. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[2] = {
      "title": "Discounts that count",
      "description":
      "For every organization you refer which pays up for our Premium plan, we will give you both ${referrerAmt}/ ${referrenceAmt} off. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[3] = {
      "title": "${referrerAmt} Off every Payment",
      "description":
      "Tell Your friends about ubiSales & get ${referrerAmt} Discount when he pays. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[4] = {
      "title": "Discounts to smile about",
      "description":
      "Give managers the gift of ease in recording attendanceand get ${referrerAmt} off on your next purchase. Hurry! Offer ends in 10 days"
    };

    var referrerName = "";
    var validity = prefs.getString("ReferralValidity");

    var rng = new Random();
    var referrerRandom = rng.nextInt(4);
    double height = 220;
    if (referrerRandom == 2 || referrerRandom == 4) height = 260;
    if (referrerRandom == 0) height = 170;

    print("----> currdate" + currDate.toString());

    if (createdDate == '') {
      dateToSend = 12;
    }
    // if(buyStatus!=0){  // for trial popup that should show on the seventh day of purchase

    //print("difference dates"+currDate.difference(cDate).inDays.toString());
    //print("created date"+createdDate);

    // } // for other organizations i.e pop up for every created date day of the month
    // else{
    dateToSend = createdDate.day;
    print('startDate');

//      print(currDate);
//      print(prefs.getString('date'));
    //print("----> currdate"+((DateTime.parse(dateShowed).day==startDate.day)&&(DateTime.parse(dateShowed).month==startDate.month)&&(DateTime.parse(dateShowed).year==startDate.year)).toString());
    if (currDate.day!=DateTime.parse(dateShowed).day&&
        (currDate.day == (createdDate.day) ) ) {
      print("inside refer");

      var nextValidity=new DateTime(currDate.year, currDate.month, currDate.add(Duration(days: 10)).day);
      //        prefs.setString('date',currDate.toString());
      // var newDate = new DateTime(startDate.year, startDate.month, startDate.day+3);
      //if (currDate.isAfter(newDate) && currDate.isBefore(endDate)) {
//        prefs.setString('date', newDate.toString());
//        print("hello");
//        print(prefs.getString('date'));

      //if(((DateTime.parse(dateShowed).day==currDate.day)&&(DateTime.parse(dateShowed).month==currDate.month)&&(DateTime.parse(dateShowed).year==currDate.year))){
      //var newDate = new DateTime(currDate.year, currDate.month, currDate.day+3);

      dateShowed = currDate.toString();
      prefs.setString('TrailReferralShownDate', dateShowed);
      prefs.setString("ReferralValidFrom", intl.DateFormat("yyyy-MM-dd").format(currDate));
      prefs.setString("ReferralValidTo", intl.DateFormat("yyyy-MM-dd").format(nextValidity));

      print("hello" + currDate.toString());

      EasyDialog(
          title: Text(
            ReferrerNotificationList[referrerRandom]['title'].toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
          description: Text(
            ReferrerNotificationList[referrerRandom]['description']
                .toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          height: height,
          contentList: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                RaisedButton(
                  child: Text(
                    "GO!",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    generateAndShareReferralLink();
                  },
                  color: Colors.green,
                ),
                SizedBox(
                  width: 10,
                  height: 10,
                ),
              ],
            )
          ]).show(context);
    }


  }

  void showReferralReminder() async{

    var prefs=await SharedPreferences.getInstance();

    String referrerId=prefs.getString("referrerId")??"0";

    String ReferralValidTo=prefs.getString("ReferralValidTo")??"0000-00-00";
    var currDate=DateTime.now();

    if(referrerId!='0'&&ReferralValidTo!='0000-00-00'){
      if(DateTime.parse("ReferralValidTo").day==(currDate.day+2))
      {
        EasyDialog(
            title: Text(
              "Reminder",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            ),
            description: Text(
              "Get 10% off your first purchase of ubiSales. Hurry! Offer ends in 2 days"
                  .toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            height: 220,
            contentList: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  RaisedButton(
                    child: Text(
                      "GO!",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      navigateToPaymentsPage();
                    },
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 10,
                    height: 10,
                  ),
                ],
              )
            ]).show(context);
      }
    }
  }

  setaddress() async {
    globalstreamlocationaddr = await getAddressFromLati(globals.assign_lat.toString(), globals.assign_long.toString());

    var serverConnected = await checkConnectionToServer();
    if (serverConnected != 0) if (globals.assign_lat == 0.0 ||
        globals.assign_lat == null ||
        !locationThreadUpdatedLocation) {
      cameraChannel.invokeMethod("openLocationDialog");

    }
    print("addon enabled"+(persistedface=='0'&& facerecognition.toString()=='1').toString());
    if(persistedface.toString()=='0'&& facerecognition.toString()=='1'){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => FaceIdScreen()), (Route<dynamic> route) => false,);
    }
  }


  void _add(lat, long, image1, name) async {

    //  var address= await getAddressFromLati(lat.toString(),long.toString());

    print("inside _add tab");
    var count = 0;
    _markers.clear();

    print(lat);
    print(long);
    print(image1);
    print("image iss");

    var Name = name;


    //  getAcronym(var name) {

    if((Name.trim()).contains(" ")) {
      var name=Name.split(" ");
      print('print(name);');
      print(name);
      First=name[0][0].trim();
      print(First);
      Last=name[1][0].trim().toString().toUpperCase();
      print(Last);
      initials =  First+Last;
      print(initials);
      print("initials ");
    }else{
      First=Name.toString().substring(0,1);
      print('print(First)else');
      print(First);
      initials =  First;
      print(initials);

    }

    StoreLocation.forEach((k, v) {

      double LAT1 = lat;
      double LONG1 = long;
      double LAT2 = double.parse(v[0]);
      double LONG2 = double.parse(v[1]);


      double distance = 2 * 6371000 * Math.asin(Math.sqrt(Math.pow((Math.sin((LAT2 * (3.14159 / 180) - LAT1 * (3.14159 / 180)) / 2)), 2) + Math.cos(LAT2 * (3.14159 / 180)) * Math.cos(LAT1 * (3.14159 / 180)) * Math.sin(Math.pow(((LONG2 * (3.14159 / 180) - LONG1 * (3.14159 / 180)) / 2), 2))));
      print(distance);
      print("distance is");
      if(distance<10) {
        //if they are less then at a distance of 10 meters
        count++;
        print(count);
        print("count is");
      }

      // }
    });
    _checkLoaded1 = false;
    var image = NetworkImage(image1);

    var image2 = image1;
    image.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((_, __) {
      _checkLoaded1 = true;
    }));

    print(_checkLoaded1);
    print("checkloaded");

    final int markerCount = markers.length;

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(lat	,long),
        zoom: 13.0,
      ),
    ));

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    print(_markerIdCounter);
    print("_markerIdCounter");

    int j =0;
    var m = Marker(
      markerId: MarkerId('searchMarkerId'),
      position: LatLng(lat,long),
      icon: _checkLoaded1 == true ? await getMarkerProfile(image2, count ,lat, long) : await getMarker(initials,lat, long ,count),

      onTap: () {

        // var moving=currentLoc.is_moving=="false"?"Still":"Moving";

        setState(() {

          //   currentlySelectedPin = PinInformation(pinPath: 'assets/friend1.jpg', avatarPath: "https://ubitech.ubihrm.com/public/uploads/"+orgId+"/"+employeeMap["info"][0]['ImageName'], location: LatLng(0, 0), client: employeeMap["info"][0]['FirstName']+" "+employeeMap["info"][0]['LastName'],description: 'At: '+address,in_time: currentLoc.time.toString()+" ("+moving+")",out_time: '-', labelColor: Colors.grey);
          //    pinPillPosition = 50;

        });
      },

      infoWindow: InfoWindow(
          title:"Current known location at:",
          snippet:address.toString()
      ),
    );

    setState(() {
      _markers.add(m);
      j++;
      //markers[markerId] = marker;
    });
  }




  void _onMarkerTapped(MarkerId markerId) {
    print("YAHOOOOOOOOOOOOOOOOOOOOOOOOOOOO");

    final Marker tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        if (markers.containsKey(selectedMarker)) {
          print("YAHOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
        }
      });
    }
  }

  Future<BitmapDescriptor> getMarkerIcon(String imagePath, Size size,int number,count1) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 2);

    final Paint tagPaint = Paint()..color = Colors.blue;
    final double tagWidth = 40.0;

    final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
    final double shadowWidth = 15.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 3.0;

    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              0.0,
              0.0,
              size.width,
              size.height
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              shadowWidth,
              shadowWidth,
              size.width - (shadowWidth * 2),
              size.height - (shadowWidth * 2)
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    // Add tag circle

    if(count1!=1) {

      canvas.drawRRect(
          RRect.fromRectAndCorners(

            Rect.fromLTWH(
                size.width - tagWidth,
                0.0,
                tagWidth,
                tagWidth
            ),
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: radius,
          ),
          tagPaint);

      // Add tag text
      TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: "+" + count1.toString(),
        style: TextStyle(fontSize: 20.0, color: Colors.white),
      );

      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(
              size.width - tagWidth / 2 - textPainter.width / 2,
              tagWidth / 2 - textPainter.height / 2
          )
      );
    }

    // Oval for the image
    Rect oval = Rect.fromLTWH(
        imageOffset,
        imageOffset,
        size.width - (imageOffset * 2),
        size.height - (imageOffset * 2)
    );

    // Add path for oval image
    canvas.clipPath(Path()
      ..addOval(oval));

    // Add image
    ui.Image image = await getImageFromNetwork(imagePath); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);

    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt()
    );

    // Convert image to bytes
    final ByteData byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }


  Future<ui.Image> getUiImage(String imageAssetPath, int height, int width) async {

    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    image.Image baseSizeImage = image.decodeImage(assetImageByteData.buffer.asUint8List());
    image.Image resizeImage = image.copyResize(baseSizeImage, height: height, width: width);
    ui.Codec codec = await ui.instantiateImageCodec(image.encodePng(resizeImage));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;

  }

  Future<ui.Image> getImageFromNetwork(String path) async {

    Completer<ImageInfo> completer = Completer();;
    var img = new NetworkImage(path);
    img.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info,bool _){
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;

  }



  Future<ui.Image> getImageFromPath(String imagePath) async {
    File imageFile = File(imagePath);

    Uint8List imageBytes = imageFile.readAsBytesSync();

    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/destination_map_marker.png');
  }
  //var formatter = new intl.DateFormat('dd-MMM-yyyy');

  void _handleSearchStart() {
    setState(() {
      _IsSearching = true;
    });
  }

  // Copy Main List into New List.
  List<dynamic> newDataList = List.from(Name);

  onItemChanged(String value) {

    //   newDataList1.clear();
    // searchedName.clear();

    setState(() {

      newDataList = NameList.where((string) => string.toLowerCase().contains(value.toLowerCase())).toList();
      print(newDataList);
      print("matched names list");

    });

  }

  @override
  Widget build(BuildContext context) {

    print(response);
    print(userpwd);
    print(newpwd);
    print(Is_Delete);
    print("after build context");

    return ( response == 0 ||
        userpwd != newpwd ||
        Is_Delete != 0 ||
        orgid == '10932')
        ? new AskRegisterationPage()
        : getmainhomewidget();
  }

  getmainhomewidget(){

    return WillPopScope(
      onWillPop: () async => true,
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(_orgName, style: new TextStyle(fontSize: 20.0)),

              /*  Image.asset(
                      'assets/logo.png', height: 40.0, width: 40.0),*/
            ],
          ),

          backgroundColor: appcolor,
          automaticallyImplyLeading: false,

        ),
        // bottomNavigationBar: Bottomnavigationbar(),
        endDrawer: new AppDrawer(),
        body: (act1 == '') ? Center(child: loader()) : checkalreadylogin(),


        floatingActionButton:  FabCircularMenu(
          key: fabKey1,
          // alignment: Alignment(2.58, 3.25),
          alignment: Alignment.bottomRight,
          ringColor: Colors.blue.withAlpha(110),
          ringDiameter: 450.0,
          ringWidth: 130.0,
          fabSize: 60.0,
          fabElevation: 8.0,
          fabColor: Color.fromRGBO(0, 135, 180, 1),
          fabOpenIcon: Icon(Icons.menu, color: Colors.white),
          fabCloseIcon: Icon(Icons.close, color: Colors.white),
          fabMargin: const EdgeInsets.all(16.0),
          animationDuration: const Duration(milliseconds: 800),
          animationCurve: Curves.easeInOutCirc,
          onDisplayChange: (isOpen) {
            fabOpen=!fabOpen;
            print(fabOpen);
            print("fabopen");
            //_showSnackBar(context, "The menu is ${isOpen ? "open" : "closed"}");
          },
          children: <Widget>[

            if(admin_sts == '1' || admin_sts == '2')
              RaisedButton(
                color: Colors.blue.withAlpha(150),
                onPressed:_addEmployee,
                shape: CircleBorder(),
                // padding: const EdgeInsets.only(left:10.0),
                child: Container(
                  // color: Colors.blue.withAlpha(120),
                    height: 59,
                    // color: ,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.group_add,
                            size: 24.0,
                            color: Colors.white,
                          ),
                          onTap: (){
                            _addEmployee();
                          },
                        ),
                        Text("+ Employee",style: TextStyle(color: Colors.white,fontSize: 12),)
                      ],
                    )
                ),
              ),

            if (visitpunch.toString() == '1')
              RaisedButton(
                color:Colors.blue.withAlpha(150),
                onPressed:_visitPunch,
                shape: CircleBorder(),
                // padding: const EdgeInsets.all(10.0),
                child: Container(
                  // color: Colors.blue.withAlpha(120),
                    height: 59,
                    // color: ,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.directions_walk,
                          size: 24.0,
                          color: Colors.white,
                        ),
                        Text("Visits",style: TextStyle(color: Colors.white,fontSize: 12),),
                      ],
                    )
                ),
              ),
            if(admin_sts == '1' || admin_sts == '2')
              RaisedButton(
                color: Colors.blue.withAlpha(150),
                onPressed:_reports,
                shape: CircleBorder(),
                //   padding: const EdgeInsets.all(10.0),
                child: Container(
                  // color: Colors.blue.withAlpha(120),
                    height: 59,
                    // color: ,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.content_paste,
                          size: 24.0,
                          color: Colors.white,
                        ),
                        Text("Reports",style: TextStyle(color: Colors.white,fontSize: 12),)
                      ],
                    )
                ),
              ),
            if(globals.ShiftPlanner==1 && admin_sts=='0')
              RaisedButton(
                color: Colors.blue.withAlpha(150),
                onPressed:_shiftsCalendar,
                shape: CircleBorder(),
                //   padding: const EdgeInsets.all(10.0),
                child: Container(
                  // color: Colors.blue.withAlpha(120),
                    height: 59,
                    // color: ,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          const IconData(0xe80e, fontFamily: "CustomIcon"),
                          size: 24.0,
                          color: Colors.white,
                        ),
                        Text("Shifts",style: TextStyle(color: Colors.white,fontSize: 12),)
                      ],
                    )
                ),
              ),


            if(admin_sts == '0')
              RaisedButton(
                color: Colors.blue.withAlpha(150),
                onPressed:_logs,
                shape: CircleBorder(),
                //   padding: const EdgeInsets.all(10.0),
                child: Container(
                  // color: Colors.blue.withAlpha(120),
                    height: 59,
                    // color: ,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          size: 24.0,
                          color: Colors.white,
                        ),
                        Text("Log",style: TextStyle(color: Colors.white,fontSize: 12),)
                      ],
                    )
                ),
              ),



            if (BasicLeave.toString() == '1')
              RaisedButton(
                color: Colors.blue.withAlpha(150),
                onPressed: _myLeave,
                shape: CircleBorder(),
                // padding: const EdgeInsets.all(10.0),
                child: Container(
                  // color: Colors.blue.withAlpha(120),
                    height: 59,
                    // color: ,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/leave-icon.png', height: 25.0,
                          width: 25.0,
                          color: Colors.white,),
                        Text("Leave",
                          style: TextStyle(color: Colors.white, fontSize: 15),)
                      ],
                    )
                ),
              ),

            RaisedButton(
              color: Colors.blue.withAlpha(150),
              onPressed:_settings,
              shape: CircleBorder(),
              //   padding: const EdgeInsets.all(10.0),
              child: Container(
                // color: Colors.blue.withAlpha(120),
                  height: 59,
                  // color: ,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.settings,
                        size: 24.0,
                        color: Colors.white,
                      ),
                      Text("Settings",style: TextStyle(color: Colors.white,fontSize: 12),)
                    ],
                  )
              ),
            ),


          ],
        ),

      ),
    );



  }

  checkalreadylogin() {
    ////print("---->"+response.toString());
    if (response == 1) {
      return new IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          underdevelopment(),
          (globalstreamlocationaddr != "Location not fetched." ||
              globals.globalstreamlocationaddr.isNotEmpty)
              ? mainbodyWidget()
              : refreshPageWidgit(),
          //(false) ? mainbodyWidget() : refreshPageWidgit(),
          underdevelopment()
        ],
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AskRegisterationPage()),
            (Route<dynamic> route) => false,
      );
    }


  }


  mainbodyWidget() {

    CameraPosition initialLocation = CameraPosition(
        zoom: CAMERA_ZOOM,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: cameraSource);

    ////to do check act1 for poor network connection

    if(globalstreamlocationaddr == "Location not fetched."){
      return Padding(
        padding: const EdgeInsets.only(left:45.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Kindly allow location permission from settings',
              textAlign: TextAlign.center,
              style: new TextStyle(fontSize: 14.0, color: Colors.red)),
          RaisedButton(
            child: Text('Open Settings'),
            onPressed: () {
              PermissionHandler().openAppSettings();
            },
          )],),
      );
    }

    if (act1 == "Poor network connection") {
      return poorNetworkWidget();
    } else {
      return   new ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          new Container(
            height: MediaQuery.of(context).size.height*0.90,
            child:Stack(
              children: <Widget>[

                GoogleMap(
                  myLocationEnabled: false,
                  compassEnabled: true,
                  tiltGesturesEnabled: false,
                  markers: (admin_sts == '1' || admin_sts =='2') && childExist == true? _markers:_markers1,
                  polylines: _polylines,
                  mapType: MapType.normal,
                  initialCameraPosition: initialLocation,
                  onMapCreated: onMapCreated,
                  mapToolbarEnabled:true,
                  zoomControlsEnabled: false,  // hide zoom button
                  onTap: (LatLng location) {
                    setState(() {
                      pinPillPosition = -470;
                    });
                  },
                ),
                /* MapPinPillComponent(
                    pinPillPosition: pinPillPosition,
                    currentlySelectedPin: currentlySelectedPin
                ),*/

                AnimatedOpacity(
                  opacity: opacityLevel1,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.linear,
                  child: Container(
                    child: Padding(
                      padding: new EdgeInsets.fromLTRB(120.0, 20.0, 50.0, 10.0),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Card(
                              elevation: 2.0,
                              child:TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.search),
                                  hintText: 'Employee Name',
                                  focusColor: Colors.white,
                                ),
                                onChanged: onItemChanged,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _textController.text!=""?ListView(
                              padding: EdgeInsets.only(top: 5),
                              //  scrollDirection:Axis.horizontal,
                              children: newDataList.map((data) {

                                return ListTile(
                                    title: Text(data),

                                    onTap: () async{

                                      print("ontap calles for emp");

                                      setLoader = false;
                                      final GoogleMapController controller = await _controller.future;
                                      _markers.clear();
                                      latlng.clear();
                                      _polylines.clear();
                                      var prefs=await SharedPreferences.getInstance();
                                      var orgid222=prefs.get("orgid")??"0";
                                      var empid222=prefs.get("empid")??"0";
                                      String todayDate = DateTime.now().toString().split(".")[0].split(" ")[0];
                                      String result = data.substring(1, data.indexOf(')'));
                                      print(result);
                                      print("resulats are");
                                      var p=97;
                                      var ii=0;
                                      int ID = 1;
                                      var lastCurrentLocation;
                                      int markerPoint = 0;
                                      List TimeInOutLocations = new List();
                                      final Uint8List TimeInMapIcon = await getBytesFromAsset('assets/TimeInMapIcon.png', 140);
                                      final Uint8List currentLocationPinMapIcon = await getBytesFromAsset('assets/mapPinPointMarker.png', 140);
                                      final Uint8List fakeLocation = await getBytesFromAsset('assets/fakeLocation.png', 140);


                                      var date11 = new DateTime.now().toString();

                                      var dateParse = DateTime.parse(date11);

                                      var formattedDate = "${dateParse.day.toString().padLeft(2, '0')}-${dateParse.month.toString().padLeft(2, '0')}-${dateParse.year}";

                                      var date222 = formattedDate.toString() ;

                                      CollectionReference _documentRef=Firestore.instance.collection('locations/$orgid222/${this.empId}/$date222/latest');

                                      // _documentRef.getDocuments().then((ds){





                                      _documentRef.getDocuments().then((ds){


                                        if(ds!=null){

                                          print("hjsghsgsj"+ds.documents.toString());
                                          var aaa=ds.documents;
                                          aaa.sort((a, b) {
                                            return a.data["location"]["timestamp"].toString().toLowerCase().compareTo(b.data["location"]["timestamp"].toString().toLowerCase());
                                          });


                                          for(var value in aaa){
                                            print("From firestore..........................................>>>>");

                                            print(value.data["location"]["timestamp"]);
                                            print("From firestore..........................................>>>>");


                                            var change1 = new Map<String, dynamic>.from(value.data);
                                            print('hjjghgjgjgjhgj' +
                                                change1['location']["activity"]["confidence"].toString());
                                            var currentLoc = Locations.fromFireStore(change1);



    if(currentLoc.mock == "true"){ //if user uses mock locations

    ID++;
    var m1=Marker(
    markerId: MarkerId('fakeLocation$ID'),
    position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
    // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
    icon:BitmapDescriptor.fromBytes(fakeLocation),

    infoWindow: InfoWindow(
    title: "Fake location found: ",
    snippet: "         "+data.snapshot.key
    // anchor: Offset(0.1, 0.1)
    ),
    );
    Future.delayed(Duration(seconds: 1),(){
    setState(() {
    _markers.add(m1);
    //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
    });
    });
    }

    TimeInOutLocations.add([currentLoc.latitude,currentLoc.longitude,data.snapshot.key]);

    var firstLocation = TimeInOutLocations[0]; //timeIn location
    if(TimeInOutLocations.length>1){
    lastCurrentLocation = TimeInOutLocations[TimeInOutLocations.length - 1];

    var m1=Marker(
    markerId: MarkerId('sourcePinCurrentLocationIcon'),
    position: LatLng(double.parse(lastCurrentLocation[0]),double.parse(lastCurrentLocation[1])),
    // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
    icon:BitmapDescriptor.fromBytes(currentLocationPinMapIcon),

    infoWindow: InfoWindow(
    title: "Last known location: "+data.snapshot.key,
    ),
    );
    Future.delayed(Duration(seconds: 1),(){
    setState(() {
    _markers.add(m1);
    setLoader = true;
    //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
    });
    });

    }
    var m=Marker(
    markerId: MarkerId('sourcePinTimeInIcon'),
    position: LatLng(double.parse(firstLocation[0]),double.parse(firstLocation[1])),
    // icon: await getMarkerIconForTimeIn("https://cdn0.iconfinder.com/data/icons/map-and-navigation-2-1/48/100-512.png", Size(150.0, 250.0),0),
    icon: BitmapDescriptor.fromBytes(TimeInMapIcon),
    // icon:pinLocationIcon,

    infoWindow: InfoWindow(
    title: "Start Time: "+firstLocation[2],
    ),
    );
    Future.delayed(Duration(seconds: 1),(){
    setState(() {
    _markers.add(m);
    //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
    });
    });


    //  setState(() {
    // create a Polyline instance
    // with an id, an RGB color and the list of LatLng pairs

    controller.animateCamera(CameraUpdate.newCameraPosition(
    CameraPosition(
    bearing: 0,
    target: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
    zoom: 13.0,
    ),
    ));

    end= double.parse(currentLoc.odometer);
    print(latlng.toString());

    // if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy)<20.0) ) {
    if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy) < 20.0)) {

    start=end;
    p++;
    //print("shashankmmmmmmmmmm"+(end-start>200.0).toString());
    //add position number marker
    // Future.delayed(Duration(seconds: 2),(){
    markerPoint++;

    getMarkerNew(markerPoint,double.parse(currentLoc.latitude),double.parse(currentLoc.longitude),data.snapshot.key);

    setState(() {

    if(ii==0) {
    startM=double.parse(currentLoc.odometer);
    print("current loc odo"+startM.toString());
    }

    endM=double.parse(currentLoc.odometer);
    print("end loc odo"+startM.toString());

    kms=((endM-startM)/1000).toStringAsFixed(2)+" kms";
    print("sgksshhskhs   "+kms);
    // if(endM-startM<0)
    //  kms='0.0';
    });
    //});

    ii++;

    /* var m=Marker(
          markerId: MarkerId('sourcePin$p'),
          position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
          //icon: await getMarkerIcon("https://i.dlpng.com/static/png/6865249_preview.png", Size(150.0, 150.0),0),
          icon:BitmapDescriptor.fromBytes(markerIcon),

          infoWindow: InfoWindow(
            title: data.snapshot.key,
          ),
        );
        Future.delayed(Duration(seconds: 1),(){
          setState(() {
            _markers.add(m);
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });*/
    }

    print(currentLoc.accuracy);
    print("currentLoc.accuracy");


    setState(() {
    // if(double.parse(currentLoc.accuracy)<20.0)           //07oct
    //   {
    latlng.add(LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)));
    //  print(latlng);
    // print("latlong iss");
    _polylines.add(Polyline(
      polylineId: PolylineId('1'),
      visible: true,
      width: 3,
      patterns: <PatternItem>[PatternItem.dash(20), PatternItem.gap(10)] ,
      //latlng is List<LatLng>
      points: latlng,
      color: Colors.blue,
    ));
    // }
    });

    }}
                    });

                                    /*  for (var keys in StoreLocation.keys) {
                                        if(result==keys.toString()){
                                          List searchedLocation = StoreLocation[result];
                                          print(searchedLocation);
                                          print("searchedLocation");
                                          _add(double.parse(searchedLocation.elementAt(0)),double.parse(searchedLocation.elementAt(1)),searchedLocation.elementAt(4),searchedLocation.elementAt(3));
                                          //   getLocation(double.parse(searchedLocation.elementAt(0)),double.parse(searchedLocation.elementAt(1)));
                                          // newDataList.clear();
                                        }
                                      }*/
                                      print(data);
                                      newDataList.clear();
                                      print(newDataList);
                                      print("sadsadnewDataList");
                                      //  _changeOpacity1();
                                      _textController.clear();
                                      opacityLevel1=0.0;

                                    });
                              }).toList(),
                            ):Container(),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                (act1 == '') ? loader() : getMarkAttendanceWidgit(),

                Container(
                    margin: new EdgeInsets.symmetric(vertical: 10.0),
                    alignment: FractionalOffset.topLeft,
                    child:AvatarGlow(
                      endRadius: 63.0,
                      glowColor: appcolor,
                      duration: Duration(milliseconds: 1500),
                      animate:true,
                      showTwoGlows: true,

                      child: Container(
                        //  color: Colors.red,
                        child:  new GestureDetector(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/avatar.png',
                                image: profile,
                                fit: BoxFit.fill,
                              ),
                            ),
                            onTap: (){
                              setState(() {

                                selected= !selected;
                                _changeOpacity();

                              });
                            }

                        ),
                        width: MediaQuery.of(context).size.height * .10,
                        height: MediaQuery.of(context).size.height * .10,
                        decoration: new BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            new BoxShadow(
                              color: appcolor,
                              blurRadius: 10.0,
                              // offset: new Offset(0.0, 10.0),
                              spreadRadius: 2.0,
                            ),
                          ],
                          /*image: new DecorationImage(
                        fit: BoxFit.fill,
                           // image: NetworkImage(profile),
                            image: NetworkImage(profile),
                          ),*/
                        ),
                      ),
                    )
                ),


                (admin_sts =='1' || admin_sts == '2') && selected!=true? Container(
                    margin: new EdgeInsets.symmetric(vertical: 35.0,horizontal: 5),
                    alignment: FractionalOffset.topRight,
                    child:Container(
                      child:  new GestureDetector(
                          child: Container(
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue[100],
                                boxShadow: <BoxShadow>[
                                  new BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 20.0,
                                    //offset: new Offset(0.0, 10.0),
                                  ),
                                ],
                              ),
                              // color: Colors.blue[100],
                              child: Icon(Icons.search)),
                          onTap: (){
                            _changeOpacity1();
                            /// });
                          }
                      ),
                      width: MediaQuery.of(context).size.height * .07,
                      height: MediaQuery.of(context).size.height * .07,
                      /* decoration: new BoxDecoration(
                   color: Colors.black,
                     shape: BoxShape.circle,
                     boxShadow: <BoxShadow>[
                       new BoxShadow(
                         color: appcolor,
                         blurRadius: 10.0,
                        // offset: new Offset(0.0, 10.0),
                         spreadRadius: 2.0,
                       ),
                     ],
                     image: new DecorationImage(
                       fit: BoxFit.fill,
                       image: NetworkImage(profile),
                     ))*/
                    )
                ):Container(),

                (admin_sts =='1' || admin_sts == '2') ? Positioned(
                  //top: 570,
                    top:  MediaQuery.of(context).size.height *.75,
                    // bottom: 310,
                    child:Align(
                      //alignment: FractionalOffset.bottomRight,
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height * .80 ,
                          width:MediaQuery.of(context).size.width * .80 ,
                          child: getProfileWidget()
                      ),
                    )
                ):Container(),

                //(admin_sts == '1' || admin_sts=='2') &&  setLoader != true && childExist == true? new Align(child: CircularProgressIndicator(),alignment: FractionalOffset.center,):Container(),
              ],
            ),
          ),
        ],
      );
    }
  }

  poorNetworkWidget() {
    return Container(
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.error,
                      color: appcolor,
                    ),
                    Text(
                      " Poor network connection.",
                      style: new TextStyle(fontSize: 20.0, color: appcolor),
                    ),
                  ]),
              SizedBox(height: 5.0),
              FlatButton(
                child: new Text(
                  "Refresh Page",
                  style: new TextStyle(
                      color: appcolor, decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  // sl.startStreaming(5);
                  // startTimer();
                  cameraChannel.invokeMethod("startAssistant");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
            ]),
      ),
    );
  }


  refreshPageWidgit() {
    if (globals.globalstreamlocationaddr.isNotEmpty) {
      return new Container(
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 20.0,
                    ),

                    Container(
                      decoration: new ShapeDecoration(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(13.0)),
                        color: Colors.red,
                      ),
                      child: Text(
                        '\nProblem Getting Location! Please turn on GPS and try again.',
                        textAlign: TextAlign.center,
                        style:
                        new TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                      width: 220.0,
                      height: 90.0,
                    ),
                  ]),
              SizedBox(height: 15.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 20.0,
                    ),

                  ]),
              FlatButton(
                child: new Text(
                  "Try now",
                  style: new TextStyle(
                      color: appcolor, decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  //  sl.startStreaming(5);
                  // startTimer();
                  cameraChannel.invokeMethod("startAssistant");
                  /* Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );*/
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Kindly allow location permission from settings',
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: 14.0, color: Colors.red)),
        RaisedButton(
          child: Text('Open Settings'),
          onPressed: () {
            PermissionHandler().openAppSettings();
          },
        ),
      ]);
    }
  }

  underdevelopment() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(
                Icons.android,
                color: appcolor,
              ),
              Text(
                "Under development",
                style: new TextStyle(fontSize: 30.0, color: appcolor),
              )
            ]),
      ),
    );
  }


  getLocation(lat, long) async{

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(lat	,long),
        zoom: 13.0,
      ),
    ));

  }

 /* getSearchLocation(empname, res) {
    print(StoreLocation);
    print("Nhkhkhkh");
    print(empname);
    StoreLocation.forEach((k, v) {
      print(v[3]);
      print("v[4]");
      if(v[3].toUpperCase().toString().contains(empname.toUpperCase().toString())){
        print("YES!!! FOUND IT");
      }
      else{
        print("NOT FOUND!!!");
      }
    });
  }*/

  formatTime(String time) {

    if(time.contains(":")) {
      var a=time.split(":");
      return a[0]+":"+a[1];
    }
    else return time;
  }

  getProfileWidget() {

    return FutureBuilder<List<Attendance>>(
      future: getAttendance(today.text),
      builder: (context, snapshot) {
        print("snapshot data os");
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            // ignore: missing_return
            return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {

                 /* setState(() {
                    recentEmployeeId = snapshot.data[index].e.toString();
                  });*/

                  _checkLoaded = false;
                  var count=0;

                  var image = NetworkImage(snapshot.data[index].profile.toString());
                  image.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((_, __) {
                    _checkLoaded = true;
                  }));


                  var Name = snapshot.data[index].name.toString();
                  print(Name);
                  print("name is the client");
                  print(_checkLoaded);

                  //  getAcronym(var name) {

                  if((Name.trim()).contains(" ")) {
                    var name=Name.split(" ");
                    print('print(name);');
                    print(name);
                    First=name[0][0].trim();
                    print(First);
                    Last=name[1][0].trim().toString().toUpperCase();
                    print(Last);
                    initials =  First+Last;
                    print(initials);
                    print("initials ");
                  }else{
                    First=Name.substring(0,1);
                    print('print(First)else');
                    print(First);
                    initials =  First;
                    print(initials);
                  }
                  // }

                  print(index);
                  print("index are");
                  print(_selectedIndex);

                  return new Column(
                      children: <Widget>[
                        new FlatButton(
                            child : new Row(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    InkWell(
                                      child:  new Container(
                                        width: MediaQuery.of(context).size.height * .075,
                                        height: MediaQuery.of(context).size.height * .075,
                                        decoration: new BoxDecoration(
                                          border: (_selectedIndex == null  && index == 0) ||_selectedIndex==index
                                              ? Border.all(
                                              width: 4, color: Colors.green//                   <--- border width here
                                          ):Border.all(
                                              width: 2, color: Colors.blue//                   <--- border width here
                                          ),
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                          /*  boxShadow: <BoxShadow>[
                                  new BoxShadow(
                                    color: appcolor,
                                    blurRadius: 10.0,
                                    // offset: new Offset(0.0, 10.0),
                                    spreadRadius: 2.0,
                                  ),
                                ],*/
                                          /*image: new DecorationImage(
                              fit: BoxFit.fill,
                                 // image: NetworkImage(profile),
                                  image: NetworkImage(profile),
                                ),*/
                                        ),

                                        child: _checkLoaded? ClipRRect(
                                          borderRadius: BorderRadius.circular(300.0),
                                          child: FadeInImage.assetNetwork(
                                            placeholder: 'l',
                                            fit: BoxFit.fill,
                                            image: snapshot.data[index].profile,
                                          ),
                                        ): CircleAvatar(
                                          child: Text(initials,style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400)),
                                        ),
                                      ),

                                      onTap: ()  {

                                        onMapCreatedNew(snapshot.data[index].EmployeeId);
                                        _onSelected(index);





















                                        ////////////////////after changes///////////

                                 /*       print(DateTime.now().toString().split(".")[0].split(" ")[0]);
                                        print(orgid);
                                        print(snapshot.data[index].EmployeeId);
                                        print("jghkhkukhjk");
                                        var value;
                                        var key;
                                    //    FirebaseDatabase.instance.reference().child("Locations").child(orgid).
                                        ///child(snapshot.data[index].EmployeeId.toString()).child(DateTime.now().toString().split(".")[0].split(" ")[0]).onChildAdded.once().then((data)  {



                                       *//*   var currentLoc=  Locations.fromFireBase(data.snapshot);
                                          print(currentLoc);
                                          print(currentLoc.latitude);
*//*

                                       FirebaseDatabase.instance.reference().child("Locations").
                                 child(orgid).child(snapshot.data[index].EmployeeId.toString()).child
                              (DateTime.now().toString().split(".")[0].split(" ")[0]).orderByKey().once().then((snapshot){
                                          var date=DateTime.now().toString().split(".")[0].split(" ")[0];

                                          var locations

                                          for(int i=0; i<snaps)

                                          var timesMap = new Map<String, dynamic>.from(snapshot.value.keys.toList());
                                          List<Map<String, dynamic>> locationList = List();
                                          timesMap.forEach((k, v) => locationList.add({k:v}));

                                          locationList.sort((a,b) {
                                            return DateTime.parse(date+" "+a.keys.first).compareTo(DateTime.parse(date+" "+b.keys.first));
                                          });
                                          print(locationList);
                                          print("locationList");


                            print(snapshot.value.keys.toList()[0]);
                            print("after asserion");
                                        print(snapshot.value.toString());
                                        print(snapshot.value);
                                        print(snapshot.key);
                                        var keys = snapshot.key;
                                        print("keys are");
                                        print(keys);
                                         print("snapshot from firebase");
                                      //   value = snapshot.value[snapshot.value.keys.toList()[0]];
                                       //  var v2 =snapshot.value;
                                         print("v24135141654");
                                       //  print(v2);
                                     //   var v1 = snapshot.value[snapshot.key][0]['is_moving'];
                                      //   print(value.toString());
                                      //   print(value['is_moving']);
                                         print("hklhlkll");
                                         print(key.toString());
                                      //  print(v1);
                                        print("-----------------");
                                        // key = snapshot.key;

                                 });


                              










                                        _markers.clear();
                                        setLoader = false;
                                        _checkLoaded = false;
                                        var image = NetworkImage(snapshot.data[index].profile);
                                        print(image);
                                        print("image is");
                                        print("name is the client123");
                                        print(_checkLoaded);

                                        image.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((_, __) {
                                          _checkLoaded = true;
                                        }));

                                        var Name = snapshot.data[index].name.toString();
                                        print(Name);
                                        print(_checkLoaded);


                                        //  getAcronym(var name) {

                                        if((Name.trim()).contains(" ")) {
                                          var name=Name.split(" ");
                                          print('print(name);');
                                          print(name);
                                          First=name[0][0].trim();
                                          print(First);
                                          Last=name[1][0].trim().toString().toUpperCase();
                                          print(Last);
                                          initials =  First+Last;
                                          print(initials);
                                          print("initials ");
                                        }else{
                                          First=Name;
                                          print('print(First)else');
                                          print(First);
                                          initials =  First;
                                          print(initials);
                                        }
                                        
                                        
                                        StoreLocation.forEach((k, v) {


                                          double LAT1 = double.parse(StoreLocation.values.elementAt(index)[0]);
                                          double LONG1 = double.parse(StoreLocation.values.elementAt(index)[1]);
                                          double LAT2 = double.parse(v[0]);
                                          double LONG2 = double.parse(v[1]);


                                          double distance = 2 * 6371000 * Math.asin(Math.sqrt(Math.pow((Math.sin((LAT2 * (3.14159 / 180) - LAT1 * (3.14159 / 180)) / 2)), 2) + Math.cos(LAT2 * (3.14159 / 180)) * Math.cos(LAT1 * (3.14159 / 180)) * Math.sin(Math.pow(((LONG2 * (3.14159 / 180) - LONG1 * (3.14159 / 180)) / 2), 2))));
                                          print(distance);
                                          print("distance is");
                                          if(distance<10) {
                                            //if they are less then at a distance of 10 meters
                                            count++;
                                            print(count);
                                            print("count is");
                                          }

                                          // }
                                        });

                                        print(initials);
                                        print("checkloaded");
                                        print(_checkLoaded);

                                        var dataBytes;
                                    *//*    var request = await http.get(StoreLocation.values.elementAt(index)[4]);
                                        var bytes = await request.bodyBytes;

                                        setState(() {
                                          dataBytes = bytes;
                                        });*//*

                                        LatLng _lastMapPositionPoints = LatLng(
                                            double.parse(StoreLocation.values.elementAt(index)[0]),
                                            double.parse(StoreLocation.values.elementAt(index)[1]));

                                        // var loader = await getMarkerIconForClients(StoreLocation.values.elementAt(index)[4],  Size(140.0, 140.0), count);

                                        _checkLoaded?
                                        getMarkerProfile(StoreLocation.values.elementAt(index)[4], count ,double.parse(StoreLocation.values.elementAt(index)[0]), double.parse(StoreLocation.values.elementAt(index)[1]))
                                            : getMarker(initials,double.parse(StoreLocation.values.elementAt(index)[0]), double.parse(StoreLocation.values.elementAt(index)[1]),count);

                                        *//*_markers.add(
                                  Marker(
                                icon: loader,
                                markerId: MarkerId(_lastMapPositionPoints.toString()),
                                position: _lastMapPositionPoints,
                                onTap: (){
                                  getPopup(double.parse(StoreLocation.values.elementAt(index)[0]), double.parse(StoreLocation.values.elementAt(index)[1]));
                                  },
                                infoWindow: InfoWindow(
                                  title: "Delivery Point",
                                  snippet:"My Position",
                                ),
                              ))*//*


                                        getLocation(double.parse(StoreLocation.values.elementAt(index)[0]),double.parse(StoreLocation.values.elementAt(index)[1]));


                                        */
                                      },
                                    ),
                                    Name.toString().length>8? Text(
                                      Name.toString().substring(0,8)+"..",
                                      style: TextStyle(fontSize: 12.0),
                                    ):Text(
                                      Name,
                                      style: TextStyle(fontSize: 12.0),
                                    )
                                  ],
                                ),

                              ],
                            ),

                            onPressed: ()  {

                              // currentlySelectedPin = PinInformation(pinPath: 'assets/friend1.jpg', avatarPath: StoreLocation.values.elementAt(index)[4], location: LatLng(0, 0), client: StoreLocation.values.elementAt(index)[3],description: 'At: '+StoreLocation.values.elementAt(index)[4],in_time: "19:20",out_time: '-', labelColor: Colors.grey);
                              //   pinPillPosition = 50;
                            }
                        ),
                      ]
                  );
                }
            );};
        }
        else if (snapshot.hasError) {
          return new Text("Unable to connect server");
        }
        // return loader();
        return new Center(child: CircularProgressIndicator());

        },
    );

  }

  var startM=0.0,endM=0.0;
  var start=0.0,end=0.0;

  // function to get locations for the user icon clicked


  void onMapCreatedNew(int EmployeeId)async {

    print(EmployeeId);

    _markers.clear();
    _polylines.clear();
    latlng.clear();

    // controller.setMapStyle(Utils.mapStyles);
   // _controller.complete(controller);
    final GoogleMapController controller = await _controller.future;

    var prefs= await SharedPreferences.getInstance();
   // today1 = new TextEditingController();
 //   today1.text = formatter.format(DateTime.now());

    var orgId11=prefs.get("orgid");
    //final GoogleMapController controller = await _controller.future;
    //onDateChanged(today1.text);
    //setMapPins();


    var p=97;
    var q=97;
    var ii=0;
    var lastCurrentLocation;
    int markerPoint = 0;
    List TimeInOutLocations = new List();
    final Uint8List TimeInMapIcon = await getBytesFromAsset('assets/TimeInMapIcon.png', 140);
    final Uint8List currentLocationPinMapIcon = await getBytesFromAsset('assets/mapPinPointMarker.png', 140);
    final Uint8List fakeLocation = await getBytesFromAsset('assets/fakeLocation.png', 200);
    int ID = 1;
    setLoader = false;

    var date11 = new DateTime.now().toString();

    var dateParse = DateTime.parse(date11);

    var formattedDate = "${dateParse.day.toString().padLeft(2, '0')}-${dateParse.month.toString().padLeft(2, '0')}-${dateParse.year}";

    var date222 = formattedDate.toString() ;

    CollectionReference _documentRef=Firestore.instance.collection('locations/$orgId11/${EmployeeId.toString()}/$date222/latest');

    // _documentRef.getDocuments().then((ds){

    _documentRef.getDocuments().then((ds){


      if(ds!=null){

        print("hjsghsgsj"+ds.documents.toString());
        var aaa=ds.documents;
        aaa.sort((a, b) {
          return a.data["location"]["timestamp"].toString().toLowerCase().compareTo(b.data["location"]["timestamp"].toString().toLowerCase());
        });


        for(var value in aaa){
          print("From firestore..........................................>>>>");

          print(value.data["location"]["timestamp"]);
          print("From firestore..........................................>>>>");


          var change1 = new Map<String, dynamic>.from(value.data);
          print('hjjghgjgjgjhgj' +
              change1['location']["activity"]["confidence"].toString());
          var currentLoc = Locations.fromFireStore(change1);

          print("onMapCreatedNew");
      print(EmployeeId);
      childExist = true;


//      var mockLocation = currentLoc.mock;
//      print(mockLocation);

      if (currentLoc.mock == "true") {
        print("mock location true"); //if user uses mock locations

        ID++;
        print(ID);
        print("ID is");


        var m1 = Marker(
          markerId: MarkerId('fakeLocation$ID'),
          position: LatLng(double.parse(currentLoc.latitude),
              double.parse(currentLoc.longitude)),
          // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
          icon: BitmapDescriptor.fromBytes(fakeLocation),

          infoWindow: InfoWindow(
              title: "Fake location found: ",
              snippet: "         " + currentLoc.time
            // anchor: Offset(0.1, 0.1)
          ),
        );
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _markers.add(m1);
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });
      }

      TimeInOutLocations.add(
          [currentLoc.latitude, currentLoc.longitude, currentLoc.time]);

       //timeIn location
      if (aaa.length > 0) {
        var lastLoc,firstLoc;
        var change11 = new Map<String, dynamic>.from(aaa[0].data);
        firstLoc = Locations.fromFireStore(change11);
        print(firstLoc.latitude.toString()+"first loc lat");

        var m = Marker(
          markerId: MarkerId('sourcePinTimeInIcon'),
          position: LatLng(double.parse(firstLoc.latitude),
              double.parse(firstLoc.longitude)),
          // icon: await getMarkerIconForTimeIn("https://cdn0.iconfinder.com/data/icons/map-and-navigation-2-1/48/100-512.png", Size(150.0, 250.0),0),
          icon: BitmapDescriptor.fromBytes(TimeInMapIcon),
          // icon:pinLocationIcon,
          infoWindow: InfoWindow(
            title: "Start Time: " + firstLoc.time.toString(),
          ),
        );
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _markers.add(m);
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });

        var change111 = new Map<String, dynamic>.from(aaa[aaa.length-1].data);
        lastLoc = Locations.fromFireStore(change111);
        print(lastLoc.latitude.toString()+"last loc lat");

        var m1 = Marker(
          markerId: MarkerId('sourcePinCurrentLocationIcon'),
          position: LatLng(double.parse(lastLoc.latitude),
              double.parse(lastLoc.longitude)),
          // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
          icon: BitmapDescriptor.fromBytes(currentLocationPinMapIcon),

          infoWindow: InfoWindow(
            title: "Last known location: ",
          ),
        );
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _markers.add(m1);
            setLoader = true;
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });
      }
      /*
      var m = Marker(
        markerId: MarkerId('sourcePinTimeInIcon$p'),
        position: LatLng(
            double.parse(firstLocation[0]), double.parse(firstLocation[1])),
        // icon: await getMarkerIconForTimeIn("https://cdn0.iconfinder.com/data/icons/map-and-navigation-2-1/48/100-512.png", Size(150.0, 250.0),0),
        icon: BitmapDescriptor.fromBytes(TimeInMapIcon),
        // icon:pinLocationIcon,

        infoWindow: InfoWindow(
          title: "Start Time: " + firstLocation[2],
        ),
      );*/
  /*
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _markers.add(m);
          //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
        });
      });
*/

      //  setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(double.parse(currentLoc.latitude),
              double.parse(currentLoc.longitude)),
          zoom: 13.0,
        ),
      ));
/*
      end = double.parse(currentLoc.odometer);
      print(latlng.toString());

      // if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy)<20.0) ) {
      if (((end - start) > 200.0) &&
          (double.parse(currentLoc.accuracy) < 20.0)) {
        start = end;
        p++;
        //print("shashankmmmmmmmmmm"+(end-start>200.0).toString());
        //add position number marker
        // Future.delayed(Duration(seconds: 2),(){
        markerPoint++;

        getMarkerNew(markerPoint, double.parse(currentLoc.latitude),
            double.parse(currentLoc.longitude), currentLoc.time);

        setState(() {
          if (ii == 0) {
            startM = double.parse(currentLoc.odometer);
            print("current loc odo" + startM.toString());
          }

          endM = double.parse(currentLoc.odometer);
          print("end loc odo" + startM.toString());

          kms = ((endM - startM) / 1000).toStringAsFixed(2) + " kms";
          print("sgksshhskhs   " + kms);
          // if(endM-startM<0)
          //  kms='0.0';
        });
        //});

        ii++;
        /* var m=Marker(
          markerId: MarkerId('sourcePin$p'),
          position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
          //icon: await getMarkerIcon("https://i.dlpng.com/static/png/6865249_preview.png", Size(150.0, 150.0),0),
          icon:BitmapDescriptor.fromBytes(markerIcon),

          infoWindow: InfoWindow(
            title: data.snapshot.key,
          ),
        );
        Future.delayed(Duration(seconds: 1),(){
          setState(() {
            _markers.add(m);
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });*/
      }

      print(currentLoc.accuracy);
      print("currentLoc.accuracy");
*/

      setState(() {
        // if(double.parse(currentLoc.accuracy)<20.0)           //07oct
        //   {
        latlng.add(LatLng(double.parse(currentLoc.latitude),
            double.parse(currentLoc.longitude)));
        //  print(latlng);
        // print("latlong iss");
        _polylines.add(Polyline(
          polylineId: PolylineId(p.toString()),
          visible: true,
          width: 3,
          patterns: <PatternItem>[PatternItem.dash(20), PatternItem.gap(10)],
          //latlng is List<LatLng>
          points: latlng,
          color: Colors.blue,
        ));
        // }
      });
    }
        }
    });
    // } );

    //setSourceAndDestinationIcons();
    var date=DateTime.now().toString().split(".")[0].split(" ")[0];
    var visits =  await  getVisitsDataList(date.toString(),EmployeeId);
    print("aaa");
    var generatedIcon;
    List<BitmapDescriptor> generatedIcons=new List<BitmapDescriptor>();
    var j=visits.length;
    print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj"+j.toString());
    if(j>0)
      await Future.forEach(visits, (Punch visit) async {

        print("marker added............");
        var m=Marker(
          markerId: MarkerId('sourcePin$j'),
          position: LatLng(double.parse(visit.pi_latit),double.parse(visit.pi_longi)),
          icon: await getMarkerIconNew("https://i.dlpng.com/static/png/6865249_preview.png", Size(140.0, 140.0),j),
          onTap: () {
            setState(() {
              currentlySelectedPin = PinInformation(pinPath: 'assets/friend1.jpg', avatarPath: visit.pi_img, location: LatLng(0, 0), client: visit.client,description: visit.desc,in_time: visit.pi_time,out_time: visit.po_time, labelColor: Colors.grey);
              pinPillPosition = 100;
            });
            print(visit.po_time);

          },

          infoWindow: InfoWindow(
              title: visit.client,
              snippet:visit.desc
          ),
        );
        Future.delayed(Duration(seconds: 1),(){
          setState(() {
            _markers.add(m);
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });

        j--;
      });

    // setPolylines();
  }

  Future<Uint8List> getMarkerIconForClients(String imagePath, Size size,int number) async {

    print(number);
    print("number issss");

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 2);

    final Paint tagPaint = Paint()..color = Colors.blue;
    final double tagWidth = 40.0;

    final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
    final double shadowWidth = 15.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 3.0;

    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              0.0,
              0.0,
              size.width,
              size.height
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              shadowWidth,
              shadowWidth,
              size.width - (shadowWidth * 2),
              size.height - (shadowWidth * 2)
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    // Add tag circle

    if(number!=1) {
      canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(
                size.width - tagWidth,
                0.0,
                tagWidth,
                tagWidth
            ),
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: radius,
          ),
          tagPaint);

      // Add tag text
      TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: "+" + number.toString(),
        style: TextStyle(fontSize: 25.0, color: Colors.white),
      );

      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(
              size.width - tagWidth / 2 - textPainter.width / 2,
              tagWidth / 2 - textPainter.height / 2
          )
      );
    }

    // Oval for the image
    Rect oval = Rect.fromLTWH(
        imageOffset,
        imageOffset,
        size.width - (imageOffset * 2),
        size.height - (imageOffset * 2)
    );
    // Add path for oval image
    canvas.clipPath(Path()
      ..addOval(oval));

    // Add image
    ui.Image image = await getImageFromNetwork(imagePath); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);

    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt()
    );

    // Convert image to bytes
    final ByteData byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData.buffer.asUint8List();
    return uint8List;
  }


  getMarkerProfile( profile,count ,latitude, longitude) async {

    //var address= await getAddressFromLati(latitude.toString(),longitude.toString());
    print(profile);
    print("PlatformException123456");

    final Uint8List markerIcon  = await getMarkerIconForClients(profile,  Size(140.0, 140.0), count) ;

    //  if(showPolylines == true || showMarker == true) {
    var m = Marker(
      markerId: MarkerId(initials.toString()),
      position: LatLng(latitude,longitude),
      onTap:(){
        getPopup(latitude, longitude);
      },
      icon: BitmapDescriptor.fromBytes(markerIcon),
      /*infoWindow: InfoWindow(
        title: "Current known location at:",
        snippet:  address.toString()
      ),*/
    );
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        print(setLoader);
        print("setloader21");
        _markers.add(m);
        setLoader= true;
        print(setLoader);
        //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
      });
    });
    //  }
  }



  getMarker(String initials, latitude,longitude, count ) async {

    print("inside getmarker");
    // var address= await getAddressFromLati(latitude.toString(),longitude.toString());

    final Uint8List markerIcon = await getBytesFromCanvasForCircleMarker(150, 150, initials,count);

    //  if(showPolylines == true || showMarker == true) {
    var m = Marker(
      markerId: MarkerId(initials.toString()),
      position: LatLng(latitude,longitude),
      onTap:(){
        getPopup(latitude, longitude);
      },
      icon: BitmapDescriptor.fromBytes(markerIcon),
      /*  infoWindow: InfoWindow(
          title: "Current known location at:",
          snippet: address.toString()
        ),*/
    );
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _markers.add(m);
        setLoader= true;
        //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
      });
    });
    //  }
  }

  Future<Uint8List> getBytesFromCanvasForCircleMarker(int width, int height, String markerPoint,count) async  {    //IMP

    print(markerPoint);
    print("countOfPositionMarker");
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    final Radius radius = Radius.circular(width/2);
    final Paint tagPaint = Paint()..color = Colors.blue;


    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(),  height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: markerPoint,
      style: TextStyle(fontSize: 50.0, color: Colors.white,fontWeight: FontWeight.bold),
    );

    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              100,
              0.0,
              50,
              50
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        tagPaint);

    // Add tag text
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: "+"+count.toString(),
      style: TextStyle(fontSize: 25.0, color: Colors.white),
    );

    textPainter.layout();       //
    textPainter.paint(
        canvas,
        Offset(
            250 / 2 - textPainter.width / 2,
            50 / 2 - textPainter.height / 2
        )
    );

    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * .5) - painter.height * 0.5));
    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }


  getPopup(LAT1 , LONG1) {

    popupLocations.clear();

    print(LAT1);
    print(LONG1);

    StoreLocation.forEach((k, v) {

      double LAT2 = double.parse(v[0]);
      double LONG2 = double.parse(v[1]);

      double distance = 2 * 6371000 * Math.asin(Math.sqrt(Math.pow((Math.sin((LAT2 * (3.14159 / 180) - LAT1 * (3.14159 / 180)) / 2)), 2) + Math.cos(LAT2 * (3.14159 / 180)) * Math.cos(LAT1 * (3.14159 / 180)) * Math.sin(Math.pow(((LONG2 * (3.14159 / 180) - LONG1 * (3.14159 / 180)) / 2), 2))));

      if(distance<10) {            //if they are less then at a distance of 10 meters
        closeEmp = true;
        print("coming lati longi");

        print(StoreLocation);
        popupLocations.add([k,v[0],v[1],v[3],v[4],v[5],v[2]]);
        print(popupLocations);
        print("poplocation list");

      }

      // }
    });

    if(closeEmp)
      showBottomNavigation(popupLocations);
  }

  void showBottomNavigation(List popupLocations){

    showModalBottomSheet(
        context: context,
        backgroundColor:const Color(0xFF0E3311).withOpacity(0.0) ,
        builder: (builder) {
          return new Container(
              height: MediaQuery.of(context).size.height*0.35,
              color: appcolor.withOpacity(0.0),
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //   SizedBox(height: 20.0,),
                  /*Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Update profile photo", style: TextStyle(fontWeight: FontWeight.bold),)
                ],),*/
                  // SizedBox(height: 20.0,),
                  Expanded(
                    child:ListView.builder(
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.all(20.0),
                      itemCount: popupLocations.length,
                      itemBuilder: (context, index) {

                        var Loaded1 = false;

                        var image = NetworkImage(popupLocations[index][4]);


                        image.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((_, __) {
                          // if (mounted) {
                          //   setState(() {
                          Loaded1 = true;
                          //   });
                          //  }
                        }));
                        var Name = popupLocations[index][3];

                        if((Name.trim()).contains(" ")) {
                          var name=Name.split(" ");
                          print('print(name);');
                          print(name);
                          First=name[0][0].trim();
                          print(First);
                          Last=name[1][0].trim().toString().toUpperCase();
                          print(Last);
                          initials =  First+Last;
                          print(initials);
                          print("initials ");
                        }else{
                          First=Name.toString().substring(0,1);
                          print('print(First)else');
                          print(First);
                          initials =  First;
                          print(initials);

                        }

                        return InkWell(
                          child: Container(

                            //color:const Color(0xFF0E3311).withOpacity(0.5),
                            height:100,
                            padding: new EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 16.0),

                            child: new Stack(
                              children: <Widget>[
                                new Container(
                                  child: Container(
                                    padding: new EdgeInsets.fromLTRB(70.0, 5.0, 16.0, 10.0),
                                    //constraints: new BoxConstraints.expand(),
                                    child: new Column(
                                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,   //to align from start
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        new Container(height:  MediaQuery.of(context).size.height*0.001,),
                                        new Text(popupLocations[index][3].toString(), style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                        new Container(height:  MediaQuery.of(context).size.height*0.005,),
                                        Container(
                                          //margin: new EdgeInsets.fromLTRB(32.0, 1.0, 16.0, 16.0),
                                          child: true ? new Text("Latitude: "+popupLocations[index][1].toString(),style: TextStyle(fontSize: 12,color: Colors.white),):new Text("jkhgk",style: TextStyle(fontSize: 14,color: Colors.white),),
                                        ),Container(
                                          //margin: new EdgeInsets.fromLTRB(32.0, 1.0, 16.0, 16.0),
                                          child: true ? new Text("Longitude: "+popupLocations[index][2].toString(),style: TextStyle(fontSize: 12,color: Colors.white),):new Text("jkhgk",style: TextStyle(fontSize: 14,color: Colors.white),),
                                        ),
                                      ],
                                    ),
                                  ),
                                  height: 75.0,
                                  width: 350,
                                  margin: new EdgeInsets.only(left: 46.0),
                                  decoration: new BoxDecoration(
                                    //color: Color.fromRGBO(0, 0, 0, 0.5),
                                    //color: Color.fromRGBO(199, 130, 10, 0.6),
                                    //  color: Color.fromRGBO(2, 112, 85, 0.6),
                                    // color: Colors.orangeAccent[200],
                                    //color: Colors.teal[500],
                                    color: Colors.cyanAccent.withOpacity(0.7),
                                    shape: BoxShape.rectangle,
                                    borderRadius: new BorderRadius.circular(8.0),
                                    /*boxShadow: <BoxShadow>[
                    new BoxShadow(
                      color: Colors.black54,
                      blurRadius: 5.0,
                      offset: new Offset(0.0, 10.0),
                    ),
                  ],*/
                                  ),
                                ),
                                Container(
                                  margin: new EdgeInsets.symmetric(vertical: 13.0),
                                  alignment: FractionalOffset.centerLeft,
                                  child: Container(
                                    width: MediaQuery.of(context).size.height * .09,
                                    height: MediaQuery.of(context).size.height * .09,
                                    decoration: new BoxDecoration(
                                      /*border: Border.all(
                                          width: 2, color: Colors.blue//                   <--- border width here
                                      ),*/
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                      /*  boxShadow: <BoxShadow>[
                            new BoxShadow(
                              color: appcolor,
                              blurRadius: 10.0,
                              // offset: new Offset(0.0, 10.0),
                              spreadRadius: 2.0,
                            ),
                          ],*/
                                      /*image: new DecorationImage(
                        fit: BoxFit.fill,
                           // image: NetworkImage(profile),
                            image: NetworkImage(profile),
                          ),*/
                                    ),
                                    // width: MediaQuery.of(context).size.width*0.30,
                                    child: Loaded1? ClipRRect(
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: FadeInImage.assetNetwork(
                                        placeholder: 'l',
                                        fit: BoxFit.fill,
                                        image: popupLocations[index][4],
                                      ),
                                    ): CircleAvatar(
                                      child: Text(initials,style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: (){
                            print(popupLocations[index][0]);
                            print(popupLocations[index][1]);
                            print(popupLocations[index][2]);
                            print(popupLocations[index][3]);
                            print(popupLocations[index][4]);
                            print(popupLocations[index][5]);
                            print("popupLocations[index][3]");
                            _onAlertForAbsent(popupLocations[index][3],popupLocations[index][1],popupLocations[index][2],popupLocations[index][4],popupLocations[index][5],popupLocations[index][6].toString());
                          },      //ontapstart
                        );
                      },


                    ),
                  ),
                  SizedBox(height: 20.0,),
                  Divider(color: Colors.black,height: 3.0,),
                  /* Container(
                      color: appcolor.withOpacity(0.15),
                      child:Column(
                        children: <Widget>[
                          Center(
                              child:FlatButton(child:Text("Cancel"),onPressed: (){
                                controller.close();
                              },)
                          )
                        ],
                      )
                  )*/

                ],
              ));
        });

  }



  loader() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset(
                  'assets/spinner.gif', height: 50.0, width: 50.0),
            ]),
      ),
    );
  }

  _onAlertForAbsent(Name , lat, long, profile,location,time) {
    print(Name);
    print(profile);
    print(time);
    print(location);
    print("otyherggiug");
    var Loaded = false;
    var image = NetworkImage(profile);
    image.resolve(new ImageConfiguration()).addListener(
        new ImageStreamListener((_, __) {
          if (mounted) {
            setState(() {
              Loaded = true;
            });
          }
        }));

    if ((Name.trim()).contains(" ")) {
      var name = Name.split(" ");
      print('print(name);');
      print(name);
      First = name[0][0].trim();
      print(First);
      Last = name[1][0].trim().toString().toUpperCase();
      print(Last);
      initials = First + Last;
      print(initials);
      print("initials ");
    } else {
      First = Name.toString().substring(0,1);
      print('print(First)else');
      print(First);
      initials = First;
      print(initials);
    }

    return showDialog<String>(
      context: context,
      // ignore: deprecated_member_use
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.all(15.0),
        content: Wrap(
          children: <Widget>[
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.28,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.70,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .end,
                    children: <Widget>[
                      InkWell(
                        highlightColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        child:
                        Row(
                          children: <Widget>[
                          ],
                        ),
                        onTap: () {
//                                         Navigator.pop(context);
                          Navigator.of(
                              context, rootNavigator: true)
                              .pop('dialog');
                        },
                      ),
                    ],
                  ),
                  InkWell(
                    child: new Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .height * .075,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * .075,
                      decoration: new BoxDecoration(
                        border: Border.all(
                            width: 2,
                            color: Colors
                                .blue //                   <--- border width here
                        ),
                        color: Colors.black,
                        shape: BoxShape.circle,
                        /*  boxShadow: <BoxShadow>[
                            new BoxShadow(
                              color: appcolor,
                              blurRadius: 10.0,
                              // offset: new Offset(0.0, 10.0),
                              spreadRadius: 2.0,
                            ),
                          ],*/
                        /*image: new DecorationImage(
                        fit: BoxFit.fill,
                           // image: NetworkImage(profile),
                            image: NetworkImage(profile),
                          ),*/
                      ),
                      // width: MediaQuery.of(context).size.width*0.30,
                      child: Loaded ? ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'l',
                          fit: BoxFit.fill,
                          image: profile,
                        ),
                      ) : CircleAvatar(
                        child: Text(initials, style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  new Text(
                    Name,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  SizedBox(height: 8,),
                  new Text(
                    time,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  SizedBox(height: 8,),
                  new Text(
                    "At: " + location,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600
                    ),
                  ),


                ],),

            ),
          ],
        ),
      ),
    );
  }

  _onSelected(int index) {

    setState(() {
      _selectedIndex = index;
    });
    // setState(() => _selectedIndex = index);
  }


  void _changeOpacity() {

    setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);

  }

  void _changeOpacity1() {
    setState(() => opacityLevel1 = opacityLevel1 == 0 ? 1.0 : 0.0);
  }



  _myLeave(){
    print("xyz123");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyLeave()),
    );
  }
  _settings(){

    print("xyz123");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Settings()),
    );
  }
  _addEmployee(){

    if (((globals.registeruser) >=
        (globals.userlimit + 5)) &&
        buysts != '0')
      showDialogWidget(
          "You have registered 5 users more than your User limit. Kindly pay for the Additional Users or delete the Inactive users");
    else
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddEmployee()),
      );
  }


  _reports(){
    print("xyz123");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Reports()),
    );
  }

  _logs(){
    print("xyz123");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => userShiftCalendar()),
    );
  }

  _shiftsCalendar(){
    print("xyz123");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => userViewShiftPlanner()),
    );
  }
  _visitPunch(){
    print("xyz123");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PunchLocationSummary()),
    );
  }

  void _showSnackBar (BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1000),
        )
    );
  }

  var iiio=0;
  void onMapCreated(GoogleMapController controller) async{

    var prefs = await SharedPreferences.getInstance();
    orgid = prefs.getString('orgid') ?? '';
    print(admin_sts);
    print("admin_sts isssssss");
    controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    setMapPins();
    setPolylines();
    controller2.complete(controller);
    var userFlag=false;
    String todayDate = DateTime.now().toString().split(".")[0].split(" ")[0];

    if(admin_sts == '1' || admin_sts == '2') {
print("inside admnnnnnn");
      var p=97;
      var ii=0;
      var lastCurrentLocation;
      int markerPoint = 0;
      List TimeInOutLocations = new List();
      final Uint8List TimeInMapIcon = await getBytesFromAsset('assets/TimeInMapIcon.png', 140);
      final Uint8List currentLocationPinMapIcon = await getBytesFromAsset('assets/mapPinPointMarker.png', 140);
      final Uint8List fakeLocation = await getBytesFromAsset('assets/fakeLocation.png', 140);
      int ID = 1;
      setLoader = false;

      getAttendance(todayDate).then((res) async {
        attList = res;

        if(attList.isEmpty){
          print("list response is empty");
          return;
        }

        for(int i = 0; i<attList.length;i++ ) {

          Name.add([attList[i].EmployeeId.toString()]);
          print("names are");
          print(Name);
          NameList.add(("(" + attList[i].EmployeeId.toString() + ") "+attList[i].name.toString()));
          print(NameList);
          print("gvjkgkghkj");

        }

/*
        updates = await FirebaseDatabase.instance.reference().child("Locations").child(orgid).child(attList[0].EmployeeId.toString()).child(todayDate).onChildAdded
            .listen((data) async {

          var currentLoc=  Locations.fromFireBase(data.snapshot);
          childExist=true;
          setLoader = true;

          if(currentLoc.mock == "true") {  //if user uses mock locations

            ID++;
            var m1=Marker(
              markerId: MarkerId('fakeLocation$ID'),
              position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
              // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
              icon:BitmapDescriptor.fromBytes(fakeLocation),

              infoWindow: InfoWindow(
                  title: "Fake location found: ",
                  snippet: "         "+data.snapshot.key
                // anchor: Offset(0.1, 0.1)
              ),
            );
            Future.delayed(Duration(seconds: 1),() {
              setState(() {
                _markers.add(m1);
                //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
              });
            });
          }

          TimeInOutLocations.add([currentLoc.latitude,currentLoc.longitude,data.snapshot.key]);

          var firstLocation = TimeInOutLocations[0];
          //timeIn location
          if(TimeInOutLocations.length>1){
            lastCurrentLocation = TimeInOutLocations[TimeInOutLocations.length - 1];

            var m1=Marker(
              markerId: MarkerId('sourcePinCurrentLocationIcon'),
              position: LatLng(double.parse(lastCurrentLocation[0]),double.parse(lastCurrentLocation[1])),
              // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
              icon:BitmapDescriptor.fromBytes(currentLocationPinMapIcon),

              infoWindow: InfoWindow(
                title: "Last known location: "+data.snapshot.key,
              ),
            );
            Future.delayed(Duration(seconds: 1),(){
              setState(() {
                _markers.add(m1);
                setLoader = true;
                //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
              });
            });
          }
          var m=Marker(
            markerId: MarkerId('sourcePinTimeInIcon'),
            position: LatLng(double.parse(firstLocation[0]),double.parse(firstLocation[1])),
            // icon: await getMarkerIconForTimeIn("https://cdn0.iconfinder.com/data/icons/map-and-navigation-2-1/48/100-512.png", Size(150.0, 250.0),0),
            icon: BitmapDescriptor.fromBytes(TimeInMapIcon),
            // icon:pinLocationIcon,
            infoWindow: InfoWindow(
              title: "Start Time: "+firstLocation[2],
            ),
          );
          Future.delayed(Duration(seconds: 1),(){
            setState(() {
              _markers.add(m);
              //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
            });
          });




          //  setState(() {
          // create a Polyline instance
          // with an id, an RGB color and the list of LatLng pairs
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 0,
              target: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
              zoom: 13.0,
            ),
          ));

          end= double.parse(currentLoc.odometer);
          print(latlng.toString());

          // if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy)<20.0) ) {
          if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy) < 20.0)) {

            start=end;
            p++;
            //print("shashankmmmmmmmmmm"+(end-start>200.0).toString());
            //add position number marker
            // Future.delayed(Duration(seconds: 2),(){
            markerPoint++;

            getMarkerNew(markerPoint,double.parse(currentLoc.latitude),double.parse(currentLoc.longitude),data.snapshot.key);

            setState(() {

              if(ii==0) {
                startM=double.parse(currentLoc.odometer);
                print("current loc odo"+startM.toString());
              }

              endM=double.parse(currentLoc.odometer);
              print("end loc odo"+startM.toString());

              kms=((endM-startM)/1000).toStringAsFixed(2)+" kms";
              print("sgksshhskhs   "+kms);
              // if(endM-startM<0)
              //  kms='0.0';
            });
            //});

            ii++;
            /* var m=Marker(
          markerId: MarkerId('sourcePin$p'),
          position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
          //icon: await getMarkerIcon("https://i.dlpng.com/static/png/6865249_preview.png", Size(150.0, 150.0),0),
          icon:BitmapDescriptor.fromBytes(markerIcon),

          infoWindow: InfoWindow(
            title: data.snapshot.key,
          ),
        );
        Future.delayed(Duration(seconds: 1),(){
          setState(() {
            _markers.add(m);
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });*/
          }

          print(currentLoc.accuracy);
          print("currentLoc.accuracy");



          setState(() {
            // if(double.parse(currentLoc.accuracy)<20.0)           //07oct
            //   {
            latlng.add(LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)));
            //  print(latlng);
            // print("latlong iss");
            _polylines.add(Polyline(
              polylineId: PolylineId('1'),
              visible: true,
              width: 3,
              patterns:  <PatternItem>[PatternItem.dash(20), PatternItem.gap(10)] ,
              //latlng is List<LatLng>
              points: latlng,
              color: Colors.blue,
            ));
            // }
          });

        });
        */




        var date11 = new DateTime.now().toString();

        var dateParse = DateTime.parse(date11);
        var prefs1=await SharedPreferences.getInstance();
        var orgid222=prefs1.get("orgid");

        var formattedDate = "${dateParse.day.toString().padLeft(2, '0')}-${dateParse.month.toString().padLeft(2, '0')}-${dateParse.year}";

        var date222 = formattedDate.toString() ;
        print("locations/$orgid222/${attList[0].EmployeeId.toString()}/$todayDate/latest");
        CollectionReference _documentRef=Firestore.instance.collection('locations/$orgid222/${attList[0].EmployeeId.toString()}/$date222/latest');

        // _documentRef.getDocuments().then((ds){





        _documentRef.getDocuments().then((ds){

          if(ds!=null){

            print("hjsghsgsj"+ds.documents.toString());
            var aaa=ds.documents;

            //// Sorting the locations from firestore
            aaa.sort((a, b) {


              return a.data["location"]["timestamp"].toString().toLowerCase().compareTo(b.data["location"]["timestamp"].toString().toLowerCase());
            });

            print("shhsjhskhsk"+aaa.toString());



            for(var value in aaa) {  //// Iterating Locations
              print(
                  "From firestore..........................................>>>>");

              print(value.data["location"]["timestamp"]);
              print(
                  "From firestore..........................................>>>>"+(aaa.length-1).toString());


              var change1 = new Map<String, dynamic>.from(value.data);

              if (aaa.length > 0) {
                var lastLoc,firstLoc;
                var change11 = new Map<String, dynamic>.from(aaa[0].data);
                firstLoc = Locations.fromFireStore(change11);
                print(firstLoc.latitude.toString()+"first loc lat");

                var m = Marker(
                  markerId: MarkerId('sourcePinTimeInIcon'),
                  position: LatLng(double.parse(firstLoc.latitude),
                      double.parse(firstLoc.longitude)),
                  // icon: await getMarkerIconForTimeIn("https://cdn0.iconfinder.com/data/icons/map-and-navigation-2-1/48/100-512.png", Size(150.0, 250.0),0),
                  icon: BitmapDescriptor.fromBytes(TimeInMapIcon),
                  // icon:pinLocationIcon,
                  infoWindow: InfoWindow(
                    title: "Start Time: " + firstLoc.time.toString(),
                  ),
                );
                Future.delayed(Duration(seconds: 1), () {
                  setState(() {
                    _markers.add(m);
                    //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
                  });
                });

                var change111 = new Map<String, dynamic>.from(aaa[aaa.length-1].data);
                lastLoc = Locations.fromFireStore(change111);
                print(lastLoc.latitude.toString()+"last loc lat");

                var m1 = Marker(
                  markerId: MarkerId('sourcePinCurrentLocationIcon'),
                  position: LatLng(double.parse(lastLoc.latitude),
                      double.parse(lastLoc.longitude)),
                  // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
                  icon: BitmapDescriptor.fromBytes(currentLocationPinMapIcon),

                  infoWindow: InfoWindow(
                    title: "Last known location: ",
                  ),
                );
                Future.delayed(Duration(seconds: 1), () {
                  setState(() {
                    _markers.add(m1);
                    setLoader = true;
                    //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
                  });
                });
              }

              print('hjjghgjgjgjhgj' +iiio.toString()+ change1['location']["coords"]["latitude"].toString());
              var currentLoc = Locations.fromFireStore(change1);
              childExist = true;
              setLoader = true;
              ///// Creating marker for fake locations
              if (currentLoc.mock == "true") { //if user uses mock locations

                ID++;
                var m1 = Marker(
                  markerId: MarkerId('fakeLocation$ID'),
                  position: LatLng(double.parse(currentLoc.latitude),
                      double.parse(currentLoc.longitude)),
                  // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
                  icon: BitmapDescriptor.fromBytes(fakeLocation),

                  infoWindow: InfoWindow(
                      title: "Fake location found: ",
                      snippet: "         " + currentLoc.time
                    // anchor: Offset(0.1, 0.1)
                  ),
                );
                Future.delayed(Duration(seconds: 1), () {
                  setState(() {
                    _markers.add(m1);
                    //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
                  });
                });
              }


              //timeIn location

              //////// Marker for last known location  //////////////////


              ///////////////// Marker from where location tracking starts //////////////////////




              //  setState(() {
              // create a Polyline instance
              // with an id, an RGB color and the list of LatLng pairs


              controller.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                  bearing: 0,
                  target: LatLng(double.parse(currentLoc.latitude),
                      double.parse(currentLoc.longitude)),
                  zoom: 26.0,
                ),
              ));

              //// Markers after 200 mtrs

              end = double.parse(currentLoc.odometer);
              print(latlng.toString());

              // if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy)<20.0) ) {
              if (((end - start) > 200.0) && (double.parse(currentLoc.accuracy) < 20.0)) {
                start = end;
                p++;
                //print("shashankmmmmmmmmmm"+(end-start>200.0).toString());
                //add position number marker
                // Future.delayed(Duration(seconds: 2),(){
                markerPoint++;

                getMarkerNew(markerPoint, double.parse(currentLoc.latitude),
                    double.parse(currentLoc.longitude), currentLoc.time);

                setState(() {
                  if (ii == 0) {
                    startM = double.parse(currentLoc.odometer);
                    print("current loc odo" + startM.toString());
                  }

                  endM = double.parse(currentLoc.odometer);
                  print("end loc odo" + startM.toString());

                  kms = ((endM - startM) / 1000).toStringAsFixed(2) + " kms";
                  print("sgksshhskhs   " + kms);
                  // if(endM-startM<0)
                  //  kms='0.0';
                });
                //});

                ii++;




                /* var m=Marker(
          markerId: MarkerId('sourcePin$p'),
          position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
          //icon: await getMarkerIcon("https://i.dlpng.com/static/png/6865249_preview.png", Size(150.0, 150.0),0),
          icon:BitmapDescriptor.fromBytes(markerIcon),

          infoWindow: InfoWindow(
            title: data.snapshot.key,
          ),
        );
        Future.delayed(Duration(seconds: 1),(){
          setState(() {
            _markers.add(m);
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });*/




              }

              print(currentLoc.accuracy);
              print("currentLoc.accuracy");

              //////     Code for polylines        ////////////////
              setState(() {
                if(double.parse(currentLoc.accuracy)<20.0)           //07oct
                 {
                latlng.add(LatLng(double.parse(currentLoc.latitude),
                    double.parse(currentLoc.longitude)));
                //  print(latlng);
                // print("latlong iss");
                _polylines.add(Polyline(
                  polylineId: PolylineId('1'),
                  visible: true,
                  width: 3,
                  patterns: <PatternItem>[
                    PatternItem.dash(20),
                    PatternItem.gap(10)
                  ],
                  //latlng is List<LatLng>
                  points: latlng,
                  color: Colors.blue,
                ));
                }
              });
             }
            }
        });
        ////////////////// Visit Markers //////////////
        var date=DateTime.now().toString().split(".")[0].split(" ")[0];
        var visits =  await  getVisitsDataList(date.toString(),attList[0].EmployeeId.toString());
        print("aaa");
        var generatedIcon;
        List<BitmapDescriptor> generatedIcons=new List<BitmapDescriptor>();
        var j=visits.length;
        print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj"+j.toString());
        if(j>0)
          await Future.forEach(visits, (Punch visit) async {

            print("marker added............");
            var m=Marker(
              markerId: MarkerId('sourcePin$j'),
              position: LatLng(double.parse(visit.pi_latit),double.parse(visit.pi_longi)),
              icon: await getMarkerIconNew("https://i.dlpng.com/static/png/6865249_preview.png", Size(140.0, 140.0),j),
              onTap: () {
                setState(() {
                  currentlySelectedPin = PinInformation(pinPath: 'assets/friend1.jpg', avatarPath: visit.pi_img, location: LatLng(0, 0), client: visit.client,description: visit.desc,in_time: visit.pi_time,out_time: visit.po_time, labelColor: Colors.grey);
                  pinPillPosition = 100;
                });
                print(visit.po_time);

              },

              infoWindow: InfoWindow(
                  title: visit.client,
                  snippet:visit.desc
              ),
            );
            Future.delayed(Duration(seconds: 1),(){
              setState(() {
                _markers.add(m);
                //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
              });
            });

            j--;
          });
      });
    }

    Future.delayed(Duration(seconds: 3), () async {

      if(childExist == false){
        _markers1.clear();
        var j=0;
        j++;


        print("inside childExist");
        print(empid);
        setLoader = false;

        _markers.clear();
        latlng.clear();
        _polylines.clear();
        print(childExist);
        var p=97;
        var ii=0;
        var lastCurrentLocation;
        int markerPoint = 0;
        List TimeInOutLocations = new List();
        final Uint8List TimeInMapIcon = await getBytesFromAsset('assets/TimeInMapIcon.png', 140);
        final Uint8List currentLocationPinMapIcon = await getBytesFromAsset('assets/mapPinPointMarker.png', 140);
        final Uint8List fakeLocation = await getBytesFromAsset('assets/fakeLocation.png', 140);
        int ID = 1;
        setLoader = false;
        var date11 = new DateTime.now().toString();

        var dateParse = DateTime.parse(date11);
        var prefs1=await SharedPreferences.getInstance();
        var orgid222=prefs1.get("orgid");
        var empIds=prefs1.get("empid");

        var formattedDate = "${dateParse.day.toString().padLeft(2, '0')}-${dateParse.month.toString().padLeft(2, '0')}-${dateParse.year}";

        var date222 = formattedDate.toString() ;





        CollectionReference _documentRef=Firestore.instance.collection('locations/$orgid222/${empIds}/$date222/latest');

        // _documentRef.getDocuments().then((ds){
        _documentRef.getDocuments().then((ds){

          if(ds!=null){

            print("hjsghsgsj"+ds.documents.toString());
            var aaa=ds.documents;

            //// Sorting the locations from firestore
            aaa.sort((a, b) {


              return a.data["location"]["timestamp"].toString().toLowerCase().compareTo(b.data["location"]["timestamp"].toString().toLowerCase());
            });


            for(var value in aaa) {  //// Iterating Locations
              print(
                  "From firestore..........................................>>>>");

              print(value.data["location"]["timestamp"]);
              print(
                  "From firestore..........................................>>>>");


              var change1 = new Map<String, dynamic>.from(value.data);
              print('hjjghgjgjgjhgj' +
                  change1['location']["activity"]["confidence"].toString());
              var currentLoc = Locations.fromFireStore(change1);

              print(currentLoc.latitude.toString());
              print('ddebug');

          if(currentLoc.mock == "true") {  //if user uses mock locations

            ID++;
            var m1=Marker(
              markerId: MarkerId('userLocation$ID'),
              position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
              // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
              icon:BitmapDescriptor.fromBytes(fakeLocation),

              infoWindow: InfoWindow(
                  title: "Fake location found: ",
                  snippet: "         "+currentLoc.time
                // anchor: Offset(0.1, 0.1)
              ),
            );
            Future.delayed(Duration(seconds: 1),() {
              setState(() {
                _markers1.add(m1);
                //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
              });
            });
          }




              //var change1 = new Map<String, dynamic>.from(value.data);
              var lastLoc,firstLoc;
              if (aaa.length > 0) {
                print("insiiiide");
                var change11 = new Map<String, dynamic>.from(aaa[0].data);
                firstLoc = Locations.fromFireStore(change11);
                print(firstLoc.latitude.toString()+"first loc lat1");

                var m = Marker(
                  markerId: MarkerId('sourcePinTimeInIcon100'),
                  position: LatLng(double.parse(firstLoc.latitude),
                      double.parse(firstLoc.longitude)),
                  // icon: await getMarkerIconForTimeIn("https://cdn0.iconfinder.com/data/icons/map-and-navigation-2-1/48/100-512.png", Size(150.0, 250.0),0),
                  icon: BitmapDescriptor.fromBytes(TimeInMapIcon),
                  // icon:pinLocationIcon,
                  infoWindow: InfoWindow(
                    title: "Start Time: " + firstLoc.time.toString(),
                  ),
                );
                Future.delayed(Duration(seconds: 1), () {
                  setState(() {
                    _markers1.add(m);
                    //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
                  });
                });

                var change111 = new Map<String, dynamic>.from(aaa[aaa.length-1].data);
                lastLoc = Locations.fromFireStore(change111);
                print(lastLoc.latitude.toString()+"last loc lat1");

                var m1 = Marker(
                  markerId: MarkerId('sourcePinCurrentLocationIcon100'),
                  position: LatLng(double.parse(lastLoc.latitude),
                      double.parse(lastLoc.longitude)),
                  // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
                  icon: BitmapDescriptor.fromBytes(currentLocationPinMapIcon),

                  infoWindow: InfoWindow(
                    title: "Last known location: ",
                  ),
                );
                Future.delayed(Duration(seconds: 1), () {
                  setState(() {
                    _markers1.add(m1);
                    setLoader = true;
                    //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
                  });
                });
              }




          //  setState(() {
          // create a Polyline instance
          // with an id, an RGB color and the list of LatLng pairs
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 0,
              target: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
              zoom: 26,
            ),
          ));

          end= double.parse(currentLoc.odometer);
          print(latlng.toString());

          // if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy)<20.0) ) {
          if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy) < 20.0)) {

            start=end;
            p++;
            //print("shashankmmmmmmmmmm"+(end-start>200.0).toString());
            //add position number marker
            // Future.delayed(Duration(seconds: 2),(){
            markerPoint++;

            getMarkerNew(markerPoint,double.parse(currentLoc.latitude),double.parse(currentLoc.longitude),currentLoc.time);

            setState(() {

              if(ii==0) {
                startM=double.parse(currentLoc.odometer);
                print("current loc odo"+startM.toString());
              }

              endM=double.parse(currentLoc.odometer);
              print("end loc odo"+startM.toString());

              kms=((endM-startM)/1000).toStringAsFixed(2)+" kms";
              print("sgksshhskhs   "+kms);
              // if(endM-startM<0)
              //  kms='0.0';
            });
            //});

            ii++;
            /* var m=Marker(
          markerId: MarkerId('sourcePin$p'),
          position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
          //icon: await getMarkerIcon("https://i.dlpng.com/static/png/6865249_preview.png", Size(150.0, 150.0),0),
          icon:BitmapDescriptor.fromBytes(markerIcon),

          infoWindow: InfoWindow(
            title: data.snapshot.key,
          ),
        );
        Future.delayed(Duration(seconds: 1),(){
          setState(() {
            _markers.add(m);
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });*/
          }

          print(currentLoc.accuracy);
          print("currentLoc.accuracy");



          setState(() {
            // if(double.parse(currentLoc.accuracy)<20.0)           //07oct
            //   {
            latlng.add(LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)));
            //  print(latlng);
            // print("latlong iss");
            _polylines.add(Polyline(
              polylineId: PolylineId(currentLoc.latitude),
              visible: true,
              width: 3,
              patterns:  <PatternItem>[PatternItem.dash(20), PatternItem.gap(10)] ,
              //latlng is List<LatLng>
              points: latlng,
              color: Colors.blue,
            ));
            // }
          });

            };
          }
        });

        if(userFlag==false){
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 0,
              target: LatLng(double.parse(globals.assign_lat.toString()), double.parse(globals.assign_long.toString())),
              zoom: 26,
            ),
          ));

          var m=Marker(
            markerId: MarkerId('sourcePinTimeInIconUserLocation1'+globals.assign_lat.toString()),
            position: LatLng(double.parse(globals.assign_lat.toString()), double.parse(globals.assign_long.toString())),
            // icon: await getMarkerIconForTimeIn("https://cdn0.iconfinder.com/data/icons/map-and-navigation-2-1/48/100-512.png", Size(150.0, 250.0),0),
            icon: BitmapDescriptor.defaultMarker,
            // icon:pinLocationIcon,
            infoWindow: InfoWindow(
              title: "You are here",
            ),
          );
          Future.delayed(Duration(seconds: 1),(){
            setState(() {
              _markers1.add(m);
              //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
            });
          });
        }

      }


    });
  }

  showDialogWidget(String loginstr) {
    return showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
              title: new Text(
              loginstr,
              style: TextStyle(fontSize: 15.0),
            ),
            content: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Text('Later', style: TextStyle(fontSize: 13.0)),
                  shape: Border.all(),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
                RaisedButton(
                  child: Text(
                    'Pay Now',
                    style: TextStyle(color: Colors.white, fontSize: 13.0),
                  ),
                  color: Colors.orangeAccent,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PaymentPage()),
                    );
                  },
                ),
              ],
            ),
          );
        });
  }

  void setMapPins() {
    setState(() {
      // source pin
      _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: SOURCE_LOCATION,
        icon: sourceIcon,
        /*  infoWindow: InfoWindow(
        title: 'I am a marker',
          snippet:'hbhs hsvgvs cshgfhgsf gschgfs sfhsfh gsfhfshfsh hgsfhfsfs '
      ),*/
      ));
      // destination pin
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: DEST_LOCATION,
          icon: destinationIcon));
    });
  }

  setPolylines() async {

    // latlng.add(_new);
    // latlng.add(_news);
    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      _polylines.add(Polyline(
        polylineId: PolylineId("1"),
        visible: true,
        //latlng is List<LatLng>
        points: latlng,
        color: Colors.blue,
      ));
    });

  }



  //<-----------------------------------------------------------while merging------------------------------------------------> //

  getMarkAttendanceWidgit() {
    if (act1 == "Imposed") {
      return getAlreadyMarkedWidgit();
    } else {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            /* Text('Mark Attendance',
                style: new TextStyle(fontSize: 30.0, color: Colors.teal)),
            SizedBox(height: 10.0),*/
            getwidget(globals.globalstreamlocationaddr),
            //    SizedBox(height: MediaQuery.of(context).size.height*.1),
            /*      Container(
            //foregroundDecoration: BoxDecoration(color:Colors.green ),
            margin: EdgeInsets.only(bottom:MediaQuery.of(context).size.height*0),
            //padding: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.02,bottom:MediaQuery.of(context).size.height*0.02),
              height: MediaQuery.of(context).size.height*.10,
              color: Colors.teal.withOpacity(0.8),
              child: Column(
                  children:[
                    SizedBox(height: 10.0,),
                    getQuickLinksWidget()
                  ]),
            ),
         */
          ]);
    }
  }

  getwidget(String addrloc) {
    if (addrloc != "Location could not be fetched.") {

      return  AnimatedOpacity(
        opacity: opacityLevel,
        duration: Duration(milliseconds: 500),
        curve: Curves.linear,
        child: new Container(
          //margin: new EdgeInsets.symmetric(vertical: 55.0),
          height: selected!=false?MediaQuery.of(context).size.height * .30:1,
          // height: 160,
          //  width: 350,
          width: selected!=false?350:1,
          child: Container(
            padding: new EdgeInsets.fromLTRB(60.0, 10.0, 16.0, 5.0),
            //constraints: new BoxConstraints.expand(),
            child: new Column(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,   //to align from start
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(height: 3.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(fname, style: TextStyle(fontSize: 22,color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                    new InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            const IconData(0xe81a,
                                fontFamily: "CustomIcon"),
                            size: 18.0,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      onTap: () {

                        cameraChannel
                            .invokeMethod("startAssistant");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage()),
                        );
                      },
                    )
                  ],
                ),
                new Container(height: 6.0),
                InkWell(
                  child: Container(
                    child: globals.globalstreamlocationaddr.length > 97? new Text( globals.globalstreamlocationaddr != null
                        ? 'You are at: '+globals.globalstreamlocationaddr.substring(0,97)+".."
                        : "Location could not be fetched",
                      style: TextStyle(fontSize: 14,color: Colors.white),)

                        :new Text( globals.globalstreamlocationaddr != null
                        ? 'You are at: '+globals.globalstreamlocationaddr
                        : "Location could not be fetched",
                      style: TextStyle(fontSize: 14,color: Colors.white),),
                  ),
                  onTap: () {
                    launchMap(globals.assign_lat.toString(),
                        globals.assign_long.toString());
                    /* Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );*/
                  },
                ),
                if (fakeLocationDetected)
                  Container(
                    padding: EdgeInsets.only(top: 5.0, right: 28),
                    //  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Text(
                      ' Fake Location ',
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          backgroundColor: Colors.red[300],
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0),
                    ),
                  )
                else
                  (areaId != 0 && geoFence == 1)
                      ? areaSts == '0'
                      ? Container(
                    padding: EdgeInsets.only(top: 5.0, right: 28.0),
                    child: Text(
                      ' Outside Geofence ',
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          backgroundColor: Colors.red[300],
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0),
                    ),
                  )
                      : Container(
                    padding: EdgeInsets.only(top: 5.0, right: 28),
                    //  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Text(
                      ' Within Geofence ',
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          backgroundColor: Colors.green[300],
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0),
                    ),
                  )
                      : Center(),

                Container(

                  padding: EdgeInsets.only(right: 28,top: 5),
                  child:  getTimeInOutButton(),

                  /*new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RaisedButton(
                        color: buttoncolor,
                        elevation: 0.0,
                        disabledElevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Text('TIME IN',
                            style: new TextStyle(
                                fontSize: 18.0, color: Colors.white, letterSpacing: 2)),
                        onPressed: () {

                          getTimeInOutButton();

                        },
                      )

                    ],
                  ),*/
                )
              ],
            ),
          ),


          margin: new EdgeInsets.only(left: 46.0,top: 10,right: 25),
          decoration: new BoxDecoration(
            color: Colors.blue[300],
            shape: BoxShape.rectangle,
            boxShadow: <BoxShadow>[
              new BoxShadow(
                color: Colors.black12,
                blurRadius: 10.0,
                offset: new Offset(0.0, 10.0),
              ),
            ],
            borderRadius: new BorderRadius.circular(8.0),
          ),
        ),
      );
    } else {
      return Column(children: [
        Text('Kindly refresh the page to fetch the location',
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: 14.0, color: Colors.red)),
        RaisedButton(
          child: Text('Refresh'),
          color: globals.buttoncolor,
          onPressed: () {
            cameraChannel.invokeMethod("startAssistant");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ]);
    }
  }

  getTimeInOutButton() {

    if (act1 == 'TimeIn') {
      return  Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          RaisedButton(
            color: buttoncolor,
            elevation: 0.0,
            disabledElevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Text('TIME IN',
                style: new TextStyle(
                    fontSize: 18.0, color: Colors.white, letterSpacing: 2)),
            //  onPressed: () {

            onPressed: () async {
              globals.globalCameraOpenedStatus = true;
              // if(changepasswordStatus == '0' || changepasswordStatus == '')
              //saveImage();
              print('covidfirst'+covid_first);
              print('covidfirst'+covid_second);
              print('covidfirst'+covidsurvey.toString());

              if(covid_first=='1' && globals.covidsurvey==1)
              {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Every7dayscovidsurvey()), (Route<dynamic> route) => true,
                );
              }
              else if(covid_second=='1'  && globals.covidsurvey==1)
              {

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Covid19serve()), (Route<dynamic> route) => true,
                );

              }
              else{
                saveImage();
              }
              //Navigator.pushNamed(context, '/home');
            },
            // },
          )

        ],
      );
    } else if (act1 == 'TimeOut') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          RaisedButton(
            color: buttoncolor,
            elevation: 0.0,
            disabledElevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Text('TIME OUT',
                style: new TextStyle(
                    fontSize: 18.0, color: Colors.white, letterSpacing: 2)),
            //  onPressed: () {

            onPressed: () async {
              globals.globalCameraOpenedStatus = true;
              // //print("Time out button pressed");
              saveImage();
            },
            // },
          )
        ],
      );
      /*RaisedButton(
        clipBehavior: Clip.antiAlias,
        elevation: 0.0,
        highlightElevation: 0.0,
        highlightColor: Colors.transparent,
        disabledElevation: 50.0,
        focusColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
//          side: BorderSide( color: Colors.red.withOpacity(0.5), width: 2,),
        ),
        child: Text('TIME OUT',
            style: new TextStyle(
                fontSize: 18.0, color: Colors.white, letterSpacing: 2)),
        color: globals.buttoncolor,
        onPressed: () async {
          globals.globalCameraOpenedStatus = true;
          // //print("Time out button pressed");
          saveImage();
        },
      );*/
    }
  }

  launchMap(String lat, String long) async {
    String url = "https://maps.google.com/?q=" + lat + "," + long;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      //print('Could not launch $url');
    }
  }

  void startLiveLocationTracking()async {

    HomeViewState tracker=HomeViewState();
    tracker.initState();
    await tracker.onClickMenu();
    tracker.onClickEnable(true);
    tracker.onClickChangePace();
    //tracker.onEnabledChange(true);

  }

  void stopLiveLocationTracking() {

    HomeViewState tracker=HomeViewState();
    tracker.initState();
    tracker.onClickEnable(false);
    //tracker.onClickChangePace();
    //tracker.onEnabledChange(true);
  }



  saveImage() async {

    final prefs = await SharedPreferences.getInstance();

    var firstTimeIn = prefs.getInt("firstTimein" )??0;
    firstTimeIn++;
    prefs.setInt("firstTimein", firstTimeIn);
    timeWhenButtonPressed = DateTime.now();
    //  sl.startStreaming(5);
    print('aidId' + aid);
    var FakeLocationStatus = 0;

    //startLiveLocationTracking();
    /*  if(areaStatus == '0'){
      geofence="Outside Fenced Area";
    }else{
      geofence="Within Fenced Area";
    }*/

    if(globals.geoFence==1) {
      if (areaSts == '0') {
        if(areaId==0 || areaId.toString()==""){
          geofence = "";
        }else{
          geofence = "Outside Geofence";
        }

        print('thisisgeofencefortesting123---->>>>'+geofence);
        print('thisisabletomarkatt---->>>>'+ableToMarkAttendance.toString());

        if(ableToMarkAttendance==1 || fencearea==1) {
          print('thisisgeofencefortesting456---->>>>'+geofence);
          await showDialog(
              context: context,
              // ignore: deprecated_member_use
              child: new AlertDialog(
                //title: new Text("Warning!"),
                content: new Text(
                    "You Can't punch Attendance Outside Geofence."),
              ));
          return null;
        }

      } else {
        geofence = "Within Geofence";
        print('thisisgeofencefortesting789---->>>>'+geofence);
      }
    }

    if(globals.departmentid==1||globals.departmentid==0){
      await showDialog(
          context: context,
          // ignore: deprecated_member_use
          child: new AlertDialog(
            //title: new Text("Warning!"),
            content: new Text("Department has not been assigned"),
          ));
      return null;
    }
    if(globals.designationid==0){
      await showDialog(
          context: context,
          // ignore: deprecated_member_use
          child: new AlertDialog(
            //title: new Text("Warning!"),
            content: new Text("Designation has not been assigned"),
          ));
      return null;
    }
    print("ssssssssssssssssshift"+shiftId.toString());
    if(globals.shiftId==''||globals.shiftId==null||globals.shiftId=='0'){
      await showDialog(
          context: context,
          // ignore: deprecated_member_use
          child: new AlertDialog(
            //title: new Text("Warning!"),
            content: new Text("Shift has not been assigned"),
          ));
      return null;
    }


    if (AbleTomarkAttendance != '1' &&
        globals.ableToMarkAttendance == 1 &&
        geoFence == 1) {
      await showDialog(
          context: context,
          // ignore: deprecated_member_use
          child: new AlertDialog(
            //title: new Text("Warning!"),
            content: new Text("You Can't punch Attendance from Outside Geofence"),
          ));
      return null;
    }

    if (fakeLocationDetected) {
      FakeLocationStatus = 1;
    }
    MarkTime mk = new MarkTime(
        empid,
        globals.globalstreamlocationaddr,
        aid,
        act1,
        shiftId,
        orgdir,
        globals.assign_lat.toString(),
        assign_long.toString(),
        FakeLocationStatus,
        globalcity);

    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraExampleHome()),
      );*/
      SaveImage saveImage = new SaveImage();
      Map issave;
      var prefs = await SharedPreferences.getInstance();
      globals.showAppInbuiltCamera =
          prefs.getBool("showAppInbuiltCamera") ?? true;
      issave = globals.showAppInbuiltCamera
          ? await saveImage.saveTimeInOutImagePickerAppCamera(mk, context)
          : await saveImage.saveTimeInOutImagePicker(mk, context);
      print(issave);
      if (issave['status'] == 3) {
        globals.timeWhenButtonPressed = null;
        showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              title: new Text(""),
              content: new Text(
                  "Sorry you have taken more time than expected to mark attendance. Please mark again!"),
            ));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }

      if (issave['status'] == 1 || issave['status']==2) {
        // Sync image
        saveImage.SendTempimage(context , true);
        if(act1=='TimeIn'){
          if(locationTrackingAddon=='1'){
            startLiveLocationTracking();
          }

          print("This is time in block " + act1);
          var prefs = await SharedPreferences.getInstance();

          String InPushNotificationStatus =
              await prefs.getString("InPushNotificationStatus") ?? '0';
          var empId = prefs.getString('empid') ?? '';
          var orgId = prefs.getString("orgid") ?? '';
          var eName = prefs.getString('fname') ?? 'User';
          var formatter = new intl.DateFormat('HH:mm');
          var date= formatter.format(DateTime.now());
          String topic = empId + 'TI' + orgId;
          if (InPushNotificationStatus == '1') {
            /*sendPushNotification(eName + ' has marked Time In', '',
                '\'' + topic + '\' in topics');*/
            sendPushNotification(eName + ' has marked Time In at '+ date, '',
                '\'' + topic + '\' in topics');
          }
          if (FakeLocationStatus==1) {
            if(FakeLocation==5|| FakeLocation==13 || FakeLocation==7|| FakeLocation==15){
              String subject="Fake Location";
              String content= eName + ' has punched Time In from a spoofed location';
              sendMailByAppToAdmin(subject, content);
            }
            if(FakeLocation==9|| FakeLocation==13 || FakeLocation==11|| FakeLocation==15) {
              sendPushNotification(
                  eName + ' has punched Time In from a spoofed location', '',
                  '(\'' + globals.globalOrgTopic +
                      '\' in topics) && (\'admin\' in topics)');
            }
          }
        }
        else{


          stopLiveLocationTracking();
          print("This is time timeout block"+ act1);
          var prefs = await SharedPreferences.getInstance();

          String OutPushNotificationStatus =
              await prefs.getString("OutPushNotificationStatus") ?? '0';
          var empId = prefs.getString('empid') ?? '';
          var orgId = prefs.getString("orgid") ?? '';
          var eName = prefs.getString('fname') ?? 'User';
          var formatter = new intl.DateFormat('HH:mm');
          var date= formatter.format(DateTime.now());
          String topic = empId + 'TO' + orgId;
          if (OutPushNotificationStatus == '1') {
            sendPushNotification(eName + ' has marked Time Out at '+ date, '',
                '\'' + topic + '\' in topics');
            /*sendPushNotification(eName + ' has marked Time Out', '',
                '\'' + topic + '\' in topics');*/

            print('\'' + topic + '\' in topics');
          }

          if (FakeLocationStatus==1) {
            if(FakeLocation==5|| FakeLocation==13 || FakeLocation==7|| FakeLocation==15){
              String subject="Fake Location";
              String content= eName + ' has punched Time Out from a spoofed location';
              sendMailByAppToAdmin(subject, content);
            }
            if(FakeLocation==9|| FakeLocation==13 || FakeLocation==11|| FakeLocation==15) {
              sendPushNotification(
                  eName + ' has punched Time Out from a spoofed location', '',
                  '(\'' + globals.globalOrgTopic +
                      '\' in topics) && (\'admin\' in topics)');
            }
          }

        }

        if (mounted) {
          setState(() {
            act1 = "";
          });
        }
        //var prefs = await SharedPreferences.getInstance();
        prefs.setBool("firstAttendanceMarked", true);
        prefs.setBool("FirstAttendance", true);
        //prefs.setBool("companyFreshlyRegistered",false );

        showInSnackBarforTimeInOut(issave['TimeInOut'],issave['EntryExitImage'],issave['checkInOutLoc'],);


        /*  showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              content: new Text("Attendance marked successfully!"),
            ));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );*/
        if (mounted) {
          setState(() {
            act1 = act;
          });
        }
      } else if(issave['status']==4) {
        showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              content: new Text("Selfie was not captured. Please change your Camera from Settings."),
            ));
        if (mounted) {
          setState(() {
            act1 = act;
          });
        }
      }
      else{      //

        showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              content: new Text("Selfie was not captured. Please change your Camera from Settings."),
            ));


      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int offlinemode = prefs.getInt("OfflineModePermission");
      if (offlinemode == 1) {
        print("Routing");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => OfflineHomePage()),
              (Route<dynamic> route) => false,
        );
      } else {
        showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              content: new Text("Internet connection not found!."),
            ));
      }
    }


  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "navigateToPage":
        navigateToPageAfterNotificationClicked(
            call.arguments["page"].toString(), context);
        break;
      case "locationAndInternet":
        locationThreadUpdatedLocation = true;
        // print(call.arguments["internet"].toString()+"akhakahkahkhakha");
        // Map<String,String> responseMap=call.arguments;
        if (call.arguments["internet"].toString() == "Internet Not Available") {
          internetAvailable = false;
          print("internet nooooot aaaaaaaaaaaaaaaaaaaaaaaavailable");
          //Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => OfflineHomePage(),maintainState: false));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => OfflineHomePage()),
                (Route<dynamic> route) => false,
          );
        }
        var long = call.arguments["longitude"].toString();
        var lat = call.arguments["latitude"].toString();
        //lat=assign_lat.toString();
        //long=assign_long.toString();
        assign_lat = double.parse(lat);
        assign_long = double.parse(long);
        address = await getAddressFromLati(lat, long);
        print(address +
            "xnjjjjjjlllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll");
        globalstreamlocationaddr = address;
        print(call.arguments["mocked"].toString());
        getAreaStatus().then((res) {
          // print('called again');
          if (mounted) {
            setState(() {
              areaSts = res.toString();
              if (areaId != 0 && geoFence == 1)
                AbleTomarkAttendance = areaSts;
            });
          }
        }).catchError((onError) {
          print('Exception occured in clling function.......');
          print(onError);
        });
        setState(() {
          if (call.arguments["mocked"].toString() == "Yes") {
            fakeLocationDetected = true;
          } else {
            fakeLocationDetected = false;
          }
          if (call.arguments["TimeSpoofed"].toString() == "Yes") {
            timeSpoofed = true;
          }
        });
        break;

        return new Future.value("");
    }
  }


  showInSnackBarforTimeInOut(var val1,var val2,var val3) {

    showModalBottomSheet(
        context: context,
        backgroundColor:const Color(0xFF0E3311).withOpacity(0.0) ,
        builder: (builder) {
          return Container(
            //color:const Color(0xFF0E3311).withOpacity(0.5),
            height:200,
            padding: new EdgeInsets.fromLTRB(10.0, 20.0, 5.0, 16.0),
            child: new Stack(
              children: <Widget>[
                new Container(
                  child: Container(
                    padding: new EdgeInsets.fromLTRB(70.0, 20.0, 16.0, 10.0),
                    //constraints: new BoxConstraints.expand(),
                    child: new Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,   //to align from start
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(height: 3.0),
                        new Text("Time: "+val1, style: TextStyle(fontSize: 22,color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                        new Container(height: 6.0),
                        Container(
                          //margin: new EdgeInsets.fromLTRB(32.0, 1.0, 16.0, 16.0),
                          child: val3.toString().length >=170 ? new Text(val3.toString().substring(0,170),style: TextStyle(fontSize: 14,color: Colors.white),):new Text(val3.toString(),style: TextStyle(fontSize: 14,color: Colors.white),),
                        ),
                      ],
                    ),
                  ),
                  height: 150.0,
                  width: 350,
                  margin: new EdgeInsets.only(left: 46.0),
                  decoration: new BoxDecoration(
                    //color: Color.fromRGBO(0, 0, 0, 0.5),
                    //color: Color.fromRGBO(199, 130, 10, 0.6),
                    //  color: Color.fromRGBO(2, 112, 85, 0.6),
                    // color: Colors.orangeAccent[200],
                    //color: Colors.teal[500],
                    color: Color.fromRGBO(255, 177, 33, 0.8),
                    //  color: Colors.cyanAccent[100],
                    shape: BoxShape.rectangle,
                    borderRadius: new BorderRadius.circular(8.0),
                    /*boxShadow: <BoxShadow>[
                    new BoxShadow(
                      color: Colors.black54,
                      blurRadius: 5.0,
                      offset: new Offset(0.0, 10.0),
                    ),
                  ],*/
                  ),
                ),
                Container(
                  margin: new EdgeInsets.symmetric(vertical: 13.0),
                  alignment: FractionalOffset.centerLeft,
                  child: Container(
                    //   foregroundDecoration: BoxDecoration(color:Colors.yellow ),
                      width: MediaQuery.of(context).size.height * .13,
                      height: MediaQuery.of(context).size.height * .13,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.cover,

                            image: facerecognition.toString()=='1'?(val2!=null?new NetworkImage(val2):AssetImage('assets/avatar.png')):MemoryImage(base64Decode(globals.PictureBase64Att)),
                            //image: AssetImage('assets/avatar.png')
                          ))),
                ),
              ],
            ),
          );
        });

    Future.delayed(const Duration(seconds: 3), () {


      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
      );
    });

  }



  getAlreadyMarkedWidgit() {

    return  AnimatedOpacity(
      opacity: opacityLevel,
      duration: Duration(milliseconds: 500),
      curve: Curves.linear,
      child: new Container(
        height: selected!=false?160:1,
        width: selected!=false?350:1,
        child: Container(
          padding: new EdgeInsets.fromLTRB(70.0, 20.0, 16.0, 10.0),
          //constraints: new BoxConstraints.expand(),
          child: new Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,   //to align from start
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(height: 3.0),
              new Text(fname, style: TextStyle(fontSize: 22,color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              new Container(height: 8.0),
              Row(
                children: <Widget>[
                  new Container(height: MediaQuery.of(context).size.height*0.14,color: Colors.white,width: 3,),
                  Container(width: 5.0),
                  Container(
                    //   color: Colors.red,
                      height:  MediaQuery.of(context).size.height*0.12,
                      width: MediaQuery.of(context).size.height*0.30,
                      child: Text("Attendance has been marked. Thank You!",textScaleFactor: 1.0,textAlign: TextAlign.center,style: TextStyle(fontSize: 22,color: Colors.white),))


                ],
              ),
              /* Container(
                padding: EdgeInsets.only(right: 28,top: 5),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    RaisedButton(
                      color: buttoncolor,
                      elevation: 0.0,
                      disabledElevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Text('TIME IN',
                          style: new TextStyle(
                              fontSize: 18.0, color: Colors.white, letterSpacing: 2)),
                      onPressed: () {

                      },
                    )

                  ],
                ),
              )*/
            ],
          ),
        ),


        margin: new EdgeInsets.only(left: 46.0,top: 10,right: 25),
        decoration: new BoxDecoration(
          color: Colors.blue[300],
          shape: BoxShape.rectangle,
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: new Offset(0.0, 10.0),
            ),
          ],
          borderRadius: new BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////after changes/////////////////////////////////////////////////////

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  getMarkerNew(markerPoint,latitude,longitude,infoWindow) async {

    final Uint8List markerIcon = await getBytesFromCanvasForCircleMarkerNew(50, 50, markerPoint);

   // if(showPolylines == true || showMarker == true) {
      var m = Marker(
        markerId: MarkerId(markerPoint.toString()),
        position: LatLng(latitude,longitude),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        infoWindow: InfoWindow(
          title: infoWindow.toString(),
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _markers.add(m);
          //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
        });
      });
   // }
  }

  Future<Uint8List> getBytesFromCanvasForCircleMarkerNew(int width, int height, int markerPoint) async  {    //IMP

    print(markerPoint);
    print("countOfPositionMarker");
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    final Radius radius = Radius.circular(width/2);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(),  height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);
    //countOfPositionMarker++;
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: markerPoint.toString(),
      style: TextStyle(fontSize: 25.0, color: Colors.white,fontWeight: FontWeight.bold),
    );

    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * .5) - painter.height * 0.5));
    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }
  Future<BitmapDescriptor> getMarkerIconNew(String imagePath, Size size,int number) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 2);

    final Paint tagPaint = Paint()..color = Colors.blue;
    final double tagWidth = 40.0;

    final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
    final double shadowWidth = 15.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 3.0;

    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              0.0,
              0.0,
              size.width,
              size.height
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              shadowWidth,
              shadowWidth,
              size.width - (shadowWidth * 2),
              size.height - (shadowWidth * 2)
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    // Add tag circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              size.width - tagWidth,
              0.0,
              tagWidth,
              tagWidth
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        tagPaint);

    // Add tag text
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: number.toString(),
      style: TextStyle(fontSize: 20.0, color: Colors.white),
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(
            size.width - tagWidth / 2 - textPainter.width / 2,
            tagWidth / 2 - textPainter.height / 2
        )
    );

    // Oval for the image
    Rect oval = Rect.fromLTWH(
        imageOffset,
        imageOffset,
        size.width - (imageOffset * 2),
        size.height - (imageOffset * 2)
    );

    // Add path for oval image
    canvas.clipPath(Path()
      ..addOval(oval));

    // Add image
    ui.Image image = await getImageFromNetwork(imagePath); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);

    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt()
    );

    // Convert image to bytes
    final ByteData byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }





}


class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}