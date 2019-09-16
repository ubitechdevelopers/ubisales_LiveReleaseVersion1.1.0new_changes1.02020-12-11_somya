import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:Shrine/globals.dart' as globals;
import 'package:Shrine/model/model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Shrine/globals.dart';
import 'package:Shrine/offline_home.dart';
import 'dart:io';
import 'package:flutter/scheduler.dart';
import 'package:Shrine/no_net.dart';
//import 'package:simple_permissions/simple_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:android_intent/android_intent.dart';
import 'package:path/path.dart';

import '../home.dart';
class Services {}


////////////////////Shashank///////////////////////////////

bool isOfflineHomeRedirected=false;

checkLocationEnabled(context) async{
  print("checkLocationEnabled function");

  bool isLocationEnabled = await Geolocator().isLocationServiceEnabled();
  print("isLocationEnabled:-------------------"+isLocationEnabled.toString());




  if(!isLocationEnabled){
    showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text(""),
          content: new Text("Sorry we can't continue without GPS"),
          actions: <Widget>[
            RaisedButton(
              child: new Text(
                "Turn On",
                style: new TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.orangeAccent,
              onPressed: () {
                openLocationSetting();
              },
            ),
            RaisedButton(
              child: new Text(
                "Done",
                style: new TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.orangeAccent,
              onPressed: () {
                cameraChannel.invokeMethod("startAssistant");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
                Navigator.of(context, rootNavigator: true)
                    .pop();

              },
            ),
          ],
        ));
  }
}

void openLocationSetting() async {
  final AndroidIntent intent = new AndroidIntent(
    action: 'android.settings.LOCATION_SOURCE_SETTINGS',
  );
  await intent.launch();
}


encode5t(String str) async
{
  for(int i=0; i<5;i++)
  {
    String rev=str.split('').reversed.join('');

    str=base64Encode(str.codeUnits).split('').reversed.join('');; //apply base64 first and then reverse the string
  }
  return str;
}
decode5t(String str) async
{

  for(int i=0; i<5;i++)
  {
    String rev=str.split('').reversed.join('');

    str=String.fromCharCodes(base64Decode(rev)); //apply base64 first and then reverse the string}
  }
  return str;
}
var serverConnected=0;

Future<int> checkConnectionToServer () async{
  try {
    var uri = Uri.parse(path);
    var host=uri.host;
    //final result = await InternetAddress.lookup(host);
     final result = await InternetAddress.lookup("google.com");
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      serverConnected=1;
    }else{
      serverConnected=0;
    }
  } on SocketException catch (_) {
    print('not connected');
    serverConnected=0;
  }
  return serverConnected;
}
////////////////////Shashank////////////////////////////////////////




/////////// location punch
punch(comments, client_name, empid, location_addr1, lid, act, orgdir, latit,
    longi) {
  /* print('Location punch successfully');
  print("\nClient: " + client_name);
  print("\nComments: " + comments);
  print("\nempid: " + empid);
  print("\nlocation_addr1: " + location_addr1);
  print("\nlid: " + lid);
  print("\nact: " + act);
  print("\norgdir: " + orgdir);
  print("\nlatit: " + latit);
  print("\nlongi: " + longi);*/
}

Future checkNow() async {
  print('*--*-*-*-*-*-*-*-*-*-');
  try{
    final res = await http.get(globals.path + 'getAppVersion?platform=Android1');
    return ((json.decode(res.body.toString()))[0]['version']).toString();
  }
  catch(e){
    print("Error finding current version of the app");
    return"error";
  }

}

Future checkMandUpdate() async {
  final res = await http.get(globals.path + 'checkMandUpdate?platform=Android');
  print(globals.path + 'checkMandUpdate?platform=Android');
  // print('*****************************'+((json.decode(res.body.toString()))[0]['is_update']).toString()+'*****************************');
  return ((json.decode(res.body))[0]['is_update']).toString();
}

Future<String> PunchSkip(lid) async {
  // print('push skip called');
  Map MarkPunchMap = {'status': 'failure'};
  try {
    Dio dio = new Dio();
    FormData formData = new FormData.from({
      "lid": lid,
    });
    Response<String> response1 =
        await dio.post(globals.path + "skipPunch", data: formData);
    MarkPunchMap = json.decode(response1.data);
    //  print('STATUS-1:' + MarkPunchMap['status'].toString());
    if (MarkPunchMap['status'].toString() == 'success') setPunchPrefs('0');
    return MarkPunchMap['status'].toString();
  } catch (e) {
    //  print("Unable to set visit: " + e.toString());
    return MarkPunchMap['status'].toString();
  }
}

Future<Map> PunchInOut(comments, client_name, empid, location_addr1, lid, act,
    orgdir, latit, longi) async {
/*  print("Punch in/out called");
  print('Location punch successfully');
  print("\nClient: "+client_name);
  print("\nComments: "+comments);
  print("\nempid: "+empid);
  print("\nlocation_addr1: "+location_addr1);
  print("\nlid: "+lid);
  print("\nact: "+act);
  print("\norgdir: "+orgdir);
  print("\nlatit: "+latit);
  print("\nlongi: "+longi);*/
  Map MarkPunchMap;
  try {
    Dio dio = new Dio();
    FormData formData = new FormData.from({
      "comment": comments,
      "cname": client_name,
      "uid": empid,
      "orgid": orgdir,
      "loc": location_addr1,
      "longi": longi,
      "latit": latit,
      "act": act,
      "lid": lid,
    });

    Response<String> response1 =
        await dio.post(globals.path + "punchLocation", data: formData);

    print(response1.toString());
    MarkPunchMap = json.decode(response1.data);
//    PunchLocation pnch=new PunchLocation();

    if (MarkPunchMap["status"].toString() == 'success') {
      /* print('------response done----------' +
          MarkPunchMap["status"].toString() +
          " shared data: ");*/
      setPunchPrefs(MarkPunchMap["lid"].toString());
      return MarkPunchMap;
    } else
      /* print('------response failer----------' +
          MarkPunchMap["status"].toString());*/
      return MarkPunchMap;
  } catch (e) {
    // print("Unable to set visit: " + e.toString());
    MarkPunchMap = {'status': 'failure', 'lid': lid};
    return MarkPunchMap;
  }
}

///////// check punch in or punch out--- depricated (NOT IN USE)
checkPunch(String empid, String orgid) async {
  var dio = new Dio();
  final prefs = await SharedPreferences.getInstance();
  return "PunchIn";
}

Future<Map> registerEmp(name, email, pass, phone) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '0';
  final response = await http.get(globals.path +
      "registerEmp?f_name= $name&username=$email&password=$pass"
          "&contact=$phone&org_id=$orgdir");
  /*print('globals.path+"registerEmp?f_name= $name&username=$email&password=$pass'
      '&contact=$phone&org_id=$orgdir');*/
  var res = json.decode(response.body.toString());
  print(res['id']);
  Map<String, String> data = {
    'id': res['id'].toString(),
    'sts': res['sts'].toString()
  };

  print('---------------------------------');
  print(data);
  print('---------------------------------');
  return data;
}

Future<String> checkAdminSts() async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '0';
  String empid = prefs.getString('empid') ?? '0';
  final response = await http
      .get(globals.path + "getSuperviserSts?uid=$empid&refid=$orgdir");
  var res = json.decode(response.body.toString());
  print('------------checkAdminSts called-123------');
  print(res[0]['appSuperviserSts']);
  prefs.setString('sstatus', res[0]['appSuperviserSts'].toString());
  employee_permission = int.parse(res[0]['appSuperviserSts']);
  return res[0]['appSuperviserSts'].toString();
}

setPunchPrefs(lid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('lid', lid);
  /* print('Preferences set successfully: new lid- ' +
      prefs.getString('lid').toString());*/
}

////////////////////////////////////////////////-----
Future<List<Punch>> getSummaryPunch() async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  print('getSummaryPunch called');
  final response =
      await http.get(globals.path + 'getPunchInfo?uid=$empid&orgid=$orgdir');

  List responseJson = json.decode(response.body.toString());
  print("get summary punch" + responseJson.toString());
  List<Punch> userList = createUserList(responseJson);
  return userList;
}

