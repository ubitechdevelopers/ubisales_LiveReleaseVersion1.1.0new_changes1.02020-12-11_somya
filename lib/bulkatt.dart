import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'drawer.dart';
import 'globals.dart';
import 'home.dart';
import 'offline_home.dart';
import 'settings.dart';
import 'reports.dart';
import 'profile.dart';
import 'package:intl/intl.dart';
import 'package:Shrine/services/newservices.dart';
import 'package:Shrine/services/services.dart';
import 'Image_view.dart';
import 'Bottomnavigationbar.dart';
import 'notifications.dart';
//import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class Bulkatt extends StatefulWidget {
  @override
  _Bulkatt createState() => _Bulkatt();
}

class _Bulkatt extends State<Bulkatt> {
  final List<grpattemp> _saved = new List<grpattemp>();
  NewServices ns = NewServices();
  List<grpattemp> emplist = null;
  bool isloading = false;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _currentIndex = 2;
  String org_name = "";
  String admin_sts = '0';
  int response;
  String fname = "",
      lname = "",
      empid = "",
      email = "",
      status = "",
      orgid = "",
      orgdir = "",
      sstatus = "",
      desination = "",
      desinationId = "",
      profile,
      latit = "",
      longi = "";
  String sts = '0';
  String aid = "";
  String shiftId = "";
  int checkall = 0;
  List<Map> attstsList = null;
  bool pageload = true;
  bool _obscureText = true;
  bool _isButtonDisabled = false;
  final _from = TextEditingController();
  final _to = TextEditingController();
  final timeFormat = DateFormat("H:mm");
  // TimeOfDay time;
  String newValue;
  bool _enabletimeout;
  bool _enabletimein;
  bool _updatetimeout;
  String colorti;
  String colorto;
  bool loaderr=false;
bool fakeLocationDetected=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    checkNetForOfflineMode(context);
    appResumedFromBackground(context);
/*    StreamLocation ns=new StreamLocation();
    ns.stopStreaming();*/
    final prefs = await SharedPreferences.getInstance();
    empid = prefs.getString('empid') ?? '';
    orgdir = prefs.getString('orgdir') ?? '';
    admin_sts = prefs.getString('sstatus') ?? '';
    orgid = prefs.getString('orgid') ?? '';
    desinationId = prefs.getString('desinationId') ?? '';
    getDeptEmp('Today').then((EmpList) {
      setState(() {
        emplist = EmpList;
      });
    });
    attstsList = createAttStsList();
    response = prefs.getInt('response') ?? 0;
    if (response == 1) {
      setState(() {
        response = prefs.getInt('response') ?? 0;
        fname = prefs.getString('fname') ?? '';
        lname = prefs.getString('lname') ?? '';
        empid = prefs.getString('empid') ?? '';
        email = prefs.getString('email') ?? '';
        status = prefs.getString('status') ?? '';
        orgid = prefs.getString('orgid') ?? '';
        orgdir = prefs.getString('orgdir') ?? '';
        sstatus = prefs.getString('sstatus') ?? '';
        org_name = prefs.getString('org_name') ?? '';
        desination = prefs.getString('desination') ?? '';
        profile = prefs.getString('profile') ?? '';
      });
      aid = prefs.getString('aid') ?? "";
      shiftId = prefs.getString('shiftId') ?? "";
    }
    platform.setMethodCallHandler(_handleMethod);
  }
  static const platform = const MethodChannel('location.spoofing.check');
  String address="";
  String areaStatus="";
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {

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

        assign_lat=double.parse(call.arguments["latitude"].toString());
        assign_long=double.parse(call.arguments["longitude"].toString());
        address=await getAddressFromLati(assign_lat.toString(), assign_long.toString());
        print(call.arguments["mocked"].toString());
        getAreaStatus().then((res) {
          // print('called again');
          if (mounted) {
            setState(() {
              areaStatus = res.toString();
            });
          }
        }).catchError((onError) {
          print('Exception occured in clling function.......');
          print(onError);
        });

        setState(() {

          if(call.arguments["mocked"].toString()=="Yes"){
            fakeLocationDetected=true;
          }
          else{
            fakeLocationDetected=false;
          }




        });
        break;

        return new Future.value("");
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return getmainhomewidget();
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(
          value,
          textAlign: TextAlign.center,
        ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
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


  getmainhomewidget() {
    return new WillPopScope(
      onWillPop: ()=> sendToHome(),
      child: Scaffold(
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
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },),
          backgroundColor: Colors.teal,
        ),
        bottomNavigationBar: Bottomnavigationbar(),
        endDrawer: new AppDrawer(),
        body: Container(
          padding: EdgeInsets.only(left: 2.0, right: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 8.0),
              Center(
                child: Text(
                  'Group Attendance',
                  style: new TextStyle(
                    fontSize: 22.0,
                    color: Colors.black54,
                  ),
                ),

              ),
    new Container(
    // width: MediaQuery.of(context).size.width*.45,
    padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
   child: InputDecorator(
   decoration: InputDecoration(
   labelText: 'Select',
   // icon is 48px widget.
   ),
     child: DropdownButton<String>(
     isDense: true,
     hint: Text('Today'),
     onChanged: (String changedValue) {
    newValue=changedValue;
    setState(() {
    loaderr=true;
    });
                getDeptEmp(changedValue).then((EmpList) {
                 setState(() {
                 emplist = EmpList;
                 _saved.clear();
                 checkall = 0;
                 loaderr=false;
                 });

                });

            },value: newValue,
              items: <String>['Today ', 'Yesterday'].map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),

            ),

          ), ),
              Divider(
                height: 10.0,
              ),
              SizedBox(height: 2.0),
              Container(
                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 40.0,
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.20,
                      child: Text(
                        'Name',
                        style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Text(
                        'Time In',
                        style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      padding: EdgeInsets.only(left:25),
                      child: Text(
                        'Time Out',
                        style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.15,
                      padding: EdgeInsets.only(left:10),
                      child: new FlatButton(
                        child: new Icon(
                          checkall == 1
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: checkall == 1 ? Colors.orangeAccent : null,
                        ),
                        onPressed: () =>
                            checkbulkall(),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              SizedBox(height: 5.0),
              new Expanded(
                child:loaderr==false?getBulkEmpWidget():loader(),
              ),
              new Container(
                child: ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    FlatButton(
                      shape: Border.all(color: Colors.black54),
                      child: Text('CANCEL'),
                      onPressed: () {
                      /*  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage()),
                        );*/
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                    ),
                    RaisedButton(
                      child: _isButtonDisabled
                          ? Text(
                        'Processing..',
                        style: TextStyle(color: Colors.white),
                      )
                          : Text(
                        'SAVE',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.orangeAccent,
                      onPressed: (){
                        if (_formKey.currentState.validate()){
                          if (_isButtonDisabled) return null;
                          if(_saved.length==0) {
                            showInSnackBar(
                                'Please Select atleast one record...');
                            return null;
                          }
                          else{
                            var formatter = new DateFormat('yyyy-MM-dd');
                            String todaydate=formatter.format(DateTime.now());
                            //print( todaydate);
                            DateTime from;
                            DateTime to;
                            for(var i = 0; i < _saved.length; i++){
                              print( _saved[i].Name);
                              print( _saved[i].data_date);
                              print( _saved[i].timeout);
                              if(_saved[i].data_date==todaydate){
                                DateTime now = DateTime.now();
                                to = new DateTime(now.year, now.month, now.day, now.hour, now.minute,00,00);
                                //print(to);
                                if(_saved[i].timein!='0:0' && _saved[i].timein!='00:00:00'){
                                  var arr = _saved[i].timein.split(':');
                                  from = new DateTime(now.year, now.month, now.day, int.parse(arr[0]), int.parse(arr[1]),00,00);
                                  if (to.isBefore(from)) {
                                    showInSnackBar(_saved[i].Name +
                                        "'s timein is greater than current time...");
                                    return null;
                                  }
                                }
                                if(_saved[i].timeout!='0:0' && _saved[i].timeout!='00:00:00') {
                                  var arr = _saved[i].timeout.split(':');
                                  from = new DateTime(now.year, now.month, now.day, int.parse(arr[0]), int.parse(arr[1]),00,00);
                                  if (to.isBefore(from)) {
                                    showInSnackBar(_saved[i].Name +
                                        "'s timeout is greater than current time...");
                                     return null;
                                  }
                                }
                              }
                              print( _saved[i].Attid);
                              if(_saved[i].shifttype=='1'){
                                print(_saved[i].timeout);
                                if(_saved[i].timeout!='0:0' && _saved[i].timeout!='00:00:00') {
                                  var arr = _saved[i].timein.split(':');
                                  from = new DateTime(2001, 01, 01, int.parse(arr[0]), int.parse(arr[1]), 00, 00);
                                  var arr1 = _saved[i].timeout.split(':');
                                  to = new DateTime(2001, 01, 01, int.parse(arr1[0]), int.parse(arr1[1]), 00, 00);
                                  if (to.isBefore(from)) {
                                    showInSnackBar(_saved[i].Name +
                                        "'s timein is greater than timeout...");
                                    return null;
                                  }
                                }
                              }
                            }
                          }
                          setState(() {
                            _isButtonDisabled = true;
                          });
                          //    print(_saved);
                          //  return false;

                          print("---------------before add bulk att");
                          addBulkAtt(_saved)
                              .then((res) {
                            //showInSnackBar(res.toString());
                            //   showInSnackBar('Employee registered Successfully');
                            if (res == "success") {
                              showDialog(context: context, child:
                              new AlertDialog(
                                content: new Text("Attendance added successfully!"),
                              )
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()),
                              );
                            }
                            else
                              showDialog(context: context, child:
                              new AlertDialog(
                                content: new Text("Unable to add attendance!"),
                              )
                              );
                            setState(() {
                              _isButtonDisabled = false;
                            });
                            // TimeOfDay.fromDateTime(10000);
                          }).catchError((exp) {
                            showInSnackBar('Unable to call service');
                            print(exp.toString());
                            setState(() {
                              _isButtonDisabled = false;
                            });
                          });
                        };
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getBulkEmpWidget() {
    if (emplist != null) {
      return new Container(
        height: MediaQuery.of(context).size.height * 0.60,
        child: Form(
          key:_formKey,
          child: new ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: emplist.length,
              //  padding: EdgeInsets.only(left: 5.0,right: 5.0),
              itemBuilder: (BuildContext context, int index) {
                final int alreadySaved = emplist[index].csts;
                //List til=emplist[index].timein.split(":");
                //if(!til[0]){til[0]=0;};
                // TimeOfDay ti = TimeOfDay(hour: int.fromEnvironment(til[0]), minute: int.fromEnvironment(til[1]));

                /* print(emplist[index].timein);
               print(int.parse(til[0]));
               print(til[1]);*/
                DateTime ti = new DateTime(
                    2001,
                    01,
                    01,
                    int.parse(emplist[index].timein.split(":")[0]),
                    int.parse(emplist[index].timein.split(":")[1]),
                    00,
                    00);
                DateTime tout = new DateTime(
                    2001,
                    01,
                    01,
                    int.parse(emplist[index].timeout.split(":")[0]),
                    int.parse(emplist[index].timeout.split(":")[1]),
                    00,
                    00);
                //TimeOfDay(hour: int.parse(emplist[index].timein.split(":")[0]), minute: int.parse(emplist[index].timein.split(":")[1]));
                //print(ti);
                //TimeOfDay tout = TimeOfDay(hour: int.parse(emplist[index].timeout.split(":")[0]), minute: int.parse(emplist[index].timeout.split(":")[1]));
                if(emplist[index].Attid=='0'){
                  _enabletimein=true;
                  ti=null;
                }
                else{
                  _enabletimein=false;
                }
                if(emplist[index].timeout=='00:00:00' || emplist[index].device=='Auto Time Out'){
                  _enabletimeout=true;
                }
              else{
                  _enabletimeout=false;
                }
               // print(tout);
                //print('_enabletimeout'+emplist[index].Name+_enabletimeout.toString()+emplist[index].Attid.toString());
                print('_enabletimein'+emplist[index].Name+_enabletimein.toString()+emplist[index].Attid.toString());
                //  print(_saved.elementAt(index).Name);
                return new Column(children: <Widget>[
                  new FlatButton(
                    child: new Row(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                InkWell(
                                  child:Container(
                                    width: 62.0,
                                    height: 62.0,
                                    child: Container(
                                        decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: new DecorationImage(
                                                fit: BoxFit.fill,
                                                image: new NetworkImage(
                                                    emplist[index].img)))),
                                  ),
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ImageView(myimage: emplist[index].img,org_name: org_name)),
                                    );
                                  },
                                ),
                                Text(
                                  emplist[index].Name.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                        SizedBox(
                          height: 50.0,
                        ),
                        new   Expanded(child:Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: DateTimeField(
                                    format: timeFormat,
                                    initialValue: ti,
                                    enabled:_enabletimein,
                                    readOnly: true,
                                    //controller: _from,
                                    decoration: InputDecoration(
                                      // labelText: 'Time In',
                                      /* prefixIcon: Padding(
                                      padding: EdgeInsets.all(0.0),
                                      child: Text('Time In'), // icon is 48px widget.
                                    ),*/
                                    ),
                                    onShowPicker: (context, currentValue) async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                                      );
                                      return DateTimeField.convert(time);
                                    },
                                    onChanged: (t) => setState(() {
                                      print('time');
                                      print(t);
                                      if(t!=null) {
                                        emplist[index].timein =
                                            t.hour.toString() + ':' +
                                                t.minute.toString();
                                      }else{
                                       // emplist[index].timein = t.toString();
                                      }
                                      if (emplist[index].csts != 1) {
                                        _saved.add(emplist[index]);
                                        emplist[index].csts = 1;
                                      }
                                    }
                                    ),
                                   /* onSaved: (t) => setState(() {
                                      emplist[index].timein = t.hour.toString()+':'+t.minute.toString();
                                      if (emplist[index].csts != 1) {
                                        _saved.add(emplist[index]);
                                        emplist[index].csts = 1;
                                      }
                                    }
                                    ),*/
                                    validator: (time) {
                                      if (time == null && emplist[index].csts==1) {
                                        return 'Please enter TimeIn';
                                      }
                                    },
                                  ),
                                ),
                                /*  SizedBox(width: 10.0),
                              Container(
                                child: TimePickerFormField(
                                  format: timeFormat,
                                  initialValue: tout,
                                  //controller: _to,
                                  decoration: InputDecoration(
                                   // labelText: 'Time Out',
                                    /*prefixIcon: Padding(
                                      padding: EdgeInsets.all(0.0),
                                      child: Text('Time Out'), // icon is 48px widget.
                                    ),*/
                                  ),
                                  onChanged: (t) => setState(() => emplist[index].timeout = t.hour.toString()+':'+t.minute.toString()),
                                  validator: (time) {
                                    if (time == null && emplist[index].csts==1) {
                                      return 'Please enter TimeOut';
                                    }
                                  },
                                ),
                              ),*/
                                //new Text(emplist[index].Name.toString()),
                                //new Text('('+snapshot.data[index].Id.toString()+')',style: TextStyle(color: Colors.grey),),
                                // new Text('('+snapshot.data[index].Id.toString()+')',style: TextStyle(color: Colors.grey),),
                              ],
                            ))),
                        SizedBox(
                            height: 50.0,
                            width:15.0
                        ),
                        new Expanded(child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: DateTimeField(
                              format: timeFormat,
                               //initialValue: tout,
                              //enabled:_enabletimeout,
                              readOnly: true,
                              onShowPicker: (context, currentValue) async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                                );
                                return DateTimeField.convert(time);
                              },
                              //editable: false,
                              //controller: _to,
                              decoration: InputDecoration(

                                // labelText: 'Time Out',
                                /*prefixIcon: Padding(
                                      padding: EdgeInsets.all(0.0),
                                      child: Text('Time Out'), // icon is 48px widget.
                                    ),*/
                              ),
                              onChanged: (t) => setState(() {
                print('timeout');
                print(t);
                if(t!=null) {
                  emplist[index].timeout =
                      t.hour.toString() + ':' + t.minute.toString();
                }else{

                }
                                if (emplist[index].csts != 1) {
                                  _saved.add(emplist[index]);
                                  emplist[index].csts = 1;
                                }
                              }),
                              validator: (time) {
                                //    print("dddddddd");
                                // print(emplist[index].Attid);
                                if ( time == null && emplist[index].csts==1 && emplist[index].Attid!='0'){
                                  return "Enter Time out";
                                }
                                else if (time == null && emplist[index].csts==1) {
                                  emplist[index].timeout ='00:00:00';
                                }
                              },
                            ),
                          ),
                          //child: getStatus_DD(emplist[index]),
                        ),
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                        new Container(
                          width: MediaQuery.of(context).size.width * 0.10,
                          child: new FlatButton(
                            child: new Icon(
                              alreadySaved == 1
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color:
                              alreadySaved == 1 ? Colors.orangeAccent : null,
                            ),
                            onPressed: () {
                              setState(() {
                                if (emplist[index].csts == 1) {
                                  _saved.remove(emplist[index]);
                                  emplist[index].csts = 0;
                                  print(emplist[index].Name+'Remove');
                                  print(_saved);
                                } else {
                                  _saved.add(emplist[index]);
                                  emplist[index].csts = 1;
                                  print(emplist[index].Name);
                                }
                              });
                              //return null;
                              // editDept(context,snapshot.data[index].Name.toString(),snapshot.data[index].Status.toString(),snapshot.data[index].Id.toString());
                            },
                          ),
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                      ],
                    ),
                    onPressed: () {
                      // editDept(context,snapshot.data[index].Name.toString(),snapshot.data[index].Status.toString(),snapshot.data[index].Id.toString());
                    },
                  ),

                  Divider(
                    color: Colors.blueGrey.withOpacity(0.25),
                    height: 20,
                  ),
                ]
                );
              }
          ),
        ),
      );
    } else {
      return loader();
      /* return new Container(
        child: new Text('No data Found...'),
      );*/
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
                color: Colors.teal,
              ),
              Text(
                "Under development",
                style: new TextStyle(fontSize: 30.0, color: Colors.teal),
              )
            ]),
      ),
    );
  }

