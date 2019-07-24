import 'database.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:Shrine/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LoginOffline{



  int 	Id;
  int UserTableId;
  int EmployeeId;
  String Password;
  String Username;
  String MobileNo;
  int OrganizationId;
  int AdminSts;
  int AppSuperviserSts;
  int EmployeeTableId;
  String FirstName;
  String LastName;
  String CurrentEmailId;
  int SentForSyncStatus;
  int SentForSyncDate;

  LoginOffline.empty();

  LoginOffline( this.Id,
  this.UserTableId,
  this.EmployeeId,
  this.Password,
  this.Username,
  this.MobileNo,
  this.OrganizationId,
  this.AdminSts,
  this.AppSuperviserSts,
  this.EmployeeTableId,
  this.FirstName,
  this.LastName,
  this.CurrentEmailId,
  this.SentForSyncStatus,
  this.SentForSyncDate

  );


  Map<String, dynamic> toMap() {
    Map map = <String, dynamic>{
      'Id': Id,
      'UserTableId': UserTableId,
      'EmployeeId': EmployeeId,
      'Password': Password,
      'Username': Username,
      'MobileNo': MobileNo,
      'OrganizationId': OrganizationId,
      'AdminSts': AdminSts,
      'AppSuperviserSts': AppSuperviserSts,
      'EmployeeTableId': EmployeeTableId,
      'FirstName': FirstName,
      'LastName': LastName,
      'CurrentEmailId': CurrentEmailId,
      'SentForSyncStatus': SentForSyncStatus,
      'SentForSyncDate': SentForSyncDate
    };
    return map;
  }

  LoginOffline.fromMap(Map<String, dynamic> map){
   // print('idddd: '+map['EmployeeId']);

    Id=map['Id'];
    UserTableId=map['UserTableId'];
    EmployeeId=map['EmployeeId'];
    Password=map['Password'];
    Username=map['Username'];
    MobileNo=map['MobileNo'];
    OrganizationId=map['OrganizationId'];
    AdminSts=map['AdminSts'];
    AppSuperviserSts=map['AppSuperviserSts'];
    EmployeeTableId=map['EmployeeTableId'];
    FirstName=map['FirstName'];
    LastName=map['LastName'];
    CurrentEmailId=map['CurrentEmailId'];
    SentForSyncStatus=map['SentForSyncStatus'];
    SentForSyncDate=map['SentForSyncDate'];

  }


  Future<LoginOffline> saveObj(LoginOffline am) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    am.Id= await dbClient.insert('LoginOffline', am.toMap());
    return am;
  }

  Future<LoginOffline> save() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    this.Id= await dbClient.insert('LoginOffline', this.toMap());
    return this;
  }

  Future<List<LoginOffline>> select() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    List<Map> maps= await dbClient.query('LoginOffline',columns: [
      'Id',
      'UserTableId',
      'EmployeeId',
      'Password',
      'Username',
      'MobileNo',
      'OrganizationId',
      'AdminSts',
      'AppSuperviserSts',
      'EmployeeTableId',
      'FirstName',
      'LastName',
      'CurrentEmailId',
      'SentForSyncStatus',
      'SentForSyncDate'
    ]);
    List<LoginOffline> ams=[];
    if(maps.length>0){
      for (int i=0;i<maps.length;i++){
        ams.add(LoginOffline.fromMap(maps[i]));
      }

    }
    return ams;

  }



  Future<String> checkOfflineLogin(String username,String password) async{
    DbHelper dbHelper=new DbHelper();
    username=await encode5t(username);
    password=await encode5t(password);
    var dbClient = await dbHelper.db;
   // print('------------Decode5t-------------');

    //print(await decode5t('U5Ga0Z1aaNlYHp0MjdEdXJ1aKVVVB1TP'));

   // print('------------Decode5t-------------');

    final prefs = await SharedPreferences.getInstance();
    var isDatabaseSet= prefs.getInt("offline_db_saved")??0;
    print("Database set or not.... :"+isDatabaseSet.toString());
    if(isDatabaseSet==1) {
      List<Map> maps = await dbClient.query('LoginOffline', columns: [
        'Id',
        'UserTableId',
        'EmployeeId',
        'Password',
        'Username',
        'MobileNo',
        'OrganizationId',
        'AdminSts',
        'AppSuperviserSts',
        'EmployeeTableId',
        'FirstName',
        'LastName',
        'CurrentEmailId',
        'SentForSyncStatus',
        'SentForSyncDate',
      ],
          where: '(Username=? OR MobileNo=?) AND Password=?',
          whereArgs: [username, username, password]);

      if (maps.length > 0) {
        print(await decode5t(maps[0]['Username']));
        print('Offline Login successful');
        prefs.setInt("OfflineLoginId",maps[0]['Id']);
        prefs.setInt("OfflineEmployeeId",maps[0]['EmployeeId']);
        prefs.setString("OfflineFirstName",maps[0]['FirstName']);
        prefs.setString("OfflineLastName",maps[0]['LastName']);
        prefs.setInt("OfflineEmailId",maps[0]['EmailId']);
        prefs.setInt("OfflineAdminStatus",maps[0]['AdminSts']);
        prefs.setInt("OfflineAppSupervisorStatus",maps[0]['AppSuperviserSts']);
        prefs.setString("OfflineUsername",maps[0]['Username']);
        prefs.setInt("OfflineOrganizationId",maps[0]['OrganizationId']);

        return 'Offline Login Successful';
        //return 'Offline Login successful';
      }
      else {
        print('Not found when checking offline!');
        return 'Offline login Unsuccessful';
      }
    }
    else{
      print('Offline Login database not set');
      return 'Database Not Set';
    }

  }

  Future<int> delete(int id) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    int ids= await dbClient.delete('LoginOffline',where:'Id =?',whereArgs: [id]);
    return ids;
  }

  Future<int> update(LoginOffline am) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    return dbClient.update('LoginOffline', am.toMap(),where:'Id=?',whereArgs: [am.Id]);
  }

  Future close() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    return dbClient.close();
  }



}