List<Punch> createUserList(List data) {
  List<Punch> list = new List();
  for (int i = data.length - 1; i >= 0; i--) {
    String id = data[i]["Id"];
    String client = data[i]["client"];
    String pi_time = data[i]["time_in"] == "00:00:00"
        ? '-'
        : data[i]["time_in"].toString().substring(0, 5);
    String pi_loc = data[i]["loc_in"];
    String po_time = data[i]["time_out"] == "00:00:00"
        ? '-'
        : data[i]["time_out"].toString().substring(0, 5);
    String po_loc = data[i]["loc_out"];
    String emp = data[i]["emp"];
    String latit_in = data[i]["latit"];
    String longi_in = data[i]["longi"];
    String latit_out = data[i]["latit_in"];
    String longi_out = data[i]["longi_out"];
    String desc = data[i]["desc"];
    String pi_img = data[i]["checkin_img"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["checkin_img"].toString();
    String po_img = data[i]["checkout_img"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["checkout_img"].toString();
    //print(data[i]["loc_out"]);
    Punch punches = new Punch(
        Id: id,
        Emp: emp,
        client: client,
        pi_time: pi_time,
        pi_loc: pi_loc.length > 40 ? pi_loc.substring(0, 40) + '...' : pi_loc,
        po_time: po_time == '00:00' ? '-' : po_time,
        po_loc: po_loc.length > 40 ? po_loc.substring(0, 40) + '...' : po_loc,
        pi_latit: latit_in,
        pi_longi: longi_in,
        po_latit: latit_out,
        po_longi: longi_out,
        desc: desc.length > 40 ? desc.substring(0, 40) + '...' : desc,
        pi_img: pi_img,
        po_img: po_img);
    list.add(punches);
  }
  return list;
}

class Punch {
  String Id;
  String Emp;
  String client;
  String pi_time;
  String pi_loc;
  String po_time;
  String po_loc;
  String pi_longi;
  String pi_latit;
  String po_longi;
  String po_latit;
  String desc;
  String pi_img;
  String po_img;

  Punch(
      {this.Id,
      this.Emp,
      this.client,
      this.pi_time,
      this.pi_loc,
      this.po_time,
      this.po_loc,
      this.pi_latit,
      this.pi_longi,
      this.po_latit,
      this.po_longi,
      this.desc,
      this.pi_img,
      this.po_img});
}

////////////////////////////////////////////////-----
///
/// ///////////////////common function
String Formatdate(String date_) {
  // String date_='2018-09-2';
  var months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  var dy = [
    'st',
    'nd',
    'rd',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'st',
    'nd',
    'rd',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'st'
  ];
  var date = date_.split("-");
  return (date[2] +
      "" +
      dy[int.parse(date[2]) - 1] +
      " " +
      months[int.parse(date[1]) - 1]);
}

goToMap(String lat, String long) async {
  if ((lat.toString()).startsWith('0', 0) ||
      (long.toString()).startsWith('0', 0)) return false;
  String url = "https://maps.google.com/?q=" + lat + "," + long;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    //print( 'Could not launch $url');
  }
}

/////////////////////
Future<List<Map>> getDepartmentsList(int label) async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response =
      await http.get(globals.path + 'DepartmentMaster?orgid=$orgid');
  List data = json.decode(response.body.toString());
  List<Map> depts = createList(data, label);
  return depts;
}

List<Map> createList(List data, int label) {
  List<Map> list = new List();
  if (label == 1) // with -All- label
    list.add({"Id": "0", "Name": "-All-"});
  else
    list.add({"Id": "0", "Name": "-Select-"});
  for (int i = 0; i < data.length; i++) {
    if (data[i]["archive"].toString() == '1') {
      Map tos = {
        "Name": data[i]["Name"].toString(),
        "Id": data[i]["Id"].toString()
      };
      list.add(tos);
    }
  }
  return list;
}

Future<List<Map>> getDesignationsList(int label) async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response =
      await http.get(globals.path + 'DesignationMaster?orgid=$orgid');
  List data = json.decode(response.body.toString());
  List<Map> depts = createList(data, label);
  return depts;
}

Future<List<Map>> getShiftsList() async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response = await http.get(globals.path + 'shiftMaster?orgid=$orgid');
  List data = json.decode(response.body.toString());
  List<Map> depts = createList(data, 0);
  return depts;
}

bool validateMobile(String value) {
// Indian Mobile number are of 10 digit only
  if (value.length < 6)
    return false;
  else
    return true;
}

bool validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return false;
  else
    return true;
}

/// ///////////////////common function/
///
/// ///////////////////////////////--generate employees list for DD
Future<List<Map>> getEmployeesList(int label) async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response =
      await http.get(globals.path + 'getEmployeesList?orgid=$orgid');
  List data = json.decode(response.body.toString());
  List<Map> depts = createEMpListDD(data, label);
  // print(depts);
  return depts;
}

List<Map> createEMpListDD(List data, int label) {
  List<Map> list = new List();
  if (label == 1) // with -All- label
    list.add({"Id": "0", "Name": "-All-", "Code": ""});
  else
    list.add({"Id": "0", "Name": "-Select-", "Code": ""});
  for (int i = 0; i < data.length; i++) {
    Map tos;
    if (data[i]["Name"].toString() != '' && data[i]["Name"].toString() != null)
      tos = {
        "Name": data[i]["name"].toString(),
        "Id": data[i]["Id"].toString(),
        "Code": data[i]["ecode"].toString()
      };
    list.add(tos);
  }
  return list;
}

Future<List<Attn>> getEmpHistoryOf30(listType, emp) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  print( globals.path + 'getEmpHistoryOf30?refno=$orgdir&datafor=$listType&emp=$emp');
  final response = await http.get(globals.path +
      'getEmpHistoryOf30?refno=$orgdir&datafor=$listType&emp=$emp');
  // print('================='+dept+'===================');
  final res = json.decode(response.body);
  // print('*************response**************');
  print(res);
  List responseJson;
  if (listType == 'present')
    responseJson = res['present'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings') responseJson = res['earlyLeavings'];
  List<Attn> userList = createListEmpHistoryOf30(responseJson);
  return userList;
}

List<Attn> createListEmpHistoryOf30(List data) {
  // print('Create list called/*******************');
  List<Attn> list = new List();
  for (int i = 0; i < data.length; i++) {
    String Name = Formatdate(data[i]["AttendanceDate"].toString());
    String TimeIn = data[i]["TimeIn"].toString();
    String TimeOut = data[i]["TimeOut"].toString() == '00:00'
        ? '-'
        : data[i]["TimeOut"].toString();
    String EntryImage = data[i]["EntryImage"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["EntryImage"].toString();
    String ExitImage = data[i]["ExitImage"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["ExitImage"].toString();
    String CheckInLoc = data[i]["checkInLoc"].toString();
    String CheckOutLoc = data[i]["CheckOutLoc"].toString();
    String LatitIn = data[i]["latit_in"].toString();
    String LatitOut = data[i]["latit_out"].toString();
    String LongiIn = data[i]["longi_in"].toString();
    String LongiOut = data[i]["longi_out"].toString();
    Attn tos = new Attn(
        Name: Name,
        TimeIn: TimeIn,
        TimeOut: TimeOut,
        EntryImage: EntryImage,
        ExitImage: ExitImage,
        CheckInLoc: CheckInLoc,
        CheckOutLoc: CheckOutLoc,
        LatitIn: LatitIn,
        LatitOut: LatitOut,
        LongiIn: LongiIn,
        LongiOut: LongiOut);
    list.add(tos);
  }
  return list;
}

/// ///////////////////////////////--generate employees list for DD/
/// ////////////////////////////////////////////////-----
Future<List<TimeOff>> getTimeOffSummary() async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  final response = await http.get(globals.path + 'fetchTimeOffList?uid=$empid');
  // print(response.body);
//  print('--------------------getTimeOffList Called-----------------------');
  List responseJson = json.decode(response.body.toString());
  List<TimeOff> userList = createTimeOffList(responseJson);
  return userList;
}

List<TimeOff> createTimeOffList(List data) {
  List<TimeOff> list = new List();
  for (int i = 0; i < data.length; i++) {
    String TimeofDate = data[i]["date"];
    String TimeFrom = data[i]["from"];
    String TimeTo = data[i]["to"];
    String hrs = data[i]["hrs"];
    String Reason = data[i]["reason"];
    String ApprovalSts = data[i]["status"];
    String ApproverComment = data[i]["comment"];
    bool withdrawlsts = data[i]["withdrawlsts"];
    String TimeOffId = data[i]["timeoffid"];
    TimeOff tos = new TimeOff(
        TimeofDate: TimeofDate,
        TimeFrom: TimeFrom,
        TimeTo: TimeTo,
        hrs: hrs,
        Reason: Reason,
        ApprovalSts: ApprovalSts,
        ApproverComment: ApproverComment,
        withdrawlsts: withdrawlsts,
        TimeOffId: TimeOffId);
    list.add(tos);
  }
  return list;
}
////////////////////////////////////////////////-----

Future<bool> getOrgPerm(perm) async {
  final prefs = await SharedPreferences.getInstance();
  String org_perm = prefs.getString('org_perm') ?? '';
  List<String> permissions = org_perm.split(',');
  // for (var x = 0; x < permissions.length; x++)
  // print(permissions.contains(perm.toString()));
  //print("check perm: "+perm.toString());
  return permissions
      .contains(perm.toString()); // return true if permission found in list set
}

//********************************************************************************************//

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////DEPARTMENT CODE START////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//********************************************************************************************//
Future<List<Dept>> getDepartments() async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
//  print('getDept called');
  final response =
      await http.get(globals.path + 'DepartmentMaster?orgid=$orgid');
  // print(response.body);
  List responseJson = json.decode(response.body.toString());
  List<Dept> deptList = createDeptList(responseJson);
  return deptList;
}

