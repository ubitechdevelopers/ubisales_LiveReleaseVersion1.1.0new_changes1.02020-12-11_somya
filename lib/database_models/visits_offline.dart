import 'database.dart';
import 'dart:io';
import 'package:intl/intl.dart';


class VisitsOffline{


  int Id ;


  int EmployeeId;
  String VisitInLatitude;
  String VisitInLongitude;
  String VisitInTime;
  String VisitInDate;

  String VisitOutLatitude;
  String VisitOutLongitude;
  String VisitOutTime;
  String VisitOutDate;
  String ClientName;
  String VisitInDescription;
  String VisitOutDescription;
  String OrganizationId;
  int Skipped;
  String VisitInImage;
  String VisitOutImage;
  int FakeLocationStatusVisitIn;
  int FakeLocationStatusVisitOut;
  int FakeVisitInTimeStatus;
int FakeVisitOutTimeStatus;
 VisitsOffline(
  this.Id,


  this.EmployeeId,
  this.VisitInLatitude,
  this.VisitInLongitude,
  this.VisitInTime,
  this.VisitInDate,

  this.VisitOutLatitude,
  this.VisitOutLongitude,
  this.VisitOutTime,
  this.VisitOutDate,
  this.ClientName,
  this.VisitInDescription,
  this.VisitOutDescription,
  this.OrganizationId,
  this.Skipped,
  this.VisitInImage,
  this.VisitOutImage,
  this.FakeLocationStatusVisitIn,
  this.FakeLocationStatusVisitOut,
  this.FakeVisitInTimeStatus,
     this.FakeVisitOutTimeStatus
     );



  VisitsOffline.empty();

  Map<String, dynamic> toMap() {
    Map map = <String, dynamic>{
      'Id':Id,


      'EmployeeId':EmployeeId,
      'VisitInLatitude':VisitInLatitude,
      'VisitInLongitude':VisitInLongitude,
      'VisitInTime':VisitInTime,
      'VisitInDate':VisitInDate,

      'VisitOutLatitude':VisitOutLatitude,
      'VisitOutLongitude':VisitOutLongitude,
      'VisitOutTime':VisitOutTime,
      'VisitOutDate':VisitOutDate,
      'ClientName':ClientName,
      'VisitInDescription':VisitInDescription,
      'VisitOutDescription':VisitOutDescription,
      'OrganizationId':OrganizationId,
      'Skipped':Skipped,
      'VisitInImage':VisitInImage,
      'VisitOutImage':VisitOutImage,
      'FakeLocationStatusVisitIn':FakeLocationStatusVisitIn,
      'FakeLocationStatusVisitOut':FakeLocationStatusVisitOut,
      'FakeVisitInTimeStatus':FakeVisitInTimeStatus,
      'FakeVisitOutTimeStatus':FakeVisitOutTimeStatus
    };
    return map;
  }

  VisitsOffline.fromMap(Map<String, dynamic> map){
    Id=map["Id"];


    EmployeeId=map["EmployeeId"];
    VisitInLatitude=map["VisitInLatitude"];
    VisitInLongitude=map["VisitInLongitude"];
    VisitInTime=map["VisitInTime"];
    VisitInDate=map["VisitInDate"];

    VisitOutLatitude=map["VisitOutLatitude"];
    VisitOutLongitude=map["VisitOutLongitude"];
    VisitOutTime=map["VisitOutTime"];
    VisitOutDate=map["VisitOutDate"];
    ClientName=map["ClientName"];
    VisitInDescription=map["VisitInDescription"];
    VisitOutDescription=map["VisitOutDescription"];
    OrganizationId=map["OrganizationId"];
    Skipped=map["Skipped"];
    VisitInImage=map["VisitInImage"];
    VisitOutImage=map["VisitOutImage"];
    FakeLocationStatusVisitIn=map["FakeLocationStatusVisitIn"];
    FakeLocationStatusVisitOut=map["FakeLocationStatusVisitOut"];
    FakeVisitInTimeStatus=map['FakeVisitInTimeStatus'];
    FakeVisitOutTimeStatus=map['FakeVisitOutTimeStatus'];
  }


