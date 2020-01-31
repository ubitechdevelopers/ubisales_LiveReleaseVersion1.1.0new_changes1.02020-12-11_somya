import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as prefix0;
//import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drawer.dart';
import 'globals.dart';
import 'home.dart';
void main() => runApp(new UserGuide());

class UserGuide extends StatefulWidget {
  @override
  _UserGuide createState() => _UserGuide();
}

class _UserGuide extends State<UserGuide> {
  String fname="";
  String lname="";
  String desination="";
  String profile="";
  String org_name="";
  double _animatedHeight_markatt = 0.0;
  double _animatedHeight_reqtimeoff = 0.0;
  double _animatedHeight_attlog = 0.0;
  double _animatedHeight_visitlog = 0.0;
  double _animatedHeight_chngpwd = 0.0;
  double _animatedHeight_editprofile = 0.0;
  double _animatedHeight_attreport = 0.0;
  double _animatedHeight_configure = 0.0;
  double _animatedHeight_addemp = 0.0;
  double _animatedHeight_checktimeoff = 0.0;
  double _animatedHeight_empvisit = 0.0;

  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    initPlatformState();

  }
  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      fname = prefs.getString('fname') ?? '';
      lname = prefs.getString('lname') ?? '';
      desination = prefs.getString('desination') ?? '';
      profile = prefs.getString('profile') ?? '';
      org_name = prefs.getString('org_name') ?? '';
     // _animatedHeight = 0.0;
    });
  }
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        appBar: new AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(org_name, style: new TextStyle(fontSize: 20.0)),
            ],
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: appcolor,
        ),
        endDrawer: new AppDrawer(),
        body: userWidget()
    );
  }

  userWidget(){

    return Container(
      margin: const EdgeInsets.all(10.0),
      width:  MediaQuery.of(context).size.width * 1,
      child:ListView(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[

          Center(
            child:Text('Explore Attendance (User)',
              style: new TextStyle(fontSize: 25.0, color: buttoncolor, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),


        Image.asset(
                'assets/mark_attendance.png',fit: BoxFit.fill,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        GestureDetector(
          onTap: ()=>setState((){
            _animatedHeight_markatt==0.0?_animatedHeight_markatt=MediaQuery.of(context).size.height * 0.15:_animatedHeight_markatt=0.0;}),
        child:Text('How to mark Attendance?',style: TextStyle(fontSize: 20.0,color: Colors.blue)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
        new AnimatedContainer(duration: const Duration(milliseconds: 5),
          child:SizedBox(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("1. Click on \"Time In\" button"),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                      Text("2. Your current location will be shown. If it is incorrect then press the refresh location button."),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                      Text("3. Capture “Selfie” by using your phone’s camera and click on “OK” button to mark attendance."),
                      //SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                      //Text("4. Time In will be marked successfully."),
                     // SizedBox(height: 5.0,),
                    ],
                  )
              ),


          height: _animatedHeight_markatt,

        ),
        SizedBox(height: 30.0,),
        /******************************* Request Timeoff*************************************/
        Image.asset(
          'assets/reqtimeoff.png',fit: BoxFit.fill,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        GestureDetector(
          onTap: ()=>setState((){
          _animatedHeight_reqtimeoff==0.0?_animatedHeight_reqtimeoff=MediaQuery.of(context).size.height * 0.30:_animatedHeight_reqtimeoff=0.0;}),
          child:Text('How to request time off?',style: TextStyle(fontSize: 20.0,color: Colors.blue)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
        new AnimatedContainer(duration: const Duration(milliseconds: 5),
          child:SizedBox(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("To check your Time off History:",style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("1. Click on “Time Off” button from Home screen"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("2. Your Time off history will be displayed"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("3. You can also check status of your time off request"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.010,),
                  Text("Request Time Off:",style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("1. Click on \"Add\" button"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("2. Fill the time off request form"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("3. Click on \"Save\" button"),

                ],
              )
          ),


          height: _animatedHeight_reqtimeoff,

        ),
        SizedBox(height: 30.0,),
        /******************************* How to view your attendnce log*************************************/
        Image.asset(
          'assets/att_log.png',fit: BoxFit.fill,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        GestureDetector(
          onTap: ()=>setState((){
            _animatedHeight_attlog==0.0?_animatedHeight_attlog=MediaQuery.of(context).size.height * 0.18:_animatedHeight_attlog=0.0;}),
          child:Text('How to view attendance log?',style: TextStyle(fontSize: 20.0,color: Colors.blue)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
        new AnimatedContainer(duration: const Duration(milliseconds: 5),
          child:SizedBox(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("1. Click on “Log” on home screen to check your last 30 days attendance which includes:",style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("     >Date"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("     >Captured Time In/ Time In Selfie"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("     >Captured Time Out/ Time Out Selfie"),
                ],
              )
          ),


          height: _animatedHeight_attlog,

        ),
        SizedBox(height: 30.0,),
        /******************************* How to view Visits Log*************************************/
        Image.asset(
          'assets/visitlog.png',fit: BoxFit.fill,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        GestureDetector(
          onTap: ()=>setState((){
            _animatedHeight_visitlog==0.0?_animatedHeight_visitlog=MediaQuery.of(context).size.height * 0.55:_animatedHeight_visitlog=0.0;}),
          child:Text('How to view visits?',style: TextStyle(fontSize: 20.0,color: Colors.blue)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
        new AnimatedContainer(duration: const Duration(milliseconds: 5),
          child:SizedBox(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                Text("Click on “Visits” on home screen to check your visits which include:",style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text(">Client"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text(">Captured visit in time / visit in selfie"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text(">Captured visit out time/ visit out selfie"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                  Text("How to punch visits?", style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("The visits feature is used for on field employees those who visit clients/ sites / offices:"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                  Text("1. The field employees should ensure that the GPS is turned on"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("2. The employee will click on “Visits” from home screen"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("3. Click on “Add” button, Add client name."),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("4. To punch your visit time in click “Visit In”, Click your selfie"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("5. To punch your visit out time click “Visit out” & fill details about the visit & click your selfie."),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                  Text("You will be redirected to your “Today’s Visits Screen”", style: TextStyle(fontWeight: FontWeight.bold),),

                ],
              )
          ),


          height: _animatedHeight_visitlog,

        ),
        SizedBox(height: 30.0,),
        /******************************* How to change Password*************************************/
        Image.asset(
          'assets/changepwd.png',fit: BoxFit.fill,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        GestureDetector(
          onTap: ()=>setState((){
            _animatedHeight_chngpwd==0.0?_animatedHeight_chngpwd=MediaQuery.of(context).size.height * 0.18:_animatedHeight_chngpwd=0.0;}),
          child:Text('How to change password?',style: TextStyle(fontSize: 20.0,color: Colors.blue)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
        new AnimatedContainer(duration: const Duration(milliseconds: 5),
          child:SizedBox(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("1. Click on “Settings”"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("2. Go to “Change password”"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("3. Enter your old password then enter new password"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("4. Click on “Submit”"),
                ],
              )
          ),


          height: _animatedHeight_chngpwd,

        ),
        SizedBox(height: 30.0,),
        /******************************* How to edit your Profile*************************************/
        Image.asset(
          'assets/editprofile.png',fit: BoxFit.fill,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        GestureDetector(
          onTap: ()=>setState((){
            _animatedHeight_editprofile==0.0?_animatedHeight_editprofile=MediaQuery.of(context).size.height * 0.15:_animatedHeight_editprofile=0.0;}),
          child:Text('How to view profile?',style: TextStyle(fontSize: 20.0,color: Colors.blue)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
        new AnimatedContainer(duration: const Duration(milliseconds: 5),
          child:SizedBox(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("1. Click on “Settings”"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("2. Click on “Profile”"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("3. You can only update your phone no. & photo"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("4. Click on “save” once completed"),
                ],
              )
          ),


          height: _animatedHeight_editprofile,

        ),
        SizedBox(height: 30.0,),

          Text('Explore Attendance (Admin)',style: TextStyle(fontSize: 25.0,color: buttoncolor, fontWeight: FontWeight.bold)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        /******************************* How to check Attendance Reports***********************************/
        Image.asset(
          'assets/attreport.png',fit: BoxFit.fill,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        GestureDetector(
          onTap: ()=>setState((){
            _animatedHeight_attreport==0.0?_animatedHeight_attreport=MediaQuery.of(context).size.height * 0.50:_animatedHeight_attreport=0.0;}),
          child:Text('How to check Attendance Reports?',style: TextStyle(fontSize: 20.0,color: Colors.blue)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
        new AnimatedContainer(duration: const Duration(milliseconds: 5),
          child:SizedBox(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("As an Admin, Track Attendance of your employees through multiple “Reports”:"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
                  Text("1. Today’s Attendance"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("2. Late Comers"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("3. Early Leavers"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("4. Attendance by Department"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("5. Attendance by Designation"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("6. Attendance by Employee"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("7. Flexi Time"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("8. Outside the fence"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("9. Visits"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("10. Time Off"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("11. Yesterday’s Attendance"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("12. Last 7 days"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("13. Last 30 days"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("14. Custom Date"),
                ],
              )
          ),


          height: _animatedHeight_attreport,

        ),
        SizedBox(height: 30.0,),
        /******************************* How to configure Shifts, Designations & Department***********************************/
        Image.asset(
          'assets/config.png',fit: BoxFit.fill,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        GestureDetector(
          onTap: ()=>setState((){
            _animatedHeight_configure==0.0?_animatedHeight_configure=MediaQuery.of(context).size.height * 0.40:_animatedHeight_configure=0.0;}),
          child:Text('How to create shifts designations & departments?',style: TextStyle(fontSize: 20.0,color: Colors.blue)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
        new AnimatedContainer(duration: const Duration(milliseconds: 5),
          child:SizedBox(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

              Text("Admin can configure shifts, departments and designations through the “Settings”:",),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                  Text("1. Click on “Shifts” to manage shifts and add shifts."),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("2. Click on “Departments” to manage departments and add new departments."),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("3. Click on “Designations” to manage existing designations and add new designations."),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("4. Click on “Employees” to add employees."),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("5. Click on “Holidays” to view holidays and add a holiday."),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("6. “Change Password” is to update your password."),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("7. “Profile” option is to edit/view your profile."),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
                  Text("Your system will be fully configured now.",style: TextStyle(fontWeight: FontWeight.bold),)

                ],
              )
          ),


          height: _animatedHeight_configure,

        ),
        SizedBox(height: 30.0,),
        /******************************* How to add an Employee***********************************/
        Image.asset(
          'assets/addemp.png',fit: BoxFit.fill,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        GestureDetector(
          onTap: ()=>setState((){
            _animatedHeight_addemp==0.0?_animatedHeight_addemp=MediaQuery.of(context).size.height * 0.20:_animatedHeight_addemp=0.0;}),
          child:Text('How to add an employee?',style: TextStyle(fontSize: 20.0,color: Colors.blue)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
        new AnimatedContainer(duration: const Duration(milliseconds: 5),
          child:SizedBox(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Going with the admin login, First go to “Settings” and click on “Employees” to register employee:',style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                  Text("1. Enter name, phone and email (optional)"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("2. Select department, Designation and shift."),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("3. Click on “ADD” to add an employee."),
             //     Text("    (Country code will automatically get selected)"),
//                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
//                  Text("    4. Enter employee's mobile no. "),
//                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
//                  Text('    5. pre - defined password "12345678" will appear. '),
//                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
//                  Text("    6. select shift designation & department for the employee."),
//                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
//                  Text("    7. Click on “Register” button."),

                ],
              )
          ),


          height: _animatedHeight_addemp,

        ),
        SizedBox(height: 30.0,),
        /******************************* How to check Time off Log ***********************************/
        Image.asset(
          'assets/timeofflog.png',fit: BoxFit.fill,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        GestureDetector(
          onTap: ()=>setState((){
            _animatedHeight_checktimeoff==0.0?_animatedHeight_checktimeoff=MediaQuery.of(context).size.height * 0.18:_animatedHeight_checktimeoff=0.0;}),
          child:Text('How to check employee(s) time off report?',style: TextStyle(fontSize: 20.0,color: Colors.blue)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
        new AnimatedContainer(duration: const Duration(milliseconds: 5),
          child:SizedBox(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                Text("Admin can view time off requests of each employee(s):",style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                  Text("1. Go to “Reports”"),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("2. Click on “Time Off” to get employee time off list."),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("3. Check employee time off with custom date."),
                ],
              )
          ),


          height: _animatedHeight_checktimeoff,

        ),
        SizedBox(height: 30.0,),
        /******************************* How to check Employee Visits***********************************/
        Image.asset(
          'assets/empvisit.png',fit: BoxFit.fill,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
        GestureDetector(
          onTap: ()=>setState((){
            _animatedHeight_empvisit==0.0?_animatedHeight_empvisit=MediaQuery.of(context).size.height * 0.25:_animatedHeight_empvisit=0.0;}),
          child:Text('How to check employee(s) visits?',style: TextStyle(fontSize: 20.0,color: Colors.blue)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015,),
        new AnimatedContainer(duration: const Duration(milliseconds: 5),

          child:SizedBox(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                Text("Admin can view list of visits of each employee:",style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                  Text("1. Go to “Reports” "),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("2. Click on “Punched visits” to view list."),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                  Text("3. Select employee(s) from drop down, Select a date from calendar."),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                  Text("Employee(s) visits list will be shown. ",style: TextStyle(fontWeight: FontWeight.bold),),
//                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
//                  Text("    5. To punch your visit out time click “Visit out”"),
//                  SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
//                  Text("    6. You Will be redirected to your “Today’s Visits Screen”"),
                ],
              )
          ),


          height: _animatedHeight_empvisit,

        )
        ]
      )
    );
  }
}