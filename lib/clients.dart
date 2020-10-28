import 'package:Shrine/addClient.dart';
import 'package:Shrine/punchlocation.dart';
import 'package:Shrine/punchlocationOld.dart';
import 'package:Shrine/services/services.dart';
import 'package:Shrine/viewClient.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Bottomnavigationbar.dart';
import 'drawer.dart';
import 'globals.dart';

class ClientList extends StatefulWidget {
  @override
  _ClientList createState() => _ClientList();
}
TextEditingController client;
class _ClientList extends State<ClientList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _currentIndex = 2;
  String _sts = 'Active';
  String _sts1 = 'Active';
  String _orgName = "";
  String admin_sts='0';
  bool _isButtonDisabled= false;

  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    client = new TextEditingController();
    getOrgName();

  }
  getOrgName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName= prefs.getString('org_name') ?? '';
      admin_sts= prefs.getString('sstatus') ?? '0';
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

  getmainhomewidget() {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            new Text(_orgName, style: new TextStyle(fontSize: 20.0)),
            /*  Image.asset(
                    'assets/logo.png', height: 40.0, width: 40.0),*/
          ],
        ),
        leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
          Navigator.pop(context);}),
        backgroundColor: appcolor,
      ),
      bottomNavigationBar: Bottomnavigationbar(),
      endDrawer: new AppDrawer(),
      body:
      Container(
        padding: EdgeInsets.only(left: 2.0, right: 2.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 8.0),
            Center(
              child: Text('Clients',
                style: new TextStyle(fontSize: 22.0, color: appcolor,),),
            ),
            Divider(height: 1.5, color: Colors.black87,),
            //Divider(height: 10.0,),
            SizedBox(height: 8.0),
            Container(
              padding: EdgeInsets.only(left: 10.0,right: 5.0),
              child: Row(
                //crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width:MediaQuery.of(context).size.width*0.38,
                    child: Text('Company', style: TextStyle(
                        color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold ),),
                  ),
                  Container(
                    width:MediaQuery.of(context).size.width*0.40,
                    child: Text('Contact Person', style: TextStyle(
                        color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold ),),
                  ),
                  Container(
                    width:MediaQuery.of(context).size.width*0.15,
                    child: Text('Action', style: TextStyle(
                        color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold ),),
                  ),
                  /*Text('Status', style: TextStyle(
                      color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold),),*/
                ],
              ),
            ),
            Divider(),
            //SizedBox(height: 5.0),
            new Expanded(
              child: getClientWidget(),

            ),

          ],
        ),

      ),
      floatingActionButton: new FloatingActionButton(
        mini: false,
        backgroundColor: buttoncolor,
        onPressed: (){
          setState(() {
            _isButtonDisabled=false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddClient(sts:"0")),
          );
          //_showDialog(context);
        },
        tooltip: 'Add Client',
        child: new Icon(Icons.add),
      ),
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

  getClientWidget() {
    return new FutureBuilder<List<Client>>(
        future: getClient(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new ListView.builder(
                itemCount: snapshot.data.length,
                //padding: EdgeInsets.only(left: 10.0,right: 10.0),
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    /*onTap: () {
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
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        InkWell(
                                          highlightColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          child:
                                          Row(
                                            children: <Widget>[
                                              *//*Icon(
                                                  Icons.edit,
                                                  color: Colors.blueAccent,
                                                ),*//*
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
                                                      AddClient(
                                                          company: snapshot
                                                              .data[index]
                                                              .company
                                                              .toString(),
                                                          name: snapshot
                                                              .data[index]
                                                              .name
                                                              .toString(),
                                                          address: snapshot
                                                              .data[index]
                                                              .address
                                                              .toString(),
                                                          contcode: snapshot
                                                              .data[index]
                                                              .contcode
                                                              .toString(),
                                                          city: snapshot
                                                              .data[index]
                                                              .city
                                                              .toString(),
                                                          contact: snapshot
                                                              .data[index]
                                                              .contact
                                                              .toString(),
                                                          email: snapshot
                                                              .data[index]
                                                              .email
                                                              .toString(),
                                                          desc: snapshot
                                                              .data[index]
                                                              .desc
                                                              .toString(),
                                                          id: snapshot
                                                              .data[index].id
                                                              .toString(),
                                                          sts: '1'
                                                      )),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20,),
                                    Expanded(
                                      child: Table(
                                        defaultVerticalAlignment: TableCellVerticalAlignment.top,
                                        columnWidths: {
                                          0: FlexColumnWidth(5),
                                          1: FlexColumnWidth(5),
                                        },
                                        children: [
                                          TableRow(
                                              children: [
                                                TableCell(
                                                  child: Row(
                                                    children: <Widget>[
                                                      new Text(
                                                        'Company',
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
                                                              .company
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
                                                        'Client Name',
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
                                                              .name
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
                                                        'Address',
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
                                                              .address
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
                                                        'City',
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
                                                              .city.toString(),
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
                                                              .contact.toString(),
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
                                                        'Email',
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
                                                              .email.toString(),
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
                                                        'Description',
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
                                                              .desc.toString(),
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
                                          )
                                        ],
                                      ),
                                    ),

                                  ],),
                              ),
                            ],
                          ),
                        ),
                      );
                    },*/
                    child: new Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left:15.0),
                            child: new Row(
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Container(
                                  width: MediaQuery.of(context).size.width * 0.38,
                                  // color: Colors.amber.shade400,
                                  padding: EdgeInsets.only(top:5.0,bottom: 5.0),
                                  //margin: EdgeInsets.only(top:5.0),
                                  //alignment: FractionalOffset.center,
                                  child: new Text(snapshot.data[index].company.toString(),style: TextStyle(
                                      color: Colors
                                      .black87,
                                      fontSize: 15.0,
                                  ),),
                                ),
                                new Container(
                                  width: MediaQuery.of(context).size.width * 0.37,
                                  // color: Colors.amber.shade400,
                                  padding: EdgeInsets.only(top:5.0,bottom: 5.0),
                                  //margin: EdgeInsets.only(top:5.0),
                                  //alignment: FractionalOffset.center,
                                  child: new Text(snapshot.data[index].name.toString(),style: TextStyle(
                                      color: Colors
                                          .black87,
                                      fontSize: 15.0,
                                  ),),
                                ),
                                InkWell(
                                  child: new Container(
                                    //width: MediaQuery.of(context).size.width * 0.15,
                                    // color: Colors.amber.shade400,
                                    padding: EdgeInsets.only(top:5.0,bottom: 5.0),
                                    //margin: EdgeInsets.only(top:5.0),
                                    //alignment: FractionalOffset.center,
                                    child: Tooltip(message:"View CLient", child: Icon(Icons.remove_red_eye))
                                  ),
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ViewClient(company: snapshot
                                          .data[index]
                                          .company
                                          .toString(),
                                          name: snapshot
                                              .data[index]
                                              .name
                                              .toString(),
                                          address: snapshot
                                              .data[index]
                                              .address
                                              .toString(),
                                          contcode: snapshot
                                              .data[index]
                                              .contcode
                                              .toString(),
                                          city: snapshot
                                              .data[index]
                                              .city
                                              .toString(),
                                          contact: snapshot
                                              .data[index]
                                              .contact
                                              .toString(),
                                          email: snapshot
                                              .data[index]
                                              .email
                                              .toString(),
                                          desc: snapshot
                                              .data[index]
                                              .desc
                                              .toString(),
                                          id: snapshot
                                              .data[index].id
                                              .toString(),
                                          sts: '1')),
                                    );
                                  },
                                ),
                                SizedBox(width:8),
                                InkWell(
                                  child: new Container(
                                      width: MediaQuery.of(context).size.width * 0.1,
                                      // color: Colors.amber.shade400,
                                      padding: EdgeInsets.only(top:5.0,bottom: 5.0),
                                      //margin: EdgeInsets.only(top:5.0),
                                      //alignment: FractionalOffset.center,
                                      child: Tooltip(message:"Visit Client",child: Icon(const IconData(0xe821, fontFamily: "CustomIcon"),))
                                  ),
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => PunchLocation(
                                          client: snapshot.data[index].company.toString(),
                                        ))
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          Divider(color: Colors.blueGrey.withOpacity(0.25),),]
                    ),
                  );
                }
            );
          }
          return loader();
        }
    );
  }
}/////////mail class close
