// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:Shrine/services/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Image_view.dart';
import 'drawer.dart';
import 'globals.dart';
import 'outside_label.dart';
// This app is a stateful, it tracks the user's current choice.
class Suspicious_selfies extends StatefulWidget {
  @override
  _Suspicious_selfies createState() => _Suspicious_selfies();
}
TextEditingController today;String _orgName='';
class _Suspicious_selfies extends State<Suspicious_selfies> with SingleTickerProviderStateMixin {
  TabController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var formatter = new DateFormat('dd-MMM-yyyy');
  bool res = true;
  String admin_sts = "0";
  var Hightvar = 0.0;
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
      admin_sts = prefs.getString('sstatus') ?? '';
      if(admin_sts == '2')
        Hightvar =  MediaQuery.of(context).size.height*0.8;
      else
        Hightvar =  MediaQuery.of(context).size.height*0.8;
    });
  }

  showsuspiciousdialog(id) async {

    await showDialog<String>(
      context: context,
      // ignore: deprecated_member_use
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(8.0),
        content: Container(
          height: MediaQuery.of(context).size.height*0.04,
          width: MediaQuery.of(context).size.width*0.06,
          child: Column(
            children: <Widget>[
              /*new Expanded(
                child: new TextField(
                  maxLines: 5,
                  autofocus: true,
                  controller: _comments,
                  decoration: new InputDecoration(
                      labelText: 'Visit Feedback ', hintText: 'Visit Feedback (Optional)'),
                ),
              ),*/
              Text('Disapprove?'
              ),
              SizedBox(height: 4.0,),

            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide( color: Colors.grey.withOpacity(0.5), width: 1,),
              ),
              child: const Text('CANCEL',style: TextStyle(color: Colors.black),),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              }),
          Padding(
            padding: const EdgeInsets.only(right:40.0),
            child: new RaisedButton(
                child: const Text('DISAPPROVE',style: TextStyle(color: Colors.white),),
                elevation: 2.0,
                highlightElevation: 5.0,
                highlightColor: Colors.transparent,
                disabledElevation: 0.0,
                focusColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                color: buttoncolor,
                onPressed: () async{
                  Navigator.of(context, rootNavigator: true).pop();
                  disapprovesuspiciousattn(id).then((res){
                    print(res.toString());

                 //   if(res)
                  //  {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Suspicious_selfies()),
                      );
                      showDialog(
                          context: context,
                          // ignore: deprecated_member_use
                          child: new AlertDialog(
                            content: new Text("\"Attendance\" disapproved successfully"),
                          ));
                  //  }
                  //  else
//                  {
//                    showDialog(
//                        context: context,
//                        // ignore: deprecated_member_use
//                        child: new AlertDialog(
//                          content: new Text("Unable to disapprove attendance"),
//                        ));
                    });
//                }).catchError((ett){
//                  showInSnackBar('Unable to disapprove attendance');
//                });
                  /*       //  Loc lock = new Loc();
                  //   location_addr1 = await lock.initPlatformState();
                  if(_isButtonDisabled)
                    return null;

                  Navigator.of(context, rootNavigator: true).pop('dialog');
                  setState(() {
                    _isButtonDisabled=true;
                  });
                  //PunchInOut(comments.text,'','empid', location_addr1, 'lid', 'act', 'orgdir', latit, longi).then((res){
                  SaveImage saveImage = new SaveImage();
                   saveImage.visitOut(comments.text,visit_id,location_addr1,latit, longi).then((res){
print('visit out called for visit id:'+visit_id);
                  /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PunchLocationSummary()),
                    );
*/


                  }).catchError((onError){
                    showInSnackBar('Unable to punch visit');
                  });
*/
                }),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    _controller = new TabController(length: 1, vsync: this);
    getOrgName();
    today = new TextEditingController();
    today.text = formatter.format(DateTime.now());
    platform.setMethodCallHandler(_handleMethod);
  }
  static const platform = const MethodChannel('location.spoofing.check');

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {
/*
      case "locationAndInternet":
      // print(call.arguments["internet"].toString()+"akhakahkahkhakha");
      // Map<String,String> responseMap=call.arguments;
        if(call.arguments["TimeSpoofed"].toString()=="Yes"){
          timeSpoofed=true;

        }
        if(call.arguments["internet"].toString()=="Internet Not Available")
        {

          print("internet nooooot aaaaaaaaaaaaaaaaaaaaaaaavailable");

          Navigator
              .of(context)
              .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => OfflineHomePage()));

        }
        break;

        return new Future.value("");

 */
    }
  } @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(_orgName, style: new TextStyle(fontSize: 20.0)),
        backgroundColor: appcolor,
      ),
      endDrawer: new AppDrawer(),
      body: new ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(height:10.0),
          new Container(
            child: Center(child:Text("Suspicious Selfies",style: TextStyle(fontSize: 22.0,color: appcolor),),),
          ),
          Divider(color: Colors.black54,height: 1.5,),
          Container(
            child: DateTimeField(
              //dateOnly: true,
              format: formatter,
              controller: today,
              //editable: false,
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime.now());
              },
              readOnly: true,
              decoration: InputDecoration(
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
                  if (date != null && date.toString()!='')
                    res = true; //showInSnackBar(date.toString());
                  else
                    res = false;
                });
              },
              validator: (date) {
                if (date == null) {
                  return 'Please select date';
                }
              },
            ),
          ),