List<Dept> createDeptList(List data) {
  List<Dept> list = new List();
  for (int i = 0; i < data.length; i++) {
    String dept = data[i]["Name"];
    String status = data[i]["archive"] == '1' ? 'Active' : 'Inactive';
    String id = data[i]["Id"];
    Dept dpt = new Dept(dept: dept, status: status, id: id);
    list.add(dpt);
  }
  return list;
}

class Dept {
  String dept;
  String status;
  String id;

  Dept({this.dept, this.status, this.id});
}

Future<String> addDept(name, status) async {
  //print('RECIEVED STATUS: '+status.toString());
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  status = status.toString() == 'Active' ? '1' : '0';
  final response = await http.get(globals.path +
      'addDept?uid=$empid&orgid=$orgdir,&name=$name&sts=$status');

  print('Add dept response----------==' + response.body.toString());
  return response.body.toString();
}

Future<String> updateDept(dept, sts, did) async {
  //print('RECIEVED STATUS: '+status.toString());
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  sts = sts.toString() == 'Active' ? '1' : '0';
  final response = await http
      .get(globals.path + 'updateDept?uid=$empid,&dept=$dept&sts=$sts&id=$did');
  return response.body.toString();
}
//********************************************************************************************//
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////DEPARTMENT CODE End////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////DESIGNATION CODE START////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

Future<List<Desg>> getDesignation() async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  // print('getDesg called');
  final response =
      await http.get(globals.path + 'DesignationMaster?orgid=$orgid');
  // print(response.body);
  List responseJson = json.decode(response.body.toString());
  List<Desg> desgList = createDesgList(responseJson);
  return desgList;
}

List<Desg> createDesgList(List data) {
  List<Desg> list = new List();
  for (int i = 0; i < data.length; i++) {
    String desg = data[i]["Name"];
    String status = data[i]["archive"] == '1' ? 'Active' : 'Inactive';
    String id = data[i]["Id"];
    Desg dpt = new Desg(desg: desg, status: status, id: id);
    list.add(dpt);
  }
  return list;
}

class Desg {
  String desg;
  String status;
  String id;
  List modulepermissions;

  Desg({this.desg, this.status, this.id, this.modulepermissions});
}

Future<String> addDesg(name, status) async {
  //print('RECIEVED STATUS: '+status.toString());
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  status = status.toString() == 'Active' ? '1' : '0';
  final response = await http.get(globals.path +
      'addDesg?uid=$empid&orgid=$orgdir,&name=$name&sts=$status');
  return response.body.toString();
}

Future<String> updateDesg(desg, sts, did) async {
  //print('RECIEVED STATUS: '+status.toString());
  print(desg + "   " + sts + "   " + did);
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  sts = sts.toString() == 'Active' ? '1' : '0';
  final response = await http
      .get(globals.path + 'updateDesg?uid=$empid,&desg=$desg&sts=$sts&id=$did');
  print(response.body.toString());
  return response.body.toString();
}

//********************************************************************************************//
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////DESIGNATION CODE End////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////Employee CODE START////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

Future<List<Emp>> getEmployee() async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  String empid = prefs.getString('empid')?? '0';
    print('getEmp called');
    print(globals.path + 'getUsersMobile?refno=$orgid&empid=$empid');
  final response = await http.get(globals.path + 'getUsersMobile?refno=$orgid&empid=$empid');
//  print(response.body);
//  print('fun end here1');
  List responseJson = json.decode(response.body.toString());
  // print('fun end here2');
  print(responseJson);
  List<Emp> empList = createEmpList(responseJson);
   print('fun end here3');
  print(empList);
  return empList;
}

List<Emp> createEmpList(List data) {
  List<Emp> list = new List();
  for (int i = 0; i < data.length; i++) {

    String name = data[i]["name"];

    String dept = data[i]["Department"].length > 20 ? data[i]["Department"].substring(0, 15) + '..' : data[i]["Department"];
    String desg = data[i]["Designation"].length > 20 ? data[i]["Designation"].substring(0, 15) + '..' : data[i]["Designation"];
    print("This is testing line");
    String shift = data[i]["Shift"];
    String status = data[i]["archive"] == '1' ? 'Active' : 'Inactive';
    String id = data[i]["Id"];
    String Email = data[i]["Email"];
    String Mobile = data[i]["Mobile"];
    String Admin = data[i]["Admin"] == '1' ? 'Mobile Admin' : 'User';
    String Profile = data[i]["Profile"];

    Emp emp = new Emp(
        Name: name,
        Department: dept,
        Designation: desg,
        Shift: shift,
        Status: status,
        Email: Email,
        Mobile: Mobile,
        Admin: Admin,
        Profile: Profile,
        Id: id);
    list.add(emp);
  }
  return list;
}

class Emp {
  String Name;
  String Department;
  String Designation;
  String Shift;
  String Status;
  String Email;
  String Mobile;
  String Admin;
  String Profile;
  String Id;

  // Emp({this.Name, this.Department, this.Designation, this.Status, this.Id});
  Emp(
      {this.Name,
      this.Department,
      this.Designation,
      this.Shift,
      this.Status,
      this.Id,
      this.Email,
      this.Mobile,
      this.Admin,
      this.Profile});
}

Future<int> addEmployee(fname, lname, email, countryCode, countryId, contact,
    password, dept, desg, shift) async {
  //print('RECIEVED STATUS: '+status.toString());
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
//  print('addEmp function called, parameters :');
/*  print(fname +
      '--' +
      lname +
      '--' +
      email +
      '--' +
      countryCode +
      '--' +
      countryId +
      '--' +
      contact +
      '--' +
      password);*/
//  print(globals.path+'registerEmp?uid=$empid&org_id=$orgdir,&f_name=$fname,&l_name=$lname,&password=$password,&username=$email,&contact=$contact,&country=$countryId,&countrycode=$countryCode,&admin=1');
  final response = await http.get(globals.path +
      'registerEmp?uid=$empid&org_id=$orgdir&f_name=$fname&l_name=$lname&password=$password&username=$email&contact=$contact&country=$countryId&countrycode=$countryCode&admin=1&designation=$desg&department=$dept&shift=$shift');
  var res = json.decode(response.body);
  print("--------> Adding employee" + res.toString());
  return res['sts'];
}
//********************************************************************************************//
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////Employee CODE End////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

// //////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////SHIFT HANDELING START////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//********************************************************************************************//

Future<List<Shift>> getShifts() async {
  // print('shifts called');
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  // print(globals.path + 'shiftMaster?orgid=10');
  final response = await http.get(globals.path + 'shiftMaster?orgid=$orgid');
  List responseJson = json.decode(response.body.toString());
  List<Shift> shiftList = createShiftList(responseJson);
//  print(shiftList);
  return shiftList;
}

List<Shift> createShiftList(List data) {
  List<Shift> list = new List();
  for (int i = 0; i < data.length; i++) {
    String name = data[i]["Name"];
    String timein = data[i]["TimeIn"];
    String timeout = data[i]["TimeOut"];
    String id = data[i]["Id"];
    String status = data[i]["archive"] == '0' ? 'Inactive' : 'Active';
    String type =
        data[i]["shifttype"] == '1' ? 'One Day Shift' : 'Two Day Shift';

    Shift shift = new Shift(
        Id: id,
        Name: name,
        TimeIn: timein,
        TimeOut: timeout,
        Status: status,
        Type: type);
    list.add(shift);
  }
  return list;
}

class Shift {
  String Id;
  String Name;
  String TimeIn;
  String TimeOut;
  String Status;
  String Type;

  Shift(
      {this.Id, this.Name, this.TimeIn, this.TimeOut, this.Status, this.Type});
}

Future<int> createShift(name, type, from, to, from_b, to_b) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  final response = await http.get(globals.path +
      'addShift?name=$name&org_id=$orgdir&ti=$from&to=$to&tib=$from_b&tob=$to_b&sts=1&shifttype=$type');
  int res = int.parse(response.body);
  return res;
}

