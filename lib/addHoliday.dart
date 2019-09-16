// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:Shrine/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/services.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'home.dart';
import 'settings.dart';
import 'reports.dart';
import 'profile.dart';
import 'holidays.dart';

class addHoliday extends StatefulWidget {
  @override
  _addHoliday createState() => _addHoliday();
}
class _addHoliday extends State<addHoliday> {
  bool isloading = false;
  final _holidayName = TextEditingController();
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _description = TextEditingController();
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy");
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int response=0;
  int _currentIndex = 2;
  String org_name="";
  String admin_sts="0";
  bool _isButtonDisabled=false;
  DateTime startdate;
  DateTime enddate;
  @override
  void initState() {
    super.initState();
    initPlatformState();
    //  shiftList= getShifts();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    final prefs = await SharedPreferences.getInstance();
    response = prefs.getInt('response') ?? 0;
    admin_sts = prefs.getString('sstatus') ?? '0';
    if(response==1) {
      Home ho = new Home();
      setState(() {
        org_name = prefs.getString('org_name') ?? '';
        /*
        response = prefs.getInt('response') ?? 0;
        fname = prefs.getString('fname') ?? '';
        lname = prefs.getString('lname') ?? '';
        empid = prefs.getString('empid') ?? '';
        email = prefs.getString('email') ?? '';
        status = prefs.getString('status') ?? '';
        orgid = prefs.getString('orgid') ?? '';
        orgdir = prefs.getString('orgdir') ?? '';
        sstatus = prefs.getString('sstatus') ?? '';

        desination = prefs.getString('desination') ?? '';
        profile = prefs.getString('profile') ?? '';
        */
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return getmainhomewidget();
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(value,textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  getmainhomewidget(){
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(org_name, style: new TextStyle(fontSize: 20.0)),
          ],
        ),
        leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
          Navigator.pop(context);
          /*  Navigator.push(
            context,
           MaterialPageRoute(builder: (context) => TimeoffSummary()),
          );*/
        },),
        backgroundColor: Colors.teal,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (newIndex) {
          if(newIndex==1){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
            return;
          }else if (newIndex == 0) {
            (admin_sts == '1')
                ? Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Reports()),
            )
                : Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
            return;
          }
          if(newIndex==2){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Settings()),
            );
            return;
          }
         /* else if(newIndex == 3){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Notifications()),
            );

          }*/
          setState((){_currentIndex = newIndex;});

        }, // this will be set when a new tab is tapped
        items: [
          (admin_sts == '1')
              ? BottomNavigationBarItem(
            icon: new Icon(
              Icons.library_books,
            ),
            title: new Text('Reports'),
          )
              : BottomNavigationBarItem(
            icon: new Icon(
              Icons.person,color: Colors.black54,
            ),
            title: new Text('Profile',style: TextStyle(color: Colors.black54)),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.home,color: Colors.black54,),
            title: new Text('Home',style: TextStyle(color: Colors.black54)),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings,color: Colors.black54,),
              title: Text('Settings',style: TextStyle(color: Colors.black54),)
          ),
          /*BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications
                ,color: Colors.black54,
              ),
              title: Text('Notifications',style: TextStyle(color: Colors.black54))),*/
        ],
      ),
      endDrawer: new AppDrawer(),
      body:  checkalreadylogin(),
    );

  }
  checkalreadylogin(){
    if(response==1) {
      return new IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          underdevelopment(),
          underdevelopment(),
          mainbodyWidget(),
        ],
      );
    }else{
      /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );*/
    }
  }
  loader(){
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset(
                  'assets/spinner.gif', height: 80.0, width: 80.0),
            ]),
      ),
    );
  }
  underdevelopment(){
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(Icons.android,color: Colors.teal,),Text("Under development",style: new TextStyle(fontSize: 30.0,color: Colors.teal),)
            ]),
      ),
    );
  }

  mainbodyWidget(){
    return Center(
      child: Form(
        key: _formKey,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Center(
                    child:Text("Add Holiday",style: new TextStyle(fontSize: 22.0,color: Colors.teal)),
                  ),
                  SizedBox(height: 30.0),

                  TextFormField(
                    //format: dateFormat,
                    controller: _holidayName,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Icon(
                          Icons.weekend,
                          color: Colors.grey,
                        ), // icon is 48px widget.
                      ), // icon is 48px widget.

                      labelText: 'Holiday Name',
                    ),
                    validator: (date) {
                      if (_holidayName.text==null||_holidayName.text.trim()==''){
                        return 'Please enter Holiday name';
                      }
                    },
                  ), //Enter date
                  SizedBox(height: 12.0),
                  DateTimeField(
                    //firstDate: new DateTime.now(),
                    //initialDate: new DateTime.now(),
                    //dateOnly: true,
                    //editable: false,
                    format: dateFormat,
                    controller: _from,
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));

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

                      labelText: 'From',
                    ),
                    validator: (date) {
                      if (date==null){
                        return 'Please enter from date';
                      }else{
                        setState(() {
                          startdate = date;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 12.0),
                  DateTimeField(
                    //firstDate: new DateTime.now(),
                    //initialDate: new DateTime.now(),
                    //dateOnly: true,
                    //editable: false,
                    format: dateFormat,
                    controller: _to,
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
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
                      labelText: 'To',
                    ),
                    validator: (date) {
                      if (date==null) {
                        return 'Please enter to date';
                      }else{
                        setState(() {
                          enddate =date;
                        });
                        print(enddate.difference(startdate).inDays);
                        if(enddate.difference(startdate).inDays<0){
                          return 'To date can not be greater than from date';
                        }
                      }
                     /* var arr=_from.text.split(':');
                      var arr1=_to.text.split(':');
                      final startTime = DateTime(2018, 6, 23,int.parse(arr[0]),int.parse(arr[1]),00,00);
                      final endTime = DateTime(2018, 6, 23,int.parse(arr1[0]),int.parse(arr1[1]),00,00);
                      if(endTime.isBefore(startTime)){
                        return '\"To Time\" can\'t be smaller.';
                      }*/
                    },
                  ),

                  TextFormField(
                    controller: _description,
                    decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Icon(
                            Icons.event_note,
                            color: Colors.grey,
                          ), // icon is 48px widget.
                        )
                    ),
                    /*validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter Description';
                      }
                    },*/
                    /*onFieldSubmitted: (String value) {
                      if (_formKey.currentState.validate()) {
                        requesttimeoff(_dateController.text ,_starttimeController.text,_endtimeController.text,_reasonController.text, context);
                      }
                    },*/
                    maxLines: 3,
                  ),
                  ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        shape: Border.all(color: Colors.black54),
                        child: Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      RaisedButton(
                        child: _isButtonDisabled?Text('Processing..',style: TextStyle(color: Colors.white),):Text('ADD',style: TextStyle(color: Colors.white),),
                        color: Colors.orangeAccent,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            if(_isButtonDisabled)
                              return null;
                            print(_from.toString());

                            setState(() {
                              _isButtonDisabled=true;
                            });
                            createHoliday(_holidayName.text,startdate,enddate,_description.text).then((res){
                              if(res.toString()=='1') {

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HolidayList()),
                                );
                                showDialog(context: context, child:
                                new AlertDialog(
                                  content: new Text("Holiday added successfully"),
                                )
                                );
                              }
                              else if(res.toString()=='-1')
                                showInSnackBar('Holiday already exists');
                              else
                                showInSnackBar('Unable to add holiday');
                              setState(() {
                                _isButtonDisabled=false;
                              });
                            }).catchError((exp){
                              showInSnackBar('Unable to call server service');
                              setState(() {
                                _isButtonDisabled=false;
                              });
                            });


  }
                        },
                      ),
                    ],
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}