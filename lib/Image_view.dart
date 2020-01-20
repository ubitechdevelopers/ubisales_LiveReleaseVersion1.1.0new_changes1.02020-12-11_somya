
// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';

import 'globals.dart';

// This app is a stateful, it tracks the user's current choice.
void main() => runApp(new ImageView());

class ImageView extends StatefulWidget {
  String myimage;
  final String org_name;
   String img=null;
  ImageView({this.myimage,this.org_name});
  ImageView.fromImage(this.img,this.org_name);
  @override
  _ImageView createState() => _ImageView();

}


class _ImageView extends State<ImageView> {
  @override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
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
        backgroundColor: appcolor,
      ),
      body: Center(
        child:

        (widget.img==null||widget.img=='')?
        Container(
          height: 300,
            child: PhotoView(

              imageProvider: NetworkImage(widget.myimage,),

            )
        )

        :
    Container(
    color: Colors.black,
    child:
         Image.memory(base64Decode(widget.img),
                  fit: BoxFit.fill,))




    ),
  ));
}

}