  Future<VisitsOffline> saveObj(VisitsOffline am) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    am.Id= await dbClient.insert('VisitsOffline', am.toMap());
    return am;
  }

  Future<int> save() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    dbClient.rawUpdate("""
    UPDATE VisitsOffline 
    SET 
    VisitOutTime = VisitInTime, 
    Skipped = 1,
    VisitOutDescription='Visit out not punched',
    FakeVisitOutTimeStatus=0
    
    WHERE EmployeeId = ? and VisitOutTime='00:00:00'
    """,
        [this.EmployeeId]);

    int id= await dbClient.insert('VisitsOffline', this.toMap());
    print("---------------------Visit In Saved------------------------ ");
    return id ;

  }
  Future<VisitsOffline> saveVisitOut(int idToUpdate,String visitOutLatitude,String visitOutLongitude,String visitOutTime,String visitOutDate,String visitOutDescription,String visitOutImage,int FakeLocationStatus,int FakeVisitOutTimeStatus) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    dbClient.rawUpdate('''
    UPDATE VisitsOffline 
    SET 
    VisitOutLatitude = ?, 
    VisitOutLongitude = ?, 
    VisitOutTime = ?, 
    VisitOutDate = ?, 
    VisitOutDescription = ?, 
    VisitOutImage = ?, 
    FakeLocationStatusVisitOut = ?, 
    FakeVisitOutTimeStatus = ?,
    Skipped = ? 
    
    WHERE Id = ?
    ''',
        [visitOutLatitude, visitOutLongitude, visitOutTime,visitOutDate,visitOutDescription,visitOutImage,FakeLocationStatus,FakeVisitOutTimeStatus,0,idToUpdate]);
    print("---------------------Visit Out Saved------------------------ ");
    return this;

  }



  Future<List<VisitsOffline>> select() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    List<Map> maps= await dbClient.query('VisitsOffline');
    List<VisitsOffline> ams=[];
    if(maps.length>0){
      for (int i=(maps.length-1);i>=0;i--){
        ams.add(VisitsOffline.fromMap(maps[i]));
      }

    }
    return ams;

  }
  /*
  Future<List<Map>> selectOnlyMaps() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    List<Map> maps= await dbClient.query('VisitsOffline');
    return maps;

  }

  Future<VisitsOffline> getSingleAttendance(int Id) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    List<Map> map= await dbClient.query('AttendanceOffline',where: "Id=?",whereArgs: [Id]);
    VisitsOffline ams=VisitsOffline.fromMap(map[0]);
    return ams;

  }

  Future<String> findCurrentDateAttendance(int Id) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');

    var today = formatter.format(now);



    List<Map> maps= await dbClient.query('AttendanceOffline',columns: [
      'Id',
      'UserId',
      'Action', // 0 for time in and 1 for time out
      'Date',
      'OrganizationId',
      'PictureBase64',
      'IsSynced',
      'Latitude',
      'Longitude',
      'Time',
      'FakeLocationStatus'

    ],where: "UserId=? and Date=? and Action=0",whereArgs: [Id,today]);
    if(maps.isEmpty){

      List<Map> map2= await dbClient.query('AttendanceOffline',columns: [
        'Id',
        'UserId',
        'Action', // 0 for time in and 1 for time out
        'Date',
        'OrganizationId',
        'PictureBase64',
        'IsSynced',
        'Latitude',
        'Longitude',
        'Time',
        'FakeLocationStatus'

      ],where: "UserId=? and Date=? and Action=1",whereArgs: [Id,today]);
      if(map2.isEmpty){
        return "Both Not Marked";
      }
      else{
        return "Only Time Out Marked";
      }
    }
    else{
      List<Map> map1= await dbClient.query('AttendanceOffline',columns: [
        'Id',
        'UserId',
        'Action', // 0 for time in and 1 for time out
        'Date',
        'OrganizationId',
        'PictureBase64',
        'IsSynced',
        'Latitude',
        'Longitude',
        'Time',
        'FakeLocationStatus'

      ],where: "UserId=? and Date=? and Action=1",whereArgs: [Id,today]);
      if(map1.isEmpty){
        return "Time In Marked";
      }
      else{
        return "Both Marked";
      }


    }

  }


*/


  Future<int> delete(int id) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    int ids= await dbClient.delete('VisitsOffline',where:'Id =?',whereArgs: [id]);
    print('offline Visits record deleted');
    return ids;

  }

  /*

  Future<int> deleteCurrentDateTimeIn(int UserId) async{

    ////////////////////////////////////// Only Last Time In will get deleted///////////////////////////////////////////

    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');

    var today = formatter.format(now);

    List<Map> lastRecordOfdate= await dbClient.query('VisitsOffline',where:'UserId =? and Date=? and Action=1 order by Id DESC LIMIT 1',whereArgs: [UserId,today]);
    VisitsOffline lastAttOfDate=VisitsOffline.fromMap(lastRecordOfdate[0]);
    int id=lastAttOfDate.Id;
    int deleted=await dbClient.delete("VisitsOffline",where: 'Id=?',whereArgs: [id]);
    print('offline Visits In deleted');

  }
  Future<int> deleteCurrentDateTimeOut(int UserId) async{

    ////////////////////////////////////// Only Last Time Out will get deleted///////////////////////////////////////////
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');

    var today = formatter.format(now);

    List<Map> lastRecordOfdate= await dbClient.query('AttendanceOffline',where:'UserId =? and Date=? and Action=1 order by Id DESC LIMIT 1',whereArgs: [UserId,today]);
    AttendanceOffline lastAttOfDate=AttendanceOffline.fromMap(lastRecordOfdate[0]);
    int id=lastAttOfDate.Id;
    int deleted=await dbClient.delete("AttendanceOffline",where: 'Id=?',whereArgs: [id]);
    print('offline time out deleted');
    //return ids;

  }

  Future<int> update(AttendanceOffline am) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    return dbClient.update('AttendanceOffline', am.toMap(),where:'id=?',whereArgs: [am.Id]);
  }
*/
  Future close() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    return dbClient.close();
  }



}