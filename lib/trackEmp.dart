// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:Shrine/visits_list_emp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as image;
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicorndial/unicorndial.dart';

import 'globals.dart';
import 'location_tracking/map_pin_pill.dart';
import 'location_tracking/pin_pill_info.dart';
import 'services/services.dart';
// This app is a stateful, it tracks the user's current choice.

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(26.19675, 78.1970444);
const LatLng DEST_LOCATION = LatLng(26.19675, 78.1970424);
double pinPillPosition = -470;
PinInformation currentlySelectedPin = PinInformation(pinPath: 'assets/friend1.jpg', avatarPath: 'http://ubiattendance.ubihrm.com/assets/img/avatar.png', location: LatLng(0, 0), client: '',description: '', labelColor: Colors.grey,in_time: '',out_time: '');
PinInformation sourcePinInfo;
PinInformation destinationPinInfo;
var cameraSource=LatLng(double.parse(assign_lat.toString()), double.parse(assign_long.toString()));
final GlobalKey<FabCircularMenuState> fabKey1 = GlobalKey();

class TrackEmp extends StatefulWidget {
  String empId,empName;
  TrackEmp(this.empId,this.empName);
  @override
  _TrackEmpState createState() => _TrackEmpState(empId,empName);
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




  Locations.fromFireBase(DataSnapshot snapshot) {

    try{
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

    }catch(e){
      print("Object Not Created");
    }

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
    this.mock = snapshot.value["mock"] ?? 'false';
  }

}

TextEditingController today1=new TextEditingController();

class _TrackEmpState extends State<TrackEmp>  with SingleTickerProviderStateMixin{
  Completer<GoogleMapController> _controller = Completer();
  // this set will hold my markers
  Set<Marker> _markers = {};
  Set<Marker> _markers1 = {};
  List<LatLng> latlng = List();
  LatLng _new = SOURCE_LOCATION;
  LatLng _news = DEST_LOCATION ;
  // this will hold the generated polylines
  Set<Polyline> _polylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];

  List <Locations> locationList = [];
  String _orgName = "";
  StreamSubscription <Event> updates;
  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyDYh77SKpI6kAD1jiILwbiISZEwEOyJLtM";
  // for my custom icons
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  BitmapDescriptor pinLocationIcon;
  bool showVisits=false;
  bool showTracks=false;
  bool showPolylines=true;
  bool showMarker=false;
  bool noVisits=false;
  bool dateTapped=false;
  ScrollController scrollController;
  bool dialVisible = true;
  double accuracy=20.0;
  String newValue ;
  int markerCount=0;
  bool visitCamera = false;

  String empId,empName;
  var dateChanged;

  var _scaffoldKey;
  Uint8List markerIcon;
  var lati;
  var longi;
  /*int markerCount=0;*/

  String kms="0.0";
  _TrackEmpState(this.empId,this.empName);
  @override
  void initState() {
    super.initState();

    initPlatformState();
    getOrgName();
    setCustomMapPin();
   /* getBytesFromCanvasForCircleMarker(45, 45, 1).then((a){
      markerIcon = a;
      print(markerIcon);
      print("marker icon");
    });*/
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




/*
    updates = FirebaseDatabase.instance.reference().child("Locations").child(orgId).child(empId).child(DateTime.now().toString().split(".")[0].split(" ")[0]).onChildAdded.listen((data) {
     // locationList.insert(0, Locations.fromFireBase(data.snapshot));
      print("adsadadadsadadadadsadsadadsadad>>>>>>>>>>>>>"+data.snapshot.value.toString());
      print(latlng.toString());
    //  print('hjjghgjgjgjhgj'+data.snapshot.value['longitude1'].toString());
      var currentLoc=Locations.fromFireBase(data.snapshot);

    //  setState(() {
        // create a Polyline instance
        // with an id, an RGB color and the list of LatLng pairs
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 0,
            target: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
            zoom: 17.0,
          ),
        ));
        latlng.add(LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)));
        _polylines.add(Polyline(
          polylineId: PolylineId("1"),
          visible: true,
          //latlng is List<LatLng>

          points: latlng,
          color: Colors.blue,
        ));
      });
   // } );

    //setSourceAndDestinationIcons();
    var date=DateTime.now().toString().split(".")[0].split(" ")[0];
    var visits=  await  getVisitsDataList(date.toString(),empId);
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
        icon: await getMarkerIcon("https://i.dlpng.com/static/png/6865249_preview.png", Size(150.0, 150.0),j),
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


*/






  }

  Future<BitmapDescriptor> getMarkerIconForTimeIn(String imagePath, Size size,int number) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 1);

    final Paint tagPaint = Paint()..color = Colors.white;
    final double tagWidth = 0.0;

    final Paint shadowPaint = Paint()..color = Colors.white.withAlpha(100);
    final double shadowWidth = 0.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 0.0;

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
    /* canvas.drawRRect(
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
        borderPaint);*/

    // Add tag circle
    /* canvas.drawRRect(
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
        tagPaint);*/

    // Add tag text
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: number.toString(),
      style: TextStyle(fontSize: 5.0, color: Colors.white),
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(
            size.width - tagWidth / 1 - textPainter.width / 1,
            tagWidth / 1 - textPainter.height / 1
        )
    );

    // Oval for the image
    Rect oval = Rect.fromLTWH(
        imageOffset,
        imageOffset,
        size.width - (imageOffset * 1),
        size.height - (imageOffset * 1)
    );

    // Add path for oval image
    canvas.clipPath(Path()
      ..addOval(oval));

    // Add image
    ui.Image image = await getImageFromNetwork(imagePath); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: image, rect: oval,);

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

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio:10,size: Size(0.1, 0.1) ),
        'assets/TimeInMapIcon.png');
  }



  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
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
    Completer<ImageInfo> completer = Completer();
    var img = new NetworkImage(path);
    img.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info,bool _){

      if (!completer.isCompleted) {
        completer.complete(info);
      }
      // completer.complete(info);
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
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');

  }

  var formatter = new intl.DateFormat('dd-MMM-yyyy');
  Future<ui.Image> loadImage() async {
    ByteData data = await rootBundle.load("assets/needle.jpg");
    if (data == null) {
      print("data is null");
    } else {
      var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      var frame = await codec.getNextFrame();
      return frame.image;
    }
  }


  @override
  Widget build(BuildContext context) {
    var childButtons = List<UnicornButton>();

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Show only Visits",
        currentButton: FloatingActionButton(
          heroTag: "train",
          backgroundColor: buttoncolor,
          mini: true,
          child: Icon(Icons.directions_walk),
          onPressed: () {
            print("show only visits");
            setState(() {

              showVisits = true;
              showTracks = false;
              showPolylines = false;
              noVisits = true;
              visitCamera = true;
              //   showMarker = false;
              print(dateChanged);
              if(!dateTapped){
                onDateChanged(DateTime.now().toString());
              }
              else{
                onDateChanged(dateChanged.toString());
              }
            });
          },
        )));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Show only Track",
        currentButton: FloatingActionButton(
          heroTag: "airplane",
          backgroundColor: buttoncolor,
          mini: true,
          child: Icon(Icons.directions),
          onPressed: () {
            setState(() {
              showTracks = true;
              showVisits = false;
              showPolylines = true;
              noVisits = false;
              print(dateChanged);
              if(!dateTapped){
                onDateChanged(DateTime.now().toString());
              }
              else{
                onDateChanged(dateChanged.toString());
              }
            });

          },)));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: showPolylines== true? "Show Polylines": "Hide Polylines",
        currentButton: FloatingActionButton(
            heroTag: "directions",
            backgroundColor: buttoncolor,
            mini: true,
            child: Icon(Icons.polymer),
            onPressed: () {
              setState(() {
                showTracks = false;
                showVisits = false;
                noVisits = false;

                // showPolylines = true;

                if(!dateTapped){
                  onDateChanged(DateTime.now().toString());
                }
                else{
                  onDateChanged(dateChanged.toString());
                }

                Future.delayed(Duration(seconds: 2),(){
                  setState(() {
                    showPolylines = !showPolylines;
                    showMarker = true;
                  });
                });

              });

            })));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Show all",
        currentButton: FloatingActionButton(
            heroTag: "directionss",
            backgroundColor: buttoncolor,
            mini: true,
            child: Icon(Icons.merge_type),
            onPressed: () {
              setState(() {

                showTracks = true;
                showVisits = true;
                showPolylines = true;
                showMarker = true;
                noVisits = false;
                visitCamera = false;


                if(!dateTapped){
                  onDateChanged(DateTime.now().toString());
                }
                else{
                  onDateChanged(dateChanged.toString());
                }
                /* Future.delayed(Duration(seconds: 2),(){
                  setState(() {
                    showPolylines = !showPolylines;
                    showMarker = true;
                  });
                });*/
              });
            })));


    CameraPosition initialLocation = CameraPosition(
        zoom: CAMERA_ZOOM,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: cameraSource);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(empName, style: new TextStyle(fontSize: 20.0)),

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

      floatingActionButton: UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground:appcolor,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.settings),
          childButtons: childButtons),
