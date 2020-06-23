import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'globals.dart';



import 'dart:convert';

import 'package:Shrine/model/user.dart';
import 'package:Shrine/services/checklogin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'otpvarify.dart';
import 'askregister.dart';
import 'globals.dart' as globals;
import 'globals.dart';
import 'home.dart';
import 'services/services.dart';
class Otp extends StatefulWidget {

  String username1 ='';
  String password1 ='';

  Otp(String username, String password, BuildContext context){
    username1 = username;
    password1 = password;
  }

  @override
  _OtpState createState() => new _OtpState(username1,password1 );
}

class _OtpState extends State<Otp> with SingleTickerProviderStateMixin {

  String username1 ='';
  String password1 ='';

  _OtpState( username,  password,){
    username1 = username;
    password1 = password;
  }


  // Constants
  final int time = 10;
  AnimationController _controller;
  Map<String, dynamic>res;
  SharedPreferences prefs;
  // Variables
  bool loader = false;
  bool otploader = false;
  Size _screenSize;
  int _currentDigit;
  int _firstDigit;
  int _secondDigit;
  int _thirdDigit;
  int _fourthDigit;
  int _fifththDigit;
  int _sixthDigit;

  Timer timer;
  int totalTimeInSeconds;
  bool _hideResendButton;

  String userName = "";
  bool didReadNotifications = false;
  int unReadNotificationsCount = 0;

  // Returns "Appbar"

