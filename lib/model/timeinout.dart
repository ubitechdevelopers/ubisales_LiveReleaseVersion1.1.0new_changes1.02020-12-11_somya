class MarkTime{

  String uid;
  String location;
  String aid;
  String act;
  String shiftid;
  String refid;
  String latit;
  String longi;
  int FakeLocationStatus;

  MarkTime(this.uid, this.location, this.aid, this.act, this.shiftid, this.refid, this.latit, this.longi,this.FakeLocationStatus);

  MarkTime.fromMap(Map map){
    uid = map[uid];
    location = map[location];
    aid = map[aid];
    act = map[act];
    shiftid = map[shiftid];
    refid = map[refid];
    latit = map[latit];
    longi = map[longi];
    FakeLocationStatus= map[FakeLocationStatus];
  }
  MarkTime.fromJson(Map map){
    uid = map[uid];
    location = map[location];
    aid = map[aid];
    act = map[act];
    shiftid = map[shiftid];
    refid = map[refid];
    latit = map[latit];
    longi = map[longi];
    FakeLocationStatus=map[FakeLocationStatus];
  }


}

class MarkVisit{

  String uid;
  String cid;
  String location;
  String refid;
  String latit;
  String longi;
  int FakeLocationStatus;

  MarkVisit(this.uid,this.cid, this.location, this.refid, this.latit, this.longi,this.FakeLocationStatus);

  MarkVisit.fromMap(Map map){
    uid = map[uid];
    cid = map[cid];
    location = map[location];
    refid = map[refid];
    latit = map[latit];
    longi = map[longi];
    FakeLocationStatus= map[FakeLocationStatus];
  }
  MarkVisit.fromJson(Map map){
    uid = map[uid];
    cid = map[cid];
    location = map[location];
    refid = map[refid];
    latit = map[latit];
    longi = map[longi];
    FakeLocationStatus=map[FakeLocationStatus];
  }


}