import 'dart:convert';
import 'dart:ui' as ui show Image;
import 'dart:math' as Math;
import 'package:dio/dio.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:Shrine/globals.dart';
import 'package:Shrine/home.dart';
import 'package:Shrine/photoviewController.dart';
import 'package:Shrine/smile_painter.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui show Image;
import 'face_detection_camera.dart';
import 'grpAttPhotoViewController.dart';
import 'model/timeinout.dart';
import 'utils.dart';
import 'package:screen/screen.dart';
import 'package:Shrine/globals.dart' as globals;


class FacePaint extends CustomPaint {
  final CustomPainter painter;

  FacePaint({this.painter}) : super(painter: painter);
}

class SmilePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;

  SmilePainter(this.image, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      canvas.drawImage(image, Offset.zero, Paint());
    }

    final paintRectStyle = Paint()
      ..color = Colors.red
      ..strokeWidth = 30.0
      ..style = PaintingStyle.stroke;

    //Draw Body
    final paint = Paint()..color = Colors.yellow;

    for (var i = 0; i < faces.length; i++) {
      final radius =
          Math.min(faces[i].boundingBox.width, faces[i].boundingBox.height) / 2;
      final center = faces[i].boundingBox.center;
      final smilePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius / 8;
      canvas.drawRect(faces[i].boundingBox, paintRectStyle);
//      canvas.drawCircle(center, radius, paint);
////      canvas.drawArc(
////          Rect.fromCircle(
////              center: center.translate(0, radius / 8), radius: radius / 2),
////          0,
////          Math.pi,
////          false,
////          smilePaint);
////      //Draw the eyes
////      canvas.drawCircle(Offset(center.dx - radius / 2, center.dy - radius / 2),
////          radius / 8, Paint());
////      canvas.drawCircle(Offset(center.dx + radius / 2, center.dy - radius / 2),
////          radius / 8, Paint());
    }
  }

  @override
  bool shouldRepaint(SmilePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}

class SmilePainterLiveCamera extends CustomPainter {
  final Size imageSize;
  final List<Face> faces;
  var _camera;
  var context;
var mk;
  SmilePainterLiveCamera(this.imageSize, this.faces, this._camera,this.context,this.mk);