/*
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(get
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[

              FloatingActionButton(
                heroTag: "btn1",
                onPressed: () {},
                child: Icon(Icons.navigate_before),
              ),
              FloatingActionButton(
                heroTag: "btn2",
                onPressed: () {},
                child: Icon(Icons.navigate_next),
              )
            ],
          ),
        ),*/



      /*  floatingActionButton: Stack(                  //main
          children: <Widget>[
          *//*  Align(
              heightFactor: 11,
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                  heroTag: null,
                   onPressed: ()=>print("buildSpeedDial"),
                  child: buildSpeedDial()),
            ),*//*
            Padding(padding: EdgeInsets.only(left:31),

              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: ()=>print("UnicornDialer"),

                  heroTag: null,
              //   onPressed: {},
                  child: UnicornDialer(
                      backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
                      parentButtonBackground:appcolor,
                      orientation: UnicornOrientation.HORIZONTAL,
                      parentButton: Icon(Icons.settings),
                      childButtons: childButtons),
                ),
              ),),

           *//* Align(
             // heightFactor: 11,
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                  onPressed: ()=>print("UnicornDialer"),
                heroTag: null,
                child: buildSpeedDial()),
            ),*//*
          ],
        ),*/


      body: new ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          /*  Container(
        constraints: BoxConstraints.expand(),
      child: FutureBuilder(
        future: loadImage(),

        builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.waiting :
              return Center(child: Text("loading..."),);
            default:
              if (snapshot.hasError) {
                return Center(child: Text("error: ${snapshot.error}"),);
              } else {
                return ImagePainter(image: snapshot.data);
              }
          }
        },
      ),
    ),*/
          Container(
            color: Colors.white,
            child: DateTimeField(
              //dateOnly: true,
              format: formatter,
              controller: today1,

              onShowPicker: (context, currentValue) {
                return showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime.now()
                );

              },
              readOnly: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Icon(
                    Icons.date_range,
                    color: Colors.grey,
                  ), // icon is 48px widget.
                ), // icon is 48px widget.
                labelText: 'Select Date',
              ),
              onChanged: (date) {
                setState(() {
                  dateChanged = date;
                  showVisits=false;
                  showTracks=false;
                  showPolylines=true;
                  showMarker=false;
                  noVisits=false;
                  dateTapped = true;
                });

                print("ondatechanged");


                onDateChanged(date.toString());

              },
              validator: (date) {
                if (date == null) {
                  return 'Please select date';
                }
              },
            ),
          ),


          new Container(
            decoration: new BoxDecoration(color: Colors.black54),
            child: new TabBar(
              indicator: BoxDecoration(color: buttoncolor,),
              controller: _controller1,
              tabs: [
                new Tab(
                  text: 'Visited Locations',
                ),
                InkWell(
                  child: new Tab(
                    text: 'Punched Visits',

                  ),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VisitListEmp(empId)),
                    );
                  },
                ),

              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left:5.0),
                child: Container(
                  width: MediaQuery.of(context).copyWith().size.width*0.7,
                  padding: EdgeInsets.all(5.0),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide( color: Colors.grey.withOpacity(1.0), width: 1,),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      child: Padding(
                        padding: const EdgeInsets.only(left:5.0,top: 5.0,bottom: 5.0,),
                        child: DropdownButton<String>(
                          icon: Icon(Icons.arrow_drop_down),
                          isDense: true,
                          hint: Text('Select Inaccuracy'),
                          value: newValue,
                          onChanged: (value) async{
                            newValue=value;
                            print(value);
                            print("newValue isss");
                            setState(() {
                              accuracy = double.parse(newValue);
                              if(!dateTapped){
                                print("it will execute, when no date has been tapped!");
                                onDateChanged(DateTime.now().toString());
                              }
                              else{
                                onDateChanged(dateChanged.toString());
                              }
                              print("accuracy");
                              print(accuracy);
                              // setAlldata();
                            });
                          },
                          items: <String>['30 ', '60 ', '80 ', '100 ', '200  ','2000 '].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 0.0,bottom: 0.0) ,
                //  margin: new EdgeInsets.only(top: 1.0,bottom: 1.0),
                color: buttoncolor.withOpacity(0.7),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(kms,style: TextStyle(color: Colors.black45),),
                ),
              ),
            ],
          ),

          //////////////TABB 2 Start
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

                  onTap: (LatLng location) {
                    setState(() {
                      pinPillPosition = -470;
                    });
                  },

                ),



                MapPinPillComponent(
                    pinPillPosition: pinPillPosition,
                    currentlySelectedPin: currentlySelectedPin
                ),
                /* Positioned(
              top: 10,
              right: 10,

              child: Container(
                color: buttoncolor.withOpacity(0.7),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(kms,style: TextStyle(color: Colors.black45),),
                ),
              ),

            ),*/
                /* Stack(
              children: <Widget>[
                Align(
                 // alignment: Alignment.bottomLeft,
                  child: FloatingActionButton(
                      heroTag: null,
                      ),
                ),
                Align(
                 // alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                      heroTag: null,
                      ),
                ),
              ],
            )*/

              ],

            ),
          )  /////////////TAB 2 Ends



          /////////////TAB 3 STARTS



        ],
      ),
    );
  }

  GoogleMapController controller2;

  Future<Uint8List> getBytesFromCanvas(int width, int height,) async  {

    print(countOfPositionMarker);
    print("countOfPositionMarker");
    print("compsition");
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
    countOfPositionMarker++;
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: countOfPositionMarker.toString(),
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


  Future<Uint8List> getBytesFromCanvasForCircleMarker(int width, int height, int markerPoint) async  {    //IMP

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
    countOfPositionMarker++;
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




  int countOfPositionMarker=0;

  Future<BitmapDescriptor> getClusterMarker(
      int clusterSize,
      Color clusterColor,
      Color textColor,
      int width,
      ) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = clusterColor;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );



    final double radius = width / 2;
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      paint,
    );
    textPainter.text = TextSpan(
      text: clusterSize.toString(),
      style: TextStyle(
        fontSize: radius - 5,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        radius - textPainter.width / 2,
        radius - textPainter.height / 2,
      ),
    );
    final image = await pictureRecorder.endRecording().toImage(
      radius.toInt() * 2,
      radius.toInt() * 2,
    );
    final data = await image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  var startM=0.0,endM=0.0;
  var start=0.0,end=0.0;


  void onMapCreated(GoogleMapController controller)async{

    print("accuracyonmapcreated");
    print(accuracy);

    controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    controller2=controller;
    //var prefs= await SharedPreferences.getInstance();
    today1 = new TextEditingController();
    today1.text = formatter.format(DateTime.now());

    //var orgId=prefs.get("orgid");
    //final GoogleMapController controller = await _controller.future;
    //onDateChanged(today1.text);
    //setMapPins();

    var prefs=await SharedPreferences.getInstance();
    var orgid222=prefs.get("orgid")??"0";
    var empid222=prefs.get("empid")??"0";
    var p=97;
    var ii=0;
    var lastCurrentLocation;
    int markerPoint = 0;
    int ID = 1;
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


      var mockLocation = currentLoc.mock;
      print(mockLocation);

            if(currentLoc.mock == "true"){  //if user uses mock locations
              //  int ID = 1;
              ID++;
              var m1=Marker(
                markerId: MarkerId('fakeLocation$ID'),
                position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
                // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
                icon:BitmapDescriptor.fromBytes(fakeLocation),

                infoWindow: InfoWindow(
                    title: "Fake location found: ",
                    snippet: "         "+currentLoc.time.toString()
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

            TimeInOutLocations.add([currentLoc.latitude,currentLoc.longitude,currentLoc.time.toString()]);

            var firstLocation = TimeInOutLocations[0];                //timeIn location
            if(TimeInOutLocations.length>1){
              lastCurrentLocation = TimeInOutLocations[TimeInOutLocations.length - 1];

              var m1=Marker(
                markerId: MarkerId('sourcePinCurrentLocationIcon'),
                position: LatLng(double.parse(lastCurrentLocation[0]),double.parse(lastCurrentLocation[1])),
                // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
                icon:BitmapDescriptor.fromBytes(currentLocationPinMapIcon),

                infoWindow: InfoWindow(
                  title: "Last known location: "+currentLoc.time.toString(),
                ),
              );
              Future.delayed(Duration(seconds: 1),(){
                setState(() {
                  _markers.add(m1);
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
                zoom: 19.0,
              ),
            ));

            end= double.parse(currentLoc.odometer);
            print(latlng.toString());

            // if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy)<20.0) ) {
            if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy) < accuracy)) {

              start=end;
              p++;
              //print("shashankmmmmmmmmmm"+(end-start>200.0).toString());
              //add position number marker
              // Future.delayed(Duration(seconds: 2),(){
              markerPoint++;

              getMarker(markerPoint,double.parse(currentLoc.latitude),double.parse(currentLoc.longitude),currentLoc.time.toString());

              setState(() {

                if(ii==0){
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
        });
        Future.delayed(Duration(seconds: 1),(){
          setState(() {
            _markers.add(m);
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });*/
            }

          print("akahkhahhakahahah");
          print(currentLoc.latitude.toString());


          setState(() {
            if(double.parse(currentLoc.accuracy)<20.0||true)           //07oct
                {
              latlng.add(LatLng(double.parse(currentLoc.latitude),
                  double.parse(currentLoc.longitude)));
              //  print(latlng);
              // print("latlong iss");
              _polylines.add(Polyline(
                polylineId: PolylineId("1"),
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


          print("From firestore..........................................>>>>");
        };
      }









    //});
/*
    Firestore.instance
        .collection('locations/10/4253/4-12-2020/13:50:29')
        .snapshots()
        .listen((snapshot){

          var a=snapshot.documentChanges;
          //for(var filename in files)



          for(var change in a) {
            // Do something with change
            print(
                "Snapshot.................................................>>><<<<");
            print(change.document.data);
            print(
                "Snapshot.................................................>>><<<<");


            var change1 = new Map<String, dynamic>.from(change.document.data);
            print('hjjghgjgjgjhgj' +
                change1['location']["activity"]["confidence"].toString());
            var currentLoc = Locations.fromFireStore(change1);


//      var mockLocation = currentLoc.mock;
//      print(mockLocation);
/*
            if(currentLoc.mock == "true"){  //if user uses mock locations
              //  int ID = 1;
              ID++;
              var m1=Marker(
                markerId: MarkerId('fakeLocation$ID'),
                position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
                // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
                icon:BitmapDescriptor.fromBytes(fakeLocation),

                infoWindow: InfoWindow(
                    title: "Fake location found: ",
                    snippet: "         "+currentLoc.time.toString()
                  // anchor: Offset(0.1, 0.1)
                ),
              );
              Future.delayed(Duration(seconds: 1),(){
                setState(() {
                  _markers.add(m1);
                  //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
                });
              });
            }*/
/*
            TimeInOutLocations.add([currentLoc.latitude,currentLoc.longitude,currentLoc.time.toString()]);

            var firstLocation = TimeInOutLocations[0];                //timeIn location
            if(TimeInOutLocations.length>1){
              lastCurrentLocation = TimeInOutLocations[TimeInOutLocations.length - 1];

              var m1=Marker(
                markerId: MarkerId('sourcePinCurrentLocationIcon'),
                position: LatLng(double.parse(lastCurrentLocation[0]),double.parse(lastCurrentLocation[1])),
                // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
                icon:BitmapDescriptor.fromBytes(currentLocationPinMapIcon),

                infoWindow: InfoWindow(
                  title: "Last known location: "+currentLoc.time.toString(),
                ),
              );
              Future.delayed(Duration(seconds: 1),(){
                setState(() {
                  _markers.add(m1);
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

*/


            //  setState(() {
            // create a Polyline instance
            // with an id, an RGB color and the list of LatLng pairs

            /*
            controller.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                bearing: 0,
                target: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
                zoom: 19.0,
              ),
            ));

            end= double.parse(currentLoc.odometer);
            print(latlng.toString());

            // if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy)<20.0) ) {
            if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy) < accuracy)) {

              start=end;
              p++;
              //print("shashankmmmmmmmmmm"+(end-start>200.0).toString());
              //add position number marker
              // Future.delayed(Duration(seconds: 2),(){
              markerPoint++;

              getMarker(markerPoint,double.parse(currentLoc.latitude),double.parse(currentLoc.longitude),currentLoc.time.toString());

              setState(() {

                if(ii==0){
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
*/
            print("akahkhahhakahahah");
            print(currentLoc.latitude.toString());


            setState(() {
              if(double.parse(currentLoc.accuracy)<20.0)           //07oct
                {
              latlng.add(LatLng(double.parse(currentLoc.latitude),
                  double.parse(currentLoc.longitude)));
              //  print(latlng);
              // print("latlong iss");
              _polylines.add(Polyline(
                polylineId: PolylineId("1"),
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
         // print("Snapshot.................................................>>><<<<");
    });

*/
/*

    updates = await FirebaseDatabase.instance.reference().child("Locations").child(orgId).child(empId).child(DateTime.now().toString().split(".")[0].split(" ")[0]).onChildAdded.listen((data)  {
      // locationList.insert(0, Locations.fromFireBase(data.snapshot));

      //print('hjjghgjgjgjhgj'+data.snapshot.value['longitude1'].toString());
      var currentLoc=  Locations.fromFireBase(data.snapshot);


//      var mockLocation = currentLoc.mock;
//      print(mockLocation);

      if(currentLoc.mock == "true"){  //if user uses mock locations
      //  int ID = 1;
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

      var firstLocation = TimeInOutLocations[0];                //timeIn location
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
          zoom: 19.0,
        ),
      ));

      end= double.parse(currentLoc.odometer);
      print(latlng.toString());

      // if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy)<20.0) ) {
      if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy) < accuracy)) {

        start=end;
        p++;
        //print("shashankmmmmmmmmmm"+(end-start>200.0).toString());
        //add position number marker
        // Future.delayed(Duration(seconds: 2),(){
        markerPoint++;

        getMarker(markerPoint,double.parse(currentLoc.latitude),double.parse(currentLoc.longitude),data.snapshot.key);

        setState(() {

          if(ii==0){
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
          polylineId: PolylineId("1"),
          visible: true,
          width: 3,
          patterns:  <PatternItem>[PatternItem.dash(20), PatternItem.gap(10)] ,
          //latlng is List<LatLng>
          points: latlng,
          color: Colors.blue,
        ));
        // }
      });
    });*/
    // } );
/*
    //setSourceAndDestinationIcons();
    var date=DateTime.now().toString().split(".")[0].split(" ")[0];
    //var visits =  await  getVisitsDataList(date.toString(),empId);
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
          icon: await getMarkerIcon("https://i.dlpng.com/static/png/6865249_preview.png", Size(140.0, 140.0),j),
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

        j--;*/
      });

    // setPolylines();
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

  onDateChanged2(String date2)async{
    var prefs= await SharedPreferences.getInstance();
    date2=date2.split(" ")[0];



    var orgId=await prefs.get("orgid");
    //final GoogleMapController controller = await _controller.future;


    //onDateChanged(today1.text);

    setState(() {
      _polylines.clear();
      _markers.clear();
      latlng.clear();
    });
    // setMapPins();
    //StreamSubscription <Event> updates ;
    FirebaseDatabase.instance.reference().child("Locations").child(orgId).child(empId).child(DateTime.now().toString().split(".")[0].split(" ")[0]).onChildAdded.listen((data) async {
      // locationList.insert(0, Locations.fromFireBase(data.snapshot));

      print("Latitude and longitudes from firebase: "+ latlng.toString());
      //  print('hjjghgjgjgjhgj'+data.snapshot.value['longitude1'].toString());
      var currentLoc=Locations.fromFireBase(data.snapshot);
      print("Object made >>>>>>>>>>>>>"+currentLoc.toString());
      //  setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      controller2.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
          zoom: 19.0,
        ),
      ));

      setState(() {
        latlng.add(LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)));
      });


    });

    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId("1"),
        visible: true,
        //latlng is List<LatLng>

        points: latlng,
        color: Colors.blue,
      ));
    });

    // } );

    //setSourceAndDestinationIcons();
    var date=DateTime.now().toString().split(".")[0].split(" ")[0];
    var visits=  await  getVisitsDataList(date.toString(),empId);
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
          icon: await getMarkerIcon("https://i.dlpng.com/static/png/6865249_preview.png", Size(150.0, 150.0),j),
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
        Future.delayed(Duration(seconds: 1),() {
          setState(() {
            _markers.add(m);
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });

        j--;
      });
  }

  void onDateChangedOld(String date2)async {
    print(showPolylines);
    print("show polylines");
    print(accuracy);
    print("ondatechangedacuuracy");

    //_controller1 = new TabController(length: 2, vsync: this);
    var prefs = await SharedPreferences.getInstance();
    date2 = date2.split(" ")[0];
    var orgId = await prefs.get("orgid");
    final GoogleMapController controller = await _controller.future;

    setState(() {
      latlng.clear();
      _polylines.clear();
      _markers.clear();
    });

    var start = 0.0,
        end = 0.0;
    var ii = 0;
    var p = 0;
    int count = 0;
    var markerPoint = 0;
    bool childExist = false;
    var lastCurrentLocation;
    List TimeInOutLocations = new List();
    final Uint8List TimeInMapIcon = await getBytesFromAsset('assets/TimeInMapIcon.png', 100);
    final Uint8List currentLocationPinMapIcon = await getBytesFromAsset('assets/mapPinPointMarker.png', 100);
    final Uint8List fakeLocation = await getBytesFromAsset('assets/fakeLocation.png', 140);



    updates =  FirebaseDatabase.instance
        .reference()
        .child("Locations")
        .child(orgId)
        .child(empId)
        .child(date2)
        .onChildAdded
        .listen((data) async {

      setState(() {
        childExist= true;
        print(childExist);
        print("child is exist or not");
      });


      // locationList.insert(0, Locations.fromFireBase(data.snapshot));

      print(showPolylines);
      //count++;
      //print(count);
      //print("start2");

      print("adsadadadsadadadadsadsadadsadad>>>>>>>>>>>>>123456" + data.snapshot.value.toString());
      print(latlng.toString());
      // print(currentLoc.latitude);

      //  print('12345645'+data.snapshot.value['longitude1'].toString());
      var currentLoc = Locations.fromFireBase(data.snapshot);

      TimeInOutLocations.add([currentLoc.latitude,currentLoc.longitude,data.snapshot.key]);
      print(TimeInOutLocations);
      print("TimeInOutLocations");
      print(TimeInOutLocations.length);
      var firstLocation = TimeInOutLocations[0];                //timeIn location
      if(TimeInOutLocations.length>1) {
        lastCurrentLocation =
        TimeInOutLocations[TimeInOutLocations.length - 1];

        if (showTracks == true && showPolylines == true) {

          var m1 = Marker(
            markerId:  MarkerId(
                'sourcePinCurrentLocationIcon'),
            position: LatLng(double.parse(lastCurrentLocation[0]),
                double.parse(lastCurrentLocation[1])),
            // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
            icon: BitmapDescriptor.fromBytes(currentLocationPinMapIcon),

            infoWindow: InfoWindow(
              title: "Last known location: " + data.snapshot.key,
            ),
          );

          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _markers.add(m1);
              //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
            });
          });
        }
      }
      print("start3");
      print(showPolylines);

      if(showTracks == true && showPolylines == true) {
        var m = Marker(
          markerId: MarkerId('sourcePinTimeInIcon'),
          position: LatLng(double.parse(firstLocation[0]),
              double.parse(firstLocation[1])),
          // icon: await getMarkerIconForTimeIn("https://cdn0.iconfinder.com/data/icons/map-and-navigation-2-1/48/100-512.png", Size(150.0, 250.0),0),
          icon: BitmapDescriptor.fromBytes(TimeInMapIcon),
          // icon:pinLocationIcon,

          infoWindow: InfoWindow(
            title: "Start Time: " + firstLocation[2],
          ),
        );
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _markers.add(m);
            //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
          });
        });
      }

      end = double.parse(currentLoc.odometer);

      //  setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      //    var markerPoint=0;

      print(currentLoc.accuracy);
      print("currentLoc.accuracy");
      print(end - start);

      if (((end - start) > 200.0) && (double.parse(currentLoc.accuracy) < accuracy)) {
        //  if (((end - start) > 200.0) && accuracy < 20.0) {
        start = end;
        print("marker point");
        markerPoint++;
        final Uint8List markerIcon = await getBytesFromCanvasForCircleMarker(45, 45, markerPoint);
        // markerPoint++;
        p++;
        print(markerPoint);
        // print(markerIcon);
        print(" value of p");
        print(data.snapshot.key);
        //print("shashankmmmmmmmmmm"+(end-start>200.0).toString());
        //add position number marker
        // Future.delayed(Duration(seconds: 2),(){
        setState(() {

          if (ii == 0) {
            startM = double.parse(currentLoc.odometer);
            print("current loc odo" + startM.toString());
          }

          endM = double.parse(currentLoc.odometer);
          print("end loc odo" + startM.toString());

          kms = ((endM - startM) / 1000).toStringAsFixed(2) + " kms";
          print("sgksshhskhs   " + kms);

          // print(5.75.toStringAsFixed(0));
          // if(endM-startM<0)
          //  kms='0.0';
        });
        //});

        ii++;
        print(showPolylines);
        print("showPolylgkjgines");
        if(showPolylines == true || showMarker == true) {
          var m = Marker(
            markerId: MarkerId('sourcePin$p'),
            position: LatLng(double.parse(currentLoc.latitude),
                double.parse(currentLoc.longitude)),
            //icon: await getMarkerIcon("https://i.dlpng.com/static/png/6865249_preview.png", Size(150.0, 150.0),0),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            infoWindow: InfoWindow(
              title: data.snapshot.key,
            ),
          );
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _markers.add(m);
              //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
            });
          });
        }
        print(showPolylines);
        print("showPolylines");
      }

      /* if(((end-start)>200.0)&&(double.parse(currentLoc.accuracy)<20.0)){
        print("gugikugkjgkjkjkjhkjhki");

        start=end;
        final Uint8List markerIcon = await getBytesFromCanvas(50,50);
        p++;
        //print("shashankmmmmmmmmmm"+(end-start>200.0).toString());
        //add position number marker

        var m=Marker(
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
        });


      }*/

      /*
        setState(() {

        if(ii==0){
          startM=double.parse(currentLoc.odometer);
          print("current loc odo"+startM.toString());
        }

        endM=double.parse(currentLoc.odometer);
        print("end loc odo"+startM.toString());

        kms=((endM-startM)/1000).toStringAsFixed(2)+" Kms";
        print("sgksshhskhs   "+kms);
        // if(endM-startM<0)
        //  kms='0.0';
      });
      //});


      ii++;

      */

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(double.parse(currentLoc.latitude),
              double.parse(currentLoc.longitude)),
          zoom: 19.0,
        ),
      ));

      setState(() {
        // updated position
        var pinPosition = LatLng(double.parse(currentLoc.latitude),
            double.parse(currentLoc.longitude));

        // the trick is to remove the marker (by id)
        // and add it again at the updated location
        /*  _markers.removeWhere(
                (m) => m.markerId.value == 'sourcePin');
        _markers.add(Marker(
            markerId: MarkerId('sourcePin'),
            position: pinPosition, // updated position
            icon: sourceIcon
        ));*/
      });
      print("start5");
      print(showPolylines);


      print('polylines>>>>>>>>>>>>');
      print(_polylines);
      setState(() {
        // if (double.parse(currentLoc.accuracy) < 20.0)
        if (showPolylines == true || showTracks == true ) {

          print(showPolylines);
          print("------------------------------------------------tracks");
          print(showTracks);
          latlng.add(LatLng(double.parse(currentLoc.latitude),
              double.parse(currentLoc.longitude)));
          print(latlng);
          print("latlong issssssssss");
          _polylines.add(Polyline(
            polylineId: PolylineId("1"),
            visible: true,
            width: 3,
            //latlng is List<LatLng>
            points: latlng,
            color: Colors.blue,
          ));
        }
      });

    });

    Future.delayed(Duration(seconds: 3), () {

      if(childExist == false) {
        print(childExist);
        print("childExist");
        setState(() {
          kms = "0.0";
        });
        showDialog(
            context: context, child:
        new AlertDialog(
          backgroundColor: buttoncolor.withOpacity(0.7),
          //title: new Text("!"),
          content: new Text("No locations found"),
        ));
      }

    });

    // } );

    //setSourceAndDestinationIcons();
    var date = date2;
    var visits = await getVisitsDataList(date.toString(), empId);

    /*    if (visits.length == 0){
      print("insisdw kms=0.0");
      setState(() {
        kms = "0.0";
      });
      showDialog(context: context, child:
      new AlertDialog(
        backgroundColor: buttoncolor.withOpacity(0.7),
        //title: new Text("!"),
        content: new Text("No location found"),
      )
      );
  }*/
    var generatedIcon;
    List<BitmapDescriptor> generatedIcons=new List<BitmapDescriptor>();
    var j=visits.length;
    print("jjjjjjjjjjjjjjjjjjjjjj"+j.toString());

    if(j == 0 && noVisits == true){

      showDialog(
          context: context, child:
      new AlertDialog(
        backgroundColor: buttoncolor.withOpacity(0.7),
        //title: new Text("!"),
        content: new Text("No visits found"),
      ));
    }

    if(j>0)
      await Future.forEach(visits, (Punch visit) async {

        if(showVisits == true) {
          print('akkakakakakka');
          print(showVisits);
          print(j);
          var m = Marker(
            markerId: MarkerId('sourcePinForVisit$j'),
            position: LatLng(
                double.parse(visit.pi_latit), double.parse(visit.pi_longi)),
            icon: await getMarkerIcon(
                'https://i.dlpng.com/static/png/6865249_preview.png',
                Size(100.0, 100.0), j),

            onTap: () {
              setState(() {
                currentlySelectedPin = PinInformation(pinPath: 'assets/friend1.jpg',
                    avatarPath: visit.pi_img,
                    location: LatLng(0, 0),
                    client: visit.client,
                    description: visit.desc,
                    in_time: visit.pi_time,
                    out_time: visit.po_time,
                    labelColor: Colors.grey);
                pinPillPosition = 100;
              });
              print(visit.po_time);
            },

            infoWindow: InfoWindow(
                title: visit.client,
                snippet: visit.desc
            ),
          );
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _markers.add(m);
              //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
            });
          });

          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 0,
              target: LatLng(double.parse(visit.pi_latit),
                  double.parse(visit.pi_longi)),
              zoom: 19.0,
            ),
          ));
        }

        j--;
      });
  }


  void onDateChanged(String date2)async {

    //_controller1 = new TabController(length: 2, vsync: this);
    var prefs = await SharedPreferences.getInstance();
    date2 = date2.split(" ")[0];
    var orgid123 = await prefs.get("orgid");
    var empid123 = await prefs.get("empid");
    var orgId = await prefs.get("orgid");
    final GoogleMapController controller = await _controller.future;
    print("kjljla"+date2.toString());
    setState(() {
      latlng.clear();
      _polylines.clear();
      _markers.clear();
    });

    var start = 0.0,
        end = 0.0;
    var ii = 0;
    var p = 0;
    int count = 0;
//    int markerCount=0;
    int markerPoint = 0;
    bool childExist = false;
    var lastCurrentLocation;
    List TimeInOutLocations = new List();
    final Uint8List TimeInMapIcon = await getBytesFromAsset('assets/TimeInMapIcon.png', 140);
    final Uint8List currentLocationPinMapIcon = await getBytesFromAsset('assets/mapPinPointMarker.png', 140);
    final Uint8List fakeLocation = await getBytesFromAsset('assets/fakeLocation.png', 140);
    int ID = 1;

    List latitude = new List();
    List longitude = new List();


    var date11 = new DateTime.now().toString();

    var dateParse = DateTime.parse(date2);

    var formattedDate = "${dateParse.day.toString().padLeft(2, '0')}-${dateParse.month.toString().padLeft(2, '0')}-${dateParse.year}";

    var date222 = formattedDate.toString() ;

    CollectionReference _documentRef=Firestore.instance.collection('locations/$orgid123/${this.empId}/$date222/latest');

    // _documentRef.getDocuments().then((ds){





    _documentRef.getDocuments().then((ds){


      if(ds!=null) {
        print("hjsghsgsj" + ds.documents.toString());
        var aaa = ds.documents;
        aaa.sort((a, b) {
          return a.data["location"]["timestamp"].toString()
              .toLowerCase()
              .compareTo(
              b.data["location"]["timestamp"].toString().toLowerCase());
        });


        for (var value in aaa) {
          print("From firestore..........................................>>>>");

          print(value.data["location"]["timestamp"]);
          print("From firestore..........................................>>>>");


          var change1 = new Map<String, dynamic>.from(value.data);
          print('hjjghgjgjgjhgj' +
              change1['location']["activity"]["confidence"].toString());
          var currentLoc = Locations.fromFireStore(change1);

          setState(() {
            childExist = true;
            print(childExist);
            print("child is exist or not");
          });


          TimeInOutLocations.add(
              [currentLoc.latitude, currentLoc.longitude, currentLoc.time]);

          var firstLocation = TimeInOutLocations[0]; //timeIn location
          if (TimeInOutLocations.length > 1) {
            lastCurrentLocation =
            TimeInOutLocations[TimeInOutLocations.length - 1];

            if (currentLoc.mock == "true") { //if user uses mock locations

              ID++;

              print("inside mock location");

              var m1 = Marker(
                markerId: MarkerId('fakeLocation$ID'),
                position: LatLng(double.parse(currentLoc.latitude),
                    double.parse(currentLoc.longitude)),
                // icon: await getMarkerIconForTimeIn("https://as2.ftcdn.net/jpg/02/22/69/89/500_F_222698911_EXuC0fIk12BLaL6BBRJUePXVPn7lOedT.jpg", Size(150.0, 250.0),0),
                icon: BitmapDescriptor.fromBytes(fakeLocation),

                infoWindow: InfoWindow(
                    title: "Fake location found: ",
                    snippet: "         " + currentLoc.time
                ),
              );
              Future.delayed(Duration(seconds: 1), () {
                setState(() {
                  _markers.add(m1);
                  //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
                });
              });
            }

            if (showTracks == true && showPolylines == true) {
              var m1 = Marker(
                markerId: MarkerId(
                    'sourcePinCurrentLocationIcon'),
                position: LatLng(double.parse(lastCurrentLocation[0]),
                    double.parse(lastCurrentLocation[1])),
                icon: BitmapDescriptor.fromBytes(currentLocationPinMapIcon),
                infoWindow: InfoWindow(
                  title: "Last known location: " + currentLoc.time,
                ),
              );

              Future.delayed(Duration(seconds: 1), () {
                setState(() {
                  _markers.add(m1);
                  //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
                });
              });
            }
          }

          if (showTracks == true && showPolylines == true) {
            var m = Marker(
              markerId: MarkerId('sourcePinTimeInIcon'),
              position: LatLng(double.parse(firstLocation[0]),
                  double.parse(firstLocation[1])),
              icon: BitmapDescriptor.fromBytes(TimeInMapIcon),

              infoWindow: InfoWindow(
                title: "Start Time: " + firstLocation[2],
              ),
            );
            Future.delayed(Duration(seconds: 1), () {
              setState(() {
                _markers.add(m);
              });
            });
          }

          end = double.parse(currentLoc.odometer);

          if (((end - start) > 200.0) &&
              (double.parse(currentLoc.accuracy) < accuracy)) {
            start = end;
            markerPoint++;
            getMarker(markerPoint, double.parse(currentLoc.latitude),
                double.parse(currentLoc.longitude), currentLoc.time);

            //   latLong.add([double.parse(currentLoc.latitude), double.parse(currentLoc.longitude)]);

            //Uint8List markerIcon;

            // Future.delayed(Duration(seconds: 2), () {

            /* getBytesFromCanvasForCircleMarker(45, 45, markerPoint).then((a){
            markerIcon = a;
            print(markerIcon);
            print("marker icon");
          });*/
            // });
            // final Uint8List markerIcon = await getBytesFromCanvasForCircleMarker(45, 45, markerPoint);

            p++;

            setState(() {
              if (ii == 0) {
                startM = double.parse(currentLoc.odometer);
                print("current loc odo" + startM.toString());
              }

              endM = double.parse(currentLoc.odometer);
              print("end loc odo" + startM.toString());
              print("error handling");

              kms = ((endM - startM) / 1000).toStringAsFixed(2) + " kms";
              print("sgksshhskhs   " + kms);

              // print(5.75.toStringAsFixed(0));
              // if(endM-startM<0)
              //  kms='0.0';
            });
            //});
            ii++;

            /* if(showPolylines == true || showMarker == true) {
          var m = Marker(
            markerId: MarkerId('sourcePin$p'),
            position: LatLng(double.parse(currentLoc.latitude), double.parse(currentLoc.longitude)),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            infoWindow: InfoWindow(
              title: data.snapshot.key,
            ),
          );
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _markers.add(m);
              //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
            });
          });
        }*/
          }

          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 0,
              target: LatLng(double.parse(currentLoc.latitude),
                  double.parse(currentLoc.longitude)),
              zoom: 19.0,
            ),
          ));

          setState(() {
            var pinPosition = LatLng(double.parse(currentLoc.latitude),
                double.parse(currentLoc.longitude));
          });

          setState(() {
            if (double.parse(currentLoc.accuracy) < accuracy) {
              print(accuracy);
              print(currentLoc.accuracy.toString());
              print("accuracy is");

              if (showPolylines == true || showTracks == true) {
                latlng.add(LatLng(double.parse(currentLoc.latitude),
                    double.parse(currentLoc.longitude)));
                print(latlng);
                print("latlong");

                _polylines.add(Polyline(
                  polylineId: PolylineId("1"),
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
            }
          });
        }
      }
       });


   // markerPoint++;
    print(markerCount);
    print("increment markerpoint");
    print(latitude);

   /* final Uint8List markerIcon = await getBytesFromCanvasForCircleMarker(45, 45, markerPoint);

    if(showPolylines == true || showMarker == true) {
      var m = Marker(
        markerId: MarkerId('sourcePin$p'),
        position: LatLng(lati,longi),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        infoWindow: InfoWindow(
          title: "info",
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _markers.add(m);
          //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
        });
      });
    }*/


    Future.delayed(Duration(seconds: 3), () {

      if(childExist == false) {
        print(childExist);
        print("childExist");
        setState(() {
          kms = "0.0";
        });
        showDialog(
            context: context, child:
        new AlertDialog(
          backgroundColor: buttoncolor.withOpacity(0.7),
          //title: new Text("!"),
          content: new Text("No locations found"),
        ));
      }

    });

    var date = date2;
    var visits = await getVisitsDataList(date.toString(), empId);


    var j=visits.length;

    if(j == 0 && noVisits == true ){

      showDialog(
          context: context, child:
      new AlertDialog(
        backgroundColor: buttoncolor.withOpacity(0.7),
        //title: new Text("!"),
        content: new Text("No visits found"),
      ));
    }

    if(j>0)
      await Future.forEach(visits, (Punch visit) async {

        if(showVisits == true ) {

          var m = Marker(
            markerId: MarkerId('sourcePinForVisit$j'),
            position: LatLng(
                double.parse(visit.pi_latit), double.parse(visit.pi_longi)),
            icon: await getMarkerIcon('https://i.dlpng.com/static/png/6865249_preview.png',
                Size(140.0, 140.0), j),

            onTap: () {
              setState(() {
                currentlySelectedPin = PinInformation(pinPath: 'assets/friend1.jpg',
                    avatarPath: visit.pi_img,
                    location: LatLng(0, 0),
                    client: visit.client,
                    description: visit.desc,
                    in_time: visit.pi_time,
                    out_time: visit.po_time,
                    labelColor: Colors.grey);
                pinPillPosition = 100;
              });
              print(visit.po_time);
            },

            infoWindow: InfoWindow(
                title: visit.client,
                snippet: visit.desc
            ),
          );
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _markers.add(m);
              //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
            });
          });

          if(visitCamera == true)
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 0,
              target: LatLng(double.parse(visit.pi_latit),
                  double.parse(visit.pi_longi)),
              zoom: 19.0,
            ),
          ));
        }

        j--;
      });
  }

  getMarker(markerPoint,latitude,longitude,infoWindow) async {

    final Uint8List markerIcon = await getBytesFromCanvasForCircleMarker(50, 50, markerPoint);

    if(showPolylines == true || showMarker == true) {
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
    }
  }

}


