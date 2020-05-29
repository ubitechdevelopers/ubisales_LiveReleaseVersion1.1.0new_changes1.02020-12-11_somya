import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class BlocCamera {
  var cameras = BehaviorSubject<List<CameraDescription>>();
  var selectCamera = BehaviorSubject<bool>();
  var imagePath = BehaviorSubject<File>();
  var cameraOn = BehaviorSubject<int>();

  CameraController controllCamera;

  Future getCameras() async {
    await availableCameras().then((lista) {
      cameras.sink.add(lista);
    }).catchError((e) {
      print("ERROR CAMERA: $e");
    });
  }

  Future<String> takePicture() async {
    if (!controllCamera.value.isInitialized) {
      print("selecionado camera");
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controllCamera.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controllCamera.takePicture(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return filePath;
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void onTakePictureButtonPressed()  async{
    takePicture().then((String filePath) async{
      imagePath.sink.add(File(filePath));
      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(filePath);
      print("image cropped successfully");

      int width = properties.width;
      var offset = (properties.height - properties.width) / 2;

      File croppedFile = await FlutterNativeImage.cropImage(
          filePath, 0, offset.round(), width, width);

      // _resizePhoto(imagei.toString());

      imagePath.sink.add(croppedFile);
    });
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    selectCamera.sink.add(null);
    if (controllCamera != null) {
      await controllCamera.dispose();
    }
    controllCamera =
        CameraController(cameraDescription, ResolutionPreset.medium);


    controllCamera.addListener(() {
      if (controllCamera.value.hasError) selectCamera.sink.add(false);
    });

    await controllCamera.initialize().then((value) {
      selectCamera.sink.add(true);
    }).catchError((e) {
      print(e);
    });
  }

  void changeCamera() {
    var list = cameras.value;
    if (list.length == 2) {
      if (controllCamera.description.lensDirection ==
          CameraLensDirection.back) {
        onNewCameraSelected(list[1]);
        cameraOn.sink.add(1);
      } else {
        onNewCameraSelected(list[0]);
        cameraOn.sink.add(0);
      }
    }
  }

  void deletePhoto() {
    var dir = new Directory(imagePath.value.path);
    dir.deleteSync(recursive: true);
    imagePath.sink.add(null);
  }

  void dispose() {
    cameras.close();
    controllCamera.dispose();
    selectCamera.close();
    imagePath.close();
    cameraOn.close();
  }

  /* Future<Null> cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
      toolbarTitle: "Editar",
      toolbarColor: Colors.black,
      
      sourcePath: imagePath.value.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (croppedFile != null) imagePath.sink.add(croppedFile);
  }*/
}
