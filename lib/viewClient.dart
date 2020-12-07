import 'dart:math' as math;
import 'dart:ui';

import 'package:Shrine/addClient.dart';
import 'package:Shrine/clients.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drawer.dart';
import 'globals.dart';


class ViewClient extends StatefulWidget {
  final String company;
  final String name;
  final String address;
  final String contcode;
  final String city;
  final String contact;
  final String email;
  final String desc;
  final String id;
  final String sts;
  ViewClient({Key key, this.company, this.name, this.address, this.contcode, this.city, this.contact, this.email, this.desc, this.id, this.sts})
      : super(key: key);

  @override
  _ViewClient createState() => _ViewClient();
}

class _ViewClient extends State<ViewClient> {
  String fname="";
  String lname="";
  String desination="";
  String profile="";
  String org_name="";
  bool _isButtonDisabled = false;
  String admin_sts='0';
  String buystatus = "";
  String new_ver='3.1.9';
  var First;
  var Last;
  var name;
  TextEditingController textsms = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    final prefs = await SharedPreferences.getInstance();
  /*  checkNow().then((res){
      setState(() {
        new_ver=res;
        print("new_ver");
        print(new_ver);
      });
    });*/
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

  getAcronym(var val) {
    if((val.trim()).contains(" ")){
      name=val.split(" ");
      print('print(name);');
      print(name);
      First=name[0][0];
      Last=name[1][0];
      return First+Last;
    }else{
      First=val[0];
      print('print(First)else');
      print(First);
      return First;
    }
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
          leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ClientList()),
            );
          },),
          backgroundColor: appcolor,
        ),
        endDrawer: new AppDrawer(),
        body: userWidget(),
        floatingActionButton: FloatingActionButton(
          mini: false,
          backgroundColor: buttoncolor,
          onPressed: (){
            setState(() {
              _isButtonDisabled=false;
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddClient(company: widget.company,
                  name: widget.name,
                  address: widget.address,
                  contcode: widget.contcode,
                  city: widget.city,
                  contact: widget.contact,
                  email: widget.email,
                  desc: widget.desc,
                  id: widget.id,
                  sts: '1')),
            );
            //_showDialog(context);
          },
          tooltip: 'Edit Client',
          child: new Icon(Icons.edit),
        ),
    );
  }

  userWidget(){
    return ListView(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20,),
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  child: Center(child: Text(getAcronym(widget.company.toUpperCase()),style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w400))),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0),
                    /*gradient: LinearGradient(
                        colors: [
                          Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0),
                          Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0),
                        ]
                    )*/
                  ),
                )
              ),
              SizedBox(height: 20,),
              Text(
                  widget.company,
                  style: new TextStyle(
                    fontSize: 26.0,
                    color:Colors.black54,
                    fontWeight: FontWeight.w500
                  )
              ),
              Divider(),
              SizedBox(height: 15,),
              Row(
                children: <Widget>[
                  Icon(Icons.person, color: Colors.black54,),
                  SizedBox(width:10),
                  Text(
                      widget.name,
                      style: new TextStyle(
                        fontSize: 18.0,
                        color:Colors.black54,
                        fontWeight: FontWeight.w400
                      )
                  ),
                ],
              ),
              SizedBox(height: 15,),
              Row(
                children: <Widget>[
                  Icon(Icons.phone, color: Colors.black54,),
                  SizedBox(width:10),
                  Text(
                      "+"+widget.contcode+" ",
                      style: new TextStyle(
                        fontSize: 18.0,
                        color:Colors.black54,
                        fontWeight: FontWeight.w400
                      )
                  ),
                  Text(
                      widget.contact,
                      style: new TextStyle(
                        fontSize: 18.0,
                        color:Colors.black54,
                        fontWeight: FontWeight.w400
                      )
                  ),
                ],
              ),
              SizedBox(height: 15,),
              Row(
                children: <Widget>[
                  Icon(Icons.email, color: Colors.black54,),
                  SizedBox(width:10),
                  Expanded(
                    child: Text(
                        widget.email,
                        style: new TextStyle(
                          fontSize: 18.0,
                          color:Colors.black54,
                          fontWeight: FontWeight.w400
                        )
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15,),
              Row(
                children: <Widget>[
                  Icon(Icons.location_on, color: Colors.black54,),
                  SizedBox(width:10),
                  Expanded(
                    child: Text(
                        widget.address,
                        style: new TextStyle(
                          fontSize: 18.0,
                          color:Colors.black54,
                          fontWeight: FontWeight.w400,
                        )
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15,),
              Row(
                children: <Widget>[
                  Icon(Icons.description, color: Colors.black54,),
                  SizedBox(width:10),
                  Expanded(
                    child: Text(
                        widget.desc,
                        style: new TextStyle(
                            fontSize: 18.0,
                            color:Colors.black54,
                            fontWeight: FontWeight.w400
                        )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}