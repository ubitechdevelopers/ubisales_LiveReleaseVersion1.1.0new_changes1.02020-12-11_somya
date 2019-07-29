import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:simple_permissions/simple_permissions.dart';
import 'package:path/path.dart';
class DbHelper{
  static Database _db;
  Future<Database> get db async{
    print("inside get");
    if(_db!=null){
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  initDB() async{
    print("inside init db");
    // PermissionStatus permissionResult = await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    // if (permissionResult == PermissionStatus.authorized) {
    io
        .Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path =
    join(documentsDirectory.path,'ubiattendance.db');
    print(path);
    var db = await openDatabase(path, version: 21, onCreate: _onCreate,onUpgrade: _onUpgrade);
    return db;
    //}
  }

  _onCreate(Database db,int version) async{
    await db.execute("CREATE TABLE LoginOffline (	Id INTEGER PRIMARY KEY,"
        "UserTableId INTEGER,"
        "EmployeeId INTEGER,"
        "Password TEXT,"
        "Username TEXT,"
        "MobileNo TEXT,"
        "OrganizationId INTEGER,"
        "AdminSts INTEGER,"
        "AppSuperviserSts INTEGER,"
        "EmployeeTableId INTEGER,"
        "FirstName TEXT,"
        "LastName TEXT,"
        "CurrentEmailId TEXT,"
        "SentForSyncStatus INTEGER,"
        "SentForSyncDate TEXT"

        ")");


    await db.execute("CREATE TABLE AttendanceOffline (Id INTEGER PRIMARY KEY,"


        'UserId INTEGER,'
        'Action INTEGER,' // 0 for time in and 1 for time out
        'Date TEXT,'
        'OrganizationId INTEGER,'
        'PictureBase64 TEXT,'
        'IsSynced INTEGER,'
        'Latitude TEXT,'
        'Longitude TEXT,'
        'Time TEXT,'
        'FakeLocationStatus INTEGER'
        ")");




  }
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
print("database upgraded");
      final prefs= await SharedPreferences.getInstance();
      prefs.setInt('offline_db_saved',0);

      await db.execute('DROP TABLE IF EXISTS LoginOffline;');
      await db.execute('DROP TABLE IF EXISTS AttendanceOffline;');
      await db.execute("CREATE TABLE LoginOffline (	Id INTEGER PRIMARY KEY,"
          "UserTableId INTEGER,"
          "EmployeeId INTEGER,"
          "Password TEXT,"
          "Username TEXT,"
          "MobileNo TEXT,"
          "OrganizationId INTEGER,"
          "AdminSts INTEGER,"
          "AppSuperviserSts INTEGER,"
          "EmployeeTableId INTEGER,"
          "FirstName TEXT,"
          "LastName TEXT,"
          "CurrentEmailId TEXT,"
          "SentForSyncStatus INTEGER,"
          "SentForSyncDate TEXT,"
          "FakeLocationStatus INTEGER"
          ")");


      await db.execute("CREATE TABLE AttendanceOffline (Id INTEGER PRIMARY KEY,"


          'UserId INTEGER,'
          'Action INTEGER,' // 0 for time in and 1 for time out
          'Date TEXT,'
          'OrganizationId INTEGER,'
          'PictureBase64 TEXT,'
          'IsSynced INTEGER,'
          'Latitude TEXT,'
          'Longitude TEXT,'
          'Time TEXT,'
          'FakeLocationStatus INTEGER'
          ")");
    }
  }




}