//          (res==true && admin_sts=='1') ?new Container(
//            padding: EdgeInsets.all(0.1),
//            margin: EdgeInsets.all(0.1),
//            child: new ListTile(
//              title: new SizedBox(height: MediaQuery.of(context).size.height*0.27,
//
//                child: new FutureBuilder<List<Map<String,String>>>(
//                    future: getChartDataCDate(today.text),
//                    builder: (context, snapshot) {
//                      if (snapshot.hasData) {
//                        if (snapshot.data.length > 0) {
//                          return new PieOutsideLabelChart.withRandomData(snapshot.data);
//                        }
//                      }
//                      return new Center( child: CircularProgressIndicator());
//                    }
//                ),
//
//                //  child: new PieOutsideLabelChart.withRandomData(),
//
//                width: MediaQuery.of(context).size.width*1.0,),
//            ),
//          ): admin_sts=='1'?Container(
//            height: MediaQuery.of(context).size.height*0.25,
//            child: Center(
//              child: Container(
//                width: MediaQuery.of(context).size.width*1,
//                color: appcolor.withOpacity(0.1),
//                padding:EdgeInsets.only(top:5.0,bottom: 5.0),
//                child:Text("No Chart Available",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
//              ),
//            ),
//
//          ):Center(),
//          (res==true && admin_sts=='1')?new Row(
//            crossAxisAlignment: CrossAxisAlignment.center,
//            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//            children: <Widget>[
//              Text('Present(P)',style: TextStyle(color:appcolor,fontSize: 12.0),),
//              Text('Absent(A)',style: TextStyle(color:appcolor,fontSize: 12.0),),
//              Text('Late Comers(LC)',style: TextStyle(color:appcolor,fontSize: 12.0),),
//              Text('Early Leavers(EL)',style: TextStyle(color:appcolor,fontSize: 12.0),)
//            ],
//          ):Center(),

          //Divider(),