Future<String> updateShift(shift, sts, did) async {
  //print('RECIEVED STATUS: '+status.toString());
  print(shift + "   " + sts + "   " + did);
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  sts = sts.toString() == 'Active' ? '1' : '0';
  final response = await http.get(
      globals.path + 'updateShift?uid=$empid,&shift=$shift&sts=$sts&id=$did');
  print(response.body.toString());
  return response.body.toString();
}

//********************************************************************************************//
// //////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////SHIFT HANDELING End////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////RESET/Forgot PASSWORD START////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//********************************************************************************************//
Future<int> changeMyPassword(oldPass, newPass) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  //  print(oldPass+'--'+newPass);
  final response = await http.get(globals.path +
      'changePassword?uid=$empid&refno=$orgdir&pwd=$oldPass&npwd=$newPass');
  if (int.parse(response.body) == 1) {
    prefs.setString('usrpwd', newPass);
  }
  return int.parse(response.body);
}

Future<int> resetMyPassword(username) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('username', username);
  print('Forgot password rew sbmit' + username);
  final response =
      await http.get(globals.path + 'resetPasswordLink?una=$username');
  print("response for forgot pass::::" + response.body.toString());
  return int.parse(response.body);
} //'https://ubiattendance.ubihrm.com/index.php/services/resetPasswordLink?una='+una+'&refno='+refno,
//********************************************************************************************//
// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////RESET/FORGOT PASSWORD END////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////REPORTS SERVICES STARTS////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//********************************************************************************************//
Future<List<Attn>> getTodaysAttn(listType) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  String empid = prefs.getString('empid') ?? '';
  final response = await http.get(globals.path +
      'getAttendances_new?refno=$orgdir&datafor=$listType&empid=$empid');
  final res = json.decode(response.body);
  // print(res);
  List responseJson;
  if (listType == 'present')
    responseJson = res['present'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings') responseJson = res['earlyLeavings'];
  List<Attn> userList = createTodayEmpList(responseJson);
  return userList;
}

Future<List<SyncNotification>> getNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgid') ?? '0';
  String empid = prefs.getString('empid') ?? '0';
  print(globals.path +
      'getNotifications'
          '?EmployeeId=$empid&OrganizationId=$orgid');

  final response = await http.get(globals.path +
      'getNotifications'
          '?EmployeeId=$empid&OrganizationId=$orgid');
  print(globals.path +
      'getNotifications'
          '?EmployeeId=$empid&OrganizationId=$orgid');
  final res = json.decode(response.body);

   print(res);

  List responseJson=res;

  List<SyncNotification> userList = createNotificationList(responseJson);
  return userList;
}

List<SyncNotification> createNotificationList(List data) {
  // print('Create list called/*******************');
  List<SyncNotification> list = new List();
  for (int i = 0; i < data.length; i++) {
    int Id=int.parse(data[i]['Id']);
    int EmployeeId=int.parse(data[i]['EmployeeId']);
    int OrganizationId=int.parse(data[i]['OrganizationId']);
    String SyncDate=data[i]['SyncDate'];
    String OfflineMarkedDate=data[i]['OfflineMarkedDate'];
    String Time=data[i]['Time'];;
    String Action=data[i]['Action'];
    String Latitude=data[i]['Latitude'];
    String Longitude=data[i]['Longitude'];
    String ReasonForFailure=data[i]['ReasonForFailure'];
    String image=data[i]['image'];


    SyncNotification tos = new SyncNotification(
        Id,
        EmployeeId,
        OrganizationId,
        SyncDate,
        OfflineMarkedDate,
        Time,
        Action,
        Latitude,
        Longitude,
        ReasonForFailure,
        image
    );
    list.add(tos);
  }
  return list;
}



List<Attn> createTodayEmpList(List data) {
  // print('Create list called/*******************');
  List<Attn> list = new List();
  for (int i = 0; i < data.length; i++) {
    String Id = data[i]['id'].toString();
    String Name = data[i]["name"].toString();
    String TimeIn = data[i]["TimeIn"].toString();
    String TimeOut = data[i]["TimeOut"].toString() == '00:00'
        ? '-'
        : data[i]["TimeOut"].toString();
    String EntryImage = data[i]["EntryImage"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["EntryImage"].toString();
    String ExitImage = data[i]["ExitImage"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["ExitImage"].toString();
    String CheckInLoc = data[i]["checkInLoc"].toString();
    String CheckOutLoc = data[i]["CheckOutLoc"].toString();
    String LatitIn = data[i]["latit_in"].toString();
    String LatitOut = data[i]["latit_out"].toString();
    String LongiIn = data[i]["longi_in"].toString();
    String LongiOut = data[i]["longi_out"].toString();
    String Total = data[i]["total"].toString();
    String Present = data[i]["present"].toString();
    String Absent = data[i]["absent"].toString();

    Attn tos = new Attn(
      Id: Id,
      Name: Name,
      TimeIn: TimeIn,
      TimeOut: TimeOut,
      EntryImage: EntryImage,
      ExitImage: ExitImage,
      CheckInLoc: CheckInLoc,
      CheckOutLoc: CheckOutLoc,
      LatitIn: LatitIn,
      LatitOut: LatitOut,
      LongiIn: LongiIn,
      LongiOut: LongiOut,
      Total: Total,
      Present: Present,
      Absent: Absent,
    );
    list.add(tos);
  }
  return list;
}

class Attn {
  String Id;
  String Name;
  String TimeIn;
  String TimeOut;
  String EntryImage;
  String ExitImage;
  String CheckInLoc;
  String CheckOutLoc;
  String LatitIn;
  String LatitOut;
  String LongiIn;
  String LongiOut;
  String Total;
  String Present;
  String Absent;

  Attn({
    this.Id,
    this.Name,
    this.TimeIn,
    this.TimeOut,
    this.EntryImage,
    this.ExitImage,
    this.CheckInLoc,
    this.CheckOutLoc,
    this.LatitIn,
    this.LatitOut,
    this.LongiIn,
    this.LongiOut,
    this.Total,
    this.Present,
    this.Absent,
  });
}

class SyncNotification {
  int Id;
  int EmployeeId;
  int OrganizationId;
  String SyncDate;
  String OfflineMarkedDate;
  String Time;
  String Action;
  String Latitude;
  String Longitude;
  String ReasonForFailure;
  String image;

  SyncNotification(
    this.Id,
    this.EmployeeId,
    this.OrganizationId,
    this.SyncDate,
    this.OfflineMarkedDate,
    this.Time,
    this.Action,
    this.Latitude,
    this.Longitude,
    this.ReasonForFailure,
    this.image,

  );
}



//******************Cdate Attn List Data
Future<List<Attn>> getCDateAttn(listType, date) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  String empid = prefs.getString('empid') ?? '';
  print(globals.path + 'getCDateAttendances_new?refno=$orgdir&date=$date&datafor=$listType&empid=$empid');
  final response = await http.get(globals.path +
      'getCDateAttendances_new?refno=$orgdir&date=$date&datafor=$listType&empid=$empid');
  final res = json.decode(response.body);
  // print(res);
  List responseJson;
  if (listType == 'present')
    responseJson = res['present'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings') responseJson = res['earlyLeavings'];
  List<Attn> userList = createTodayEmpList(responseJson);
  return userList;
}

//******************Cdate Attn List Data

//******************Cdate Attn DepartmentWise
Future<List<Attn>> getCDateAttnDeptWise(listType, date, dept) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
print( globals.path + 'getCDateAttnDeptWise_new?refno=$orgdir&date=$date&datafor=$listType&dept=$dept');
  final response = await http.get(globals.path +
      'getCDateAttnDeptWise_new?refno=$orgdir&date=$date&datafor=$listType&dept=$dept');
  // print('================='+dept+'===================');
  final res = json.decode(response.body);
  // print('*************response**************');
  print(res);
  List responseJson;
  if (listType == 'present')
    responseJson = res['present'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings') responseJson = res['earlyLeavings'];
  List<Attn> userList = createTodayEmpList(responseJson);
  return userList;
}

Future<List<Attn>> getEmpdataDepartmentWise(date) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
//print( globals.path + 'getCDateAttnDeptWise_new?refno=$orgdir&date=$date&datafor=$listType&dept=$dept');
  final response = await http
      .get(globals.path + 'getEmpdataDepartmentWise?refno=$orgdir&date=$date');
  // print('================='+dept+'===================');
  final res = json.decode(response.body);
  // print('*************response**************');
  print(res);
  List responseJson;
  responseJson = res['departments'];
  List<Attn> userList = createTodayEmpList(responseJson);
  return userList;
}

//******************Cdate Attn DepartmentWise//
//******************Cdate Attn DesignationWise
Future<List<Attn>> getCDateAttnDesgWise(listType, date, desg) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
   print(globals.path +
       'getCDateAttnDesgWise_new?refno=$orgdir&date=$date&datafor=$listType&desg=$desg');
  final response = await http.get(globals.path +
      'getCDateAttnDesgWise_new?refno=$orgdir&date=$date&datafor=$listType&desg=$desg');
  // print('================='+dept+'===================');
  final res = json.decode(response.body);
  // print('*************response**************');
  print(res);
  List responseJson;
  if (listType == 'present')
    responseJson = res['present'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings') responseJson = res['earlyLeavings'];
  List<Attn> userList = createTodayEmpList(responseJson);
  return userList;
}
//******************Cdate Attn DesignationWise//

//******************yesterday Attn List Data
Future<List<Attn>> getYesAttn(listType) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  final response = await http
      .get(globals.path + 'getAttendances_yes?refno=$orgdir&datafor=$listType');
  final res = json.decode(response.body);
  // print(res);
  List responseJson;
  if (listType == 'present')
    responseJson = res['present'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings') responseJson = res['earlyLeavings'];
  List<Attn> userList = createTodayEmpList(responseJson);
  return userList;
}
//******************yesterday Attn List Data

// getData list for last 7/30 days- start
Future<List<Attn>> getAttnDataLast(days, listType) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
   print(globals.path + 'getAttnDataLast?refno=$orgdir&datafor=$listType&limit=$days');
  final response = await http.get(globals.path +
      'getAttnDataLast?refno=$orgdir&datafor=$listType&limit=$days');
  final res = json.decode(response.body);
//  print(res);
  List responseJson;
  responseJson = res['elist'];

  /* if (listType == 'present')
    responseJson = res['elist'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings')
    responseJson = res['earlyLeavings'];*/
  List<Attn> userList = createLastEmpList(responseJson);
  return userList;
}

