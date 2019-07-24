// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:Shrine/services/services.dart';
import 'outside_label.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'drawer.dart';
import 'Image_view.dart';
import 'home.dart';
import 'reports.dart';
import 'settings.dart';
import 'profile.dart';
import 'package:Shrine/database_models/attendance_offline.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

// This app is a stateful, it tracks the user's current choice.
class OfflineAttendanceLogs extends StatefulWidget {
  @override
  _OfflineAttendanceLogs createState() => _OfflineAttendanceLogs();
}
String _orgName;
String org_name="";
class _OfflineAttendanceLogs extends State<OfflineAttendanceLogs> with SingleTickerProviderStateMixin {
  TabController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String fname="";
  String lname="";
  String desination="";
  String profile="";

  int _currentIndex = 1;
  String admin_sts='0';
  String countP='-',countA='-',countL='-',countE='-';
  AttendanceOffline attendances;
  List<Map<String,String>> chartData;
  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(value,textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
  getOrgName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName= prefs.getString('org_name') ?? '';
    });
/*
    getChartDataToday().then((onValue){
      print('get chart data summary called successfully......');
      setState(() {
        countP=onValue[0]['present'];
        countA=onValue[0]['absent'];
        countL=onValue[0]['late'];
        countE=onValue[0]['early'];
      });
    });
*/
  }
  @override
  void initState() {
    super.initState();
   // checkNetForOfflineMode(context);
   // appResumedFromBackground(context);
    attendances=AttendanceOffline.empty();
    initPlatformState();
    _controller = new TabController(length: 4, vsync: this);
    getOrgName();

  }

  initPlatformState() async {
    //checkNetForOfflineMode(context);
    //appResumedFromBackground(context);
    final prefs = await SharedPreferences.getInstance();



    setState(() {
      org_name = prefs.getString('org_name') ?? '';


    });
  }
  Future<bool> sendToHome() async{
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );*/
    print("-------> back button pressed");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,
    );
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: ()=> sendToHome(),
        child: new Scaffold(
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
            backgroundColor: Colors.teal,
          ),


          body: getWidgets(context),
        )
    );

  }
  getWidgets(context) {
    return new ListView(
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        SizedBox(height:3.0),
        Container(
          padding: EdgeInsets.only(top:12.0,bottom: 2.0),
          child:Center(
            child:Text('Unsynced Attendance Log',
                style: new TextStyle(fontSize: 22.0, color: Colors.teal,)),
          ),
        ),
        Divider(color: Colors.black54,height: 1.5,),



        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//            crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 70.0,),
            Container(
              width: MediaQuery.of(context).size.width*0.22,
              child:Text('  Selfie',style: TextStyle(color: Colors.black54,fontWeight:FontWeight.bold,fontSize: 16.0),),
            ),
            SizedBox(height: 70.0,),
            Container(
              width: MediaQuery.of(context).size.width*0.44,
              child:Text(' Event',style: TextStyle(color: Colors.black54,fontWeight:FontWeight.bold,fontSize: 16.0),),
            ),
            SizedBox(height: 70.0,),
            Container(
              width: MediaQuery.of(context).size.width*0.22,
              child:Text(' Date',style: TextStyle(color: Colors.black54,fontWeight:FontWeight.bold,fontSize: 16.0),),
            ),
          ],
        ),
        new Divider(height: 1.0,color: Colors.black45,),
        new Container(
            height: MediaQuery.of(context).size.height*0.60,
            child: new FutureBuilder<List<AttendanceOffline>>(
              future: attendances.select(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if(snapshot.data.length>0) {
                    return new ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return new Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: <Widget>[
                                    SizedBox(height: 40.0,),


                                    Container(
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.22,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center,
                                          children: <Widget>[

                                            Container(
                                              width: 62.0,
                                              height: 62.0,
                                              child:InkWell(
                                                child: Container(

                                                              child:  ClipOval(


                                                                  child:Image.memory(base64Decode(snapshot
                                                                    .data[index]
                                                                    .PictureBase64),height: 100,
                                                                    width: 100,
                                                                    fit: BoxFit.cover,))

                                                    ),
                                                onTap: (){
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => ImageView.fromImage((snapshot
                                                        .data[index]
                                                        .PictureBase64),org_name)),
                                                  );
                                                },
                                              ),),

                                          ],
                                        )

                                    ),
                                    Container(
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.44,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text((snapshot.data[index].Action
                                                ==0)?" Time In"+", "+ snapshot.data[index].Time+" , Location:"+snapshot.data[index].Latitude+", "+snapshot.data[index].Longitude:" Time Out"+", "+ snapshot.data[index].Time+" , Location:"+snapshot.data[index].Latitude+", "+snapshot.data[index].Longitude ,style: TextStyle(fontSize: 14.0,)),


                                          ],
                                        )

                                    ),

                                    Container(
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width * 0.22,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(snapshot.data[index].Date
                                              .toString(), style: TextStyle(
                                            color: Colors.black87,

                                          ),),

                                          SizedBox(height: 15.0,),


                                        ],
                                      ),
                                    ),
                                  ],

                                ),
                                Divider(color: Colors.black26,),
                              ]);
                        }
                    );
                  }else{
                    return new Center(
                      child:Text("No logs found"),
                    );
                  }
                }
                else if (snapshot.hasError) {
                  return new Center(child:Text("Unable to connect server"));
                }

                // By default, show a loading spinner
                return new Center( child: CircularProgressIndicator());
              },
            )
        ),
      ],
    );

  }
}



