import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Shrine/globals.dart' as globals;

class Home{
  var dio = new Dio();

  checkTimeIn(String empid, String orgid) async{
    try {

      final prefs = await SharedPreferences.getInstance();
     /* prefs.getKeys();
      prefs.remove('aid');*/
      /*prefs.remove("aid");
      prefs.commit();*/
      //print(prefs.getString('aid'));
      FormData formData = new FormData.from({
        "uid": empid,
        "refno": orgid,
      });
      print(globals.path+"getInfo?uid=$empid&refno=$orgid");
      //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
      Response response = await dio.post(
          globals.path+"getInfo",
          data: formData);
      //print("<<------------------GET HOME-------------------->>");
      print(response.toString());
      //print("this is status "+response.statusCode.toString());
      if (response.statusCode == 200) {
        Map timeinoutMap = json.decode(response.data);
        String aid = timeinoutMap['aid'].toString();
        print('aid'+aid);
        String sstatus = timeinoutMap['sstatus'].toString();

        String mail_varified = timeinoutMap['mail_varified'].toString();
        String profile = timeinoutMap['profile'].toString();
        String newpwd = timeinoutMap['pwd'].toString();
        int Is_Delete = int.parse(timeinoutMap['Is_Delete']);
        globals.departmentname = timeinoutMap['departmentname'].toString();
        globals.departmentid = int.parse(timeinoutMap['departmentid']);
        globals.bulkAttn=int.parse(timeinoutMap['Addon_BulkAttn']);
        globals.geoFence=int.parse(timeinoutMap['Addon_GeoFence']);
        globals.tracking=int.parse(timeinoutMap['Addon_Tracking']);
        globals.payroll=int.parse(timeinoutMap['Addon_Payroll']);
        globals.visitpunch=int.parse(timeinoutMap['Addon_VisitPunch']);
        globals.timeOff=int.parse(timeinoutMap['Addon_TimeOff']);
        globals.flexi_permission=int.parse(timeinoutMap['Addon_flexi_shif']);
        globals.offline_permission=int.parse(timeinoutMap['Addon_offline_mode']);
        globals.visitImage=int.parse(timeinoutMap['visitImage']);
        globals.attImage=int.parse(timeinoutMap['attImage']);
        globals.areaId=int.parse(timeinoutMap['areaId']);

        print("Area Id :"+globals.areaId.toString()+" geofence :"+globals.geoFence.toString());

        prefs.setString("nextWorkingDay", timeinoutMap['nextWorkingDay']);
        prefs.setInt("OfflineModePermission", int.parse(timeinoutMap['Addon_offline_mode']));
        prefs.setInt("ImageRequired", int.parse(timeinoutMap['attImage']));
        prefs.setInt("VisitImageRequired", int.parse(timeinoutMap['visitImage']));

        globals.assigned_lat=  (timeinoutMap['assign_lat']).toDouble();
        globals.assigned_long=    (timeinoutMap['assign_long']).toDouble();
        globals.assign_radius=  (timeinoutMap['assign_radius']).toDouble();
        print("----visitImage------>"+globals.visitImage.toString());


      //  print(newpwd+" new pwd  and old pwd "+  prefs.getString('userpwd'));
       // print(timeinoutMap['pwd']);
        prefs.setString('aid', aid);
        prefs.setString('sstatus', sstatus);
        prefs.setString('mail_varified', mail_varified);
        prefs.setString('profile', profile);
        prefs.setString('newpwd', newpwd);
        prefs.setString('shiftId', timeinoutMap['shiftId']);
        prefs.setString('leavetypeid', timeinoutMap['leavetypeid']);
        prefs.setString('ShiftTimeOut', timeinoutMap['ShiftTimeOut']);
        prefs.setString('ShiftTimeIn', timeinoutMap['ShiftTimeIn']);
        prefs.setString('nextWorkingDay', timeinoutMap['nextWorkingDay']);
        print("Next working day"+timeinoutMap['nextWorkingDay']);
        prefs.setInt('Is_Delete', Is_Delete);
        print('lastact'+prefs.getString('aid'));

        return timeinoutMap['act'];
      } else {
      //  print('8888');
        return "Poor network connection";
      }
    }catch(e){
     // print('9999');
     print(e.toString());
      return "Poor network connection";
    }
  }

