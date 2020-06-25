// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drawer.dart';
import 'globals.dart';
import 'outside_label.dart';
// This app is a stateful, it tracks the user's current choice.
class LastSeven extends StatefulWidget {
  @override
  _LastSeven createState() => _LastSeven();
}

class _LastSeven extends State<LastSeven> with SingleTickerProviderStateMixin {

  TabController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _orgName = "";
  String newValue ;
  Future<List<Attn>> _listFuture,_listFuture1,_listFuture2,_listFuture3,_listFuture4;


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
  }

  @override
  void initState() {
    super.initState();

    //getChartDataLast('Last 7 days ');
    _listFuture1 = getAttnDataLast('Last 7 days ','present');
    _listFuture2 = getAttnDataLast('Last 7 days ','absent');
    _listFuture3 = getAttnDataLast('Last 7 days ','latecomings');
    _listFuture4 = getAttnDataLast('Last 7 days ','earlyleavings');
    //getChartDataLast('Last 7 days ');

    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    _controller = new TabController(length: 4, vsync: this);
    getOrgName();
    //setAlldata();
  }

  setAlldata() {

    _listFuture1 = getAttnDataLast(newValue,'present');
    _listFuture2 = getAttnDataLast(newValue,'absent');
    _listFuture3 = getAttnDataLast(newValue,'latecomings');
    _listFuture4 = getAttnDataLast(newValue,'earlyleavings');

  }

  @override
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
            child: Center(child:Text("Attendance Snap",style: TextStyle(fontSize: 22.0,color: appcolor,),),),
          ),
          Divider(color: Colors.black54,height: 1.5,),
          SizedBox(height:10.0),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left:10.0),
                child: Container(
                  width: MediaQuery.of(context).copyWith().size.width*0.4,
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
                          hint: Text('Select Period'),
                          value: newValue,
                          onChanged: (value) async{
                            newValue=value;
                            print(value);
                            print(newValue);
                            setState(() {
                              setAlldata();
                            });
                          },
                          items: <String>['Last 7 days ', 'Last 14 days ', 'Last 30 days ', 'This month ', 'Last month'].map((String value) {
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
              )
            ],
          ),
          new Container(
            padding: EdgeInsets.all(0.1),
            margin: EdgeInsets.all(0.1),
            child: new ListTile(
              title: new SizedBox(height: MediaQuery.of(context).size.height*0.25,
                child: new FutureBuilder<List<Map<String,String>>>(
                    future: newValue != null? getChartDataLast(newValue): getChartDataLast('Last 7 days '),
                    // future:  getChartDataLast(newValue),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.length > 0) {
                          return new PieOutsideLabelChart.withRandomData_range(snapshot.data);
                        }
                      }
                      return new Center( child: CircularProgressIndicator());
                    }
                ),

                //  child: new PieOutsideLabelChart.withRandomData(),

                width: MediaQuery.of(context).size.width*1.0,),
            ),
          ),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text('Present(P)',style: TextStyle(color:appcolor,fontSize: 12.0),),
              Text('Absent(A)',style: TextStyle(color:appcolor,fontSize: 12.0),),
              Text('Late Comers(LC)',style: TextStyle(color:appcolor,fontSize: 12.0),),
              Text('Early Leavers(EL)',style: TextStyle(color:appcolor,fontSize: 12.0),),
            ],
          ),
          Divider(),
          new Container(
            decoration: new BoxDecoration(color: Colors.black54),
            child: new TabBar(
              indicator: BoxDecoration(color: buttoncolor,),
              controller: _controller,
              tabs: [
                new Tab(
                  text: 'Present',
                ),
                new Tab(
                  text: 'Absent',
                ),
                new Tab(
                  text: 'Late \nComers',
                ),
                new Tab(
                  text: 'Early \nLeavers',
                ),
              ],
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 50.0,),
              SizedBox(width: MediaQuery.of(context).size.width*0.02),
              Container(
                width: MediaQuery.of(context).size.width*0.18,
                child:Text('  Date',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.35,
                child:Text('Name',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.18,
                child:Text('Time In',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.18,
                child:Text('Time Out',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
            ],
          ),
          new Divider(height: 1.0,),
          new Container(
            height: MediaQuery.of(context).size.height*0.30,
            child: new TabBarView(
              controller: _controller,
              children: <Widget>[
                new Container(
                  height: MediaQuery.of(context).size.height*0.3,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: MediaQuery.of(context).size.height*.30,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        //future: getAttnDataLast('l7','present'),
                        future: _listFuture1,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if(snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[

                                        SizedBox(height: 40.0,),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.18,
                                          child:  Text(snapshot.data[index].EntryImage
                                              .toString(), style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16.0),),
                                        ),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.40,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: <Widget>[
                                              Text(snapshot.data[index].Name
                                                  .toString(),
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                ),

                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.16,
                                          child:  Text(snapshot.data[index].TimeIn
                                              .toString(), style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16.0),),
                                        ),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.16,
                                          child:  Text(snapshot.data[index].TimeOut.toString(),
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16.0),),
                                        ),
                                      ],

                                    );
                                  }
                              );
                            }else{
                              return new Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width*1,
                                  color: appcolor.withOpacity(0.1),
                                  padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                  child:Text("No one was present in the last 7 days",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                ),
                              );
                            }
                          }
                          else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                          }

                          // By default, show a loading spinner
                          return new Center( child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),
                ),
                //////////////TABB 2 Start
                new Container(
                  height: MediaQuery.of(context).size.height*0.3,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: MediaQuery.of(context).size.height*.3,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        //future: getAttnDataLast('l7','absent',),
                        future: _listFuture2,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if(snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Row(
//                                      mainAxisAlignment: MainAxisAlignment
//                                          .spaceAround,
                                      children: <Widget>[

                                        SizedBox(height: 40.0,),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.18,
                                          child:  Text(snapshot.data[index].EntryImage
                                              .toString(), style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16.0),),
                                        ),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.40,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: <Widget>[
                                              Text(snapshot.data[index].Name
                                                  .toString(), style: TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0),),
                                            ],
                                          ),
                                        ),
