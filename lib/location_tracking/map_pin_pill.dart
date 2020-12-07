import 'package:flutter/material.dart';

import 'pin_pill_info.dart';

class MapPinPillComponent extends StatefulWidget {

  double pinPillPosition;
  PinInformation currentlySelectedPin;

  MapPinPillComponent({ this.pinPillPosition, this.currentlySelectedPin});

  @override
  State<StatefulWidget> createState() => MapPinPillComponentState();
}

class MapPinPillComponentState extends State<MapPinPillComponent> {

  @override
  Widget build(BuildContext context) {

    return AnimatedPositioned(
        bottom: widget.pinPillPosition,
        right: 0,
        left: 0,
        duration: Duration(milliseconds: 200),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(20),
              height: 370,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50)),
                boxShadow: <BoxShadow>[
                  BoxShadow(blurRadius: 20, offset: Offset.zero, color: Colors.grey.withOpacity(0.5))
                ]
              ),
              child: Wrap(
                direction: Axis.vertical, //Vertical || Horizontal
                children: <Widget>[Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                
                children: <Widget>[
                  Container(
                    width: 200, height: 200,
                    margin: EdgeInsets.only(left: 50,right: 50,top: 20,bottom: 20),
                    child: ClipOval(child: Image.network(widget.currentlySelectedPin.avatarPath, fit: BoxFit.cover )),
                  ),

                          Text(widget.currentlySelectedPin.client, style: TextStyle(color: Colors.black,fontSize: 18)),
                          SizedBox(height: 10,),
                (widget.currentlySelectedPin.out_time!=null&&widget.currentlySelectedPin.out_time!='-')?

                  Text(widget.currentlySelectedPin.in_time+" - " + widget.currentlySelectedPin.out_time, style: TextStyle(color: Colors.black,fontSize: 14)):
                Text(widget.currentlySelectedPin.in_time, style: TextStyle(color: Colors.black,fontSize: 14)),
                          SizedBox(height: 10,),
                          Container(
                              width: 200,
                              child: Text(widget.currentlySelectedPin.description, style: TextStyle(fontSize: 12, color: Colors.grey,),textAlign: TextAlign.center,)),
                          //Text('Longitude: ${widget.currentlySelectedPin.location.longitude.toString()}', style: TextStyle(fontSize: 12, color: Colors.grey)),

                  /*
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Image.asset(widget.currentlySelectedPin.pinPath, width: 50, height: 50),
                  )*/
                ],
              ),])
            ),
          ),
        );
  }

}