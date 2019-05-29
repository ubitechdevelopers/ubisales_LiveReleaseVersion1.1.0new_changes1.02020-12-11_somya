// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:Shrine/services/services.dart';
import 'outside_label.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'drawer.dart';
import 'department_att.dart';
import 'generatepdf.dart';
import 'Image_view.dart';
import 'package:flutter/scheduler.dart';

// This app is a stateful, it tracks the user's current choice.
class Departmentwise_att extends StatefulWidget {
  @override
  _Departmentwise_att createState() => _Departmentwise_att();
}

TextEditingController today;
String _orgName;
class _Departmentwise_att extends State<Departmentwise_att>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String countP = '-', countA = '-', countL = '-', countE = '-';
  String dept = '0';
  var formatter = new DateFormat('dd-MMM-yyyy');
  bool res = true;
  List<Map<String, String>> chartData;
bool filests=false;
  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        duration: const Duration(minutes: 5),
        content: Text(
      value,
      textAlign: TextAlign.center,
    ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  getOrgName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName = prefs.getString('org_name') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 4, vsync: this);
    getOrgName();
    today = new TextEditingController();
    today.text = formatter.format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(_orgName, style: new TextStyle(fontSize: 20.0)),
        backgroundColor: Colors.teal,
      ),
      endDrawer: new AppDrawer(),
      body: getMainWidget(),
    );
  }

  getMainWidget(){
    return (filests==true)?loader():new ListView(
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        SizedBox(height: 3.0),
        new Container(
          child: Center(
            child: Text(
              "Department Wise Attendance",
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.black54,
              ),
            ),
          ),
        ),
        Container(
          child: DateTimePickerFormField(
            dateOnly: true,
            format: formatter,
            controller: today,
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
                if (date != null && date.toString() != '') {
                  res = true; //showInSnackBar(date.toString());
                  countP = '-';
                  countA = '-';
                  countE = '-';
                  countL = '-';
                } else
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
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//            crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 50.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.44,
              child: Text(
                ' Departments',
                style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.12,
              child: Text(
                'Total',
                style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.18,
              child: Text(
                'Present',
                style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.18,
              child: Text(
                'Absent',
                style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
            ),
          ],
        ),
        Divider(
          color: Colors.black,
        ),
        (res==false)?Center():new Container(
          height: MediaQuery.of(context).size.height * 0.60,
          //   shape: Border.all(color: Colors.deepOrange),
          child: new ListTile(
            title: Container(
              height: MediaQuery.of(context).size.height * 0.60,
              //width: MediaQuery.of(context).size.width*.99,
              color: Colors.white,
              //////////////////////////////////////////////////////////////////////---------------------------------
              child: new FutureBuilder<List<Attn>>(
                future: getEmpdataDepartmentWise(today.text),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    /* SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
                              countA=snapshot.data.length.toString();
                            }));*/
                    countA = snapshot.data.length.toString();
                    if (snapshot.data.length > 0) {
                      return new ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return new Column(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                (index == 0)?
                                Row(
                                    children: <Widget>[
                                      SizedBox(height: 25.0,),
                                      Container(
                                        padding: EdgeInsets.only(left: 5.0),
                                        child: Text("Total Department: ${countA}",style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 16.0,),),
                                      ),

                                      Container(
                                        padding: EdgeInsets.only(left: 5.0),
                                        child: InkWell(
                                          child: Text('CSV',style: TextStyle(decoration: TextDecoration.underline,color: Colors.blueAccent),),

                                          onTap: () {
                                            setState(() {
                                                filests=true;
                                              });
                                            getCsv(snapshot.data,'Department_Report_'+today.text,'dept').then((res) {
                                              setState(() {
                                                filests=false;
                                              });
                                              // showInSnackBar('CSV has been saved in file storage in ubiattendance_files/Department_Report_'+today.text+'.csv');
                                              dialogwidget("CSV has been saved in internal storage in ubiattendance_files/Department_Report_"+today.text+".csv");
                                              /*showDialog(context: context, child:
                                              new AlertDialog(
                                                content: new Text("CSV has been saved in file storage in ubiattendance_files/Department_Report_"+today.text+".csv"),
                                              )
                                              );*/
                                            });
                                          },
                                        ),
                                      ),

                                      Container(
                                        padding: EdgeInsets.only(left: 5.0),
                                        child: InkWell(
                                          child: Text('PDF',style: TextStyle(decoration: TextDecoration.underline,color: Colors.blueAccent),),
                                          onTap: () {
                                            setState(() {
                                              filests=true;
                                            });
                                            CreateDeptpdf(snapshot.data,'Department Summary Report',snapshot.data.length.toString(),'Department_Report_'+today.text,'dept').then((res) {
                                              setState(() {
                                                filests=false;
                                              });
                                              dialogwidget('PDF has been saved in internal storage in ubiattendance_files/'+'Department_Report_'+today.text+'.pdf');
                                             // showInSnackBar('PDF has been saved in file storage in ubiattendance_files/'+'Department_Report_'+today.text+'.pdf');
                                            });
                                          },
                                        ),
                                      ),
                                    ]
                                ):new Center(),
                                (index == 0)?
                                Divider(color: Colors.black26,):new Center(),
                                Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 50.0,
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.42,
                                        child: Column(

                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: <Widget>[
                                            /*  RaisedButton(

                                        textColor: Colors.white,
                                        //color: Colors.blue,
                                        child:Text( "sohan"
                                           /*snapshot.data[index].Name
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0),*/
                                          ),
                                          ),*/

                                            InkWell(
                                              child: Text(snapshot.data[index].Name.toString(),
                                                  style: TextStyle(decoration: TextDecoration.underline,color:Colors.teal,)
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => Department_att(departid: snapshot.data[index].Id.toString(),date: today.text, dname: snapshot.data[index].Name.toString(),total: snapshot.data[index].Total.toString())),
                                                );
                                              },
                                            ),
                                            /*  new RaisedButton(
                                            padding:  EdgeInsets.only(left: 0.0,),
                                            child:  Text(snapshot.data[index].Name.toString(),),
                                            color: Colors.white,
                                            elevation: 0.0, // remove
                                            textColor: Colors.teal,
                                            splashColor: Colors.green[200],
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => Department_att(departid: snapshot.data[index].Id.toString(),date: today.text,)),
                                              );
                                            },
                                          ),*/

                                          ],
                                        ),
                                      ),
                                      /* onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => Department_att()),
                                    );
                                  },*/
                                      //   ),
                                      Container(
                                          width:
                                          MediaQuery.of(context).size.width *
                                              0.12,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(snapshot.data[index].Total
                                                  .toString()),
                                            ],
                                          )),

                                      Container(
                                          width:
                                          MediaQuery.of(context).size.width *
                                              0.18,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(snapshot.data[index].Present
                                                  .toString()),
                                            ],
                                          )),

                                      Container(
                                          width:
                                          MediaQuery.of(context).size.width *
                                              0.18,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(snapshot.data[index].Absent
                                                  .toString()),
                                            ],
                                          )),
                                    ]),
                              ],
                            );
                          });
                    } else {
                      return new Container(
                          height: MediaQuery.of(context).size.height * 0.30,
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 1,
                              color: Colors.teal.withOpacity(0.1),
                              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                              child: Text(
                                "No one is absent on this date ",
                                style: TextStyle(fontSize: 18.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                      );
                    }
                  } else if (snapshot.hasError) {
                    return new Text("Unable to connect server");
                    // return new Text("${snapshot.error}");
                  }

                  // By default, show a loading spinner
                  return new Center(child: CircularProgressIndicator());
                },
              ),
              //////////////////////////////////////////////////////////////////////---------------------------------
            ),
          ),
        ),
      ],
    );
  }

  loader() {
    return new Container(
      child: Center(
        child: SizedBox(
          child: CircularProgressIndicator(strokeWidth: 2.2,),
          height: 20.0,
          width: 20.0,
        ),
      ),
    );
  }
  dialogwidget(msg) {
    showDialog(context: context, child:
    new AlertDialog(
      content: new Text(msg),
    )
    );
  }
}
