import 'dart:math' as math;

import 'package:Shrine/addEmployee.dart';
import 'package:Shrine/editEmployee.dart';
import 'package:Shrine/globals.dart' as globals;
import 'package:Shrine/payment.dart';
import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Bottomnavigationbar.dart';
import 'drawer.dart';
import 'globals.dart';
import 'settings.dart';
//import 'package:material_search/material_search.dart';

class EmployeeList extends StatefulWidget {
  @override
  _EmployeeList createState() => _EmployeeList();
}
TextEditingController dept;
//FocusNode f_dept ;
class _EmployeeList extends State<EmployeeList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  /*int _currentIndex = 2;
  String _sts = 'Active';
  String _sts1 = 'Active';*/
  String admin_sts='0';
  String _orgName = "";
  String empname = "";
  bool res = true;
  String buysts = '0';
  var First;
  var Last;
  var name;

  final _searchController = TextEditingController();
//  bool _checkLoaded = true;

  _launchURL(url) async {
    //  const url = 'https://flutter.io';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);

    dept = new TextEditingController();
    // f_dept = FocusNode();
    getOrgName();
  }
  getOrgName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName= prefs.getString('org_name') ?? '';
      admin_sts= prefs.getString('sstatus') ?? '';
      buysts= prefs.getString('buysts') ?? '0';
    });
  }
  @override
  Widget build(BuildContext context) {
    return getmainhomewidget();
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(value, textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
  Future<bool> sendToHome() async{

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Settings()), (Route<dynamic> route) => false,
    );
    return false;
  }
  getmainhomewidget() {
    return new WillPopScope(
      onWillPop: ()=> sendToHome(),
      child: new Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text('Employee Directory', style: new TextStyle(fontSize: 20.0)),

              /*  Image.asset(
                    'assets/logo.png', height: 40.0, width: 40.0),*/
            ],
          ),
          leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
            sendToHome();}),
          backgroundColor: appcolor,
        ),
        bottomNavigationBar: Bottomnavigationbar(),

        endDrawer: new AppDrawer(),
        body: Container(
          //   padding: EdgeInsets.only(left: 2.0, right: 2.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 8.0),
              /* Center(
              child: Text('Employee Directory',
                style: new TextStyle(fontSize: 22.0, color: buttoncolor,),),
                ),*/
              SizedBox(height: 5.0),
              Container(
//              height: 40,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2.0,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search',
                        focusColor: Colors.white,
                        /*suffixIcon: IconButton(
                            icon: Icon(Icons.close),
                            : (){},
                          )*/
                      ),
                      /*onChanged: _searchController,*/
                      onChanged: (value) {
                        setState(() {
                          print("empname");
                          print(value);
                          empname = value;
                          res = true;
                        });
                      },
                    ),
                  ),
                ),
              ),
              new Expanded(
                child: res?getDeptWidget():Center(),
              ),

            ],
          ),

        ),
        floatingActionButton: new FloatingActionButton(
          mini: false,
          backgroundColor: buttoncolor,
          onPressed: (){
            if(((globals.registeruser)>=(globals.userlimit+5)) && buysts !=0) {
              showDialogWidget(
                  "You have registered 5 users more than your User limit. Kindly pay for the Additional Users or delete the Inactive users");
            }else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEmployee()),
              );
            }
          },
          tooltip: 'Add Employee',
          child: new Icon(Icons.person_add),
        ),
      ),
    );

  }

  showDialogWidget(String loginstr){
    return showDialog(context: context, builder:(context) {

      return new AlertDialog(
        title: new Text(
          loginstr,
          style: TextStyle(fontSize: 15.0),),
        content: ButtonBar(
          children: <Widget>[
            FlatButton(
              child: Text('Later',style: TextStyle(fontSize: 13.0)),
              shape: Border.all(),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            RaisedButton(
              child: Text(
                'Pay Now', style: TextStyle(color: Colors.white,fontSize: 13.0),),
              color: Colors.orangeAccent,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentPage()),
                );
              },
            ),
          ],
        ),
      );
    }
    );
  }

  loader() {
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


  getDeptWidget() {
    return new FutureBuilder<List<Emp>>(
        future: getEmployee(empname),
        builder: (context, snapshot) {
          print("snapshot.hasData");
          print(snapshot.hasData);
          if (snapshot.hasData) {
            print("snapshot.hasData1");
            print(snapshot.hasData);
              return new ListView.builder(
                  itemCount: snapshot.data.length,
                  //    padding: EdgeInsets.only(left: 15.0,right: 15.0),
                  itemBuilder: (BuildContext context, int index) {
                    getAcronym(var val) {
                      if((snapshot.data[index].Name.trim()).contains(" ")) {
                        name=snapshot.data[index].Name.split(" ");
                        print('print(name);');
                        print(name);
                        First=name[0][0].trim();
                        print(First);
                        Last=name[1][0].trim();
                        print(Last);
                        return First+Last;
                      }else{
                        First=snapshot.data[index].Name[0];
                        print('print(First)else');
                        print(First);
                        return First;
                      }
                    }
                    return InkWell(
                      onTap: () {
                        showDialog<String>(
                          context: context,
                          // ignore: deprecated_member_use
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.all(15.0),
                            content: Wrap(
                              children: <Widget>[
                                 Container(
                                    height: MediaQuery
                                        .of(context)
                                        .size
                                        .height * 0.45,
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.70,
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .end,
                                          children: <Widget>[
                                            InkWell(
                                              highlightColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              child:
                                              Row(
                                                children: <Widget>[
                                                  /*Icon(
                                                  Icons.edit,
                                                  color: Colors.blueAccent,
                                                ),*/
                                                  Text(
                                                    "Edit",
                                                    style: TextStyle(
                                                        color: Colors.blueAccent,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight
                                                            .w600
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onTap: () {
//                                         Navigator.pop(context);
                                                Navigator.of(
                                                    context, rootNavigator: true)
                                                    .pop('dialog');
                                                Navigator.push(
                                                  context,

                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditEmployee(
                                                              name: snapshot
                                                                  .data[index]
                                                                  .Name
                                                                  .toString(),
                                                              phone: snapshot
                                                                  .data[index]
                                                                  .Mobile
                                                                  .toString(),
                                                              email: snapshot
                                                                  .data[index]
                                                                  .Email
                                                                  .toString(),
                                                              password: snapshot
                                                                  .data[index]
                                                                  .Password
                                                                  .toString(),
                                                              department: snapshot
                                                                  .data[index]
                                                                  .DepartmentId
                                                                  .toString(),
                                                              designation: snapshot
                                                                  .data[index]
                                                                  .DesignationId
                                                                  .toString(),
                                                              shift: snapshot
                                                                  .data[index]
                                                                  .ShiftId
                                                                  .toString(),
                                                              empid: snapshot
                                                                  .data[index].Id
                                                                  .toString())),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                          child: Container(
                                              width: 70.0,
                                              height: 70.0,
//                               child: FadeInImage.assetNetwork(
//                                  placeholder: 'assets/user_profile.png',
//                                  ),
                                              decoration: new BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: new DecorationImage(
                                                      fit: BoxFit.fill,
                                                      image:
//                                          AssetImage('assets/user_profile.png'),
//                                            _checkLoaded
//                                                ? AssetImage('assets/imgloader.gif')
//                                                :
                                                      NetworkImage(
                                                          snapshot.data[index]
                                                              .Profile.toString())

                                                    //_checkLoaded ? AssetImage('assets/avatar.png') : profileimage,
                                                  )
                                              )
                                          ),
                                          /*onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ImageView(
                                                      myimage: snapshot
                                                          .data[index].Profile,
                                                      org_name: _orgName)),
                                            );
                                          },*/
                                        ),
                                        SizedBox(height: 10.0),
                                        new Text(
                                          snapshot.data[index].Name.toString(),
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600
                                          ),
                                        ),
                                        SizedBox(height: 20,),
                                        Table(
                                          defaultVerticalAlignment: TableCellVerticalAlignment
                                              .top,
                                          columnWidths: {

                                            0: FlexColumnWidth(5),
                                            // 0: FlexColumnWidth(4.501), // - is ok
                                            // 0: FlexColumnWidth(4.499), //- ok as well
                                            1: FlexColumnWidth(5),
                                          },
                                          children: [
                                            TableRow(
                                                children: [
                                                  TableCell(
                                                    child: Row(

                                                      children: <Widget>[
                                                        new Text(
                                                          'Department',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 15.0,
                                                              fontWeight: FontWeight
                                                                  .w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Text(
                                                            snapshot.data[index]
                                                                .Department
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontSize: 15.0,
                                                                fontWeight: FontWeight
                                                                    .bold
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ]
                                            ),
                                            TableRow(
                                                children: [
                                                  TableCell(
                                                    child: Row(
                                                      children: <Widget>[
                                                        new Text(
                                                          'Designation',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 15.0,
                                                              fontWeight: FontWeight
                                                                  .w400
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Text(
                                                            snapshot.data[index]
                                                                .Designation
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontSize: 15.0,
                                                                fontWeight: FontWeight
                                                                    .bold
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ]
                                            ),
                                            TableRow(
                                                children: [
                                                  TableCell(
                                                    child: Row(
                                                      children: <Widget>[
                                                        new Text(
                                                          'Phone',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 15.0,
                                                              fontWeight: FontWeight
                                                                  .w400
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Text(
                                                            snapshot.data[index]
                                                                .Mobile
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontSize: 15.0,
                                                                fontWeight: FontWeight
                                                                    .bold
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ]
                                            ),
                                            TableRow(
                                                children: [
                                                  TableCell(
                                                    child: Row(
                                                      children: <Widget>[
                                                        new Text(
                                                          'Shift',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 15.0,
                                                              fontWeight: FontWeight
                                                                  .w400
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Text(
                                                            snapshot.data[index]
                                                                .Shift.toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontSize: 15.0,
                                                                fontWeight: FontWeight
                                                                    .bold
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ]
                                            ),
                                            TableRow(
                                                children: [
                                                  TableCell(
                                                    child: Row(
                                                      children: <Widget>[
                                                        new Text(
                                                          'Permissions',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 15.0,
                                                              fontWeight: FontWeight
                                                                  .w400
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: snapshot
                                                              .data[index].Admin
                                                              .toString() ==
                                                              'Mobile Admin' ?
                                                          Text(
                                                              snapshot.data[index]
                                                                  .Admin
                                                                  .toString(),
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight: FontWeight
                                                                      .bold)) :
                                                          Text(
                                                              snapshot.data[index]
                                                                  .Admin
                                                                  .toString(),
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight: FontWeight
                                                                      .bold)),
                                                        ),

                                                      ],
                                                    ),
                                                  )
                                                ]
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.0),
                                        Flexible(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            children: <Widget>[
                                              IconButton(
                                                icon: Icon(
                                                  const IconData(0xe81e,
                                                      fontFamily: "CustomIcon"),
                                                  color: Colors.black54,
                                                  size: 21.0,
                                                ),
                                                onPressed: () {
                                                  _launchURL('tel:' +
                                                      snapshot.data[index].Mobile
                                                          .toString());
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  const IconData(0xe820,
                                                      fontFamily: "CustomIcon"),
                                                  color: Colors.black54,
                                                  size: 21.0,
                                                ),
                                                onPressed: () {
                                                  _launchURL('sms:' +
                                                      snapshot.data[index].Mobile
                                                          .toString());
                                                },
                                              ),
                                              /*IconButton(
                                              icon: Icon(
                                                const IconData(0xe81f, fontFamily: "CustomIcon"),
                                                color:Colors.black54,
                                                size: 21.0,
                                              ),
                                              onPressed:(){
                                                _launchURL('Email:'+snapshot.data[index].Email.toString());
                                              },
                                            )*/
                                            ],
                                          ),
                                        ),
                                      ],),

                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: new Column(
                          children: <Widget>[
                            SizedBox(height: 10.0,),
                            Wrap(
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: <Widget>[
                                      InkWell(
                                        child:
                                        new Container(
                                          margin: EdgeInsets.only(left: 10.0),
                                          width: 40.0,
                                          height: 40.0,

                                          /*child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                50),
                                            child: FadeInImage.assetNetwork(
                                              placeholder: 'assets/imgloader.gif',

                                              image: snapshot.data[index]
                                                  .Profile.toString(),
                                              fit: BoxFit.fill,
                                              placeholderScale: 55.0,
                                            ),
                                          ),*/
                                          child: CircleAvatar(
                                            child: Text(getAcronym(snapshot.data[index].Name),style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400)),
                                            backgroundColor: Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0),
                                          ),
//                                    decoration: new BoxDecoration(
//                                        shape: BoxShape.circle,
//                                        image: new DecorationImage(
//                                          fit: BoxFit.fill,
//                                          image:
////                                          AssetImage('assets/user_profile.png'),
//
//                                            NetworkImage(snapshot.data[index].Profile.toString())
//
//                    //_checkLoaded ? AssetImage('assets/avatar.png') : profileimage,
//                                        )
//                                    )
                                        ),
                                        /*onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ImageView(
                                                    myimage: snapshot
                                                        .data[index].Profile,
                                                    org_name: _orgName)),
                                          );
                                        },*/
                                      ),
                                      SizedBox(width: 10.0,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.63,
                                                child: new Text(
                                                  snapshot.data[index].Name
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 18.0,
//                                                   fontWeight: FontWeight.w500
                                                  ),
                                                ),
                                              ),


                                              new InkWell(
                                                onTap: () {
                                                  _launchURL('tel:' +
                                                      snapshot.data[index]
                                                          .Mobile.toString());
                                                },
                                                child: Icon(
                                                  const IconData(0xe81e,
                                                      fontFamily: "CustomIcon"),
                                                  color: Colors.black54,
                                                  size: 21.0,
                                                ),
                                              ),

                                              SizedBox(width: 10.0,),
                                              new InkWell(
                                                onTap: () {
                                                  print('SMS tapped');
                                                  _launchURL('sms:' +
                                                      snapshot.data[index]
                                                          .Mobile.toString());
                                                  // _showPopupMenu();
                                                },
                                                child: Icon(
                                                  const IconData(0xe820,
                                                      fontFamily: "CustomIcon"),
                                                  color: Colors.black87,
                                                  size: 21.0,
                                                ),
                                              ),
                                              SizedBox(width: 10.0,),
                                              /*new InkWell(
                                             onTap:(){
                                               print('email tapped');
                                               _launchURL('Email:'+snapshot.data[index].Email.toString());
                                             },
                                             child:Icon(
                                               const IconData(0xe81f, fontFamily: "CustomIcon"),
                                               color:Colors.black87,
                                               size: 21.0,
                                             ),
                                           ),*/
                                              /*     snapshot.data[index].Email.toString()!=''&& snapshot.data[index].Email.toString()!=null?
                                           new InkWell(
                                             onTap:(){
                                               print('SMS tapped');
                                               _launchURL('Email:'+snapshot.data[index].Email.toString());
                                             },
                                             child:Icon(Icons.mail,color:Colors.blue,),),
                                               :Center(),*/
                                            ],
                                          ),
                                          /* SizedBox(height: 1.0,),
                                         Text(snapshot.data[index].Department.toUpperCase(),
                                           style: TextStyle(
                                           color: Colors.black87,
                                           fontSize: 13.0,
                                           fontWeight: FontWeight.w400
                                           ),
                                         ),*/
                                          /*SizedBox(height: 1.0,),*/
                                          /*Text(snapshot.data[index].Designation.toString(),
                                         style: TextStyle(
                                             color: Colors.black87,
                                             fontSize: 13.0,
                                             fontWeight: FontWeight.w600
                                         ),
                                       ),*/
//                                   Text(snapshot.data[index].Mobile.toString()),
//                                 snapshot.data[index].Email.toString()!=''&& snapshot.data[index].Email.toString()!=null?Text(snapshot.data[index].Email.toString()):Center(),
//                                 RichText(
//                                   textAlign: TextAlign.left,
//                                   softWrap: true,
//                                   text: TextSpan(children: <TextSpan>
//                                   [
//                                     TextSpan(text:"Shift: ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                     TextSpan(text:snapshot.data[index].Shift.toString(),style: TextStyle(color: Colors.black)),
//                                   ]
//                                   ),
//                                 ),
//                                 RichText(
//                                   textAlign: TextAlign.left,
//                                   softWrap: true,
//                                   text: TextSpan(children: <TextSpan>
//                                   [
//                                     TextSpan(text:"Permissions: ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//                                     snapshot.data[index].Admin.toString()=='Mobile Admin'?
//                                     TextSpan(text:snapshot.data[index].Admin.toString(),style: TextStyle(color: Colors.green)):
//                                     TextSpan(text:snapshot.data[index].Admin.toString(),style: TextStyle(color: Colors.black)),
//                                   ]
//                                   ),
//                                 ),
                                          /*    RichText(
                                         textAlign: TextAlign.left,
                                         softWrap: true,
                                         text: TextSpan(children: <TextSpan>
                                         [
                                           TextSpan(text:"Status: ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                                           snapshot.data[index].Status.toString()=='Inactive'?
                                           TextSpan(text:snapshot.data[index].Status.toString(),style: TextStyle(color: Colors.red)):
                                           TextSpan(text:snapshot.data[index].Status.toString(),style: TextStyle(color: Colors.black)),

                                         ]
                                         ),
                                       ),
*/

                                        ],
                                      ),


                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15.0,)
                          ]
                      ),
                    );
                  }
              );
            }
            /*

                        new FlatButton(
                          child : new Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Container(
                                width: MediaQuery.of(context).size.width*0.3,
                                child: new Text(snapshot.data[index].Name.toString()),
                              ),
                              new Container(
                                width: MediaQuery.of(context).size.width*0.22,
                                child: new Text(snapshot.data[index].Department.toString(),),
                              ),
                              new Container(
                                width: MediaQuery.of(context).size.width*0.22,
                                child: new Text(snapshot.data[index].Designation.toString(),),
                              ),
                              new Container(
                                width: MediaQuery.of(context).size.width*0.16,
                                child: new Text(snapshot.data[index].Status.toString(),style: TextStyle(color: snapshot.data[index].Status.toString()!='Active'?Colors.deepOrange:Colors.green),),
                              ),
                            ],
                          ),
                          onPressed: (){
                            null;
                            //    editDept(context,snapshot.data[index].dept.toString(),snapshot.data[index].status.toString(),snapshot.data[index].id.toString());
                          },),
                        Divider(color: Colors.blueGrey.withOpacity(0.25),height: 0.2,),
                        */


          return loader();
        }
    );
  }
  _showPopupMenu() async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 400, 100, 400),
      items: [
        PopupMenuItem(
          child: Text("View"),
        ),
        PopupMenuItem(
          child: Text("Edit"),
        ),
        PopupMenuItem(
          child: Text("Delete"),
        ),
      ],
      elevation: 8.0,
    );
  }

}/////////mail class close