// getData list for last 7/30 days- close
List<Attn> createLastEmpList(List data) {
  data = data.reversed.toList();
  List<Attn> list = new List();

  for (int i = 0; i < data.length; i++) {
    //  print('Create list called*******************');
    // print(data[i][0]['name']);
    String Name = '';
    String TimeIn = '';
    String TimeOut = '';
    String date = '';
    String ExitImage = '';
    String CheckInLoc = '';
    String CheckOutLoc = '';
    String LatitIn = '';
    String LatitOut = '';
    String LongiIn = '';
    String LongiOut = '';
    if (data[i].length != 0) {
      for (int j = 0; j < data[i].length; j++) {
        Name = data[i][j]["name"].toString();
        TimeIn = data[i][j]["TimeIn"].toString() == '00:00:00' ||
                data[i][j]["TimeIn"].toString() == '-'
            ? '-'
            : data[i][j]["TimeIn"].toString().substring(0, 5);
        TimeOut = data[i][j]["TimeOut"].toString() == '00:00:00' ||
                data[i][j]["TimeOut"].toString() == '-'
            ? '-'
            : data[i][j]["TimeOut"].toString().substring(0, 5);
        date = Formatdate(data[i][j]["AttendanceDate"].toString());
        ExitImage = '';
        CheckInLoc = '';
        CheckOutLoc = '';
        LatitIn = '';
        LatitOut = '';
        LongiIn = '';
        LongiOut = '';

        Attn tos = new Attn(
            Name: Name,
            TimeIn: TimeIn,
            TimeOut: TimeOut,
            EntryImage: date,
            ExitImage: ExitImage,
            CheckInLoc: CheckInLoc,
            CheckOutLoc: CheckOutLoc,
            LatitIn: LatitIn,
            LatitOut: LatitOut,
            LongiIn: LongiIn,
            LongiOut: LongiOut);
        list.add(tos);
      }
    }
  }
  return list;
}

//********************************************************************************************//
// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////REPORTS SERVICES ENDS///////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////Get chart data start///////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//********************************************************************************************//
Future<List<Map<String, String>>> getChartDataToday() async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  final response =
      await http.get(globals.path + 'getChartDataToday?refno=$orgdir');
  final data = json.decode(response.body);
  List<Map<String, String>> val = [
    {
      "present": data['present'].toString(),
      "absent": data['absent'].toString(),
      "late": data['late'].toString(),
      "early": data['early'].toString()
    }
  ];
  // print('==========');
  // print(val);
  return val;
}

Future<List<Map<String, String>>> getChartDataYes() async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  final response =
      await http.get(globals.path + 'getChartDataYes?refno=$orgdir');
  final data = json.decode(response.body);
  List<Map<String, String>> val = [
    {
      "present": data['present'].toString(),
      "absent": data['absent'].toString(),
      "late": data['late'].toString(),
      "early": data['early'].toString()
    }
  ];
  // print('==========');
  // print(val);
  return val;
}

Future<List<Map<String, String>>> getChartDataCDate(date) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  final response = await http
      .get(globals.path + 'getChartDataCDate?refno=$orgdir&date=$date');
  final data = json.decode(response.body);
  //print(response);
  List<Map<String, String>> val = [
    {
      "present": data['present'].toString(),
      "absent": data['absent'].toString(),
      "late": data['late'].toString(),
      "early": data['early'].toString()
    }
  ];
  // print('==========');
  // print(val);
  return val;
}

Future<List<Map<String, String>>> getChartDataLast(dys) async {
  // dys: no. of days
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  List<Map<String, String>> val = [];
  if (dys.toString() == 'l7') {
    final response = await http
        .get(globals.path + 'getChartDataLast_7?refno=$orgdir&limit=$dys');
    final data = json.decode(response.body);
    for (int i = 0; i < data.length; i++)
      val.add({
        "date": data[i]['event'].toString(),
        "total": data[i]['total'].toString()
      });
  } else if (dys.toString() == 'l30') {
    final response = await http
        .get(globals.path + 'getChartDataLast_30?refno=$orgdir&limit=$dys');
    final data = json.decode(response.body);
    for (int i = 0; i < data.length; i++)
      val.add({
        "date": data[i]['event'].toString(),
        "total": data[i]['total'].toString()
      });
  }
  return val;
}
//********************************************************************************************//
// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////Get chart data ends///////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////Get late/early/timeoff emp reports///////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//********************************************************************************************//
Future<List<EmpList>> getLateEmpDataList(date) async {
  if (date == '' || date == null) return null;
  // print('shifts called');
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response =
      await http.get(globals.path + 'getlateComings?refno=$orgid&cdate=$date');
  List responseJson = json.decode(response.body.toString());
  List<EmpList> list = createListLateComings(responseJson);
  //print(list);
  return list;
}

List<EmpList> createListLateComings(List data) {
  List<EmpList> list = new List();
  for (int i = 0; i < data.length; i++) {
    String diff = data[i]["lateby"];
    String timeAct = data[i]["timein"];
    String name = data[i]["name"];
    String shift = data[i]["shift"];
    String date = data[i]["date"];
    EmpList row = new EmpList(
        diff: diff, timeAct: timeAct, name: name, shift: shift, date: date);
    list.add(row);
  }
  return list;
}

class EmpList {
  String diff;
  String timeAct; // timein or timeout
  String name;
  String shift;
  String date;

  EmpList({this.diff, this.timeAct, this.name, this.shift, this.date});
}

////*********************************************************************
Future<List<EmpList>> getEarlyEmpDataList(date) async {
  if (date == '' || date == null) return null;
  // print('shifts called');
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response = await http
      .get(globals.path + 'getEarlyLeavings?refno=$orgid&cdate=$date');
  List responseJson = json.decode(response.body.toString());
  List<EmpList> list = createListEarlyLeaving(responseJson);
  // print(list);
  return list;
}

List<EmpList> createListEarlyLeaving(List data) {
  List<EmpList> list = new List();
  for (int i = 0; i < data.length; i++) {
    String diff = data[i]["earlyby"];
    String timeAct = data[i]["timeout"];
    String name = data[i]["name"];
    String shift = data[i]["shift"];
    String date = data[i]["date"];
    EmpList row = new EmpList(
        diff: diff, timeAct: timeAct, name: name, shift: shift, date: date);
    list.add(row);
  }
  return list;
}

//*******************************************************
Future<List<EmpListTimeOff>> getTimeOFfDataList(date) async {
  if (date == '' || date == null) return null;
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response = await http
      .get(globals.path + 'getTimeoffList?fd=$date&to=$date&refno=$orgid');

  List responseJson = json.decode(response.body.toString());
  // print(responseJson.toString());
  List<EmpListTimeOff> list = createTimeOFfDataList(responseJson);
//  print(list);
  return list;
}

