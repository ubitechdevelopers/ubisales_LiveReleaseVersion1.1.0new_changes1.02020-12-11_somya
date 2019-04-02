
// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
/*import 'openCameraInActivity.dart';
import 'package:camera/camera.dart';*/
import 'package:connectivity/connectivity.dart';

// This app is a stateful, it tracks the user's current choice.
void main() => runApp(new ImageView());

class ImageView extends StatefulWidget {
  final String myimage;
  final String org_name;
  ImageView({this.myimage,this.org_name});
  @override
  _ImageView createState() => _ImageView();

}


class _ImageView extends State<ImageView> {
  @override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(widget.org_name, style: new TextStyle(fontSize: 20.0)),
          ],
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child:Container(
            child: PhotoView(
              imageProvider: NetworkImage(widget.myimage),
            )
        ),
      ),
    ),
  );
}

}
