// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;
import 'dart:math';
import 'dart:typed_data';
import 'package:Shrine/avatar_glow.dart';
import 'package:Shrine/home.dart';
//import 'package:Shrine/punchlocation_summary.dart';
import 'package:Shrine/timeoff_summary.dart';
//import 'package:circular_menu/circular_menu.dart';
import 'package:dio/dio.dart';
import 'package:Shrine/visits_list_emp.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
//import 'package:flutter_boom_menu/flutter_boom_menu.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:location/location.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
//import 'package:search_map_place/search_map_place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicorndial/unicorndial.dart';
import 'Bottomnavigationbar.dart';
//import 'Search.dart';
import 'attendance_summary.dart';
import 'bulkatt.dart';
import 'globals.dart';
import 'location_tracking/map_pin_pill.dart';
import 'location_tracking/pin_pill_info.dart';
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


class NewHomePage extends StatefulWidget {
  String empId;
  @override
  _NewHomePageState createState() => _NewHomePageState();
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
    this.time = snapshot.key ?? '00:00:00';

  }
}


class _NewHomePageState extends State<NewHomePage>  with SingleTickerProviderStateMixin{
  Completer<GoogleMapController> _controller = Completer();
  // this set will hold my markers
  Set<Marker> _markers = {};
  bool selected = true;
  String _colorName = 'No';
  var profile;
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



  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyDYh77SKpI6kAD1jiILwbiISZEwEOyJLtM";
  // for my custom icons
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  String empId;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // var _scaffoldKey;

  @override
  void initState() {
    Name.clear();
    NameList.clear();
    super.initState();
    initPlatformState();
    getOrgName();
    _getLocation();

    //opacityLevel=2.0;
  }

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


