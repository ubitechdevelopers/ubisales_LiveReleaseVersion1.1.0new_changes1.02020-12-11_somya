
// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:Shrine/services/fetch_location.dart';
//import 'package:simple_permissions/simple_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/saveimage.dart';
import 'package:Shrine/model/timeinout.dart';
import 'attendance_summary.dart';
import 'punchlocation.dart';
import 'drawer.dart';
import 'package:Shrine/model/model.dart';
import 'timeoff_summary.dart';
import 'package:Shrine/services/services.dart';
import 'package:Shrine/services/newservices.dart';
import 'home.dart';
import 'dart:io';
import 'dart:async';
import 'settings.dart';
import 'reports.dart';
import 'profile.dart';
import 'package:flutter/scheduler.dart';


// This app is a stateful, it tracks the user's current choice.
class NoNet extends StatefulWidget {
  @override
  _NoNetState createState() => _NoNetState();
}

class _NoNetState extends State<NoNet> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  /*var _defaultimage = new NetworkImage(
      "http://ubiattendance.ubihrm.com/assets/img/avatar.png");*/
  var profileimage;
  List<Map> countryList = [{"id":"0","name":"Country"},{"id":"2","name":"Afghanistan"},{"id":"4","name":"Albania"},{"id":"50","name":"Algeria"},{"id":"5","name":"American Samoa"},{"id":"6","name":"Andorra"},{"id":"7","name":"Angola"},{"id":"11","name":"Anguilla"},{"id":"3","name":"Antigua and Barbuda"},{"id":"160","name":"Argentina"},{"id":"8","name":"Armenia"},{"id":"9","name":"Aruba"},{"id":"10","name":"Australia"},{"id":"1","name":"Austria"},{"id":"12","name":"Azerbaijan"},{"id":"27","name":"Bahamas"},{"id":"25","name":"Bahrain"},{"id":"14","name":"Bangladesh"},{"id":"15","name":"Barbados"},{"id":"29","name":"Belarus"},{"id":"13","name":"Belgium"},{"id":"30","name":"Belize"},{"id":"16","name":"Benin"},{"id":"17","name":"Bermuda"},{"id":"20","name":"Bhutan"},{"id":"23","name":"Bolivia"},{"id":"22","name":"Bosnia and Herzegovina"},{"id":"161","name":"Botswana"},{"id":"24","name":"Brazil"},{"id":"28","name":"British Virgin Islands"},{"id":"26","name":"Brunei"},{"id":"19","name":"Bulgaria"},{"id":"18","name":"Burkina Faso"},{"id":"21","name":"Burundi"},{"id":"101","name":"Cambodia"},{"id":"32","name":"Cameroon"},{"id":"34","name":"Canada"},{"id":"43","name":"Cape Verde"},{"id":"33","name":"Cayman Islands"},{"id":"163","name":"Central African Republic"},{"id":"203","name":"Chad"},{"id":"165","name":"Chile"},{"id":"205","name":"China"},{"id":"233","name":"Christmas Island"},{"id":"39","name":"Cocos Islands"},{"id":"38","name":"Colombia"},{"id":"40","name":"Comoros"},{"id":"41","name":"Cook Islands"},{"id":"42","name":"Costa Rica"},{"id":"36","name":"Cote dIvoire"},{"id":"90","name":"Croatia"},{"id":"31","name":"Cuba"},{"id":"44","name":"Cyprus"},{"id":"45","name":"Czech Republic"},{"id":"48","name":"Denmark"},{"id":"47","name":"Djibouti"},{"id":"226","name":"Dominica"},{"id":"49","name":"Dominican Republic"},{"id":"55","name":"Ecuador"},{"id":"58","name":"Egypt"},{"id":"57","name":"El Salvador"},{"id":"80","name":"Equatorial Guinea"},{"id":"56","name":"Eritrea"},{"id":"60","name":"Estonia"},{"id":"59","name":"Ethiopia"},{"id":"62","name":"Falkland Islands"},{"id":"63","name":"Faroe Islands"},{"id":"65","name":"Fiji"},{"id":"186","name":"Finland"},{"id":"61","name":"France"},{"id":"64","name":"French Guiana"},{"id":"67","name":"French Polynesia"},{"id":"69","name":"Gabon"},{"id":"223","name":"Gambia"},{"id":"70","name":"Gaza Strip"},{"id":"77","name":"Georgia"},{"id":"46","name":"Germany"},{"id":"78","name":"Ghana"},{"id":"75","name":"Gibraltar"},{"id":"81","name":"Greece"},{"id":"82","name":"Greenland"},{"id":"228","name":"Grenada"},{"id":"83","name":"Guadeloupe"},{"id":"84","name":"Guam"},{"id":"76","name":"Guatemala"},{"id":"72","name":"Guernsey"},{"id":"167","name":"Guinea"},{"id":"79","name":"Guinea-Bissau"},{"id":"85","name":"Guyana"},{"id":"168","name":"Haiti"},{"id":"218","name":"Holy See"},{"id":"87","name":"Honduras"},{"id":"89","name":"Hong Kong"},{"id":"86","name":"Hungary"},{"id":"97","name":"Iceland"},{"id":"93","name":"India"},{"id":"169","name":"Indonesia"},{"id":"94","name":"Iran"},{"id":"96","name":"Iraq"},{"id":"95","name":"Ireland"},{"id":"74","name":"Isle of Man"},{"id":"92","name":"Israel"},{"id":"91","name":"Italy"},{"id":"99","name":"Jamaica"},{"id":"98","name":"Japan"},{"id":"73","name":"Jersey"},{"id":"100","name":"Jordan"},{"id":"102","name":"Kazakhstan"},{"id":"52","name":"Kenya"},{"id":"104","name":"Kiribati"},{"id":"106","name":"Kosovo"},{"id":"107","name":"Kuwait"},{"id":"103","name":"Kyrgyzstan"},{"id":"109","name":"Laos"},{"id":"114","name":"Latvia"},{"id":"171","name":"Lebanon"},{"id":"112","name":"Lesotho"},{"id":"111","name":"Liberia"},{"id":"110","name":"Libya"},{"id":"66","name":"Liechtenstein"},{"id":"113","name":"Lithuania"},{"id":"108","name":"Luxembourg"},{"id":"117","name":"Macau"},{"id":"125","name":"Macedonia"},{"id":"172","name":"Madagascar"},{"id":"132","name":"Malawi"},{"id":"118","name":"Malaysia"},{"id":"131","name":"Maldives"},{"id":"173","name":"Mali"},{"id":"115","name":"Malta"},{"id":"124","name":"Marshall Islands"},{"id":"119","name":"Martinique"},{"id":"170","name":"Mauritania"},{"id":"130","name":"Mauritius"},{"id":"120","name":"Mayotte"},{"id":"123","name":"Mexico"},{"id":"68","name":"Micronesia"},{"id":"122","name":"Moldova"},{"id":"121","name":"Monaco"},{"id":"127","name":"Mongolia"},{"id":"126","name":"Montenegro"},{"id":"128","name":"Montserrat"},{"id":"116","name":"Morocco"},{"id":"129","name":"Mozambique"},{"id":"133","name":"Myanmar"},{"id":"136","name":"Namibia"},{"id":"137","name":"Nauru"},{"id":"139","name":"Nepal"},{"id":"142","name":"Netherlands"},{"id":"135","name":"Netherlands Antilles"},{"id":"138","name":"New Caledonia"},{"id":"146","name":"New Zealand"},{"id":"140","name":"Nicaragua"},{"id":"174","name":"Niger"},{"id":"225","name":"Nigeria"},{"id":"141","name":"Niue"},{"id":"145","name":"Norfolk Island"},{"id":"144","name":"North Korea"},{"id":"143","name":"Northern Mariana Islands"},{"id":"134","name":"Norway"},{"id":"147","name":"Oman"},{"id":"153","name":"Pakistan"},{"id":"150","name":"Palau"},{"id":"149","name":"Panama"},{"id":"155","name":"Papua New Guinea"},{"id":"157","name":"Paraguay"},{"id":"151","name":"Peru"},{"id":"178","name":"Philippines"},{"id":"152","name":"Pitcairn Islands"},{"id":"154","name":"Poland"},{"id":"148","name":"Portugal"},{"id":"156","name":"Puerto Rico"},{"id":"158","name":"Qatar"},{"id":"164","name":"Republic of the Congo"},{"id":"166","name":"Reunion"},{"id":"175","name":"Romania"},{"id":"159","name":"Russia"},{"id":"182","name":"Rwanda"},{"id":"88","name":"Saint Helena"},{"id":"105","name":"Saint Kitts and Nevis"},{"id":"229","name":"Saint Lucia"},{"id":"191","name":"Saint Martin"},{"id":"195","name":"Saint Pierre and Miquelon"},{"id":"232","name":"Saint Vincent and the Grenadines"},{"id":"230","name":"Samoa"},{"id":"180","name":"San Marino"},{"id":"197","name":"Sao Tome and Principe"},{"id":"184","name":"Saudi Arabia"},{"id":"193","name":"Senegal"},{"id":"196","name":"Serbia"},{"id":"200","name":"Seychelles"},{"id":"224","name":"Sierra Leone"},{"id":"187","name":"Singapore"},{"id":"188","name":"Slovakia"},{"id":"190","name":"Slovenia"},{"id":"189","name":"Solomon Islands"},{"id":"194","name":"Somalia"},{"id":"179","name":"South Africa"},{"id":"176","name":"South Korea"},{"id":"51","name":"Spain"},{"id":"37","name":"Sri Lanka"},{"id":"198","name":"Sudan"},{"id":"192","name":"Suriname"},{"id":"199","name":"Svalbard"},{"id":"185","name":"Swaziland"},{"id":"183","name":"Sweden"},{"id":"35","name":"Switzerland"},{"id":"201","name":"Syria"},{"id":"162","name":"Taiwan"},{"id":"202","name":"Tajikistan"},{"id":"53","name":"Tanzania"},{"id":"204","name":"Thailand"},{"id":"206","name":"Timor-Leste"},{"id":"181","name":"Togo"},{"id":"209","name":"Tonga"},{"id":"211","name":"Trinidad and Tobago"},{"id":"208","name":"Tunisia"},{"id":"210","name":"Turkey"},{"id":"207","name":"Turkmenistan"},{"id":"212","name":"Turks and Caicos Islands"},{"id":"213","name":"Tuvalu"},{"id":"219","name":"U.S. Virgin Islands"},{"id":"54","name":"Uganda"},{"id":"214","name":"Ukraine"},{"id":"215","name":"United Arab Emirates"},{"id":"71","name":"United Kingdom"},{"id":"216","name":"United States"},{"id":"177","name":"Uruguay"},{"id":"217","name":"Uzbekistan"},{"id":"221","name":"Vanuatu"},{"id":"235","name":"Venezuela"},{"id":"220","name":"Vietnam"},{"id":"222","name":"Wallis and Futuna"},{"id":"227","name":"West Bank"},{"id":"231","name":"Western Sahara"},{"id":"234","name":"Yemen"},{"id":"237","name":"Zaire"},{"id":"236","name":"Zambia"},{"id":"238","name":"Zimbabwe"}];
  String _country;
  PersistentBottomSheetController controller;
  bool _checkLoaded = true;
  bool _isButtonDisabled= false;
  bool _isProfileUploading= false;
  int _currentIndex = 2;
  bool _visible = true;
  String location_addr="";
  String location_addr1="";
  String admin_sts='0';
  String act="";
  String act1="";
  int response;
  String fname="", lname="", empid="", email="", status="", orgid="", orgdir="", sstatus="", org_name="", desination="", shifttiming="", profile,latit="",longi="";
  String department, shift, mobile;
  TextEditingController _phone;
  TextEditingController _city;
  String aid="";
  String shiftId="";
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    checkNetForOfflineMode(context);
    appResumedFromBackground(context);
    final prefs = await SharedPreferences.getInstance();
    empid = prefs.getString('empid') ?? '';
    orgdir = prefs.getString('orgdir') ?? '';
    admin_sts = prefs.getString('sstatus') ?? '';
    response = prefs.getInt('response') ?? 0;
    if(response==1) {
      NewServices po = new NewServices();
      Map profileMap = await po.getProfile(empid);

      Home ho = new Home();
      act = await ho.checkTimeIn(empid, orgdir);
      setState(() {
        response = prefs.getInt('response') ?? 0;
        fname = prefs.getString('fname') ?? '';
        lname = prefs.getString('lname') ?? '';
        empid = prefs.getString('empid') ?? '';
        email = prefs.getString('email') ?? '';
        status = prefs.getString('status') ?? '';
        orgid = prefs.getString('orgid') ?? '';
        orgdir = prefs.getString('orgdir') ?? '';
        sstatus = (int.parse(prefs.getString('sstatus')))==1 ? 'You have logged in as an admin':'';
        org_name = prefs.getString('org_name') ?? '';
        desination = prefs.getString('desination') ?? '';
        profile = prefs.getString('profile') ?? '';
        print(profile);
        profileimage = new NetworkImage(profile);
        //print("1-"+profile);
        profileimage.resolve(new ImageConfiguration()).addListener((_, __) {
          if (mounted) {
            setState(() {
              _checkLoaded = false;
            });
          }
        });
        //print("2-"+_checkLoaded.toString());
        act1=act;
        department = profileMap["dept"]??'';
        shift = profileMap["shift"]??'';
        desination = profileMap["desg"]??'';
        shifttiming = profileMap["shifttiming"]??'';
        _phone = new TextEditingController(text: profileMap["PersonalNo"]??'');
        _city = new TextEditingController(text: profileMap["PersonalNo"]??'');
        _country = profileMap["CurrentCountry"]??'';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (response==0) ? new LoginPage() : getmainhomewidget();
  }
  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(value,textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  getmainhomewidget(){
    return new Scaffold(
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
            MaterialPageRoute(builder: (context) => NoNet()),
          );
        }),
        backgroundColor: Colors.teal,
      ),
      /* bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
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
          //setState((){_currentIndex = newIndex;});

        }, // this will be set when a new tab is tapped
        items: [
          (admin_sts == '1')
              ? BottomNavigationBarItem(
            icon: new Icon(
              Icons.library_books,color: Colors.black54,
            ),
            title: new Text('Reports'),
          )
              : BottomNavigationBarItem(
            icon: new Icon(
              Icons.person,color: Colors.orangeAccent,
            ),
            title: new Text('Profile',style: TextStyle(color: Colors.orangeAccent),),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Home'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings,color: Colors.black54,),
              title: Text('Settings',style: TextStyle(color: Colors.black54),)
          )
        ],
      ),*/

      //endDrawer: new AppDrawer(),
      body:mainbodyWidget(),
    );

  }

  loader(){
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

  mainbodyWidget(){
    return Center(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text('No Internet Connection'),
          FlatButton(
            child: new Text(
              "Refresh Page",
              style: new TextStyle(
                  color: Colors.teal, decoration: TextDecoration.underline),
            ),
            onPressed: () {
              checknetonpage();
            },
          ),
        ],
      ),
    );
  }
  checknetonpage(){
    checkNet().then((value) {
      if(value==1) {
        print(
            '====================internet checked...Not connected=====================');
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
        });
      }
    });
  }

}



