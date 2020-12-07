import 'dart:ui';

import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'drawer.dart';
import 'globals.dart';



void main() => runApp(new ContactUs());

class ContactUs extends StatefulWidget {
  @override
  _ContactUs createState() => _ContactUs();
}

class _ContactUs extends State<ContactUs> {
  String fname="";
  String lname="";
  String desination="";
  String profile="";
  String org_name="";
  bool _isButtonDisabled = false;
  String admin_sts='0';
  String buystatus = "";
  TextEditingController textsms = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    initPlatformState();

  }
  _launchURL(url) async {
    //  const url = 'https://flutter.io';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      admin_sts = prefs.getString('sstatus').toString();
      buystatus = prefs.getString('buysts') ?? '';
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
        key: _scaffoldKey,
        backgroundColor: Colors.white,
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

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(
          value,
          textAlign: TextAlign.center,
        ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  SMS(String sms) async{
    sendsms(sms).then((res){
      textsms.text = "";
      setState(() {
        _isButtonDisabled = false;
      });

      showDialog(
          context: context,
          child: new AlertDialog(
            content: new Text('Thanks. Message sent successfully'),
          ));
    }).catchError((exp) {
      showDialog(
          context: context,
          child: new AlertDialog(
            content: new Text('Unable to call service. Please try later'),
          ));
    });
  }
  openWhatsApp() async{
    //prefix0.facebookChannel.invokeMethod("logContactEvent");
    print("Language is "+window.locale.countryCode);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var name=prefs.getString("fname")??"";
    var org_name= prefs.getString('org_name') ?? '';
    var country = prefs.getString("org_country")??"";
    //  String country=window.locale.countryCode;
    var message;

    message="Hello%20I%20am%20"+name+"%20from%20"+org_name+"%0AI%20need%20some%20help%20regarding%20ubiAttendance%20app";

    var url;
    if(country=="93" || country== '14' || country== '153	' )
      url = "https://wa.me/917067822132?text="+message;
    else{
      url = "https://wa.me/971555524131?text="+message;
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch Maps';
    }
  }

  userWidget(){
    return ListView(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child:Text(
                    "Contact Us",
                    style: new TextStyle(
                        fontSize: 22.0,
                        color:appcolor
                    )
                ),
              ),
              SizedBox(height: 15,),
//              Text(
//                'Hello There!',
//                style: TextStyle(
//                  fontSize: 25.0,
//                  letterSpacing: 1.0,
//                ),
//              ),
//              SizedBox(height: 10,),
              Text(
                "Drop us a message. We'd love to hear from you.",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 25,),
              Text(
                "Your Message",
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
              SizedBox(height: 5,),
              Card(
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide( color: Colors.grey.withOpacity(0.5), width: 1,),
                ),
                child: TextField(
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal:10,vertical: 15.0),
                  ),

                  controller: textsms,
                  maxLines: 5,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: RaisedButton(
                      elevation: 2.0,
                      highlightElevation: 5.0,
                      highlightColor: Colors.transparent,
                      disabledElevation: 0.0,
                      focusColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.amber,
                      onPressed: (){
                        if(textsms.text.length<=0)
                        {
                          showInSnackBar("Please enter message");
                          return null;
                        }
                        setState(() {
                          _isButtonDisabled = true;
                        });

                        SMS(textsms.text);
                      },
                      child: _isButtonDisabled?Text(
                        'Processing..',
                        style: TextStyle(color: Colors.white),
                      ): Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0,),

              (admin_sts=='1' && buystatus != '0')?Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "Get in touch on WhatsApp",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    InkWell(
                      onTap: (){
                        openWhatsApp();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.message,
                                size: 30.0,
//                                color: Colors.black54,
                                color: appcolor,
                              ),
                              SizedBox(width: 10.0,),
                              Text(
                                'WhatsApp',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: appcolor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'Lets talk on phone',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    InkWell(
                      onTap: ()async{
                        var phone;
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        var country = prefs.getString("org_country")??"";
                        if(country=="93" || country== '14' || country== '153' )
                          phone = "917067822132";
                        else{
                          phone = "971555524131";
                        }
                        _launchURL('tel:'+phone);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.phone,
                                size: 30.0,
                                color: appcolor,
//                                  color: Colors.black54,
                              ),
                              SizedBox(width: 10.0,),
                              Text(
                                'Call Us',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: appcolor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),


                  ],
                ),
              ):Center(),
            ],
          ),


        ),
      ],
    );
  }
}