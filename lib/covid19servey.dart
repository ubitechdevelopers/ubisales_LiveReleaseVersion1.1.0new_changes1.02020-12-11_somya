import 'package:Shrine/services/gethome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'askregister.dart';
import 'package:Shrine/services/checklogin.dart';
import 'home.dart';
import 'package:Shrine/model/user.dart';
import 'services/services.dart';
import 'dart:convert';
import 'globals.dart';
import 'login.dart';


class Covid19serve extends StatefulWidget {

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<Covid19serve> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _name,_cname,_email,_pass,_cont,_phone,_city,_contcode;
  var phone ="";
  var pass = "";
  bool loader = false;
  bool _isButtonDisabled = false;
  final FocusNode __name = FocusNode();
  final FocusNode __cname = FocusNode();
  final FocusNode __email = FocusNode();
  final FocusNode __pass = FocusNode();
  final FocusNode __cont = FocusNode();
  final FocusNode __contcode = FocusNode();
  final FocusNode __phone = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SharedPreferences prefs;
  Map<String, dynamic>res;

  String _country;
  bool _obscureText = true;
  String  _tempcontry  = '';
  int contactwithperson = 11;  // 1 means yes , and 0 means no
  int covidsymptoms = 11;  // 1 means yes , and 0 means no// 1 means yes , and 0 means no
  bool noneofabove = false;
  String empid = "";
  String orgid = "";
  String _orgName = "";
  String orgname = "";

