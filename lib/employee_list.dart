import 'package:flutter/material.dart';
import 'drawer.dart';
import 'package:Shrine/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:Shrine/addEmployee.dart';
import 'home.dart';
import 'settings.dart';
import 'reports.dart';
import 'profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Image_view.dart';
import 'Bottomnavigationbar.dart';
import 'notifications.dart';

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
            backgroundColor: Colors.teal,
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
                    style: new TextStyle(fontSize: 22.0, color: Colors.orangeAccent,),),
                ),
                Divider(height: 10.0,),
                SizedBox(height: 2.0),
                new Expanded(
                  child: getDeptWidget(),
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

  getDeptWidget() {
    return new FutureBuilder<List<Emp>>(
        future: getEmployee(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new ListView.builder(
                itemCount: snapshot.data.length,
            //    padding: EdgeInsets.only(left: 15.0,right: 15.0),
                itemBuilder: (BuildContext context, int index) {
                  return  new Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              InkWell(
                          child:
                              new Container(
                                margin: EdgeInsets.only(left: 5.0),
                                  width: 70.0,
                                  height: 70.0,
                               child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/imgloader.gif',
                                  image: snapshot.data[index].Profile.toString(),
                                  fit: BoxFit.fill,
                                  placeholderScale: 55.0,

                                ),
                                /*  decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(snapshot.data[index].Profile.toString()),//_checkLoaded ? AssetImage('assets/avatar.png') : profileimage,
                                      )
                                  )*/),

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
                                       width: MediaQuery.of(context).size.width*0.55,
                                       child: new Text(snapshot.data[index].Name.toString(),style: TextStyle(color: Colors.teal,fontSize: 18.0,fontWeight: FontWeight.w500),),
                                     ),


                                     new InkWell(
                                       onTap:(){
                                         _launchURL('tel:'+snapshot.data[index].Mobile.toString());
                                       },
                                       child:Icon(Icons.call,color:Colors.blue,),),

                                     SizedBox(width: 10.0,),
                                     new InkWell(
                                       onTap:(){
                                         print('SMS tapped');
                                         _launchURL('sms:'+snapshot.data[index].Mobile.toString());
                                       },
                                       child:Icon(Icons.sms,color:Colors.blue,),),
                                /*     snapshot.data[index].Email.toString()!=''&& snapshot.data[index].Email.toString()!=null?
                                     new InkWell(
                                       onTap:(){
                                         print('SMS tapped');
                                         _launchURL('Email:'+snapshot.data[index].Email.toString());
                                       },
                                       child:Icon(Icons.mail,color:Colors.blue,),)
                                         :Center(),*/
                                   ],
                                 ),
                                   Text(snapshot.data[index].Designation.toString()+'('+snapshot.data[index].Department.toString()+')'),
                                   Text(snapshot.data[index].Mobile.toString()),
                                 snapshot.data[index].Email.toString()!=''&& snapshot.data[index].Email.toString()!=null?Text(snapshot.data[index].Email.toString()):Center(),
                                 RichText(
                                   textAlign: TextAlign.left,
                                   softWrap: true,
                                   text: TextSpan(children: <TextSpan>
                                   [
                                     TextSpan(text:"Shift: ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                                     TextSpan(text:snapshot.data[index].Shift.toString(),style: TextStyle(color: Colors.black)),
                                   ]
                                   ),
                                 ),
                                 RichText(
                                   textAlign: TextAlign.left,
                                   softWrap: true,
                                   text: TextSpan(children: <TextSpan>
                                   [
                                     TextSpan(text:"Permissions: ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                                     snapshot.data[index].Admin.toString()=='Mobile Admin'?
                                     TextSpan(text:snapshot.data[index].Admin.toString(),style: TextStyle(color: Colors.green)):
                                     TextSpan(text:snapshot.data[index].Admin.toString(),style: TextStyle(color: Colors.black)),
                                   ]
                                   ),
                                 ),
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
                        Divider(),
                      ]
                  );
                }
            );
          }/*

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
}/////////mail class close