  initPlatformState() async {
    print("adsadadadsadadadadsadsadadsadad");
    _controller1 = new TabController(length: 2, vsync: this);
    var prefs= await SharedPreferences.getInstance();

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
      First=Name[0];
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


    final GoogleMapController controller = await _controller.future;

    updates = await FirebaseDatabase.instance.reference().child("Locations").child(orgId).onChildAdded.listen((data)async {
      // locationList.insert(0, Locations.fromFireBase(data.snapshot));
      var date=DateTime.now().toString().split(".")[0].split(" ")[0];
      var empId=data.snapshot.key.toString();

      setLoader = true;
      if(data.snapshot.value[date]!=null) {
        var timesMap = new Map<String, dynamic>.from(data.snapshot.value[date]);
        List<Map<String, dynamic>> locationList = List();
        timesMap.forEach((k, v) => locationList.add({k:v}));

        locationList.sort((a,b) {
          return DateTime.parse(date+" "+a.keys.first).compareTo(DateTime.parse(date+" "+b.keys.first));
        });



        print("adsadadadsadadadadsadsadadsadad>>>>>>>>>>>>>"+locationList.length.toString()
            +
            locationList.toString() + ">>>" +
            locationList[locationList.length - 1].toString());
//var lastLocation=timesList[timesList.length - 1];
        var currentLoc=Locations.fromFireBase1(locationList[locationList.length - 1]);

        setState(() {
          // create a Polyline instance
          // with an id, an RGB color and the list of LatLng pairs
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 0,
              target: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
              zoom: 17.0,
            ),
          ));
          /*
        latlng.add(LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)));
        _polylines.add(Polyline(
          polylineId: PolylineId("1"),
          visible: true,
          //latlng is List<LatLng>

          points: latlng,
          color: Colors.blue,
        ));*/
        });

        var res=await Dio().post(globals.path+"getProfile?uid="+empId);
        Map employeeMap =await json.decode(res.data);

        //print("https://ubitech.ubihrm.com/public/uploads/"+orgId+"/"+employeeMap["info"][0]['ImageName'].toString());

        print(globals.path+"getProfile?uid="+empId);

        /* List values = locationList[locationList.length - 1].values.toList();
        StoreLocation.addAll({empId:[values[0]['latitude'],values[0]['longitude'],locationList[locationList.length - 1].keys, employeeMap["info"][0]['FirstName']+" "+employeeMap["info"][0]['LastName'], "https://ubitech.ubihrm.com/public/uploads/"+orgId+"/"+employeeMap["info"][0]['ImageName']]});
         print(StoreLocation);
           print("storelocation123");

        for(int i = 0; i<StoreLocation.length; i++) {

          for(int j = i+1 ; j<StoreLocation.length;j++) {

            var initialLati = StoreLocation.values.elementAt(i)[0];   //comparing latitiude
            var initialLongi = StoreLocation.values.elementAt(i)[1];   //comparing longitude

            var lati = StoreLocation.values.elementAt(j)[0];
            var longi = StoreLocation.values.elementAt(j)[1];

            getradius(double.parse(initialLati),double.parse(initialLongi),double.parse(lati),double.parse(longi));
          }
        }*/


        var generatedIcon;
        BitmapDescriptor generatedIcons;
        var j=0;

        var address= await getAddressFromLati_offline(double.parse(currentLoc.latitude), double.parse(currentLoc.longitude));

        List values = locationList[locationList.length - 1].values.toList();
        //  Name.add(employeeMap["info"][0]['FirstName'].toString()+" "+employeeMap["info"][0]['LastName'].toString());

        Name.add(["("+empId+") "+employeeMap["info"][0]['FirstName'].toString()+" "+employeeMap["info"][0]['LastName'].toString(),"https://ubitech.ubihrm.com/public/uploads/"+orgId+"/"+employeeMap["info"][0]['ImageName'],empId]);
        NameList.add(("("+empId+") "+employeeMap["info"][0]['FirstName'].toString()+" "+employeeMap["info"][0]['LastName'].toString()));
        print(Name);
        print(NameList);
        print("--------------------------------------------123");
        StoreLocation.addAll({empId:[values[0]['latitude'],values[0]['longitude'],locationList[locationList.length - 1].keys, employeeMap["info"][0]['FirstName']+" "+employeeMap["info"][0]['LastName'], "https://ubitech.ubihrm.com/public/uploads/"+orgId+"/"+employeeMap["info"][0]['ImageName'], address]});
        print(StoreLocation);
        print("storelocation123");

       /* for(int i = 0; i<StoreLocation.length ; i++){

          double LAT1 = double.parse(StoreLocation.values.elementAt(StoreLocation.length-1)[0]);
          double LONG1 = double.parse(StoreLocation.values.elementAt(StoreLocation.length-1)[1]);

          print(LAT1);
          print(LONG1);
          print("last lat long");


          var LAT2 = double.parse(StoreLocation.values.elementAt(i)[0]);
          var LONG2 = double.parse(StoreLocation.values.elementAt(i)[1]);

          print(LAT2);
          print(LONG2);
          print("i dont know");


       //   double LAT2 = double.parse(v[0]);
       //   double LONG2 = double.parse(v[1]);


          double distance = 2 * 6371000 * Math.asin(Math.sqrt(Math.pow((Math.sin((LAT2 * (3.14159 / 180) - LAT1 * (3.14159 / 180)) / 2)), 2) + Math.cos(LAT2 * (3.14159 / 180)) * Math.cos(LAT1 * (3.14159 / 180)) * Math.sin(Math.pow(((LONG2 * (3.14159 / 180) - LONG1 * (3.14159 / 180)) / 2), 2))));

          if(distance<10) {

            print(StoreLocation.values.elementAt(i)[3]);//if they are less then at a distance of 10 meters
            print("hi Somya..!!!!");//if they are less then at a distance of 10 meters
         //   count++;
          //  print(count);
            print("count is");
          }
        }*/

        var m = Marker(
          markerId: MarkerId('sourcePin$j'),
          position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
          icon: await getMarkerIcon("https://ubitech.ubihrm.com/public/uploads/"+orgId+"/"+employeeMap["info"][0]['ImageName'], Size(150.0, 150.0),j+1),

          onTap: () {

            var moving=currentLoc.is_moving=="false"?"Still":"Moving";

            setState(() {

              currentlySelectedPin = PinInformation(pinPath: 'assets/friend1.jpg', avatarPath: "https://ubitech.ubihrm.com/public/uploads/"+orgId+"/"+employeeMap["info"][0]['ImageName'], location: LatLng(0, 0), client: employeeMap["info"][0]['FirstName']+" "+employeeMap["info"][0]['LastName'],description: 'At: '+address,in_time: currentLoc.time.toString()+" ("+moving+")",out_time: '-', labelColor: Colors.grey);
              pinPillPosition = 50;

            });
          },

        /*  infoWindow: InfoWindow(
              //title: visits[i].client,
              //snippet:visits[i].desc
          ),*/

        );
        Future.delayed(Duration(seconds: 1),(){
          setState(() {
            _markers.add(m);
          });
        });
        j++;
      }
    });
    setSourceAndDestinationIcons();

  }



  void _add(lat, long, image1, name) async {


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
      First=Name[0];
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
        zoom: 15.0,
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
          pinPillPosition = 50;

        });
      },