  managePermission(String empid, String orgid, String designation) async{
//print("This is called manage permissions-------------------->");
    /*Comment permission module below as per discussion with badi ma'am @ 5 nov- Abhinav*/
   /* try {
      final prefs = await SharedPreferences.getInstance();
      FormData formData = new FormData.from({
        "uid": empid,
        "refid": orgid,
        "roleid": designation
      });

      Response response = await dio.post(
          globals.path+"getUserPermission",
          data: formData
      );

      //print("<<------------------GET USER PERMISSION-------------------->>");
      //print(response.toString());
      //print("this is user permission "+response.statusCode.toString());
      if (response.statusCode == 200) {
        Map permissionMap = json.decode(response.data.toString());
        //print(permissionMap["userpermission"]["DepartmentMaster"]);
        globals.department_permission = permissionMap["userpermission"]["DepartmentMaster"]==1 ? permissionMap["userpermission"]["DepartmentMaster"]: 0;
        globals.designation_permission = permissionMap["userpermission"]["DesignationMaster"]==1 ? permissionMap["userpermission"]["DesignationMaster"]: 0;
        globals.leave_permission = permissionMap["userpermission"]["EmployeeLeave"]==1 ? permissionMap["userpermission"]["EmployeeLeave"]: 0;
        globals.shift_permission = permissionMap["userpermission"]["ShiftMaster"]==1 ? permissionMap["userpermission"]["ShiftMaster"]: 0;
        globals.timeoff_permission = permissionMap["userpermission"]["Timeoff"]==1 ? permissionMap["userpermission"]["Timeoff"]: 0;
        globals.punchlocation_permission = permissionMap["userpermission"]["checkin_master"]==1 ? permissionMap["userpermission"]["checkin_master"]: 0;
        globals.employee_permission = permissionMap["userpermission"]["EmployeeMaster"]==1 ? permissionMap["userpermission"]["EmployeeMaster"]: 0;
        globals.permission_module_permission = permissionMap["userpermission"]["UserPermission"]==1 ? permissionMap["userpermission"]["UserPermission"]: 0;
        globals.report_permission = permissionMap["userpermission"]["ReportMaster"]==1 ? permissionMap["userpermission"]["ReportMaster"]: 0;
      } else {
        return "Poor network connection";
      }
    }catch(e){
      //print(e.toString());
      return "Poor network connection";
    }*/

   /*Putting Admin_sts instead of permissions*/
    final prefs = await SharedPreferences.getInstance();
    String admin_sts=prefs.getString('sstatus') ?? '0';
    //print("---------> this is admin status from get home "+admin_sts);
    if(admin_sts=='1'){
      globals.department_permission = 1;
      globals.designation_permission = 1;
      //globals.leave_permission = 1;
      globals.shift_permission = 1;
      globals.timeoff_permission = 1;
      globals.punchlocation_permission = 1;
      globals.employee_permission = 1;
      //globals.permission_module_permission = 1;
      globals.report_permission = 1;
    }
  }

  checkTimeInQR(String empid, String orgid) async{
    try {
      final prefs = await SharedPreferences.getInstance();
      FormData formData = new FormData.from({
        "uid": empid,
        "refid": orgid,
      });
      //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
      Response response = await dio.post(
          globals.path+"getInfo",
          data: formData);
      //Response response = await dio.post("http://192.168.0.20 0/UBIHRM/HRMINDIA/services/getInfo", data: formData);
      //Response response = await dio.post("https://ubitech.ubihrm.com/services/getInfo", data: formData);

      //print(response.toString());
      //print("this is status "+response.statusCode.toString());
      if (response.statusCode == 200) {
        Map timeinoutMap = json.decode(response.data);
        /*Loc lock = new Loc();
        Map location = await lock.fetchlatilongi();*/
        String lat="",long="";
        String streamlocationaddr = "";
        if(globals.assign_lat!=null ||globals.assign_lat!=0.0 ) {
          lat = globals.assign_lat.toString();
          long = globals.assign_long.toString();
          streamlocationaddr = globals.globalstreamlocationaddr;

          print("--------------------------- Location detection for qr-----------------------------------");
          print(lat+""+long);
          print(streamlocationaddr);

          print("--------------------------- Location detection for qr-----------------------------------");
          timeinoutMap.putIfAbsent('latit', ()=> lat );
          timeinoutMap.putIfAbsent('longi', ()=> long );
        }else{
          timeinoutMap.putIfAbsent('latit', ()=> 0.0 );
          timeinoutMap.putIfAbsent('longi', ()=> 0.0 );
        }
        timeinoutMap.putIfAbsent('location', ()=> streamlocationaddr );
        timeinoutMap.putIfAbsent('uid', ()=> empid );
        timeinoutMap.putIfAbsent('refid', ()=> orgid );
       return timeinoutMap;
      } else {
        return "Poor network connection";
      }
    }catch(e){
      //print(e.toString());
      return "Poor network connection";
    }
  }

}