  get _getAppbar {
    return new AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: new InkWell(
        borderRadius: BorderRadius.circular(30.0),
        child: new Icon(
          Icons.arrow_back,
          color: Colors.black54,
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
    );
  }


  // Return "Verification Code" label
  get _getVerificationCodeLabel {
    return new Text(
      "Code Verification",
      textAlign: TextAlign.center,
      style: new TextStyle(
          fontSize: 20.0, color: appcolor, fontWeight: FontWeight.bold),
    );
  }

  // Return "Email" label
  get _getEmailLabel {
    return new Text(
      "Please enter the OTP sent on your \nregistered Email ID.",
      textAlign: TextAlign.center,
      style: new TextStyle(
          fontSize: 16.0, color: Colors.orange, fontWeight: FontWeight.w600),
    );
  }

  // Return "OTP" input field
  get _getInputField {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _otpTextField(_firstDigit),
        _otpTextField(_secondDigit),
        _otpTextField(_thirdDigit),
        _otpTextField(_fourthDigit),
        _otpTextField(_fifththDigit),
        _otpTextField(_sixthDigit),
      ],
    );
  }

  // Returns "OTP" input part
  get _getInputPart {
    return new Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        //_getVerificationCodeLabel,
        new SizedBox(
          width: 5.0,
        ),
        _getEmailLabel,
        (otploader) ? Center(child :   SizedBox(
          child: CircularProgressIndicator(), height: 30.0, width: 30.0,)) : Center(child :   SizedBox(height: 30.0, width: 30.0,)),
        _getInputField,
        // _hideResendButton ? _getTimerText : _getResendButton,
        _getResendButton,
        _getTimerText,
        _getOtpKeyboard
      ],
    );
  }


  // Returns "Timer" label
  get _getTimerText {
    return Container(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Icon(Icons.access_time),
          new SizedBox(
            width: 5.0,
          ),
          Text("OTP is valid for 24 hours"),
        ],
      ),

    );
  }

  // Returns "Resend" button
  get _getResendButton {
    return new InkWell(
      child: new Container(
        height: 32,
        width: 120,
//        decoration: BoxDecoration(
//            color: Colors.black,
//            shape: BoxShape.rectangle,
//            borderRadius: BorderRadius.circular(32)),
        alignment: Alignment.center,
        child: new Text(
          "Resend OTP",
          style:
          new TextStyle(fontWeight: FontWeight.bold, color: Colors.blue,decoration: TextDecoration.underline),
        ),
      ),
      onTap: ()async {
        var a = await resendOTP(username1, password1);
        if(a){
          showDialog(context: context, child:
          new AlertDialog(
            title: new Text("Alert"),
            content: new Text("Please check your mail for OTP."),
          ));
        }
        else{
          showDialog(context: context, child:
          new AlertDialog(
            title: new Text("Alert"),
            content: new Text("Poor Network Connection."),
          ));
        }
        //Resend you OTP via API or anything
      },
    );
  }

  // Returns "Otp" keyboard
  get _getOtpKeyboard {
    return new Container(
        height: _screenSize.width - 80,
        child: new Column(
          children: <Widget>[
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "1",
                      onPressed: () {
                        _setCurrentDigit(1);
                      }),
                  _otpKeyboardInputButton(
                      label: "2",
                      onPressed: () {
                        _setCurrentDigit(2);
                      }),
                  _otpKeyboardInputButton(
                      label: "3",
                      onPressed: () {
                        _setCurrentDigit(3);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "4",
                      onPressed: () {
                        _setCurrentDigit(4);
                      }),
                  _otpKeyboardInputButton(
                      label: "5",
                      onPressed: () {
                        _setCurrentDigit(5);
                      }),
                  _otpKeyboardInputButton(
                      label: "6",
                      onPressed: () {
                        _setCurrentDigit(6);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "7",
                      onPressed: () {
                        _setCurrentDigit(7);
                      }),
                  _otpKeyboardInputButton(
                      label: "8",
                      onPressed: () {
                        _setCurrentDigit(8);
                      }),
                  _otpKeyboardInputButton(
                      label: "9",
                      onPressed: () {
                        _setCurrentDigit(9);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new SizedBox(
                    width: 80.0,
                  ),
                  _otpKeyboardInputButton(
                      label: "0",
                      onPressed: () {
                        _setCurrentDigit(0);
                      }),
                  _otpKeyboardActionButton(
                      label: new Icon(
                        Icons.backspace,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_sixthDigit != null) {
                            _sixthDigit = null;
                          }
                          else if (_fifththDigit != null) {
                            _fifththDigit = null;
                          } else if (_fourthDigit != null) {
                            _fourthDigit = null;
                          } else if (_thirdDigit != null) {
                            _thirdDigit = null;
                          } else if (_secondDigit != null) {
                            _secondDigit = null;
                          } else if (_firstDigit != null) {
                            _firstDigit = null;
                          }
                        });
                      }),
                ],
              ),
            ),
          ],
        ));
  }


  login(var username,var userpassword, BuildContext context) async{
    var user = User(username,userpassword);
    Login dologin = Login();
    setState(() {
      loader = true;
    });
    var islogin = await dologin.checkLogin(user);
    print("islogin  " +islogin);
    if(islogin=="success"){
      /*Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );*/
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,
      );
    }else if(islogin=="failure"){
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Invalid login credentials")));
    }else{
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Poor network connection.")));
    }
  }
  // Overridden methods
  @override
  void initState() {

    print(username1);
    print(password1);
    print("username1 ajja");
    totalTimeInSeconds = time;
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: Duration(seconds: time))
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          setState(() {
            _hideResendButton = !_hideResendButton;
          });
        }
      });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
    _startCountdown();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      appBar:  AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text("Email Verification", style: new TextStyle(fontSize: 20.0)),
          ],
        ),
        leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
          Navigator.pop(context);}),
        backgroundColor: appcolor,
      ),
      //backgroundColor: Colors.white,
      body: loader ? runloader():new Container(
        width: _screenSize.width,
//        padding: new EdgeInsets.only(bottom: 16.0),
        child: _getInputPart,
      ),
    );
  }

  // Returns "Otp custom text field"
  Widget _otpTextField(int digit) {
    return new Container(
      width: 35.0,
      height: 45.0,
      alignment: Alignment.center,
      child: new Text(
        digit != null ? digit.toString() : "",
        style: new TextStyle(
          fontSize: 25.0,
          color: Colors.black,
        ),
      ),
      decoration: BoxDecoration(
//            color: Colors.grey.withOpacity(0.4),
          border: Border(
              bottom: BorderSide(
                width: 2.0,
                color: Colors.black,
              ))),
    );
  }

  // Returns "Otp keyboard input Button"
  Widget _otpKeyboardInputButton({String label, VoidCallback onPressed}) {
    return new Material(
      color: Colors.transparent,
      child: new InkWell(
        onTap: onPressed,
        borderRadius: new BorderRadius.circular(40.0),
        child: new Container(
          height: 70.0,
          width: 80.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: new Center(
            child: new Text(
              label,
              style: new TextStyle(
                fontSize: 30.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Returns "Otp keyboard action Button"
  _otpKeyboardActionButton({Widget label, VoidCallback onPressed}) {
    return new InkWell(
      onTap: onPressed,
      borderRadius: new BorderRadius.circular(40.0),
      child: new Container(
        height: 70.0,
        width: 80.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: new Center(
          child: label,
        ),
      ),
    );
  }

  // Current digit
  void _setCurrentDigit(int i) {
    setState(() {
      _currentDigit = i;
      if (_firstDigit == null) {
        _firstDigit = _currentDigit;
      } else if (_secondDigit == null) {
        _secondDigit = _currentDigit;
      } else if (_thirdDigit == null) {
        _thirdDigit = _currentDigit;
      } else if (_fourthDigit == null) {
        _fourthDigit=_currentDigit;
      }else if (_fifththDigit == null) {
        _fifththDigit=_currentDigit;
      }
      else if (_sixthDigit == null) {
        _sixthDigit=_currentDigit;

        var otp = _firstDigit.toString() +
            _secondDigit.toString() +
            _thirdDigit.toString() +
            _fourthDigit.toString()+
            _fifththDigit.toString()+
            _sixthDigit.toString();
        print(otp);
        varifyotp(otp,username1,password1);
        // Verify your otp by here. API call

      }
    });
  }

/*  varifyotp(otp,  username1 , password1 ) async{
    var prefs=await SharedPreferences.getInstance();
    print(globals.path+"varifyotp?otp=$otp");
    var url = globals.path+"varifyotp";
    setState(() {
      otploader = true;
    });
    http.post(url, body: {
      "otp": otp
    }) .then((response)async {
      // print(response);

      print(response.statusCode);
      if  (response.statusCode == 200) {
        var prefs=await SharedPreferences.getInstance();
        //  prefs.setBool("companyFreshlyRegistered",true );
        res = json.decode(response.body);
        print("This si a return value");
        print(res);
        if (res['sts'] == 'true') {
          globals.facebookChannel.invokeMethod("logStartTrialEvent");
          gethome () async{
            await new Future.delayed(const Duration(seconds: 1));
            login(res['phone'], res['pass'], context);
          }
          gethome ();

        }
        else if(res['sts'] == 'timeout'){
          setState(() {
            otploader = false;
          });
          showDialog(context: context, child:
          new AlertDialog(
            // title: new Text("ubiAttendance"),
            content: new Text("Your OTP has expired"),
            //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
          ));
        }
        else if(res['sts'] == 'otpused')
        {
          setState(() {
            otploader = false;
          });
          showDialog(context: context, child:
          new AlertDialog(
            // title: new Text("ubiAttendance"),
            content: new Text("OTP already used, Please register again"),
          ));
        }
        else{
          setState(() {
            otploader = false;
          });
          showDialog(context: context, child:
          new AlertDialog(
            // title: new Text("ubiAttendance"),
            content: new Text("Invalid OTP, Please try again"),
            //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
          ));
        }

      }
    }).catchError((onError) {
      setState(() {
        setState(() {
          otploader = false;
        });
        showDialog(context: context, child:
        new AlertDialog(
          // title: new Text("ubiAttendance"),
          content: new Text("Unable to Connect server."),
          //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
        ));
      });
    });
  }*/

  varifyotp(otp,  username1 ,password1) async{
//    print(username1);
//    print(password1);
//    print("user pass");
    var prefs=await SharedPreferences.getInstance();
    Dio dio = new Dio();
//    FormData formData = new FormData.from({
//      "otp":otp,
//      "username":username1,
//      "password":password1
//      // "file": new UploadFileInfo(imagei, "image.png"),
//    });
    print(globals.path+"verifyOTPNew?otp=$otp&username=$username1&password=$password1");
    //Response<String> response1 = await dio.post(globals.path + "resend_otp", data: formData);
    var url = globals.path+"verifyOTPNew";
    setState(() {
      otploader = true;
    });
    http.post(url, body: {
      "otp": otp,
      "username": username1,
      "password": password1
    }).then((response)async {
      print(response);
      print(response.statusCode);
      if  (response.statusCode == 200) {
        var prefs=await SharedPreferences.getInstance();
        //  prefs.setBool("companyFreshlyRegistered",true );
        print(response.body.toString());
        Map res = json.decode(response.body);
        print("This si a return value");
        print(res);
        if (res['sts'] == 'true') {
          globals.facebookChannel.invokeMethod("logStartTrialEvent");
          gethome () async{
            await new Future.delayed(const Duration(seconds: 1));
            login(res['phone'], res['pass'], context);
          }
          gethome ();
        }
        else if(res['sts'] == 'timeout'){
          setState(() {
            otploader = false;
          });
          showDialog(context: context, child:
          new AlertDialog(
            // title: new Text("ubiAttendance"),
            content: new Text("Your OTP has expired"),
            //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
          ));
        }
        else if(res['sts'] == 'otpused')
        {
          setState(() {
            otploader = false;
          });
          showDialog(context: context, child:
          new AlertDialog(
            // title: new Text("ubiAttendance"),
            content: new Text("OTP already used, Please register again"),
          ));
        }
        else{
          setState(() {
            otploader = false;
          });
          showDialog(context: context, child:
          new AlertDialog(
            // title: new Text("ubiAttendance"),
            content: new Text("Invalid OTP, Please try again"),
            //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
          ));
        }

      }
    }).catchError((onError) {
      setState(() {
        setState(() {
          otploader = false;
        });
        showDialog(context: context, child:
        new AlertDialog(
          // title: new Text("ubiAttendance"),
          content: new Text("Unable to Connect server."),
          //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
        ));
      });
    });
  }
  runloader(){
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset(
                  'assets/spinner.gif', height: 50.0, width: 50.0),
            ]),
      ),
    );
  }

  Future<Null> _startCountdown() async {
    setState(() {
      _hideResendButton = true;
      totalTimeInSeconds = time;
    });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
  }

  void clearOtp() {
    _sixthDigit = null;
    _fifththDigit = null;
    _fourthDigit = null;
    _thirdDigit = null;
    _secondDigit = null;
    _firstDigit = null;
    setState(() {});
  }
}

class OtpTimer extends StatelessWidget {
  final AnimationController controller;
  double fontSize;
  Color timeColor = Colors.black;

  OtpTimer(this.controller, this.fontSize, this.timeColor);

  String get timerString {
    Duration duration = controller.duration * controller.value;
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Duration get duration {
    Duration duration = controller.duration;
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget child) {
          return new Text(
            timerString,
            style: new TextStyle(
                fontSize: fontSize,
                color: timeColor,
                fontWeight: FontWeight.w600),
          );
        });
  }
}