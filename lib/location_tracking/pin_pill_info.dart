import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class PinInformation {
  String pinPath;
  String avatarPath;
  LatLng location;
  String client;
  String description;
  String in_time;
  String out_time;

  Color labelColor;

  PinInformation({this.pinPath, this.avatarPath, this.location, this.client, this.description,this.in_time,this.out_time, this.labelColor});
}
