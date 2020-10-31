// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Shrine/addClient.dart';
import 'package:Shrine/globals.dart' as prefix0;
import 'package:Shrine/globals.dart' as globals;
import 'package:Shrine/model/timeinout.dart';
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/newservices.dart';
import 'package:Shrine/services/saveimage.dart';
import 'package:Shrine/services/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Bottomnavigationbar.dart';
import 'askregister.dart';
import 'drawer.dart';
import 'globals.dart';
import 'home.dart';
import 'offline_home.dart';
import 'punchlocation_summaryOld.dart';
import 'services/services.dart';
// This app is a stateful, it tracks the user's current choice.
class PunchLocation extends StatefulWidget {
  final String client;

  PunchLocation({Key key, this.client}) : super(key: key);
  @override
  _PunchLocation createState() => _PunchLocation();
}

class _PunchLocation extends State<PunchLocation> {
  static const platform = const MethodChannel('location.spoofing.check');
  // StreamLocation sl = new StreamLocation();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _clientname = TextEditingController();
  String id="";
  String company="";
  /*var _defaultimage =
      new NetworkImage("http://ubiattendance.ubihrm.com/assets/img/avatar.png");*/
  final TextEditingController _searchQueryController = new TextEditingController();
  final FocusNode _focusNode = new FocusNode();
  var res;
  bool _isSearching = true;
  String _searchText = "";
  var _searchList = List();
  bool _onTap = false;
  int ontap=0;
  int _onTapTextLength = 0;
  String finalClientId;
  _PunchLocation() {
    _searchQueryController.addListener(() {
      if (_searchQueryController.text.isEmpty) {
        setState(() {
         // _isSearching = false;
          _searchText = "";
          _searchList = List();
        });
      } else {
        setState(() {
          _isSearching = true;
          _searchText = _searchQueryController.text;
          _onTap = _onTapTextLength == _searchText.length;
        });
      }
    });
  }
  var profileimage;
  bool _checkLoaded = true;
  int _currentIndex = 1;
  String userpwd = "new";
  String newpwd = "new";
  int Is_Delete=0;
  bool _visible = true;
  String location_addr = "";
  String location_addr1 = "";
  String streamlocationaddr = "";
  String admin_sts = '0';
  String mail_varified = '1';
  String lat = "";
  String long = "";
  String act = "";
  String act1 = "";
  int alertdialogcount = 0;
  Timer timer;
  Timer timer1;
  int response;
  final Widget removedChild = Center();
  String fname = "",
      lname = "",
      empid = "",
      cid = "",
      email = "",
      status = "",
      orgid = "",
      orgdir = "",
      sstatus = "",
      org_name = "",
      desination = "",
      desinationId = "",
      profile;
  //String client="";
  String aid = "";
  String clientname='';
  String shiftId = "";
  int notFound;

  List<Widget> widgets;

