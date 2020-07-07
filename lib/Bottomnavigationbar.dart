
import 'package:Shrine/globals.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';
import 'home.dart';
import 'profile.dart';
import 'reports.dart';
import 'settings.dart';

class Bottomnavigationbar extends StatefulWidget {
  @override
  _Bottomnavigationbar createState() => new _Bottomnavigationbar();
}
class _Bottomnavigationbar extends State<Bottomnavigationbar> {
  String admin_sts='0';
  var _currentIndex=1;



  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    final prefs = await SharedPreferences.getInstance();
    //String admin= await getUserPerm();
    setState(() {
      admin_sts=prefs.getString('sstatus').toString();

    });
  }

  void initState() {
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return new BottomNavigationBar(
      backgroundColor: prefix0.appcolor,

      currentIndex: _currentIndex,
//      fixedColor: Colors.yellowAccent,
      type: BottomNavigationBarType.fixed,
      onTap: (newIndex) {
        if(newIndex==1){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          return;
        }else if (newIndex == 0) {
          (admin_sts == '1' || admin_sts == '2')
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
        /*else if(newIndex == 3){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Notifications()),
            );

          }*/
        setState((){_currentIndex = newIndex;});

      }, // this will be set when a new tab is tapped
      items:  [
        (admin_sts == '1' || admin_sts == '2' )
            ? BottomNavigationBarItem(
          icon:new Icon(Icons.library_books,color: Colors.white,size: 30.0),
          title: new Text('Reports',style: TextStyle(color: Colors.white,)),
        )
            : BottomNavigationBarItem(
          icon: new Icon(
              Icons.person, color: Colors.white,size: 30.0),
          title: new Text('Profile',style: TextStyle(color: Colors.white,)),
        ),
        BottomNavigationBarItem(
          icon: new Icon(Icons.home,color: Colors.white,size: 30.0,),
          title: new Text('Home', textAlign: TextAlign.center,style: TextStyle(color: Colors.white,)),
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings,color: Colors.white,size: 30.0),
            title: Text('Settings',style: TextStyle(color: Colors.white,)
        )),
        /* BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications
                ,color: Colors.black54,
              ),
              title: Text('Notifications',style: TextStyle(color: Colors.black54))),*/
      ],
    );
  }



}