List<EmpListTimeOff> createTimeOFfDataList(List data) {
  List<EmpListTimeOff> list = new List();
  for (int i = 0; i < data.length; i++) {
    String diff = data[i]["diff"];
    String to = data[i]["TimeTo"];
    String from = data[i]["TimeFrom"];
    String name = data[i]["name"];
    String date = data[i]["tod"];
    String ApprovalSts = data[i]["ApprovalSts"];
    EmpListTimeOff row = new EmpListTimeOff(
        diff: diff, to: to, from: from, name: name, date: date,ApprovalSts:ApprovalSts);
    list.add(row);
  }
  return list;
}

class EmpListTimeOff {
  String diff;
  String to;
  String from;
  String name;
  String date;
  String ApprovalSts;

  EmpListTimeOff({this.diff, this.to, this.from, this.name, this.date,this.ApprovalSts});
}
//********************************************************************************************//
// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////Get late/early emp reports/timeoff close///////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
////////////////////////////Punch location/visits  reports start////////////////////////
///////////////////////////////////////////////////////////////////////

Future<List<Punch>> getVisitsDataList(date,emp) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  // print(globals.path + 'getPunchInfo?orgid=$orgdir&date=$date');
  final response =
      await http.get(globals.path + 'getPunchInfo?orgid=$orgdir&date=$date&uid=$emp');
  List responseJson = json.decode(response.body.toString());
  List<Punch> userList = createUserList(responseJson);
  // print('getSummaryPunch called--1');
//  print(userList);
  // print('getSummaryPunch called--2');
  return userList;
}

// ///////////////////////////////////////////////////////////////////
////////////////////////////Punch location/visits  reports ends////////////////////////
///////////////////////////////////////////////////////////////////////
Future<Map> checkOrganization(crn) async {
  final response =
      await http.get(globals.path + 'checkOrganization?refid=$crn');

  var responseJson = json.decode(response.body.toString());
  Map<String, String> res;
  if (responseJson['sts'].toString() == '1')
    res = {
      'sts': responseJson['sts'].toString(),
      'Id': responseJson['result'][0]['Id'].toString(),
      'Name': responseJson['result'][0]['Name'].toString()
    };
  else
    res = {'sts': responseJson['sts'].toString()};
  return res;
}

Future<List> getAttentancees() async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response =
      await http.get(globals.path + 'getAttendancees?orgid=$orgid');
  List responseJson = json.decode(response.body.toString());
  print(responseJson);
  return responseJson;
  // List<Shift> shiftList = createShiftList(responseJson);

  // return shiftList;
}

MarkAttendance(data) {
  print('bulk attendance mark successfully');
  //print(data);
}

// ///////////////////////////////////////////////////////////////////
////////////////////////////Bulk Attendance////////////////////////
///////////////////////////////////////////////////////////////////////

class grpattemp {
  String Name;
  String Department;
  String Designation;
  String Status;
  String Id;
  String img;
  String attsts;
  String timein;
  String timeout;
  String rtimein;
  String rtimeout;
  String todate;
  String shift;
  String shifttype;
  int csts;
  String Attid;
  String data_date;
  String device;

  grpattemp(
      {this.Name,
      this.Department,
      this.Designation,
      this.Status,
      this.csts,
      this.img,
      this.attsts,
      this.timein,
      this.timeout,
      this.rtimein,
      this.rtimeout,
      this.todate,
      this.shift,
      this.shifttype,
      this.Id,
      this.Attid,
      this.data_date,
      this.device});
}

Future<List<grpattemp>> getDeptEmp(value) async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  String empid = prefs.getString('empid')?? '0';
  print(value);

  String formattedDate;
  if (value == "Today") {
    var now = new DateTime.now();
    print(now);
    var formatter = new DateFormat('yyyy-MM-dd');
    formattedDate = formatter.format(now);
    print(formattedDate);
    print("bbbbbb");
  }

  if (value == "Yesterday") {
    var today = new DateTime.now();
    DateTime onedayago = today.subtract(new Duration(days: 1));
    var formatter = new DateFormat('yyyy-MM-dd');
    formattedDate = formatter.format(onedayago);
    print(formattedDate);
  }
  //print(globals.path + 'getDeptEmp?orgid=$orgid&dept=13');
  final response =
      await http.get(globals.path + 'getDeptEmp?orgid=$orgid&datafor=$value&empid=$empid');

  print(globals.path + 'getDeptEmp?orgid=$orgid&datafor=$value&empid=$empid');
  List responseJson = json.decode(response.body.toString());
  print("))))))))))");
  // print(responseJson);
  List<grpattemp> deptList = createDeptempList(responseJson);
  // print(responseJson);
  return deptList;
}

List<grpattemp> createDeptempList(List data) {
  List<grpattemp> list = new List();
  for (int i = 0; i < data.length; i++) {
    String name = data[i]["name"];
    // String status=data[i]["archive"]=='1'?'Active':'Inactive';
    String id = data[i]["id"];
    int csts = data[i]["csts"];
    String img = data[i]["img"];
    // String timein=data[i]["timein"];
    String timein = data[i]["timein"];
    String timeout = data[i][
        "timeout"]; //(hour: data[i]["timeout"].split(":")[0], minute: data[i]["timeout"].split(":")[1]);
    //print(timein+' and '+timeout);
    String attsts = '1';
    String todate = data[i]["todate"];
    String shift = data[i]["shift"];
    String shifttype = data[i]["shifttype"];
    String rtimein = data[i]["rtimein"];
    String rtimeout = data[i]["rtimeout"];
    String attid = data[i]["Attid"];
    String data_date = data[i]["data_date"];
    String device = data[i]["device"];
    //String timein='';
    //String timeout ='';
    if (data[i]["rtimein"] != '') {
      timein = data[i]["rtimein"];
    }
    if (data[i]["rtimeout"] != '') {
      timeout = data[i]["rtimeout"];
    }
    print("......");
    print(timein);
    print(timeout);
    grpattemp dpt = new grpattemp(
        Name: name,
        csts: csts,
        img: img,
        attsts: attsts,
        timein: timein,
        timeout: timeout,
        todate: todate,
        shift: shift,
        shifttype: shifttype,
        Id: id,
        Attid: attid,
        data_date: data_date,
        device: device);
    list.add(dpt);
  }
  return list;
}

addBulkAtt(List<grpattemp> data) async {
  var dio = new Dio();
  String location = globals.globalstreamlocationaddr;

  String lat = globals.assign_lat.toString();
  String long = globals.assign_long.toString();
  print("global Address: " + location);
  print("global lat" + lat);
  print("global long" + long);
  print("_updatetimeoutt");
  // print(_updatetimeout);
  List<Map> list = new List();
  print(data);
  //print(list);
  for (int i = 0; i < data.length; i++) {
    String Attid = data[i].Attid.toString();
    Map per = {
      "Id": data[i].Id.toString(),
      "Name": data[i].Name.toString(),
      "timein": data[i].timein,
      "timeout": data[i].timeout,
      "attsts": data[i].attsts.toString(),
      "todate": data[i].todate.toString(),
      "shift": data[i].shift.toString(),
      "Attid": data[i].Attid.toString(),
      "data_date": data[i].data_date.toString(),
    };
    list.add(per);
  }
  var jsonlist;
  jsonlist = json.encode(list);
  print(jsonlist);
  //print('RECIEVED STATUS: '+status.toString());
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
//  print('addEmp function called, parameters :');
  print(globals.path +
      'CreateBulkAtt?uid=$empid&org_id=$orgdir&attlist=$jsonlist');
  try {
    FormData formData = new FormData.from({
      "attlist": jsonlist,
      "org_id": orgdir,
      "uid": empid,
      "location": location,
      "lat": lat,
      "long": long,
    });
    Response response = await dio.post(globals.path + "CreateBulkAtt/",
        data:
            formData); //, options: new Options(contentType:ContentType.parse("application/json"))
    //print(response.data.toString());
    //Map permissionMap = json.decode(response.data.toString());
    if (response.statusCode == 200) {
      print("successfully");
      return "success";
    } else {
      //print("failed");
      return "failed";
    }
  } catch (e) {
    //print("connection error");
    return "connection error";
    //print(e.toString());
  }
  final response = await http.get(globals.path +
      'CreateBulkAtt?uid=$empid&org_id=$orgdir&attlist=$jsonlist');
  var res = json.decode(response.body);
  print("--------> Adding Bulk Attendance" + res.toString());
  return res['sts'];
}
///////////////////////////////////////////////////////////
////////////////////////////group attendance ends///////////////////////////////
///////////////////////////////////////////////////////////