//                                        Container(
//                                          width: MediaQuery
//                                              .of(context)
//                                              .size
//                                              .width * 0.16,
//                                          child:  Text(snapshot.data[index].TimeIn
//                                              .toString(), style: TextStyle(
//                                              color: Colors.black87,
//                                              fontSize: 16.0),),
//                                        ),
//                                        Container(
//                                          width: MediaQuery
//                                              .of(context)
//                                              .size
//                                              .width * 0.16,
//                                          child:  Text(snapshot.data[index].TimeOut
//                                              .toString(), style: TextStyle(
//                                              color: Colors.black87,
//                                              fontSize: 16.0),),
//                                        ),

                                      ],

                                    );
                                  }
                              );
                            }else{
                              return new Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width*1,
                                  color: appcolor.withOpacity(0.1),
                                  padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                  child:Text("No one was absent in the last 7 days ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                ),
                              );
                            }
                          }
                          else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                          }

                          // By default, show a loading spinner
                          return new Center( child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),

                ),

                /////////////TAB 2 Ends



                /////////////TAB 3 STARTS

                new Container(

                  height: MediaQuery.of(context).size.height*0.3,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: MediaQuery.of(context).size.height*.3,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        //future: getAttnDataLast('l7','latecomings'),
                        future: _listFuture3,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if(snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceAround,
                                      children: <Widget>[

                                        SizedBox(height: 40.0,),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.18,
                                          child:  Text(snapshot.data[index].EntryImage
                                              .toString(), style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16.0),),
                                        ),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.40,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: <Widget>[
                                              Text(snapshot.data[index].Name
                                                  .toString(), style: TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0),),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.16,
                                          child:  Text(snapshot.data[index].TimeIn
                                              .toString(), style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16.0),),
                                        ),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.16,
                                          child:  Text(snapshot.data[index].TimeOut
                                              .toString(), style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16.0),),
                                        ),

                                      ],

                                    );
                                  }
                              );
                            }else{
                              return new Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width*1,
                                  color: appcolor.withOpacity(0.1),
                                  padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                  child:Text("No late comers in the last 7 days  ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                ),
                              );
                            }
                          }
                          else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                          }

                          // By default, show a loading spinner
                          return new Center( child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),

                ),
                /////////TAB 3 ENDSF


                /////////TAB 4 STARTS
                new Container(


                  height: MediaQuery.of(context).size.height*0.3,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: MediaQuery.of(context).size.height*.3,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        //future: getAttnDataLast('l7','earlyleavings'),
                        future:_listFuture4,
                        // future: getabc(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if(snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceAround,
                                      children: <Widget>[

                                        SizedBox(height: 40.0,),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.18,
                                          child:  Text(snapshot.data[index].EntryImage
                                              .toString(), style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16.0),),
                                        ),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.40,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: <Widget>[
                                              Text(snapshot.data[index].Name
                                                  .toString(), style: TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0),),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.16,
                                          child:  Text(snapshot.data[index].TimeIn
                                              .toString(), style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16.0),),
                                        ),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.16,
                                          child:  Text(snapshot.data[index].TimeOut
                                              .toString(), style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16.0),),
                                        ),

                                      ],

                                    );
                                  }
                              );
                            }else{
                              return new Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width*1,
                                  color: appcolor.withOpacity(0.1),
                                  padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                  child:Text("No early leavers in the last 7 days",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                ),
                              );
                            }
                          }
                          else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                          }

                          // By default, show a loading spinner
                          return new Center( child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),
                ),
                ///////////////////TAB 4 Ends
              ],
            ),
          ),
        ],
      ),
    );
  }
}