  clickpicture() async{


    //await _initializeControllerFuture;
    // print("Path of dcim ------------------->"+await AlbumSaver.getDcimPath());
    // Construct the path where the image should be saved using the
    // pattern package.

    if(_camera!=null){
      if (_camera.value.isInitialized)


      if(!started){
        started=true;
        print('Picture Clicked?');
        await _camera.stopImageStream();
        Future.delayed(Duration(milliseconds: 200),() async{
          final path = p.join(
            // Store the picture in the temp directory.
            // Find the temp directory using the `path_provider` plugin.
            (await getTemporaryDirectory()).path,
            //  (await getApplicationDocumentsDirectory()).path,
            '${DateTime.now()}.png',
          );


          await _camera.takePicture(path);
          //await _camera.dispose();



          var takenImage = await Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) => new GrpAttControllerExample(image:File(path)),
            fullscreenDialog: true,)
          );

          print("Image Taken successfully");
          print("-------------------------------------------------------");
          print(takenImage);
          File imageFile=await File(path).writeAsBytes(takenImage);

          //Navigator.pop(context,imageFile);

          saveTimeInOutImagePickerGroupAttFaceCamera(mk,context,imageFile);
          //await _camera.stopImageStream();
         //await _camera.dispose();

       //   FaceDetectionFromLiveCameraState f = new FaceDetectionFromLiveCameraState(mk);

         // f.initializeCamera();
clickPictureCalled=false;

        });

      }

    //  _camera.startImageStream((CameraImage availableImage) {



      //});

     // print("Length of file"+File(path).lengthSync().toString());
      //print(result.lengthSync());
      //Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => TodayAttendance(),maintainState: false));


      // Attempt to take a picture and log where it's been saved.
      // Future.delayed(Duration(seconds: 1), () => stopimagestream());




    }


  }

  Future<bool> saveTimeInOutImagePickerGroupAttFaceCamera(MarkTime mk,context,imagei) async {

    try{
      //File imagei = null;
      var isNextDayAWorkingDay=0;
      var prefs=await SharedPreferences.getInstance();
      isNextDayAWorkingDay=prefs.getInt("isNextDayAWorkingDay")??0;

      imageCache.clear();
      if (globals.attImage == 1) {
/*
        imagei = await Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) => new FaceDetectionFromLiveCamera(),
          fullscreenDialog: true,)
        );
*/
//          ImageProperties properties =
//          await FlutterNativeImage.getImageProperties(imagei.path);
//          print("image cropped successfully");
//
//          int width = properties.width;
//          var offset = (properties.height - properties.width) / 2;
//
//          File croppedFile = await FlutterNativeImage.cropImage(
//              imagei.path, 0, offset.round(), width, width);
//
//          // _resizePhoto(imagei.toString());
//
//          imagei= croppedFile;




        if (imagei != null) {
          //print("---------------actionb   ----->"+mk.act);


          var currentTime=DateTime.now();
          int timeDifference=currentTime.difference(globals.timeWhenButtonPressed).inSeconds;
          print("--------------------------Time difference------>"+timeDifference.toString());
          if(timeDifference>120){
            return null;
          }

          List<int> imageBytes = await imagei.readAsBytes();
          String  PictureBase64 = base64.encode(imageBytes);

          /*
      final tempDir = await getTemporaryDirectory();
      String path = tempDir.path;
      int rand = new Math.Random().nextInt(10000);
      im.Image image1 = im.decodeImage(imagei.readAsBytesSync());
      imagei.deleteSync();
      im.Image smallerImage = im.copyResize(image1, 500); // choose the size here, it will maintain aspect ratio
      File compressedImage = new File('$path/img_$rand.jpg')..writeAsBytesSync(im.encodeJpg(smallerImage, quality: 50));
    */
          //// sending this base64image string +to rest api
          Dio dio = new Dio();
          String location = globals.globalstreamlocationaddr;
          //String deviceidmobile= prefs.getString("deviceid")??"";

          String lat = globals.assign_lat.toString();
          String long = globals.assign_long.toString();
          print("saveImageGrpAttFace?uid=" + mk.uid + "&location=" + location + "&aid=" +
              mk.aid + "&act=" + mk.act + "&shiftid=" + mk.shiftid + "&refid=" +
              mk.refid + "&latit=" + lat + "&longi=" + long);
          print("global Address: " + location);
          print("global lat" + lat);
          print("global long" + long);
          print(mk.uid + " " + location + " " + mk.aid + " " + mk.act + " " +
              mk.shiftid + " " + mk.refid + " " + lat + " " + long);
          FormData formData = new FormData.from({
            "uid": mk.uid,
            "location": location,
            "aid": mk.aid,
            "act": mk.act,
            "shiftid": mk.shiftid,
            "refid": mk.refid,
            "latit": lat,
            "longi": long,
            "file": new UploadFileInfo(imagei, "image.png"),
            "FakeLocationStatus" : mk.FakeLocationStatus,
            "platform":'android',
            "tempimagestatus":1,
            //"deviceidmobile":deviceidmobile,
            //"devicenamebrand":globals.devicenamebrand
          });
          print(formData);
          Response<String> response1 = await dio.post(
              globals.path + "saveImageGrpAttFace", data: formData);
          print("Response from save image:"+response1.toString());
          //Response<String> response1=await dio.post("https://ubiattendance.ubihrm.com/index.php/services/saveImage",data:formData);
          //Response<String> response1=await dio.post("http://192.168.0.200/ubiattendance/index.php/services/saveImage",data:formData);
          //Response<String> response1 = await dio.post("https://ubitech.ubihrm.com/services/saveImage", data: formData);
          imagei.deleteSync();
          imageCache.clear();
          // globals.cameraChannel.invokeMethod("cameraClosed");
          /*getTempImageDirectory();*/
          Map MarkAttMap = json.decode(response1.data);
          print("facerecog");

          print(MarkAttMap["status"].toString());
          if (MarkAttMap["status"] == 1 || MarkAttMap["status"] == 2) {
            globals.firstface=1;
            globals.PictureBase64Att = PictureBase64;
            //TempImage tempimage = new TempImage(null, int.parse(mk.uid),mk.act, MarkAttMap["insert_updateid"], PictureBase64, int.parse(mk.refid) , 'Attendance');
           // tempimage.save();
            startCameraAgain();
            return true;
          }
          else{
            startCameraAgain();
            return false;
        }
        }
        else {
          globals.globalCameraOpenedStatus=false;
          print("6");
          return false;
        }
      }else{

        var currentTime=DateTime.now();
        int timeDifference=currentTime.difference(globals.timeWhenButtonPressed).inSeconds;
        print("--------------------------Time difference------>"+timeDifference.toString());
        if(timeDifference>120){
          return null;
        }

        Dio dio = new Dio();
        String location = globals.globalstreamlocationaddr;
        String deviceidmobile= prefs.getString("deviceid")??"";
        String lat = globals.assign_lat.toString();
        String long = globals.assign_long.toString();
        print("saveImageGrpAttFace?uid=" + mk.uid + "&location=" + location + "&aid=" +
            mk.aid + "&act=" + mk.act + "&shiftid=" + mk.shiftid + "&refid=" +
            mk.refid + "&latit=" + lat + "&longi=" + long);
        print("global Address: " + location);
        print("global lat" + lat);
        print("global long" + long);
        print(mk.uid + " " + location + " " + mk.aid + " " + mk.act + " " +
            mk.shiftid + " " + mk.refid + " " + lat + " " + long);
        FormData formData = new FormData.from({
          "uid": mk.uid,
          "location": location,
          "aid": mk.aid,
          "act": mk.act,
          "shiftid": mk.shiftid,
          "refid": mk.refid,
          "latit": lat,
          "longi": long,
          "FakeLocationStatus":mk.FakeLocationStatus,
          "platform":'android',
          // "file": new UploadFileInfo(imagei, "image.png"),
        });
        print("5");
        Response<String> response1 = await dio.post(
            globals.path + "saveImageGrpAttFace", data: formData);
        print(response1.toString());
        //Response<String> response1=await dio.post("https://ubiattendance.ubihrm.com/index.php/services/saveImage",data:formData);
        //Response<String> response1=await dio.post("http://192.168.0.200/ubiattendance/index.php/services/saveImage",data:formData);
        //Response<String> response1 = await dio.post("https://ubitech.ubihrm.com/services/saveImage", data: formData);
        /*imagei.deleteSync();
        imageCache.clear();*/
        /*getTempImageDirectory();*/
        Map MarkAttMap = json.decode(response1.data);
        if(MarkAttMap["facerecog"]=='5'){
          globals.firstface=0;

        }
        print(MarkAttMap["status"].toString());
        if (MarkAttMap["status"] == 1 || MarkAttMap["status"] == 2)
          return true;
        else
          return false;
      }
    } catch (e) {
      print(e.toString());
      globals.globalCameraOpenedStatus=false;
      return false;
    }


  }




  var st=false;

  @override
  void paint(Canvas canvas, Size size) {
    final paintRectStyle = Paint()
      ..color = Colors.yellowAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final paint = Paint()..color = Colors.yellow;

    for (var i = 0; i < faces.length; i++) {
      //Scale rect to image size
      final rect = _scaleRect(
        rect: faces[i].boundingBox,
        imageSize: imageSize,
        widgetSize: size,
      );

      //Radius for smile circle
      final radius = Math.min(rect.width, rect.height) / 2;

      //Center of face rect
      final Offset center = rect.center;

      final smilePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius / 8;
     /*
      if(!clickPictureCalled)
        {
          clickPictureCalled=true;
          clickpicture();
        }
*/
      //Draw rect border
      //canvas.drawRect(rect, paintRectStyle);

      //Draw body
//      canvas.drawCircle(center, radius, paint);
//
//      //Draw mouth
//      canvas.drawArc(
//          Rect.fromCircle(
//              center: center.translate(0, radius / 8), radius: radius / 2),
//          0,
//          Math.pi,
//          false,
//          smilePaint);
//
//      //Draw the eyes
//      canvas.drawCircle(Offset(center.dx - radius / 2, center.dy - radius / 2),
//          radius / 8, Paint());
//      canvas.drawCircle(Offset(center.dx + radius / 2, center.dy - radius / 2),
//          radius / 8, Paint());
    }
  }

  @override
  bool shouldRepaint(SmilePainterLiveCamera oldDelegate) {
    return imageSize != oldDelegate.imageSize || faces != oldDelegate.faces;
  }

  void startCameraAgain() {
    started=false;
    FaceDetectionFromLiveCameraState f = new FaceDetectionFromLiveCameraState(mk);

    f.reInitialize();
    //_camera.startCamera()


  }
}

Rect _scaleRect({
  @required Rect rect,
  @required Size imageSize,
  @required Size widgetSize,
}) {
  final double scaleX = widgetSize.width / imageSize.width;
  final double scaleY = widgetSize.height / imageSize.height;

  return Rect.fromLTRB(
    rect.left.toDouble() * scaleX,
    rect.top.toDouble() * scaleY,
    rect.right.toDouble() * scaleX,
    rect.bottom.toDouble() * scaleY,
  );
}