  var FakeLocationStatus=0;
  @override
  void initState() {
    /*checkPermission().then((res){
      if(res==false) {
        showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              title: new Text("Please enable Camera access to punch Visit"),
              content: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Open Settings', style: new TextStyle(
                    fontSize: 18.0, color: Colors.white)),
                color: Colors.orangeAccent,
                onPressed: () {
                  PermissionHandler().openAppSettings();
                },
              ),));
      }
    });*/
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    streamlocationaddr=globalstreamlocationaddr;
    initPlatformState();
    //  setLocationAddress();
    // startTimer();
    platform.setMethodCallHandler(_handleMethod);
  }
  bool internetAvailable=true;
  String address="";
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "navigateToPage":
        navigateToPageAfterNotificationClicked(call.arguments["page"].toString(),context);
        break;
      case "locationAndInternet":
        prefix0.locationThreadUpdatedLocation=true;
        // print(call.arguments["internet"].toString()+"akhakahkahkhakha");
        // Map<String,String> responseMap=call.arguments;
        if(call.arguments["TimeSpoofed"].toString()=="Yes"){
          timeSpoofed=true;

        }
        if(call.arguments["internet"].toString()=="Internet Not Available")
        {
          internetAvailable=false;
          print("internet nooooot aaaaaaaaaaaaaaaaaaaaaaaavailable");

          Navigator
              .of(context)
              .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => OfflineHomePage()));

        }
        long=call.arguments["longitude"].toString();
        lat=call.arguments["latitude"].toString();
        assign_lat=double.parse(lat);
        assign_long=double.parse(long);
        address=await getAddressFromLati(lat, long);
        globalstreamlocationaddr=address;
        print(call.arguments["mocked"].toString());


        setState(() {

          if(call.arguments["mocked"].toString()=="Yes"){
            fakeLocationDetected=true;
          }
          else{
            fakeLocationDetected=false;
          }

        });
        break;

    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  /*
  startTimer() {
    const fiveSec = const Duration(seconds: 5);
    int count = 0;
    timer = new Timer.periodic(fiveSec, (Timer t) {
      //print("timmer is running");
      count++;
      //print("timer counter" + count.toString());
    //  setLocationAddress();
      if (stopstreamingstatus) {
        t.cancel();
        //print("timer canceled");
      }
    });
  }

  startTimer1() {
    const fiveSec = const Duration(seconds: 1);
    int count = 0;
    timer1 = new Timer.periodic(fiveSec, (Timer t) {
      print("timmer is running");
    });
  }

  setLocationAddress() async {
    setState(() {
      streamlocationaddr = globalstreamlocationaddr;
      if (list != null && list.length > 0) {
        lat = list[list.length - 1].latitude.toString();
        long = list[list.length - 1].longitude.toString();
        if (streamlocationaddr == '') {
          streamlocationaddr = lat + ", " + long;
        }
      }
      if(streamlocationaddr == ''){
       //sl.startStreaming(5);
      //  startTimer();
      }
      //print("home addr" + streamlocationaddr);
      //print(lat + ", " + long);

      //print(stopstreamingstatus.toString());
    });
  }
*/
  launchMap(String lat, String long) async {
    String url = "https://maps.google.com/?q=" + lat + "," + long;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      //print('Could not launch $url');
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    appResumedPausedLogic(context);
    /*await availableCameras();*/
    final prefs = await SharedPreferences.getInstance();
    empid = prefs.getString('empid') ?? '';
    orgdir = prefs.getString('orgdir') ?? '';
    desinationId = prefs.getString('desinationId') ?? '';
    response = prefs.getInt('response') ?? 0;

    _searchQueryController.text=widget.client;

    if (response == 1) {
      // Loc lock = new Loc();
      //location_addr = await lock.initPlatformState();
      Home ho = new Home();
      act = await ho.checkTimeIn(empid, orgdir,context);
      ho.managePermission(empid, orgdir, desinationId);
      // //print(act);
      ////print("this is-----> "+act);
      ////print("this is main "+location_addr);
      setState(() {
        Is_Delete = prefs.getInt('Is_Delete') ?? 0;
        newpwd = prefs.getString('newpwd') ?? "";
        userpwd = prefs.getString('usrpwd') ?? "";
        print("New pwd"+newpwd+"  User ped"+userpwd);
        location_addr1 = location_addr;
        admin_sts = prefs.getString('sstatus').toString() ?? '0';
        mail_varified = prefs.getString('mail_varified').toString() ?? '0';
        alertdialogcount = globalalertcount;
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
        profileimage = new NetworkImage(profile);
        // //print("1-"+profile);
        profileimage.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((_, __) {
          if (mounted) {
            setState(() {
              _checkLoaded = false;
            });
          }
        }));
        // //print("2-"+_checkLoaded.toString());

        aid = prefs.getString('aid') ?? "";
        shiftId = prefs.getString('shiftId') ?? "";
        ////print("this is set state "+location_addr1);
        act1 = act;
        // //print(act1);
        streamlocationaddr = globalstreamlocationaddr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (response == 0 || userpwd!=newpwd || Is_Delete!=0) ? new AskRegisterationPage() : getmainhomewidget();
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(
          value,
          textAlign: TextAlign.center,
        ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  getmainhomewidget() {
    return new WillPopScope(
        onWillPop: () async => true,
        child: new Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(org_name, style: new TextStyle(fontSize: 20.0)),
              ],
            ),
            leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PunchLocationSummary()),
              );
            },),
            automaticallyImplyLeading: false,
            backgroundColor: appcolor,
            // backgroundColor: Color.fromARGB(255,63,163,128),
          ),


          bottomNavigationBar: Bottomnavigationbar(),
          endDrawer: new AppDrawer(),
          body: (act1 == '') ? Center(child: loader()) : checkalreadylogin(),
        ));
  }

  checkalreadylogin() {

    ////print("---->"+response.toString());
    if (response == 1) {
      return new IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          underdevelopment(),
          (streamlocationaddr != '') ? mainbodyWidget() : refreshPageWidgit(),
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

  refreshPageWidgit() {
    if (location_addr1 != "PermissionStatus.deniedNeverAsk") {
      return new Container(
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 20.0,),
                    Icon(
                      Icons.all_inclusive,
                      color: appcolor,
                    ),
                    Text(
                      " Fetching location, please wait..",
                      style: new TextStyle(fontSize: 20.0, color: appcolor),
                    )
                  ]),
              SizedBox(height: 15.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 20.0,),
                    Text(
                      "Note: ",
                      style: new TextStyle(
                          fontSize: 15.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      " If Location not being fetched automatically?",
                      style: new TextStyle(fontSize: 12.0, color: Colors.black),
                      textAlign: TextAlign.left,
                    ),

                  ]),

              FlatButton(
                child: new Text(
                  "Fetch Location now",
                  style: new TextStyle(
                      color: appcolor, decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  //sl.startStreaming(5);
                  //      startTimer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Location permission is restricted from app settings, click "Open Settings" to allow permission.',
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

  loader() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset('assets/spinner.gif', height: 50.0, width: 50.0),
            ]),
      ),
    );
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
                      "Poor network connection.",
                      style: new TextStyle(fontSize: 20.0, color: appcolor),
                    ),
                  ]),
              SizedBox(height: 5.0),
              FlatButton(
                child: new Text(
                  "Refresh location",
                  style: new TextStyle(
                      color: appcolor, decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  //sl.startStreaming(5);
                  //   startTimer();
                  cameraChannel.invokeMethod("startAssistant");

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PunchLocation()),
                  );
                },
              ),
            ]),
      ),
    );
  }

  mainbodyWidget() {
    ////to do check act1 for poor network connection

    if (act1 == "Poor network connection") {
      return poorNetworkWidget();
    } else {
      var globals;
      return SafeArea(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              // foregroundDecoration: BoxDecoration(color:Colors.red ),
              height: MediaQuery.of(context).size.height * 0.80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top:12.0,bottom: 2.0),
                    child:Center(
                      child:Text('Punch Visit',
                          style: new TextStyle(fontSize: 22.0,color:appcolor)),
                    ),
                  ),
                  //SizedBox(height: MediaQuery.of(context).size.height * .01),
                  //Image.asset('assets/logo.png',height: 150.0,width: 150.0),
                  //SizedBox(height: 5.0),
                  advancevisit==1?getClients_DD():getClients_DD1(),
                  //SizedBox(height: 35.0),
                  SizedBox(height: MediaQuery.of(context).size.height * .04),
                  // SizedBox(height: MediaQuery.of(context).size.height*.01),
                  (act1 == '') ? loader() : getMarkAttendanceWidgit(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  getMarkAttendanceWidgit() {
    return Expanded(
      child: Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 1.0),
              getwidget(location_addr1),
            ]),
      ),
    );

  }
  getwidget(String addrloc) {
    if (addrloc != "PermissionStatus.deniedNeverAsk") {
      return Column(children: [
        ButtonTheme(
          minWidth: 120.0,
          height: 45.0,
          child: getVisitInButton(),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * .01),
        Padding(
          padding: const EdgeInsets.only(left:8.0,right: 8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide( color: Colors.grey.withOpacity(0.5), width: 1,),
            ),
            elevation: 0.0,
            borderOnForeground: true ,
            clipBehavior: Clip.antiAliasWithSaveLayer ,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * .15,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    FlatButton(
                      child: new Text(globalstreamlocationaddr,
                          textAlign: TextAlign.center,
                          style: new TextStyle(fontSize: 14.0,color: Colors.black54)),
                      onPressed: () {
                        launchMap(lat, long);
                      },
                    ),
                    new Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[

                          SizedBox(width: 1.0,),
                          new InkWell(
                            child:Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(const IconData(0xe81a, fontFamily: "CustomIcon"),size: 15.0,color: prefix0.appcolor,),
                                  ),
                                  Text(
                                    "Refresh location",
                                    style: new TextStyle(
                                        color: appcolor,
                                        decoration: TextDecoration.none),
                                  ),
                                ]),
                            onTap: () {
                              //   startTimer();
                              //sl.startStreaming(5);
                              cameraChannel.invokeMethod("startAssistant");
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PunchLocation()),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ])),
            ),
          ),
        ),
      ]);
    } else {
      return Column(children: [
        Text(
            'Location permission is restricted from app settings, click "Open Settings" to allow permission.',
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

  getVisitInButton() {
    return notFound==1?RaisedButton(
      clipBehavior: Clip.antiAlias,
      elevation: 0.0,
      highlightElevation: 0.0,
      highlightColor: Colors.transparent,
      disabledElevation: 50.0,
      focusColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('ADD CLIENT',
          style: new TextStyle(fontSize: 18.0, color: Colors.white)),
      color: buttoncolor,
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddClient(
              company: _searchQueryController.text,
              clientaddress: globalstreamlocationaddr,
              sts:"2"
          )),
        );
      },
    ):notFound==3?RaisedButton(
      clipBehavior: Clip.antiAlias,
      elevation: 0.0,
      highlightElevation: 0.0,
      highlightColor: Colors.transparent,
      disabledElevation: 50.0,
      focusColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('ASSIGN TEMPORARILY',
          style: new TextStyle(fontSize: 18.0, color: Colors.white)),
      color: buttoncolor,
      onPressed: () async {
        temporarilyAssign(id).then((res) {
          if(int.parse(res)==0) {
            showDialog(context: context, child:
            new AlertDialog(
              //title: new Text("Alert"),
              content: new Text("Unable to assign client"),
            ));
          } else {
            showDialog(context: context, child:
            new AlertDialog(
              //title: new Text("Alert"),
              content: new Text("Client has been temporarily assigned to you"),
            ));
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PunchLocation(client: company,)));
          }
        }
        ).catchError((err){
          showDialog(context: context, child:
          new AlertDialog(
            title: new Text("Alert"),
            content: new Text("Unable to call the service"),
          ));
          //showInSnackBar('Unable to call the service');
        });
      },
    ):RaisedButton(
      clipBehavior: Clip.antiAlias,
      elevation: 0.0,
      highlightElevation: 0.0,
      highlightColor: Colors.transparent,
      disabledElevation: 50.0,
      focusColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        //side: BorderSide( color: Colors.red.withOpacity(0.5), width: 2,),
      ),
      child: Text('VISIT IN',
          style: new TextStyle(fontSize: 18.0, color: Colors.white)),
      color: buttoncolor,
      onPressed: () async {
        globalCameraOpenedStatus=true;
        if(advancevisit==1) {
          if (_searchQueryController.text.trim().isEmpty) {
            showDialog(
                context: context,
// ignore: deprecated_member_use
                child: new AlertDialog(
                  content: new Text(
                      "Please select a client first"),
                ));
            return false;
          }else{
            saveVisitImage();
            return true;
          }
        }else{
          if(_clientname.text.trim().isEmpty) {
            showDialog(
                context: context,
// ignore: deprecated_member_use
                child: new AlertDialog(
                  content: new Text("Please enter client name first"),
                ));
//showInSnackBar('Please enter client name first');
            return false;
          } else {
            saveVisitImage();
            return true;
          }
        }
      },
    );
  }

  Text getText(String addrloc) {
    if (addrloc != "PermissionStatus.deniedNeverAsk") {
      return Text('You are at: ' + addrloc,
          textAlign: TextAlign.center, style: new TextStyle(fontSize: 14.0));
    } else {
      return new Text(
          'Location access is denied. Enable the access through the settings.',
          textAlign: TextAlign.center,
          style: new TextStyle(fontSize: 14.0, color: Colors.red));
      /*return new  Text('Location is restricted from app settings, click here to allow location permission and refresh', textAlign: TextAlign.center, style: new TextStyle(fontSize: 14.0,color: Colors.red));*/
    }
  }

  saveVisitImage() async {
    // sl.startStreaming(5);
    //client = _clientname.text;

    advancevisit==1?clientname = _searchQueryController.text:clientname = _clientname.text;
    print("clientname");
    print(clientname);
    MarkVisit mk = new MarkVisit(empid, clientname, finalClientId, streamlocationaddr, orgdir, lat, long, FakeLocationStatus);
    /* mk1 = mk;*/

    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraExampleHome()),
      );*/
      /*PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
      print("permission status");
      print(permission);
      print("permission status");

      if(permission.toString()=='PermissionStatus.denied' && globals.visitImage==1){
        print("PermissionStatus.denied");
        await showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              title: new Text("Please enable Camera access to punch Visit"),
              content: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Open Settings', style: new TextStyle(
                    fontSize: 18.0, color: Colors.white)),
                color: Colors.orangeAccent,
                onPressed: () {
                  PermissionHandler().openAppSettings();
                },
              ),));
        return;
      }*/
      SaveImage saveImage = new SaveImage();
      bool issave = false;
      setState(() {
        act1 = "";
      });
      var prefs= await SharedPreferences.getInstance();
      showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??false;
      issave = showAppInbuiltCamera?await saveImage.saveVisitAppCamera(mk,context):await saveImage.saveVisit(mk,context);
      ////print(issave);
      if (issave) {
        // ignore: deprecated_member_use
        showDialog(context: context, child:
        new AlertDialog(
          content: Text("'Visit In' punched successfully"),
        )
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PunchLocationSummary()),
        );
        setState(() {
          act1 = act;
        });
      } else {
        // ignore: deprecated_member_use
        showDialog(context: context, child:
        new AlertDialog(

          content: new Text("Selfie was not captured. Please punch again."),
        )
        );
        setState(() {
          act1 = act;
        });
      }
    }else{
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(

        content: new Text("Internet connection not found!."),
      )
      );
    }


    /*SaveImage saveImage = new SaveImage();
    bool issave = false;
    setState(() {
      act1 = "";
    });
    issave = await saveImage.saveTimeInOut(mk);
    ////print(issave);
    if (issave) {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
      setState(() {
        act1 = act;
      });
    } else {
      setState(() {
        act1 = act;
      });
    }*/
  }