//          infoWindow: InfoWindow(
//              title: visits[i].client,
//              snippet:visits[i].desc
//          ),
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

  Future<BitmapDescriptor> getMarkerIcon(String imagePath, Size size,int number) async {
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
  var formatter = new intl.DateFormat('dd-MMM-yyyy');

  void _handleSearchStart() {
    setState(() {
      _IsSearching = true;
    });
  }


  //newDataList = List.from(Name);

  /* onItemChanged(String value) {

 // newDataList = List.from(Name);      //search bar
  print(newDataList);
  print(Name);
  print("ghjgcnewDataList");
  setState(() {
      newDataList = NameList.where((string) => string.toLowerCase().contains(value.toLowerCase())).toList();
      print(newDataList);
      print("newDataListghgfhf");
  });
  for(int i = 0; i<Name.length; i++) {
    if(newDataList.contains(Name[i][0])) {
      newDataList1 = Name[i];
    }
  }
  print(newDataList1);
  print("newDguoiuyoiyoataList1");
  }*/



  static List<String> mainDataList = [
    "Apple",
    "Apricot",
    "Banana",
    "Blackberry",
    "Coconut",
    "Date",
    "Fig",
    "Gooseberry",
    "Grapes",
    "Lemon",
    "Litchi",
    "Mango",
    "Orange",
    "Papaya",
    "Peach",
    "Pineapple",
    "Pomegranate",
    "Starfruit"
  ];

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

/*    for(int i = 0; i<Name.length; i++) {
      print(Name[i][0]);
      print("name in main list");

      if(newDataList.contains(Name[i][0])) {
        print("inside if");
        newDataList1.add(Name[i]);
        searchedName.add(Name[i][0]);
        print(searchedName);
        print(newDataList1);
        print("list is is");
      }
    }*/
    /*newDataList1.clear();
    searchedName.clear();*/

  }

  @override
  Widget build(BuildContext context) {

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Choo choo",
        currentButton: FloatingActionButton(
          heroTag: "train",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(Icons.train),
          onPressed: () {},
        )));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Shift Planner",
        currentButton: FloatingActionButton(
            heroTag: "airplane",
            backgroundColor: Colors.greenAccent,
            mini: true,
            child: Icon(Icons.airplanemode_active))));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Shift Planner2",
        currentButton: FloatingActionButton(
            heroTag: "directions",
            splashColor:Colors.red,
            backgroundColor: Colors.blueAccent,
            mini: true,
            child: Icon(Icons.directions_car))));

    final primaryColor = Theme.of(context).primaryColor;
    CameraPosition initialLocation = CameraPosition(
        zoom: CAMERA_ZOOM,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: cameraSource);

    return new Scaffold(
      key: _scaffoldKey,
      //endDrawer: insideGeo.isNotEmpty?endDrawer():Container(),

      /*Drawer(
        elevation: 0.0,
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color:appcolor,
              ),
            ),
            new ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               // crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                 Container(
                   height:65,
                   width: 65,
                   decoration: new BoxDecoration(
                      color: Colors.red,
                        shape: BoxShape
                            .circle,
                        image: new DecorationImage(
                            fit: BoxFit
                                .fill,
                            image: new AssetImage('assets/avatar.png'),)),
                  ),
                  new Text('Home', style: new TextStyle(fontSize: 15.0)),
                ],
              ),
              onTap: () {
               *//* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );*//*
              },
            ), new ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               // crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                 Container(
                   height:65,
                   width: 65,
                   decoration: new BoxDecoration(
                      color: Colors.red,
                        shape: BoxShape
                            .circle,
                        image: new DecorationImage(
                            fit: BoxFit
                                .fill,
                            image: new AssetImage('assets/avatar.png'),)),
                  ),
                  new Text('Home', style: new TextStyle(fontSize: 15.0)),
                ],
              ),
              onTap: () {
               *//* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );*//*
              },
            ), new ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               // crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                 Container(
                   height:65,
                   width: 65,
                   decoration: new BoxDecoration(
                      color: Colors.red,
                        shape: BoxShape
                            .circle,
                        image: new DecorationImage(
                            fit: BoxFit
                                .fill,
                            image: new AssetImage('assets/avatar.png'),)),
                  ),
                  new Text('Home', style: new TextStyle(fontSize: 15.0)),
                ],
              ),
              onTap: () {
               *//* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );*//*
              },
            ), new ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               // crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                 Container(
                   height:65,
                   width: 65,
                   decoration: new BoxDecoration(
                      color: Colors.red,
                        shape: BoxShape
                            .circle,
                        image: new DecorationImage(
                            fit: BoxFit
                                .fill,
                            image: new AssetImage('assets/avatar.png'),)),
                  ),
                  new Text('Home', style: new TextStyle(fontSize: 15.0)),
                ],
              ),
              onTap: () {
               *//* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );*//*
              },
            ),
            new ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               // crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                 Container(
                   height:65,
                   width: 65,
                   decoration: new BoxDecoration(
                      color: Colors.red,
                        shape: BoxShape
                            .circle,
                        image: new DecorationImage(
                            fit: BoxFit
                                .fill,
                            image: new AssetImage('assets/avatar.png'),)),
                  ),
                  new Text('Home', style: new TextStyle(fontSize: 15.0)),
                ],
              ),
              onTap: () {
               *//* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );*//*
              },
            ),
            *//*ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),*//*
          ],
        ),
      ),*/
      appBar: AppBar(

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(_orgName, style: new TextStyle(fontSize: 20.0)),

            /*  Image.asset(
                    'assets/logo.png', height: 40.0, width: 40.0),*/
          ],
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: appcolor,
      ),
      bottomNavigationBar: Bottomnavigationbar(),
      body: new ListView(
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
                  markers: _markers,
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
                                  hintText: 'Search',
                                  focusColor: Colors.white,
                                ),
                                onChanged: onItemChanged,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _textController.text!=""?ListView(
                              padding: EdgeInsets.only(top: 5),
                              children: newDataList.map((data) {
                                return ListTile(
                                    title: Text(data),
                                    onTap: () {

                                      String result = data.substring(1, data.indexOf(')'));

                                      for (var keys in StoreLocation.keys) {
                                        if(result==keys.toString()){
                                          List searchedLocation = StoreLocation[result];
                                          print(searchedLocation);
                                          print("searchedLocation");
                                          _add(double.parse(searchedLocation.elementAt(0)),double.parse(searchedLocation.elementAt(1)),searchedLocation.elementAt(4),searchedLocation.elementAt(3));
                                          //   getLocation(double.parse(searchedLocation.elementAt(0)),double.parse(searchedLocation.elementAt(1)));
                                          // newDataList.clear();
                                        }
                                      }
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
                  ),/* Container(
                    padding: new EdgeInsets.fromLTRB(120.0, 20.0, 50.0, 10.0),
                    child: SearchMapPlaceWidget(
                      apiKey: googleAPIKey,
                      placeholder: "Search",
                      location: LatLng(currlat , currlong),
                      icon:null,
                      radius: 30000,
                      onSelected: (place) async {
                        final geolocation = await place.geolocation;
                        final GoogleMapController controller = await controller2.future;
                        controller.animateCamera(CameraUpdate.newLatLng(geolocation.coordinates));
                        controller.animateCamera(CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
                      },
                    ),
                  ),*/
                ),


                AnimatedOpacity(
                  opacity: opacityLevel,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.linear,
                  child: new Container(
                    //margin: new EdgeInsets.symmetric(vertical: 55.0),
                    height: selected!=false?160:1,
                   // height: 160,
                  //  width: 350,
                    width: selected!=false?350:1,
                    child: Container(
                      padding: new EdgeInsets.fromLTRB(70.0, 20.0, 16.0, 10.0),
                      //constraints: new BoxConstraints.expand(),
                      child: new Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,   //to align from start
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(height: 3.0),
                          new Text("Somya Goyal", style: TextStyle(fontSize: 22,color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                          new Container(height: 6.0),
                          Container(
                            child: new Text("City Center, Gwalior, Madhya Pradesh, India",
                              style: TextStyle(fontSize: 16,color: Colors.white),),
                          ),
                          Container(
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
                ),

                Container(
                    margin: new EdgeInsets.symmetric(vertical: 10.0),
                    alignment: FractionalOffset.topLeft,
                    child:AvatarGlow(
                      endRadius: 63.0,
                      glowColor: appcolor,
                      duration: Duration(milliseconds: 1500),
                      animate:true,
                      showTwoGlows: true,

                      child: /* Container(
                        height:  MediaQuery.of(context).size.height*0.09,
                        width:  MediaQuery.of(context).size.width*0.15,
                        decoration: new BoxDecoration(
                          color: Colors.black,
                          border: Border.all(
                              width: 4, color: Colors.blue//                   <--- border width here
                          ),
                          shape: BoxShape.circle,
                          *//*image: new DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(StoreLocation.values.elementAt(index)[4]),
                              )*//*),
                        // width: MediaQuery.of(context).size.width*0.30,
                        child: profileLoaded? ClipOval(
                          child: FadeInImage.assetNetwork(
                            placeholder: 'l',
                            fit: BoxFit.fill,
                            image: profile,
                          ),
                        ): CircleAvatar(
                          child: Text(initials,style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400)),
                        ),
                      ),*/



                      Container(
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
                                ContainerHeight==0.0?ContainerHeight=160:ContainerHeight=0.0;
                                ContainerWidth==0.0?ContainerWidth=350:ContainerWidth=0.0;
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
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                           // image: NetworkImage(profile),
                            image: NetworkImage(profile),
                          ),
                        ),
                      ),
                    )
                ),

                selected!=true? Container(
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

                Positioned(
                  //top: 570,
                    top:  MediaQuery.of(context).size.height *.68,
                    // bottom: 310,
                    child:Align(
                      //alignment: FractionalOffset.bottomRight,
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height * .80 ,
                          width:MediaQuery.of(context).size.width * .80 ,
                          child: getProfileWidget()
                      ),
                    )
                ),

                setLoader != true? new Align(child: CircularProgressIndicator(),alignment: FractionalOffset.center,):Container(),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton:  FabCircularMenu(
        key: fabKey1,
        alignment: Alignment.bottomRight,
        ringColor: Colors.blue.withAlpha(110),
        ringDiameter: 450.0,
        ringWidth: 130.0,
        fabSize: 56.0,
        fabElevation: 8.0,
        fabColor: Color.fromRGBO(0, 135, 180, 1),
        fabOpenIcon: Icon(Icons.menu, color: Colors.white),
        fabCloseIcon: Icon(Icons.close, color: Colors.white),
        fabMargin: const EdgeInsets.all(16.0),
        animationDuration: const Duration(milliseconds: 800),
        animationCurve: Curves.easeInOutCirc,
        onDisplayChange: (isOpen) {
          //_showSnackBar(context, "The menu is ${isOpen ? "open" : "closed"}");
        },
        children: <Widget>[

          RaisedButton(
            color: Colors.blue.withAlpha(100),
            onPressed:_buttonWasPressed3,
            shape: CircleBorder(),
            // padding: const EdgeInsets.all(10.0),
            child: Container(
              // color: Colors.blue.withAlpha(120),
                height: 65,
                // color: ,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.directions_walk,
                      size: 30.0,
                      color: Colors.white,
                    ),
                    Text("Visits",style: TextStyle(color: Colors.white),)
                  ],
                )
            ),
          ),

          RaisedButton(
            color: Colors.blue.withAlpha(100),
            onPressed:_buttonWasPressed,
            shape: CircleBorder(),
            // padding: const EdgeInsets.all(10.0),
            child: Container(
              // color: Colors.blue.withAlpha(120),
                height: 65,
                // color: ,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.access_time,
                      size: 30.0,
                      color: Colors.white,
                    ),
                    Text("Time off",style: TextStyle(color: Colors.white),)
                  ],
                )
            ),
          ),

          RaisedButton(
            color: Colors.blue.withAlpha(100),
            onPressed:_buttonWasPressed1,
            shape: CircleBorder(),
            // padding: const EdgeInsets.all(10.0),
            child: Container(
              // color: Colors.blue.withAlpha(120),
                height: 65,
                // color: ,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.group,
                      size: 30.0,
                      color: Colors.white,
                    ),
                    Text("Group",style: TextStyle(color: Colors.white),)
                  ],
                )
            ),
          ),

          RaisedButton(
            color: Colors.blue.withAlpha(100),
            onPressed:_buttonWasPressed2,
            shape: CircleBorder(),
            // padding: const EdgeInsets.all(10.0),
            child: Container(
              // color: Colors.blue.withAlpha(120),
                height: 65,
                // color: ,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.content_paste,
                      size: 30.0,
                      color: Colors.white,
                    ),
                    Text("Log",style: TextStyle(color: Colors.white),)
                  ],
                )
            ),
          ),
        ],
      ),