////////////check net
Future<int> checkNet() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      varCheckNet = 1;
    } else {
      varCheckNet = 0;
    }
  } on SocketException catch (_) {
    print('not connected');
    varCheckNet = 0;
  }
  return varCheckNet;
}
////////////check net/

getAddressFromLati( String Latitude,String Longitude) async{
  try {
    ///print(_currentLocation);
    //print("${_currentLocation["latitude"]},${_currentLocation["longitude"]}");
    if (globals.assign_lat.compareTo(0.0) != 0&&globals.assign_lat!=null) {
      var addresses = await Geocoder.local.findAddressesFromCoordinates(
          Coordinates(
              globals.assign_lat, globals.assign_long));
      var first = addresses.first;
      //streamlocationaddr = "${first.featureName} : ${first.addressLine}";
      var streamlocationaddr = "${first.addressLine}";

      globalstreamlocationaddr = streamlocationaddr;
      return streamlocationaddr;
    }
    else{
      globalstreamlocationaddr="Location not fetched.";

      return globalstreamlocationaddr;
    }

  }catch(e){
    print(e.toString());
    if (globals.assign_lat.compareTo(0.0) != 0&&globals.assign_lat!=null) {
      globalstreamlocationaddr = "${Latitude},${Longitude}";
      print("inside iffffffffffffffffffffffffffffffffffffffffffffff"+globals.assign_lat.toString());
    }
    else{
      globalstreamlocationaddr="Location not fetched.";
    }

    return globals.globalstreamlocationaddr;
  }
}




checkNetForOfflineMode(context) {
 // checkLocationEnabled(context);
  checkNet().then((value) async {
    var prefs=await SharedPreferences.getInstance();
    var isLoggedIn=prefs.getInt("response");
  var OfflineModePermitted=prefs.getInt("OfflineModePermission")??0;


    if (value == 0) {
      print(
          '====================internet checked...Not connected=====================');
      SchedulerBinding.instance.addPostFrameCallback((_) {
      if(isLoggedIn==1 && OfflineModePermitted==1) {
        Navigator
            .of(context)
            .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => OfflineHomePage()));
      }
      });
    }
  });
}


appResumedFromBackground(context){
  SystemChannels.lifecycle.setMessageHandler((msg)async{
    if(msg=='AppLifecycleState.resumed' )
    {
      print("------------------------------------ App Resumed-----------------------------");
      serverConnected= await checkConnectionToServer();

      if(serverConnected==0){
        Navigator
            .of(context)
            .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => OfflineHomePage()));
      }

    }

  });
}



checknetonpage(context) {
  checkNet().then((value) {
    if (value == 0) {
      print(
          '====================internet checked...Not connected=====================');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator
            .of(context)
            .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => OfflineHomePage()));
      /*  Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OfflineHomePage()),
        );*/
      });
    }
  });
}

Future<String> getAreaStatus() async {
  //print('getAreaStatus 1');
 // LocationData _currentLocation = globals.list[globals.list.length - 1];
  double lat = globals.assign_lat;
  double long = globals.assign_long;
  double assign_lat = globals.assigned_lat;
  double assign_long = globals.assigned_long;
  double assign_radius = globals.assign_radius;

  /*print("${assign_long}");
  print("${assign_lat}");
  print("${assign_radius}");*/
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  //print('SERVICE CALLED: '+globals.path + 'getAreaStatus?lat=$lat&long=$long&empid=$empid');
  String status = '0';
  /*if(empid!=null && empid!='' && empid!=0) {
    final response =
    await http.get(
        globals.path + 'getAreaStatus?lat=$lat&long=$long&empid=$empid');
    status = json.decode(response.body.toString());
  }*/
  //print('-------status----------->');
  //print(status);
  // print('<-------status-----------');
  if (empid != null && empid != '' && empid != 0) {
    double calculateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    }

    double totalDistance =
        calculateDistance(lat, long, assign_lat, assign_long);
    status = (assign_radius >= totalDistance) ? '1' : '0';
    // print("sohan ${status}");
  }
 // print(status);
  return status;
}

getCsv(associateList, fname, name) async {
  //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and associateList be a list of associate model class.

  List<List<dynamic>> rows = List<List<dynamic>>();
  List<dynamic> row1 = List();

  if (name == 'dept') {
    row1.add('Department');
    row1.add('Total');
    row1.add('Present');
    row1.add('Absent');
    rows.add(row1);
    for (int i = 0; i < associateList.length; i++) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      List<dynamic> row = List();
      row.add(associateList[i].Name);
      row.add(associateList[i].Total);
      row.add(associateList[i].Present);
      row.add(associateList[i].Absent);
      rows.add(row);
    }
  } else {
    row1.add('Name');
    if (name != 'absent') {
      row1.add('TimeIn');
      row1.add('TimeIn Location');
      row1.add('TimeOut');
      row1.add('TimeOut Location');
    }
    rows.add(row1);
    for (int i = 0; i < associateList.length; i++) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      List<dynamic> row = List();
      row.add(associateList[i].Name);
      if (name != 'absent') {
        row.add(associateList[i].TimeIn);
        row.add(associateList[i].CheckInLoc);
        row.add(associateList[i].TimeOut);
        row.add(associateList[i].CheckOutLoc);
      }
      rows.add(row);
    }
  }


  PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  print(permission);
  Map<PermissionGroup, PermissionStatus> permissions;
  if(permission.toString()!='PermissionStatus.granted'){
    permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  }

  //PermissionStatus res = await SimplePermissions.requestPermission(Permission. WriteExternalStorage);
  /*final res = await SimplePermissions.requestPermission(
      Permission.WriteExternalStorage);
  bool checkPermission =
      await SimplePermissions.checkPermission(Permission.WriteExternalStorage);*/
  if (permission.toString() == "PermissionStatus.granted") {
//store file in documents folder
    String dir = (await getExternalStorageDirectory()).absolute.path;
    String file = "$dir/ubiattendance_files/";
    await new Directory('$file').create(recursive: true);
    print(" FILE " + file);
    File f = new File(file + fname + ".csv");

// convert rows to String and write as csv file
    String csv = const ListToCsvConverter().convert(rows);
    f.writeAsString(csv);
    return file + fname + ".csv";
  }
}

///Flexi Attendance start///

class FlexiAtt {
  String Id;
  String Emp;
  String client;
  String pi_time;
  String pi_loc;
  String po_time;
  String po_loc;
  String timeindate;
  String timeoutdate;
  String pi_longi;
  String pi_latit;
  String po_longi;
  String po_latit;
  String desc;
  String pi_img;
  String po_img;

  FlexiAtt(
      {this.Id,
      this.Emp,
      this.client,
      this.pi_time,
      this.pi_loc,
      this.po_time,
      this.po_loc,
      this.timeindate,
      this.timeoutdate,
      this.pi_latit,
      this.pi_longi,
      this.po_latit,
      this.po_longi,
      this.desc,
      this.pi_img,
      this.po_img});
}


Future<List<FlexiAtt>> getFlexiDataList(date) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';

  print(globals.path + 'getFlexiInfo?uid=$empid&orgid=$orgdir&date=$date');
  final response = await http
      .get(globals.path + 'getFlexiInfo?uid=$empid&orgid=$orgdir&date=$date');
  List responseJson = json.decode(response.body.toString());
  List<FlexiAtt> userList = createUserListFlexi(responseJson);
  print('getSummaryPunch called--1');
  print(userList);
  print('getSummaryPunch called--2');
  return userList;
}