////////////////common dropdowns
  Widget getStatus_DD(data) {
    // String dc = "0";
    return new Container(
      //width: MediaQuery.of(context).size.width*0.01,
      child: InputDecorator(
        decoration: InputDecoration(

          //labelText: 'Status',
          /*prefixIcon: Padding(
            padding: EdgeInsets.all(1.0),
            child: Icon(
              Icons.attach_file,
              color: Colors.grey,
            ), // icon is 48px widget.
          ),*/

        ),
        child: new DropdownButton<String>(
          isDense: true,
          style: new TextStyle(fontSize: 15.0, color: Colors.black),
          value: data.attsts,
          onChanged: (String newValue) {
            setState(() {
              data.attsts = newValue;
            });
          },
          items: attstsList.map((Map map) {
            return new DropdownMenuItem<String>(
              value: map["Id"].toString(),
              child: new SizedBox(
                //width: 200.0,
                  child: new Text(
                    map["Name"],
                  )),
            );
          }).toList(),
        ),
      ),
    );
  }

  loader() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset('assets/spinner.gif', height: 30.0, width: 30.0),
            ]),
      ),
    );
  }

  createAttStsList() {
    List<Map> list = new List();
    //list.add({"Id": "0", "Name": "-Select-"});
    Map tos = {"Name": 'P', "Id": '1'};
    list.add(tos);
    tos = {"Name": 'A', "Id": '2'};
    list.add(tos);
    return list;
  }

  checkbulkall() {
    setState(() {
      if (checkall == 0) {
        checkall = 1;
        _saved.clear();
        _saved.addAll(emplist);
        for (var i = 0; i < emplist.length; i++) {
          emplist[i].csts = 1;
        }
      } else {
        _saved.clear();
        checkall = 0;
        for (var i = 0; i < emplist.length; i++) {
          emplist[i].csts = 0;
        }
      }
    });
  }
}