/*
      floatingActionButton: Stack(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left:31,bottom: 40),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: null,
                child: Icon(Icons.camera_alt),
              ),
            ),
           ),
          Padding(
            padding: const EdgeInsets.only(left:31,bottom: 100),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: null,
                child: Icon(Icons.backup),
              ),
            ),
          ),
        ],
      ),*/
    );
  }
  getLocation(lat, long) async{

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(lat	,long),
        zoom: 15.0,
      ),
    ));

  }

  getSearchLocation(empname, res) {
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
  }

  formatTime(String time){

    if(time.contains(":")){
      var a=time.split(":");
      return a[0]+":"+a[1];
    }
    else return time;

  }

  double getDistance(double LAT1, double LONG1, double LAT2, double LONG2) {
    double distance = 2 * 6371000 * Math.asin(Math.sqrt(Math.pow((Math.sin((LAT2 * (3.14159 / 180) - LAT1 * (3.14159 / 180)) / 2)), 2) + Math.cos(LAT2 * (3.14159 / 180)) * Math.cos(LAT1 * (3.14159 / 180)) * Math.sin(Math.pow(((LONG2 * (3.14159 / 180) - LONG1 * (3.14159 / 180)) / 2), 2))));
    print(distance);
    print("distanve isdjkkjkjhgkgh");
  }


  getProfileWidget()  {

    return new ListView.builder(

        scrollDirection: Axis.horizontal,
        itemCount: StoreLocation.length,
        itemBuilder: (BuildContext context, int index) {

         // var image =  StoreLocation.values.elementAt(index)[4];
          _checkLoaded = false;

          var count=0;


          var image = NetworkImage(StoreLocation.values.elementAt(index)[4]);
          image.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((_, __) {
              _checkLoaded = true;
            }));


          var Name = StoreLocation.values.elementAt(index)[3];
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
              First=Name[0];
              print('print(First)else');
              print(First);
              initials =  First;
              print(initials);

            }
            // }

          return  new Column(
              children: <Widget>[
                new FlatButton(
                    child : new Row(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                      child:  new Container(
                          height:  MediaQuery.of(context).size.height*0.09,
                          width:  MediaQuery.of(context).size.width*0.15,
                        decoration: new BoxDecoration(
                              color: Colors.black,
                              border: Border.all(
                                  width: 4, color: Colors.blue//                   <--- border width here
                              ),
                              shape: BoxShape.circle,
                              /*image: new DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(StoreLocation.values.elementAt(index)[4]),
                              )*/),
                          // width: MediaQuery.of(context).size.width*0.30,
                          child: _checkLoaded? ClipOval(
                            child: FadeInImage.assetNetwork(
                              placeholder: 'l',
                              fit: BoxFit.fill,
                              image: StoreLocation.values.elementAt(index)[4],
                            ),
                          ): CircleAvatar(
                            child: Text(initials,style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400)),
                          ),
                      ),
                        onTap: () async {

                        _markers.clear();
                        setLoader = false;
                        _checkLoaded = false;
                        var image = NetworkImage(StoreLocation.values.elementAt(index)[4]);
                        print(image);
                        print("image is");
                        print("name is the client123");
                        print(_checkLoaded);

                        image.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((_, __) {
                          _checkLoaded = true;
                        }));

                        var Name = StoreLocation.values.elementAt(index)[3];
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
                          First=Name[0];
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
                        var request = await http.get(StoreLocation.values.elementAt(index)[4]);
                        var bytes = await request.bodyBytes;

                        setState(() {
                          dataBytes = bytes;
                        });

                        LatLng _lastMapPositionPoints = LatLng(
                            double.parse(StoreLocation.values.elementAt(index)[0]),
                            double.parse(StoreLocation.values.elementAt(index)[1]));

                       // var loader = await getMarkerIconForClients(StoreLocation.values.elementAt(index)[4],  Size(140.0, 140.0), count);

                        _checkLoaded?
                        getMarkerProfile(StoreLocation.values.elementAt(index)[4], count ,double.parse(StoreLocation.values.elementAt(index)[0]), double.parse(StoreLocation.values.elementAt(index)[1]))
                            : getMarker(initials,double.parse(StoreLocation.values.elementAt(index)[0]), double.parse(StoreLocation.values.elementAt(index)[1]),count);

                        /*_markers.add(
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
                        ))*/


                        getLocation(double.parse(StoreLocation.values.elementAt(index)[0]),double.parse(StoreLocation.values.elementAt(index)[1]));

                        },
                        )
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
    );

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
      infoWindow: InfoWindow(
        title: initials.toString(),
      ),
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

    final Uint8List markerIcon = await getBytesFromCanvasForCircleMarker(150, 150, initials,count);

  //  if(showPolylines == true || showMarker == true) {
      var m = Marker(
        markerId: MarkerId(initials.toString()),
        position: LatLng(latitude,longitude),
        onTap:(){
          getPopup(latitude, longitude);
        },
        icon: BitmapDescriptor.fromBytes(markerIcon),
        infoWindow: InfoWindow(
          title: "+"+count.toString(),
        ),
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
          popupLocations.add([k,v[0],v[1],v[3],v[4]]);
          print(popupLocations);
          print(distance);
          print("distanve is");
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
                                        new Container(height: 3.0),
                                        new Text(popupLocations[index][3].toString(), style: TextStyle(fontSize: 22,color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                        new Container(height: 6.0),
                                        Container(
                                          //margin: new EdgeInsets.fromLTRB(32.0, 1.0, 16.0, 16.0),
                                          child: true ? new Text("Latitude: "+popupLocations[index][1].toString(),style: TextStyle(fontSize: 14,color: Colors.white),):new Text("jkhgk",style: TextStyle(fontSize: 14,color: Colors.white),),
                                        ),Container(
                                          //margin: new EdgeInsets.fromLTRB(32.0, 1.0, 16.0, 16.0),
                                          child: true ? new Text("Longitude: "+popupLocations[index][2].toString(),style: TextStyle(fontSize: 14,color: Colors.white),):new Text("jkhgk",style: TextStyle(fontSize: 14,color: Colors.white),),
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
                                    //   foregroundDecoration: BoxDecoration(color:Colors.yellow ),
                                      width: MediaQuery.of(context).size.width * .20,
                                      height: MediaQuery.of(context).size.height * .22,
                                      decoration: new BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                            fit: BoxFit.fill,
                                            image: true?(true?new NetworkImage(popupLocations[index][4]):AssetImage('assets/avatar.png')):MemoryImage(base64Decode(globals.PictureBase64Att)),
                                            //image: AssetImage('assets/avatar.png')
                                          )
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap:_onAlertForAbsent(popupLocations) ,      //ontapstart
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

/*
  Future<BitmapDescriptor> getMarkerIconForClients(String imagePath, Size size,int number) async {
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
      text: "+"+number.toString(),
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
*/

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

  _onAlertForAbsent(List popupLocations) {


    var alertStyle = AlertStyle(
      animationType: AnimationType.fromBottom,
      isCloseButton: false,
      isOverlayTapDismiss: true,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),

    );
    Alert(
        style: alertStyle,
        context: context,
        title: "Absent",
        image: Image.asset('assets/AbsentIcon.png',
          width: 50, height: 50,),

        /* content: Wrap(

            children: <Widget>[
              Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.45,
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
                      ],
                    ),

                    SizedBox(height: 10.0),
                    *//* new Text(
                    snapshot.data[index].Name.toString(),
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600
                    ),
                  ),*//*
                    //SizedBox(height: 20,),
                    Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment
                          .top,
                      columnWidths: {

                        0: FlexColumnWidth(5),
                        // 0: FlexColumnWidth(4.501), // - is ok
                        // 0: FlexColumnWidth(4.499), //- ok as well
                        1: FlexColumnWidth(5),
                        //2: FlexColumnWidth(5),
                      },
                      children: [
                        TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    new Text(
                                      "Time In",
                                      style: TextStyle(
                                          color: Colors
                                              .black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight
                                              .bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    new Text(
                                      "Time Out",
                                      style: TextStyle(
                                          color: Colors
                                              .black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight
                                              .bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ) ,
                        TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    new Text(
                                      userlist.isEmpty?"-": userlist[0].TimeIn,
                                      style: TextStyle(
                                          color: Colors
                                              .black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight
                                              .w400
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    new Text(
                                      userlist.isEmpty?"-": userlist[0].TimeOut,
                                      style: TextStyle(
                                          color: Colors
                                              .black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight
                                              .w400
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),
                        TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    InkWell(
                                      child: Container(
                                          width: 70.0,
                                          height: 70.0,
//                               child: FadeInImage.assetNetwork(
//                                  placeholder: 'assets/user_profile.png',
//                                  ),
                                          decoration: new BoxDecoration(
                                              border: Border.all(
                                                  width: 2, color: Colors.teal//                   <--- border width here
                                              ),
                                              shape: BoxShape.circle,
                                              image: new DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image:
//                                          AssetImage('assets/user_profile.png'),
//                                            _checkLoaded
//                                                ? AssetImage('assets/imgloader.gif')
//                                                :
                                                  userlist.isNotEmpty?NetworkImage(
                                                      userlist[0].EntryImage):AssetImage('assets/avatar.png')

                                                //_checkLoaded ? AssetImage('assets/avatar.png') : profileimage,
                                              )
                                          )
                                      ),
                                      onTap: () {

                                        if( userlist.isNotEmpty) {
                                          Navigator.of(
                                              context, rootNavigator: true)
                                              .pop();

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ImageView(
                                                        myimage: userlist[0]
                                                            .EntryImage,
                                                        org_name: _orgName)),
                                          );
                                        }

                                      },
                                    ),
                                  ],
                                ),
                              ),

                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    InkWell(
                                      child: Container(
                                          width: 70.0,
                                          height: 70.0,
//                               child: FadeInImage.assetNetwork(
//                                  placeholder: 'assets/user_profile.png',
//                                  ),
                                          decoration: new BoxDecoration(
                                              border: Border.all(
                                                  width: 2, color: Colors.teal//                   <--- border width here
                                              ),
                                              shape: BoxShape.circle,
                                              image: new DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image:
//                                          AssetImage('assets/user_profile.png'),
//                                            _checkLoaded
//                                                ? AssetImage('assets/imgloader.gif')
//                                                :
                                                  userlist.isNotEmpty?NetworkImage(
                                                      userlist[0].ExitImage):AssetImage('assets/avatar.png')

                                                //_checkLoaded ? AssetImage('assets/avatar.png') : profileimage,
                                              )
                                          )
                                      ),
                                      onTap: () {
                                        if( userlist.isNotEmpty) {
                                          Navigator.of(
                                              context, rootNavigator: true)
                                              .pop();


                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ImageView(
                                                        myimage: userlist[0]
                                                            .ExitImage,
                                                        org_name: _orgName)),
                                          );
                                        }

                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),
                        //TableRow(),

                        TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 40,
                                      child:  new Container(
                                        //color: Colors.red,
                                        padding: new EdgeInsets.only(left: 10.0, right: 10.0,top: 10,bottom: 10),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            InkWell(
                                              child:Center(
                                                child: Text(
                                                  userlist.isEmpty?"-": userlist[0].checkInLoc,style: TextStyle(color: Colors.black54,fontSize: 12.0),textAlign: TextAlign.center,),
                                              ),
                                              onTap: () {
                                                goToMap(userlist.isEmpty?"-": userlist[0].latit_in,userlist.isEmpty?"-": userlist[0].longi_in);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 40,
                                      child:  new Container(
                                        padding: new EdgeInsets.only(left: 10.0, right: 10.0,top: 10,bottom: 10),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[

                                            InkWell(
                                              child:Center(
                                                child: Text(
                                                  userlist.isEmpty?"-": userlist[0].CheckOutLoc,style: TextStyle(color: Colors.black54,fontSize: 12.0),textAlign: TextAlign.center,),
                                              ),
                                              onTap: () {
                                                goToMap(userlist.isEmpty?"-": userlist[0].latit_out,userlist.isEmpty?"-": userlist[0].longi_out);
                                              },
                                            ),
                                            *//*Container(
                                              padding: EdgeInsets.all(2.0),
                                              color: snapshot.data[index].incolor.toString()=='0'?Colors.red:Colors.green,

                                              child: Text(snapshot.data[index].instatus,
                                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12.0,color: Colors.white),
                                              ),
                                            ),*//*
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),
                        *//*TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.end,
                                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 37,
                                      child:  new Container(
                                        //width: MediaQuery.of(context).size.width * 0.37,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            *//**//* new Text(
                                    snapshot.data[index].client.toString(),style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.left,
                                  ),*//**//*
                                            InkWell(
                                              child:Text(
                                                userlist.isEmpty?"-": userlist[0].checkInLoc,style: TextStyle(color: Colors.black54,fontSize: 12.0),),
                                              onTap: () {
                                               // goToMap(snapshot.data[index].latin,snapshot.data[index].lonin.toString());
                                              },
                                            ),
                                           *//**//* Container(
                                              padding: EdgeInsets.all(2.0),
                                              color: snapshot.data[index].incolor.toString()=='0'?Colors.red:Colors.green,

                                              child: Text(snapshot.data[index].instatus,
                                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12.0,color: Colors.white),
                                              ),
                                            ),*//**//*
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    new Text(
                                      '',
                                      style: TextStyle(
                                          color: Colors
                                              .black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight
                                              .bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),*//*
                      ],
                    ),
                    *//* Expanded(
                      flex: 37,
                      child:  new Container(
                        //width: MediaQuery.of(context).size.width * 0.37,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            *//**//* new Text(
                                    snapshot.data[index].client.toString(),style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.left,
                                  ),*//**//*
                            InkWell(
                              child:Text(
                                userlist.isEmpty?"-": userlist[0].checkInLoc,style: TextStyle(color: Colors.black54,fontSize: 12.0),),
                              *//**//*onTap: () {
                                goToMap(snapshot.data[index].latin,snapshot.data[index].lonin.toString());
                              },*//**//*
                            ),
                           *//**//* Container(
                              padding: EdgeInsets.all(2.0),
                              color: snapshot.data[index].incolor.toString()=='0'?Colors.red:Colors.green,

                              child: Text(snapshot.data[index].instatus,
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12.0,color: Colors.white),
                              ),
                            )*//**//*
                          ],
                        ),
                      ),
                    ),*//*
                    //SizedBox(height: 10.0),
                    Divider(color: Colors.black54,height: 1.5,),
                    SizedBox(height: 19,),
                    Container(
                      padding: new EdgeInsets.only(left: 15.0, right: 10.0),
                      decoration: new ShapeDecoration(
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                          color: Colors.white.withOpacity(0.1)
                      ) ,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[

                          Row(
                            children: <Widget>[
                              Icon(Icons.timelapse, size: 20.0,
                                color: Colors.black54,), SizedBox(width: 5.0),
                              new Text("Shift Timings: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold)),
                              new Text(
                                  userlist.isEmpty ? "-"
                                      : userlist[0].ShiftTimeIn+" - "+userlist[0].ShiftTimeOut,
                                  style: new TextStyle(fontSize: 15.0,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * .01),
                          Row(
                            children: <Widget>[
                              Icon(Icons.access_time, size: 20.0,
                                color: Colors.black54,), SizedBox(width: 5.0),
                              new Text("Logged Hours: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold)),
                              new Text(
                                  userlist.isEmpty ? "-" : userlist[0].thours,
                                  style: new TextStyle(fontSize: 15.0,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                          *//*SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * .01),*//*
                          *//*Row(
                            children: <Widget>[
                              Icon(Icons.timer, size: 20.0,
                                color: Colors.black54,), SizedBox(width: 5.0),
                              new Text("Shift TimeIn: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold)),
                              new Text(userlist.isEmpty ? "-"
                                  : userlist[0].ShiftTimeIn,
                                  style: new TextStyle(fontSize: 15.0,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * .01),
                          Row(
                            children: <Widget>[
                              Icon(Icons.timer, size: 20.0,
                                color: Colors.black54,), SizedBox(width: 5.0),
                              new Text("Shift TimeOut: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold)),
                              new Text(userlist.isEmpty ? "-"
                                  : userlist[0].ShiftTimeOut,
                                  style: new TextStyle(fontSize: 15.0,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),*//*
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * .01),
                          (date.toString().substring(0,10).compareTo(now.toString().substring(0,10))) != 0?Row(
                            children: <Widget>[
                              Icon(Icons.timer, size: 20.0,
                                color: Colors.black54,), SizedBox(width: 5.0),

                              userlist.isEmpty ?new Text("Undertime: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold))

                                  :userlist[0].overtime.contains("-")?new Text("Undertime: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold))

                                  :Text("Overtime: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold)),


                              userlist.isEmpty ?new Text("-"):userlist[0].overtime.contains("-")?Text(userlist[0].overtime,style: new TextStyle(fontSize: 15.0,
                                  fontWeight: FontWeight.bold,color: Colors.red)):Text(userlist[0].overtime,style: new TextStyle(fontSize: 15.0,
                                  fontWeight: FontWeight.bold,color: Colors.green)),
                            ],
                          ):Container(),

                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * .01),
                        ],

                      ),
                    )
                  ],),

              ),
            ],
          ),*/

        buttons: [
          DialogButton(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.22,
            color: Colors.orangeAccent,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
    ///});
  }



/*  endDrawer(){
    print(insideGeo);
    print("88888888888888888888888888888888");
    print(distinctIds);
    print("inside geooooooo");
   return  Drawer(

      elevation: 0.0,
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color:appcolor,
            ),
          ),
          new ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height:65,
                  width: 65,
                  decoration: new BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape
                          .circle,
                      image: new DecorationImage(
                        fit: BoxFit
                            .fill,
                        image: new AssetImage('assets/avatar.png'),)),
                ),
                new Text(StoreLocation.values.elementAt(1)[3], style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              *//* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );*//*
            },
          ), new ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              // crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height:65,
                  width: 65,
                  decoration: new BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape
                          .circle,
                      image: new DecorationImage(
                        fit: BoxFit
                            .fill,
                        image: new AssetImage('assets/avatar.png'),)),
                ),
                new Text(StoreLocation.values.elementAt(2)[3], style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              *//* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );*//*
            },
          ), new ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height:65,
                  width: 65,
                  decoration: new BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape
                          .circle,
                      image: new DecorationImage(
                        fit: BoxFit
                            .fill,
                        image: new AssetImage('assets/avatar.png'),)),
                ),
                new Text(StoreLocation.values.elementAt(3)[3], style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              *//* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );*//*
            },
          ),

          *//*ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),*//*
        ],
      ),
    );
  }*/

  void _changeOpacity() {
    print(opacityLevel);
    print("opacityLevel23");
    setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
    print(opacityLevel);
    print("opacityLevel23456");
  }

  void _changeOpacity1() {
    setState(() => opacityLevel1 = opacityLevel1 == 0 ? 1.0 : 0.0);
    print(opacityLevel1);
    print("oipacity level");
  }

  _doanimation(){

    setState(() {
      ContainerWidth ==0.0? ContainerWidth =50: ContainerWidth =0.0;

    });
  }

  _buttonWasPressed(){
    print("xyz123");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimeoffSummary()),
    );
  }
  _buttonWasPressed1(){
    print("xyz123");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Bulkatt()),
    );
  }
  _buttonWasPressed2(){
    print("xyz123");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }
  _buttonWasPressed3(){
    print("xyz123");
   /* Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PunchLocationSummary()),
    );*/
  }

  void _showSnackBar (BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1000),
        )
    );
  }


  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    setMapPins();
    setPolylines();
    controller2.complete(controller);
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