//          new Container(
//            decoration: new BoxDecoration(color: Colors.black54),
//            child: new TabBar(
//              indicator: BoxDecoration(color: buttoncolor,),
//              controller: _controller,
//              tabs: [
//                new Tab(
//                  text: 'Present',
//                ),
//                new Tab(
//                  text: 'Absent',
//                ),
//                new Tab(
//                  text: 'Late \nComers',
//                ),
//                new Tab(
//                  text: 'Early \nLeavers',
//                ),
//              ],
//            ),
//          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.20,
                child:Text('     Name',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 14.0),),
              ),
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.22,
                child:Text('    Face ID',textAlign: TextAlign.right,style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 14.0),),
              ),
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.20,
                child:Text('       Selfies',textAlign: TextAlign.right,style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 14.0),),
              ),
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.20,
                child:Text('Match(%)',textAlign: TextAlign.right,style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 14.0),),
              ),
              SizedBox(height: 50.0,),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width*0.20,
                  child:Text('  Action',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 14.0),),
                ),
              ),
            ],
          ),
          new Divider(height: 1.0,),
          res==true?new Container(
            height: Hightvar,
            child: new TabBarView(
              controller: _controller,
              children: <Widget>[
                new Container(
                  height: Hightvar,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: Hightvar,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<SuspiciousAttn>>(
                        future: getCDateSSAttn('present',today.text),
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
                                            children: <Widget>[
                                              SizedBox(height: 40.0,),
                                              Container(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.22,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: <Widget>[
                                                    Text(snapshot.data[index].Name
                                                        .toString(), style: TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14.0),),

                                                    InkWell(
                                                      child: Text(
                                                          snapshot.data[index]
                                                              .TimeInOut.toString(),
                                                          style: TextStyle(
                                                              color: Colors.black54,
                                                              fontSize: 12.0)),
                                                    ),
                                                    SizedBox(height: 15.0,),


                                                  ],
                                                ),
                                              ),

                                              Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.20,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      Container(
                                                        width: 62.0,
                                                        height: 62.0,
                                                        child:InkWell(
                                                          child: Container(
                                                              decoration: new BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image: new DecorationImage(
                                                                      fit: BoxFit.fill,
                                                                      image: new NetworkImage(
                                                                          snapshot
                                                                              .data[index]
                                                                              .ProfileImage)
                                                                  )
                                                              )),
                                                          onTap: (){
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].ProfileImage,org_name: _orgName)),
                                                            );
                                                          },
                                                        ),
                                                      ),

                                                    ],
                                                  )

                                              ),
                                              Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.20,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      Container(
                                                        width: 62.0,
                                                        height: 62.0,
                                                        child:InkWell(
                                                          child: Container(
                                                              decoration: new BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image: new DecorationImage(
                                                                      fit: BoxFit.fill,
                                                                      image: new NetworkImage(
                                                                          snapshot
                                                                              .data[index]
                                                                              .EntryExitImage)
                                                                  )
                                                              )),
                                                          onTap: (){
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].EntryExitImage,org_name: _orgName)),
                                                            );
                                                          },
                                                        ),
                                                      ),

                                                    ],
                                                  )

                                              ),
                                              Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.14,
                                                  child: Text("     "+((double.parse(snapshot.data[index].TimeInOutConfidence
                                                      .toString())*100).toStringAsFixed(0)), style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14.0),),

                                              ),
                                              Expanded(
                                                child: Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.14,
                                                  child: IconButton(
                                                    icon: Icon(Icons.block,color: Colors.red,),
                                                    tooltip: 'Disapprove selfie?',
                                                    onPressed: () {
                                                      showsuspiciousdialog(snapshot.data[index].Id);
                                                    },
                                                  ),

                                                ),
                                              ),
                                            ],

                                          ),
                                          Divider(color: Colors.black26,),
                                        ]);}
                              );
                            }else{
                              return new Container(
                                  height: MediaQuery.of(context).size.height*0.30,
                                  child:Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*1,
                                      color: appcolor.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child:Text("No suspicious selfies on this date ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                    ),
                                  )
                              );
                            }
                          }
                          else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
//                            print("faceface");
//                            print("${snapshot.error}");
//                              return new Text("${snapshot.error}");
                          }

                          // By default, show a loading spinner
                          return new Center( child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),
                )
              ],
            ),
         )
              :Container(
            height: MediaQuery.of(context).size.height*0.25,
            child:Center(
              child: Container(
                width: MediaQuery.of(context).size.width*1,
                color: appcolor.withOpacity(0.1),
                padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                child:Text("No Data Available",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



