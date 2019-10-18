import 'package:Shrine/globals.dart' as prefix0;
import 'package:flutter/material.dart';
import 'drawer.dart';
import 'package:Shrine/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:Shrine/editEmployee.dart';
import 'package:Shrine/addEmployee.dart';
import 'home.dart';
import 'settings.dart';
import 'reports.dart';
import 'profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Image_view.dart';
import 'Bottomnavigationbar.dart';
import 'globals.dart';
//import 'package:material_search/material_search.dart';

class EmployeeList extends StatefulWidget {
  @override
  _EmployeeList createState() => _EmployeeList();
}
TextEditingController dept;
//FocusNode f_dept ;
class _EmployeeList extends State<EmployeeList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _currentIndex = 2;
  String _sts = 'Active';
  String _sts1 = 'Active';
  String admin_sts='0';
  String _orgName = "";
  String empname = "";
  bool res = true;
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
      backgroundColor: Colors.white,
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
        //   padding: EdgeInsets.only(left: 2.0, right: 2.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 8.0),
            Center(
              child: Text('Employee Directory',
                style: new TextStyle(fontSize: 22.0, color: buttoncolor,),),
            ),

            SizedBox(height: 5.0),
            Container(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.only(left:8.0,right: 8.0),
                child: TextField(

                  decoration: InputDecoration(
                    /*border: OutlineInputBorder(
                    //  borderRadius: BorderRadius.circular(5),
                     // borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 0.0,),
                    ),*/
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search',
                  ),
                  onChanged: (value) {
                    setState(() {
                      empname = value;
                      res = true;
                    });
                  },
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
        backgroundColor: Colors.blue,
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEmployee()),
          );
        },
        tooltip: 'Add Employee',
        child: new Icon(Icons.person_add),
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


  void filterSearchResults($val){
    print($val);
  }

  getDeptWidget() {

    return new FutureBuilder<List<Emp>>(
        future: getEmployee(empname),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new ListView.builder(
                itemCount: snapshot.data.length,
                //    padding: EdgeInsets.only(left: 15.0,right: 15.0),
                itemBuilder: (BuildContext context, int index) {
                  return  InkWell(
                    onTap: (){
                      showDialog<String>(
                        context: context,
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.all(15.0),
                          content: Wrap(
                            children: <Widget>[
                              Container(
//                            height: MediaQuery.of(context).size.height*0.45,
//                            width: MediaQuery.of(context).size.width*0.45,
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
                                              /* Icon(
                                                Icons.edit,
                                                color: Colors.blueAccent,
                                              ),*/
                                              Text(
                                                "Edit",
                                                style: TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: (){
//                                         Navigator.pop(context);
                                            Navigator.of(context, rootNavigator: true).pop('dialog');
                                            Navigator.push(
                                              context,

                                              MaterialPageRoute(builder: (context) => EditEmployee(name: snapshot.data[index].Name.toString(),phone: snapshot.data[index].Mobile.toString(),email:snapshot.data[index].Email.toString(),password:snapshot.data[index].Password.toString(),department:snapshot.data[index].DepartmentId.toString(),designation:snapshot.data[index].DesignationId.toString(),shift:snapshot.data[index].ShiftId.toString(),empid:snapshot.data[index].Id.toString())),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    Container(
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
                                                NetworkImage(snapshot.data[index].Profile.toString())

                                              //_checkLoaded ? AssetImage('assets/avatar.png') : profileimage,
                                            )
                                        )
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
                                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
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
                                                      'Department:',
                                                      style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              TableCell(
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(snapshot.data[index].Department.toString(),
                                                        style: TextStyle(
                                                            color: Colors.black87,
                                                            fontSize: 15.0,
                                                            fontWeight: FontWeight.w400
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
                                                      'Designation:',
                                                      style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              TableCell(
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(snapshot.data[index].Designation.toString(),
                                                        style: TextStyle(
                                                            color: Colors.black87,
                                                            fontSize: 15.0,
                                                            fontWeight: FontWeight.w400
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
                                                      'Mobile:',
                                                      style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              TableCell(
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(snapshot.data[index].Mobile.toString(),
                                                        style: TextStyle(
                                                            color: Colors.black87,
                                                            fontSize: 15.0,
                                                            fontWeight: FontWeight.w400
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
                                                      'Shift:',
                                                      style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              TableCell(
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(snapshot.data[index].Shift.toString(),
                                                        style: TextStyle(
                                                            color: Colors.black87,
                                                            fontSize: 15.0,
                                                            fontWeight: FontWeight.w400
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
                                                      'Permissions:',
                                                      style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              TableCell(
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: snapshot.data[index].Admin.toString()=='Mobile Admin'?
                                                      Text(snapshot.data[index].Admin.toString(),maxLines: 2,style: TextStyle(color: Colors.green)):
                                                      Text(snapshot.data[index].Admin.toString(),maxLines: 2,style: TextStyle(color: Colors.black)),
                                                    ),

                                                  ],
                                                ),
                                              )
                                            ]
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(
                                            const IconData(0xe81e, fontFamily: "CustomIcon"),
                                            color:Colors.black54,
                                            size: 21.0,
                                          ),
                                          onPressed:(){
                                            _launchURL('tel:'+snapshot.data[index].Mobile.toString());
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            const IconData(0xe820, fontFamily: "CustomIcon"),
                                            color:Colors.black54,
                                            size: 21.0,
                                          ),
                                          onPressed:(){
                                            _launchURL('sms:'+snapshot.data[index].Mobile.toString());
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            const IconData(0xe81f, fontFamily: "CustomIcon"),
                                            color:Colors.black54,
                                            size: 21.0,
                                          ),
                                          onPressed:(){
                                            _launchURL('Email:'+snapshot.data[index].Email.toString());
                                          },
                                        )
                                      ],
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
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[

                                InkWell(
                                  child:
                                  new Container(
                                    margin: EdgeInsets.only(left: 10.0),
                                    width: 65.0,
                                    height: 65.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: FadeInImage.assetNetwork(
                                        placeholder: 'assets/imgloader.gif',

                                        image: snapshot.data[index].Profile.toString(),
                                        fit: BoxFit.fill,
                                        placeholderScale: 55.0,
                                      ),
                                    ),
                                  ),

                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].Profile,org_name: _orgName)),
                                    );
                                  },
                                ),
                                SizedBox(width: 10.0,),

                                Column(


                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(

                                      children: <Widget>[
                                        Container(

                                          width: MediaQuery.of(context).size.width*0.5,
                                          child: new Text(
                                            snapshot.data[index].Name.toString(),
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),
                                        ),


                                        new InkWell(
                                          onTap:(){
                                            _launchURL('tel:'+snapshot.data[index].Mobile.toString());
                                          },
                                          child:Icon(
                                            const IconData(0xe81e, fontFamily: "CustomIcon"),
                                            color:Colors.black54,
                                            size: 21.0,
                                          ),
                                        ),

                                        SizedBox(width: 10.0,),
                                        new InkWell(
                                          onTap:(){
                                            print('SMS tapped');
                                            _launchURL('sms:'+snapshot.data[index].Mobile.toString());
                                          },
                                          child:Icon(
                                            const IconData(0xe820, fontFamily: "CustomIcon"),
                                            color:Colors.black87,
                                            size: 21.0,
                                          ),
                                        ),
                                        SizedBox(width: 10.0,),
                                        new InkWell(
                                          onTap:(){
                                            print('email tapped');
                                            _launchURL('Email:'+snapshot.data[index].Email.toString());
                                          },
                                          child:Icon(
                                            const IconData(0xe81f, fontFamily: "CustomIcon"),
                                            color:Colors.black87,
                                            size: 21.0,
                                          ),
                                        ),
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
                                    SizedBox(height: 1.0,),
                                    Text(snapshot.data[index].Department.toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w400
                                      ),
                                    ),
                                    SizedBox(height: 1.0,),
                                    Text(snapshot.data[index].Designation.toString(),
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w600
                                      ),
                                    ),

                                  ],
                                ),

                              ],
                            ),
                          ),
                          SizedBox(height: 15.0,)
                        ]
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