  @override
  void initState() {
    _name = new TextEditingController();
    _cname = new TextEditingController();
    _email = new TextEditingController();
    _phone = new TextEditingController();
    _pass = new TextEditingController();
    _cont = new TextEditingController();
    _city = new TextEditingController();
    _contcode = new TextEditingController();

    super.initState();
    initplatform();
  }
  initplatform() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      empid = prefs.getString('empid') ?? '';
      orgid = prefs.getString('orgdir') ?? '';
      _orgName = prefs.getString('org_name') ?? '';
      orgname=_orgName.split("..")[1];
    });
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text("COVID-19 TEST", style: new TextStyle(fontSize: 20.0)),
          ],
        ),
        leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },),
        backgroundColor: appcolor,
      ),
      body: new SafeArea(
          top: false,
          bottom: false,
          child: loader ? runloader():new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  /*
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("English"),
                                  groupValue: globals.language,
                                  value: 1,
                                  onChanged: (val) {
                                    setState(() {
                                      globals.language = 1;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => Covid19serve()),
                                      );
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("Hindi"),
                                  groupValue: globals.language,
                                  value: 2,
                                  onChanged: (val) {
                                    setState(() {
                                      globals.language = 2;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => Covid19serveHindi()),
                                      );
                                    });
                                  },
                                )
                              ],
                            ),
                          )),

                    ],
                  ),
                  */

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
                    child: new Text(' Daily Self Health Information Tool.',
                      textAlign: TextAlign.center,
                      style: new TextStyle(fontWeight: FontWeight.bold, fontSize:18.0, color: Colors.red ),
                    ),
                  ),


                  SizedBox(height: 20.0),



           /*****   First question start   ******/

                  Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text('1.   Have you been within 6 feet of a person with a lab-confirmed case of COVID-19 for at least 5 minutes, or had direct contact with their mucus or saliva, in the past 14 days?',
                            //  textAlign: TextAlign.center,
                              style: new TextStyle(fontSize:16.0, color: Colors.blue, ),
                            ),
                          ]
                      ),
                    ),
                  ), Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("YES"),
                                  groupValue: contactwithperson,
                                  value: 1,
                                  onChanged: (val) {
                                    setState(() {
                                      contactwithperson = 1;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("NO"),
                                  groupValue: contactwithperson,
                                  value: 0,
                                  onChanged: (val) {
                                    setState(() {
                                      contactwithperson = 0;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                    ],
                  ),


                  /*****   First question end   ******/


                  /*****   Second question start   ******/
                  SizedBox(height: 20.0),
                  Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text('2.   Are you or your family members experiencing any of the symptoms like Cold/Cough/Fever/Difficulty in breathing?',
                              //textAlign: TextAlign.start,
                              style: new TextStyle(fontSize:16.0, color: Colors.blue, ),
                            ),
                          ]
                      ),
                    ),
                  ), Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("YES"),
                                  groupValue: covidsymptoms,
                                  value: 1,
                                  onChanged: (val) {
                                    setState(() {
                                      covidsymptoms = 1;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("NO"),
                                  groupValue: covidsymptoms,
                                  value: 0,
                                  onChanged: (val) {
                                    setState(() {
                                      covidsymptoms = 0;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                  /*


                  /*****   Secod question end   ******/




                  /*****   Third question start   ******/
                  SizedBox(height: 20.0),
                  Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text('3.   Do you have a cough ',
                              textAlign: TextAlign.center,
                              style: new TextStyle(fontSize:16.0, color: Colors.blue, ),
                            ),
                          ]
                      ),
                    ),
                  ), Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("YES"),
                                  groupValue: coughid,
                                  value: 1,
                                  onChanged: (val) {
                                    setState(() {
                                      coughid = 1;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("NO"),
                                  groupValue: coughid,
                                  value: 0,
                                  onChanged: (val) {
                                    setState(() {
                                      coughid = 0;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                    ],
                  ),


                  /*****   third question end   ******/



                  /*****   Forth question start   ******/
                  SizedBox(height: 20.0),
                  Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text('4.  Do you have a trouble breathing, shortness of breath or severe wheezing?',
                             // textAlign: TextAlign.center,
                              style: new TextStyle(fontSize:16.0, color: Colors.blue, ),
                            ),
                          ]
                      ),
                    ),
                  ), Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("YES"),
                                  groupValue: breathingid,
                                  value: 1,
                                  onChanged: (val) {
                                    setState(() {
                                      breathingid = 1;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("NO"),
                                  groupValue: breathingid,
                                  value: 0,
                                  onChanged: (val) {
                                    setState(() {
                                      breathingid = 0;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                    ],
                  ),


                  /*****   Forth question end   ******/



                  /*****   Fifth question start   ******/
                  SizedBox(height: 20.0),
                  Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text('5.   do you feel cold?',
                              textAlign: TextAlign.center,
                              style: new TextStyle(fontSize:16.0, color: Colors.blue, ),
                            ),
                          ]
                      ),
                    ),
                  ), Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("YES"),
                                  groupValue: coldid,
                                  value: 1,
                                  onChanged: (val) {
                                    setState(() {
                                      coldid = 1;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("NO"),
                                  groupValue: coldid,
                                  value: 0,
                                  onChanged: (val) {
                                    setState(() {
                                      coldid = 0;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                    ],
                  ),


                  /*****   fifth question end   ******/


                  /*****   Six question start   ******/
                  SizedBox(height: 20.0),
                  Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text('6.   Do you have muscle aches?',
                              //textAlign: TextAlign.center,
                              style: new TextStyle(fontSize:16.0, color: Colors.blue, ),
                            ),
                          ]
                      ),
                    ),
                  ), Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("YES"),
                                  groupValue: muscleid,
                                  value: 1,
                                  onChanged: (val) {
                                    setState(() {
                                      muscleid = 1;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("NO"),
                                  groupValue: muscleid,
                                  value: 0,
                                  onChanged: (val) {
                                    setState(() {
                                      muscleid = 0;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                    ],
                  ),


                  /*****   Six question end   ******/


                  /*****   Seventh question start   ******/
                  SizedBox(height: 20.0),
                  Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text('7.   Do you have a sore throat?',
                              //textAlign: TextAlign.center,
                              style: new TextStyle(fontSize:16.0, color: Colors.blue, ),
                            ),
                          ]
                      ),
                    ),
                  ), Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("YES"),
                                  groupValue: throatid,
                                  value: 1,
                                  onChanged: (val) {
                                    setState(() {
                                      throatid = 1;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("NO"),
                                  groupValue: throatid,
                                  value: 0,
                                  onChanged: (val) {
                                    setState(() {
                                      throatid = 0;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                    ],
                  ),


                  /*****   Seventh question end   ******/


                  /*****   Eight question start   ******/
                  SizedBox(height: 20.0),
                  Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text('8.   Do you have a loss of smell or taste or change in taste?',
                             // textAlign: TextAlign.center,
                              style: new TextStyle(fontSize:16.0, color: Colors.blue, ),
                            ),
                          ]
                      ),
                    ),
                  ), Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("YES"),
                                  groupValue: smellid,
                                  value: 1,
                                  onChanged: (val) {
                                    setState(() {
                                      smellid = 1;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                      Expanded(
                          child: Container(
                            // height: 350.0,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: Text("NO"),
                                  groupValue: smellid,
                                  value: 0,
                                  onChanged: (val) {
                                    setState(() {
                                      smellid = 0;
                                    });
                                  },
                                )
                              ],
                            ),
                          )),
                    ],
                  ),


                  /*****   Eight question end   ******/
                  SizedBox(height: 15.0),
                  Container(
                    width: MediaQuery.of(context).size.width*0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 14.0),
                              child: new Text('NONE OF THE ABOVE  ',
                                // textAlign: TextAlign.center,
                                style: new TextStyle(fontSize:16.0, color: Colors.blue, ),
                              ),
                            ),
                            Checkbox(
                              value: noneofabove,
                              onChanged: (bool value) {
                                setState(() {
                                  noneofabove = value;
                                  print(value);
                                  if(value==true)
                                  {
                                    contactwithpersonid = 0;
                                    feverid = 0;
                                    coughid = 0;
                                    breathingid = 0;
                                    coldid = 0;
                                    muscleid = 0;
                                    throatid = 0;
                                    smellid = 0;
                                  }
                                  else{
                                    contactwithpersonid = 11;
                                    feverid = 11;
                                    coughid = 11;
                                    breathingid = 11;
                                    coldid = 11;
                                    muscleid = 11;
                                    throatid = 11;
                                    smellid =11;
                                  }
                                });
                              },
                            ),
                          ]
                      ),
                    ),
                  ),
                  */

                  SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: new Container(
                        child: _isButtonDisabled?new RaisedButton(
                            color: buttoncolor,
                            textColor: Colors.white,
                            padding: EdgeInsets.all(20.0),
                            child: const Text('Please wait...',style: TextStyle(fontSize: 18.0),),
                            onPressed: (){}
                        ):new RaisedButton(
                          elevation: 1.0,
                          highlightElevation: 5.0,
                          highlightColor: Colors.transparent,
                          disabledElevation: 0.0,
                          focusColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: buttoncolor,
                          textColor: Colors.white,
                          padding: EdgeInsets.all(20.0),
                          child: const Text('Submit',style: TextStyle(fontSize: 18.0),),
                          onPressed: (){
                            if(_isButtonDisabled)
                              return null;
                           /* int contactwithpersonid = 0;  // 1 means yes , and 2 means no
                            int feverid = 0;  // 1 means yes , and 2 means no
                            int coughid = 0;  // 1 means yes , and 2 means no
                            int breathingid = 0;  // 1 means yes , and 2 means no
                            int coldid = 0;  // 1 means yes , and 2 means no
                            int muscleid = 0;  // 1 means yes , and 2 means no
                            int throatid = 0;  // 1 means yes , and 2 means no
                            int smellid = 0;*/
                            String  noneofabovetemp = '0';
                            bool tempstatus = true;
                            if(noneofabove==false) {
                              print(1);
                              if (contactwithperson == 11 || covidsymptoms == 11) {
                                showDialog(context: context, child:
                                new AlertDialog(
                                  //title: new Text("Alert"),
                                  content: new Text(
                                      "Please answer all questions"),
                                ));
                                tempstatus = false;
                                return false;
                              }
                            }

                          if(tempstatus) {
                              if(noneofabove==true)
                              {
                                print(2);
                                noneofabovetemp = '1';
                                contactwithperson = 0;
                                covidsymptoms = 0;
                              }
                              print("success");
                           //   return false;
                              setState(() {
                                _isButtonDisabled=true;

                              });
                              print(globals.path+"EveryDayCOVID19data");
                              var url = globals.path+"EveryDayCOVID19data";
                              http.post(url, body: {
                                "contactwithperson": contactwithperson.toString(),
                                "covidsymptoms": covidsymptoms.toString(),
                                "orgid": orgid,
                                "empid": empid
                              }) .then((response) {
                                if  (response.statusCode == 200) {

                                  print("-----------------> After Registration ---------------->");
                                  print(response.body.toString());
                                  res = json.decode(response.body);
                                  if (res['status'] == 'true') {
                                    if(contactwithperson==1 || covidsymptoms==1){
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,
                                      );
                                    showDialog(context: context, child:
                                    new AlertDialog(
                                      //title: new Text("Alert!"),
                                      content: new Text("You are unsafe and need to be under self-quarantine and visit a Doctor."),
                                    ));
                                    /*
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            Future.delayed(Duration(seconds: 2), () {


                                              Navigator.of(context).pop(true);



                                            });
                                            return AlertDialog(
                                              //title: Text('Alert!'),
                                              content: Text("You are unsafe and need to be under self-quarantine and visit a Doctor."),
                                            );
                                          });
                                      */
                                    }else{
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,
                                      );
                                    showDialog(context: context, child:
                                    new AlertDialog(
                                      //title: new Text("Alert!"),
                                      content: new Text("You are safe and we recommend you to attend Office today."),
                                    ));
                                      /*
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            Future.delayed(Duration(seconds: 2), () {


                                              Navigator.of(context).pop(true);



                                            });
                                            return AlertDialog(
                                              //title: Text('Alert!'),
                                              content: Text("You are safe and we recommend you to attend Office today."),
                                            );
                                          });
                                      */
                                    }



                                  }
                                  else {
                                    showDialog(context: context, child:
                                    new AlertDialog(
                                      title: new Text("Warning"),
                                      content: new Text("Unable to connect API. Please try again."),
                                    ));
                                  }
                                  setState(() {
                                    _isButtonDisabled=false;

                                  });
                                } else {
                                  setState(() {
                                    _isButtonDisabled=false;

                                  });
                                  showDialog(context: context, child:
                                  new AlertDialog(
                                    title: new Text("Error"),
                                    // content: new Text("Unable to call service"),
                                    content: new Text("Response status: ${response
                                        .statusCode} \n Response body: ${response
                                        .body}"),
                                  )
                                  );

                                }
                                //   print("Response status: ${response.statusCode}");
                                //   print("Response body: ${response.body}");
                              }).catchError((onError) {
                                print(onError);
                                setState(() {
                                  _isButtonDisabled=false;
                                });
                                showDialog(context: context, child:
                                new AlertDialog(
                                  title: new Text("Error"),
                                  content: new Text("Poor network connection."),
                                )
                                );
                              });
                            }
                            // return false;

                          },
                        )),
                  ),
                ],
              ))),
    );

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

}