/*  saveImage() async {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraApp()),
      );

  }*/

  resendVarification() async{
    NewServices ns= new NewServices();
    bool res = await ns.resendVerificationMail(orgid);
    if(res){
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              content: Row( children:<Widget>[
                Text("Verification link has been sent to \nyour organization's registered \nEmail."),
              ]
              )
          )
      );
    }
  }

  Widget getFutureWidget() {
    print('----------getFutureWidget123--------------');
    return new FutureBuilder(
        future: _buildSearchList(),
        initialData: List<ListTile>(),
        builder: (BuildContext context, AsyncSnapshot<List<ListTile>> childItems) {
          return new Container(
            //color: Colors.white,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(1),// changes position of shadow
                ),
              ],
            ),
            //height: getChildren(childItems).length*15.0,
            height:_searchList.length==1?MediaQuery.of(context).size.height*0.1:notFound!=1?MediaQuery.of(context).size.height*0.27:MediaQuery.of(context).size.height*0.0,
            width: MediaQuery.of(context).size.width,
            child: new Stack(
              children: <Widget>[
                ListView(
                  //   padding: new EdgeInsets.only(left: 50.0),
                  children: childItems.data.isNotEmpty
                      ? ListTile
                      .divideTiles(
                      context: context, tiles: getChildren(childItems))
                      .toList()
                      : List(),
                ),
              ],
            ),
          );
        });
  }

  List<ListTile> getChildren(AsyncSnapshot<List<ListTile>> childItems) {
    if (_onTap && _searchText.length != _onTapTextLength) _onTap = false;
    print("childItems.data");
    print(childItems.data);
    List<ListTile> childrenList = _isSearching && !_onTap ? childItems.data : List();
    print("childrenList");
    print(childrenList);
    return childrenList;
  }

  ListTile _getListTile(var suggestedPhrase, int listIndex) {
    return new ListTile(
      dense: true,
      trailing: InkWell(
          child: Icon(Icons.info, size: 40,color: Colors.grey[400],),
          onTap: (){
            FocusScope.of(context).unfocus();
            print("_searchList.length");
            print(_searchList.length);
            _showModalSheet(context, listIndex);
            /*Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => AddClient(
                   company: _searchQueryController.text,
                   clientaddress: globalstreamlocationaddr,
                   sts:"2"
               )),
             );*/
          },
        ),
      /*title: new Text(
        suggestedPhrase["company"]+" assigned to "+suggestedPhrase["employeename"],
        style: TextStyle(color: (suggestedPhrase["assignsts"].toString()=='1')?Colors.black:Colors.grey  )
      ),*/
      title: RichText(
        text: TextSpan(
          text: suggestedPhrase["company"],
          style: TextStyle(color:(suggestedPhrase["assignsts"].toString()=='1')?Colors.black:Colors.grey , fontSize: 16),
          children: <TextSpan>[
            suggestedPhrase["employeename"]!=''?TextSpan(text: ' assigned to ', style: TextStyle(color: Colors.grey),):null,
            TextSpan(text: suggestedPhrase["employeename"], style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      onTap: () {
        setState(() {
          _onTap = true;
          _isSearching = false;
          _onTapTextLength = suggestedPhrase["company"].length;
          if(suggestedPhrase["assignsts"].toString()=='2') {
            notFound=3;
            id=suggestedPhrase["id"];
            company=suggestedPhrase["company"];
            _searchQueryController.text = suggestedPhrase["company"];
          }
        });
        _searchQueryController.text = suggestedPhrase["company"];
      },
    );
  }

  Future<List<ListTile>> _buildSearchList() async {
    print('----------_buildSearchList--------------');
    /*if (_searchText.isEmpty) {
      _searchList = List();
      return List();
    } else {*/
      _searchList = await _getSuggestion(_searchText, orgdir, empid) ?? List();
      print("_searchList");
      print(_searchList);
      //..add(_searchText);
      List<ListTile> childItems = new List();
      int index = 0;
      for (var value in _searchList) {
        index = (index+1);
        print("index");
        print(index-1);
        //  if (!(value.contains(" ") && value.split(" ").length > 2)) {
        childItems.add(_getListTile(value, index-1));
        print(childItems);
        Divider();
        // }
      }
      return childItems;
    //}
  }

  Future<List<Map<String, String>>> _getSuggestion(String hintText, String orgdir, String empid) async {
    print('--------_getSuggestion-------------');
    print(hintText);
    print(orgdir);
    String url = globals.path+"getClientList?startwith=$hintText&orgdir=$orgdir&empid=$empid";//=$hintText&max=4
    print(url);
    var response = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    print(response.body);
    List decode = json.decode(response.body);
    res=json.decode(response.body.toString());
    if (response.statusCode != HttpStatus.OK || decode.length == 0) {
      print("if data not found");
      notFound=1;
      return null;
    } else {
      print("if data found");
      notFound=0;
      List<Map<String,String>> suggestedWords = new List();
      //if (decode.length == 0) return null;
      print('-------------------------1');
      print(decode);
      decode.forEach((f) => suggestedWords.add({"id":f['Id'],"company":f['Company'],"name":f['Name'],"contact":f['Contact'],"email":f['Email'],"addr":f['Address'],"desc":f['Description'],"employeename":f['EmployeeName'],"assignsts":f['Assignsts']}));
      print('-------------------------2');
      return suggestedWords;
    }
  }

////////////////////////////////////////////////////////////
  Widget getClients_DD() {
    return Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                child: Center(
                  child: Form(
                    child: Padding(
                      padding: const EdgeInsets.only(left:16.0,right: 16.0,top: 40.0),
                      child: /*TextFormField(
                    controller: _clientname,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                        ),
                        labelText: 'Client Name',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Icon(
                            Icons.supervised_user_circle,
                            color: Colors.grey,
                          ), // icon is 48px widget.
                        )
                    ),
                  ),*/
                      new TextFormField(
                        onTap:(){
                          print("getFutureWidget");
                          getFutureWidget();
                        },
                        controller: _searchQueryController,
                        focusNode: _focusNode,
                        onFieldSubmitted: (String value) {
                          print("$value submitted");
                          setState(() {
                            _searchQueryController.text = value;
                            _onTap = true;
                          });
                        },
                        onSaved: (String value) => print("$value saved"),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                            ),
                            labelText: 'Client Name',
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(0.0),
                              child: Icon(
                                Icons.supervised_user_circle,
                                color: Colors.grey,
                              ), // icon is 48px widget.
                            ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top:100.0, left: 20.0, right:20.0, bottom:10.0),
            child: new Container(
                //alignment: Alignment.topCenter,
                //height: 150.0,
               /* decoration: BoxDecoration(
                  border: Border.all()
                ),*/
                padding: new EdgeInsets.only(
                   // top: MediaQuery.of(context).size.height * .15,
                    //top: 60.0,
                    //right: 20.0,
                    //left: 38.0
                   ),
                child: _isSearching && (!_onTap) ? getFutureWidget() : null),
          )
        ]
    );
  }

  Widget getClients_DD1() {
    return Center(
      child: Form(
        child: Padding(
          padding: const EdgeInsets.only(left:16.0,right: 16.0,top: 10.0),
          child: TextFormField(
            controller: _clientname,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                ),
                labelText: 'Client Name',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Icon(
                    Icons.supervised_user_circle,
                    color: Colors.grey,
                  ), // icon is 48px widget.
                )
            ),
          ),
        ),
      ),
    );

  }

  _showModalSheet(context, int i) async{
    showRoundedModalBottomSheet(context: context, builder: (builder) {
      return Container(
        height: MediaQuery.of(context).size.height*0.40,
        decoration: new BoxDecoration(
            color: appcolor.withOpacity(0.2),
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(0.0),
                topRight: const Radius.circular(0.0))),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //Text('Client Name: ', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                  Text(_searchList[i]['company'], style: TextStyle(fontSize: 22.0, color: appcolor, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height:10.0),
              Row(
                children: <Widget>[
                  //Text('Contact Person: ', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                  Icon(Icons.person),
                  SizedBox(width:10.0),
                  Text(_searchList[i]['name'], style: TextStyle(fontSize: 16.0)),
                ],
              ),
              SizedBox(height:5.0),
              Row(
                children: <Widget>[
                  //Text('Contact: ', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                  Icon(Icons.phone),
                  SizedBox(width:10.0),
                  Text(_searchList[i]['contact'], style: TextStyle(fontSize: 16.0)),
                ],
              ),
              SizedBox(height:5.0),
              Row(
                children: <Widget>[
                  //Text('Email ID: ', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                  Icon(Icons.mail),
                  SizedBox(width:10.0),
                  Text(_searchList[i]['email'], style: TextStyle(fontSize: 16.0)),
                ],
              ),
              SizedBox(height:5.0),
              Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Icon(Icons.location_on),
                      //Text('Address: ', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                    ],
                  ),
                  SizedBox(width:10.0),
                  Flexible(
                    child: Column(
                      children: <Widget>[
                        Text(_searchList[i]['addr'], style: TextStyle(fontSize: 16.0)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height:5.0),
              Row(
                children: <Widget>[
                  //Text('Description: ', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                  Icon(Icons.description),
                  SizedBox(width:10.0),
                  Text(_searchList[i]['desc'], style: TextStyle(fontSize: 16.0)),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  temporarilyAssign(String id) async {
    final prefs = await SharedPreferences.getInstance();
    String empid = prefs.getString('empid') ?? '';
    String orgid = prefs.getString('orgdir') ?? '';
    print(globals.path + 'tempAssignClient?uid=$empid&orgid=$orgid&cid=$id');
    final response = await http.get(globals.path + 'tempAssignClient?uid=$empid&orgid=$orgid&cid=$id');
    return response.body.toString();
  }

////////////////////////////////////////////////////////////
}