/*getMarker(markerPoint,latitude,longitude){

  final Uint8List markerIcon = await getBytesFromCanvasForCircleMarker(45, 45, markerPoint);

  if(showPolylines == true || showMarker == true) {
    var m = Marker(
      markerId: MarkerId('sourcePin$p'),
      position: LatLng(lati,longi),
      icon: BitmapDescriptor.fromBytes(markerIcon),
      infoWindow: InfoWindow(
        title: "info",
      ),
    );
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _markers.add(m);
        //controller.showMarkerInfoWindow(MarkerId('sourcePin$j'));
      });
    });
  }
}*/


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


class ImagePainter extends StatefulWidget {

  ui.Image image;

  ImagePainter({this.image}) : assert(image != null);
  @override
  State<StatefulWidget> createState() {
    return ImagePainterState();
  }
}


class ImagePainterState extends State<ImagePainter> {


  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CustomImagePainter(image: widget.image),
    );
  }
}

class CustomImagePainter extends CustomPainter {

  ui.Image image;

  CustomImagePainter({this.image}): assert(image != null);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    // TODO: implement paint
    Offset imageSize = Offset(image.width.toDouble(), image.height.toDouble());
    Paint paint = new Paint()
      ..color = Colors.green;
    // canvas.drawCircle(size.center(Offset.zero), 20.0, paint);

    print(size);
    canvas.save();
    var scale = size.width / image.width;
    canvas.scale(scale);
    // canvas.translate(image.width/2 * scale, image.height/2 * scale);
    // canvas.rotate(45 * PI /180);
    // canvas.translate(- image.width /2/ scale, - image.height/2/scale);
    canvas.drawImage(image, Offset.zero, paint);


  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}



///140->100,50->45,150->100