List<FlexiAtt> createUserListFlexi(List data) {
  List<FlexiAtt> list = new List();
  for (int i = data.length - 1; i >= 0; i--) {
    String id = data[i]["Id"];
    String client = data[i]["client"];
    String pi_time = data[i]["time_in"] == "00:00:00"
        ? '-'
        : data[i]["time_in"].toString().substring(0, 5);
    String pi_loc = data[i]["loc_in"];
    String po_time = data[i]["time_out"] == "00:00:00"
        ? '-'
        : data[i]["time_out"].toString().substring(0, 5);
    String po_loc = data[i]["loc_out"];
    String timeindate = data[i]["date"];
    String timeoutdate = data[i]["timeout_date"];
    String emp = data[i]["emp"];
    String latit_in = data[i]["latit"];
    String longi_in = data[i]["longi"];
    String latit_out = data[i]["latit_in"];
    String longi_out = data[i]["longi_out"];
    String desc = data[i]["desc"];
    String pi_img = data[i]["checkin_img"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["checkin_img"].toString();
    String po_img = data[i]["checkout_img"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["checkout_img"].toString();
    print(data[i]["id"]);

    FlexiAtt flexi = new FlexiAtt(
        Id: id,
        Emp: emp,
        client: client,
        pi_time: pi_time,
        pi_loc: pi_loc.length > 40 ? pi_loc.substring(0, 40) + '...' : pi_loc,
        po_time: po_time == '00:00' ? '-' : po_time,
        po_loc: po_loc.length > 40 ? po_loc.substring(0, 40) + '...' : po_loc,
        timeindate: timeindate,
        timeoutdate: timeoutdate,
        pi_latit: latit_in,
        pi_longi: longi_in,
        po_latit: latit_out,
        po_longi: longi_out,
        desc: desc.length > 40 ? desc.substring(0, 40) + '...' : desc,
        pi_img: pi_img,
        po_img: po_img);
    list.add(flexi);
  }
  return list;
}

class Flexi {
  String fid;
  String sts;

  Flexi({this.fid, this.sts});
}

Future checkTimeinflexi() async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  print('*--*-*-*-*-*-*-*-*-*-');
  final res =
      await http.get(globals.path + 'getAttendanceesFlexi?empid=$empid');
  print("99999");
  print(res.body.toString());
  // return res.body.toString();
  List<Flexi> list = new List();

  String fid = ((json.decode(res.body.toString()))['id']).toString();
  String sts = ((json.decode(res.body.toString()))['sts']).toString();
  Flexi flexi = new Flexi(fid: fid, sts: sts);
  list.add(flexi);
  print("kkkkkk");
  print(list);
//return ((json.decode(res.body.toString()))['sts']).toString();
  return list;
}

Future<List<FlexiAtt>> getFlexiDataListReport(date, emp) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';

  print(globals.path +
      'getFlexiInfoReport?seid=$emp&uid=$empid&orgid=$orgdir&date=$date');
  final response = await http.get(globals.path +
      'getFlexiInfoReport?seid=$emp&uid=$empid&orgid=$orgdir&date=$date');
  List responseJson = json.decode(response.body.toString());
  List<FlexiAtt> userList = createUserListFlexi(responseJson);
  print('getSummaryPunch called--1');
  print(userList);
  print('getSummaryPunch called--2');
  return userList;
}


List<FlexiAtt> createListFlexiReport(List data) {
  List<FlexiAtt> list = new List();
  for (int i = data.length - 1; i >= 0; i--) {
    String id = data[i]["Id"];
    String client = data[i]["client"];
    String pi_time = data[i]["time_in"] == "00:00:00"
        ? '-'
        : data[i]["time_in"].toString().substring(0, 5);
    String pi_loc = data[i]["loc_in"];
    String po_time = data[i]["time_out"] == "00:00:00"
        ? '-'
        : data[i]["time_out"].toString().substring(0, 5);
    String po_loc = data[i]["loc_out"];
    String timeindate = data[i]["date"];
    String timeoutdate = data[i]["timeout_date"];
    String emp = data[i]["emp"];
    String latit_in = data[i]["latit"];
    String longi_in = data[i]["longi"];
    String latit_out = data[i]["latit_in"];
    String longi_out = data[i]["longi_out"];
    String desc = data[i]["desc"];
    String pi_img = data[i]["checkin_img"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["checkin_img"].toString();
    String po_img = data[i]["checkout_img"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["checkout_img"].toString();
    print(data[i]["id"]);

    FlexiAtt flexi = new FlexiAtt(
        Id: id,
        Emp: emp,
        client: client,
        pi_time: pi_time,
        pi_loc: pi_loc.length > 40 ? pi_loc.substring(0, 40) + '...' : pi_loc,
        po_time: po_time == '00:00' ? '-' : po_time,
        po_loc: po_loc.length > 40 ? po_loc.substring(0, 40) + '...' : po_loc,
        timeindate: timeindate,
        timeoutdate: timeoutdate,
        pi_latit: latit_in,
        pi_longi: longi_in,
        po_latit: latit_out,
        po_longi: longi_out,
        desc: desc.length > 40 ? desc.substring(0, 40) + '...' : desc,
        pi_img: pi_img,
        po_img: po_img);
    list.add(flexi);
  }
  return list;
}


///flexi attendance end////

class OutsideAttendance {
  String Id;
  String empname;
  String timein;
  String timeout;
  String locationin;
  String locationout;
  String attdate;
  String latin;
  String lonin;
  String latout;
  String lonout;
  String outstatus;
  String instatus;
  String incolor;
  String outcolor;


  OutsideAttendance(
      {
        this.Id,
        this.empname,
        this.timein,
        this.timeout,
        this.locationin,
        this.locationout,
        this.attdate,
        this.latin,
        this.lonin,
        this.latout,
        this.lonout,
        this.outstatus,
        this.instatus,
        this.incolor,
        this.outcolor,
      });
}
Future<List<OutsideAttendance>> getOutsidegeoReport(date, emp) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';

  print(globals.path +
      'getOutsidegeoReport?seid=$emp&uid=$empid&orgid=$orgdir&date=$date');
  final response = await http.get(globals.path +
      'getOutsidegeoReport?seid=$emp&uid=$empid&orgid=$orgdir&date=$date');

  List responseJson = json.decode(response.body.toString());
  print("Json responce ");

  List<OutsideAttendance> userList = createListOutsidefance(responseJson);
  print('getSummaryPunch called--1');
  print('getSummaryPunch called--2');
  return userList;


}


List<OutsideAttendance> createListOutsidefance(List data) {
  List<OutsideAttendance> list = new List();
  print("Data length");
  print(data.length);

  for (int i = data.length - 1; i >= 0; i--) {
    String id = data[i]["id"];
    String timein = data[i]["timein"] == "00:00:00" ? '-'
        : data[i]["timein"].toString().substring(0, 5);
    String timeout = data[i]["timeout"] == "00:00:00" ? '-'
        : data[i]["timeout"].toString().substring(0, 5);
    String locationin = data[i]["locationin"];
    String locationout = data[i]["locationout"];
    String attdate = data[i]["attdate"];
    String empname = data[i]["empname"];
    String latin = data[i]["latin"];
    String lonin = data[i]["lonin"];
    String latout = data[i]["latout"];
    String lonout = data[i]["lonout"];
    String outstatus = data[i]["outstatus"];
    String instatus = data[i]["instatus"];
    String incolor = data[i]["incolor"];
    String outcolor = data[i]["outcolor"];


    OutsideAttendance Outsid = new OutsideAttendance(
        Id: id,
        empname: empname,
        timein: timein == '00:00' ? '-' : timein,
        timeout: timeout == '00:00' ? '-' : timeout,
        locationin: locationin.length > 40 ? locationin.substring(0, 40) + '...' : locationin,
        locationout: locationout.length > 40 ? locationout.substring(0, 40) + '...' : locationout,
        attdate: attdate,
        latin: latin,
        lonin: lonin,
        latout: latout,
        lonout: lonout,
        outstatus: outstatus,
        instatus: instatus,
        incolor: incolor,
        outcolor: outcolor,
        );
    list.add(Outsid);
  }
  return list;
}

/************************************************************************
****************************Start Holiday functions*********************
************************************************************************/


Future<List<Holiday>> getHolidays() async {
  print('holidays called');
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  print(globals.path + 'getAllHoliday?orgid=$orgid');
  final response = await http.get(globals.path + 'getAllHoliday?orgid=$orgid');
  List responseJson = json.decode(response.body.toString());
  print(responseJson);
  List<Holiday> holidayList = createHolidayList(responseJson);
//  print(shiftList);
  return holidayList;
}

List<Holiday> createHolidayList(List data) {
  List<Holiday> list = new List();
  for (int i = 0; i < data.length; i++) {
    String name = data[i]["Name"];
    String from = (data[i]["fromDate"]);
    String to =   (data[i]["DateTo"]);
    String days = data[i]["DiffDate"];
    Holiday holiday = new Holiday(
        Name: name,
        From: from,
        To: to,
        Days: days
    );
    list.add(holiday);
  }
  return list;
}



class Holiday {
  //String Id;
  String Name;
  String From;
  String To;
  String Days;

  Holiday(
      {this.Name, this.From, this.To, this.Days});
}


Future<int> createHoliday(name, from, to, description) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  print(globals.path +
      'addHoliday?name=$name&org_id=$orgdir&from=$from&to=$to&description=$description&empid=$empid');
  final response = await http.get(globals.path +
      'addHoliday?name=$name&org_id=$orgdir&from=$from&to=$to&description=$description&empid=$empid');
  int res = int.parse(response.body);
  print(response.body);
  return res;
}


/************************************************************************
 ****************************End Holiday functions*********************
 ************************************************************************/