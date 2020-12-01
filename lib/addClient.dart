import 'dart:convert';

import 'package:Shrine/clients.dart';
import 'package:Shrine/model/timeinout.dart';
import 'package:Shrine/offline_home.dart';
import 'package:Shrine/punchlocation.dart';
import 'package:Shrine/punchlocationOld.dart';
import 'package:Shrine/punchlocation_summaryOld.dart';
import 'package:Shrine/services/saveimage.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:http/http.dart' as http;
import 'package:native_contact_picker/native_contact_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart' as globals;
import 'globals.dart';
import 'services/services.dart';

class AddClient extends StatefulWidget {
  final String company;
  final String name;
  final String address;
  final String clientaddress;
  final String contcode;
  final String city;
  final String contact;
  final String email;
  final String desc;
  final String id;
  final String sts;
  AddClient({Key key, this.company, this.name, this.clientaddress, this.address, this.contcode, this.city, this.contact, this.email, this.desc, this.id, this.sts})
      : super(key: key);

  static final kInitialPosition = LatLng(globals.assign_lat, globals.assign_long);
  static final apiKey = "AIzaSyDYh77SKpI6kAD1jiILwbiISZEwEOyJLtM";

  @override
  _AddClientState createState() => new _AddClientState();
}

class _AddClientState extends State<AddClient> {
  static const platform = const MethodChannel('location.spoofing.check');
  final NativeContactPicker _contactPicker = new NativeContactPicker();
  Contact _contactpick;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final Geolocator geolocator = Geolocator()
    ..forceAndroidLocationManager;
  TextEditingController _name = new TextEditingController();
  TextEditingController _cname = new TextEditingController();
  TextEditingController _addr = new TextEditingController();
  TextEditingController _caddr = new TextEditingController();
  TextEditingController _contcode = new TextEditingController();
  TextEditingController _city = new TextEditingController();
  TextEditingController _phone = new TextEditingController();
  TextEditingController _email = new TextEditingController();
  TextEditingController _desc = new TextEditingController();

  final FocusNode __name = FocusNode();
  final FocusNode __cname = FocusNode();
  final FocusNode __addr = FocusNode();
  final FocusNode __caddr = FocusNode();
  final FocusNode __contcode = FocusNode();
  final FocusNode __city = FocusNode();
  final FocusNode __phone = FocusNode();
  final FocusNode __email = FocusNode();
  final FocusNode __desc = FocusNode();

  PickResult selectedPlace;
  Position _currentPosition;
  var phone = "";
  var pass = "";
  var clientId = "";
  String code;
  bool loader = false;
  String _orgName = "";
  String admin_sts = '0';
  var arr;
  var lat; //These are user to store latitude got from javacode throughout the app
  var long;
  String empid = "";
  String orgid = "";
  bool _isButtonDisabled = false;
  String finalClientId;
  var FakeLocationStatus=0;
  bool internetAvailable=true;
  String getaddress="";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SharedPreferences prefs;
  Map<String, dynamic>res;
  List<Map> _myJson = [
    { "ind": "0", "id": "2", "name": "Afghanistan", "countrycode": "+93"},
    { "ind": "1", "id": "4", "name": "Albania", "countrycode": "+355"},
    { "ind": "2", "id": "50", "name": "Algeria", "countrycode": "+213"},
    { "ind": "3", "id": "5", "name": "American Samoa", "countrycode": "+1"},
    { "ind": "4", "id": "6", "name": "Andorra", "countrycode": "+376"},
    { "ind": "5", "id": "7", "name": "Angola", "countrycode": "+244"},
    { "ind": "6", "id": "11", "name": "Anguilla", "countrycode": "+264"},
    {
      "ind": "7",
      "id": "3",
      "name": "Antigua and Barbuda",
      "countrycode": "+1"
    },
    { "ind": "8", "id": "160", "name": "Argentina", "countrycode": "+54"},
    { "ind": "9", "id": "8", "name": "Armenia", "countrycode": "+374"},
    { "ind": "10", "id": "9", "name": "Aruba", "countrycode": "+297"},
    { "ind": "11", "id": "10", "name": "Australia", "countrycode": "+61"},
    { "ind": "12", "id": "1", "name": "Austria", "countrycode": "+43"},
    { "ind": "13", "id": "12", "name": "Azerbaijan", "countrycode": "+994"},
    { "ind": "14", "id": "27", "name": "Bahamas", "countrycode": "+242"},
    { "ind": "15", "id": "25", "name": "Bahrain", "countrycode": "+973"},
    { "ind": "16", "id": "14", "name": "Bangladesh", "countrycode": "+880"},
    { "ind": "17", "id": "15", "name": "Barbados", "countrycode": "+246"},
    { "ind": "18", "id": "29", "name": "Belarus", "countrycode": "+375"},
    { "ind": "19", "id": "13", "name": "Belgium", "countrycode": "+32"},
    { "ind": "20", "id": "30", "name": "Belize", "countrycode": "+501"},
    { "ind": "21", "id": "16", "name": "Benin", "countrycode": "+229"},
    { "ind": "22", "id": "17", "name": "Bermuda", "countrycode": "+441"},
    { "ind": "23", "id": "20", "name": "Bhutan", "countrycode": "+975"},
    { "ind": "24", "id": "23", "name": "Bolivia", "countrycode": "+591"},
    {
      "ind": "25",
      "id": "22",
      "name": "Bosnia and Herzegovina",
      "countrycode": "+387"
    },
    { "ind": "26", "id": "161", "name": "Botswana", "countrycode": "+267"},
    { "ind": "27", "id": "24", "name": "Brazil", "countrycode": "+55"},
    {
      "ind": "28",
      "id": "28",
      "name": "British Virgin Islands",
      "countrycode": "+284"
    },
    { "ind": "29", "id": "26", "name": "Brunei", "countrycode": "+673"},
    { "ind": "30", "id": "19", "name": "Bulgaria", "countrycode": "+359"},
    { "ind": "31", "id": "18", "name": "Burkina Faso", "countrycode": "+226"},
    { "ind": "32", "id": "21", "name": "Burundi", "countrycode": "+257"},
    { "ind": "33", "id": "101", "name": "Cambodia", "countrycode": "+855"},
    { "ind": "34", "id": "32", "name": "Cameroon", "countrycode": "+237"},
    { "ind": "35", "id": "34", "name": "Canada", "countrycode": "+1"},
    { "ind": "36", "id": "43", "name": "Cape Verde", "countrycode": "+238"},
    { "ind": "37", "id": "33", "name": "Cayman Islands", "countrycode": "+345"},
    {
      "ind": "38",
      "id": "163",
      "name": "Central African Republic",
      "countrycode": "+236"
    },
    { "ind": "39", "id": "203", "name": "Chad", "countrycode": "+235"},
    { "ind": "40", "id": "165", "name": "Chile", "countrycode": "+56"},
    { "ind": "41", "id": "205", "name": "China", "countrycode": "+86"},
    {
      "ind": "42",
      "id": "233",
      "name": "Christmas Island",
      "countrycode": "+61"
    },
    { "ind": "43", "id": "39", "name": "Cocos Islands", "countrycode": "+891"},
    { "ind": "44", "id": "38", "name": "Colombia", "countrycode": "+57"},
    { "ind": "45", "id": "40", "name": "Comoros", "countrycode": "+269"},
    { "ind": "46", "id": "41", "name": "Cook Islands", "countrycode": "+682"},
    { "ind": "47", "id": "42", "name": "Costa Rica", "countrycode": "+506"},
    { "ind": "48", "id": "36", "name": "Cote dIvoire", "countrycode": "+225"},
    { "ind": "49", "id": "90", "name": "Croatia", "countrycode": "+385"},
    { "ind": "50", "id": "31", "name": "Cuba", "countrycode": "+53"},
    { "ind": "51", "id": "44", "name": "Cyprus", "countrycode": "+357"},
    { "ind": "52", "id": "45", "name": "Czech Republic", "countrycode": "+420"},
    { "ind": "53", "id": "48", "name": "Denmark", "countrycode": "+45"},
    { "ind": "54", "id": "47", "name": "Djibouti", "countrycode": "+253"},
    { "ind": "55", "id": "226", "name": "Dominica", "countrycode": "+767"},
    {
      "ind": "56",
      "id": "49",
      "name": "Dominican Republic",
      "countrycode": "+1"
    },
    { "ind": "57", "id": "55", "name": "Ecuador", "countrycode": "+593"},
    { "ind": "58", "id": "58", "name": "Egypt", "countrycode": "+20"},
    { "ind": "59", "id": "57", "name": "El Salvador", "countrycode": "+503"},
    {
      "ind": "60",
      "id": "80",
      "name": "Equatorial Guinea",
      "countrycode": "+240"
    },
    { "ind": "60", "id": "56", "name": "Eritrea", "countrycode": "+291"},
    { "ind": "62", "id": "60", "name": "Estonia", "countrycode": "+372"},
    { "ind": "63", "id": "59", "name": "Ethiopia", "countrycode": "+251"},
    {
      "ind": "64",
      "id": "62",
      "name": "Falkland Islands",
      "countrycode": "+500"
    },
    { "ind": "65", "id": "63", "name": "Faroe Islands", "countrycode": "+298"},
    { "ind": "66", "id": "65", "name": "Fiji", "countrycode": "+679"},
    { "ind": "67", "id": "186", "name": "Finland", "countrycode": "+358"},
    { "ind": "68", "id": "61", "name": "France", "countrycode": "+33"},
    { "ind": "69", "id": "64", "name": "French Guiana", "countrycode": "+594"},
    {
      "ind": "70",
      "id": "67",
      "name": "French Polynesia",
      "countrycode": "+689"
    },
    { "ind": "71", "id": "69", "name": "Gabon", "countrycode": "+241"},
    { "ind": "72", "id": "223", "name": "Gambia", "countrycode": "+220"},
    { "ind": "73", "id": "70", "name": "Gaza Strip", "countrycode": "+970"},
    { "ind": "74", "id": "77", "name": "Georgia", "countrycode": "+995"},
    { "ind": "75", "id": "46", "name": "Germany", "countrycode": "+49"},
    { "ind": "76", "id": "78", "name": "Ghana", "countrycode": "+233"},
    { "ind": "77", "id": "75", "name": "Gibraltar", "countrycode": "+350"},
    { "ind": "78", "id": "81", "name": "Greece", "countrycode": "+30"},
    { "ind": "79", "id": "82", "name": "Greenland", "countrycode": "+299"},
    { "ind": "80", "id": "228", "name": "Grenada", "countrycode": "+473"},
    { "ind": "81", "id": "83", "name": "Guadeloupe", "countrycode": "+590"},
    { "ind": "82", "id": "84", "name": "Guam", "countrycode": "+1"},
    { "ind": "83", "id": "76", "name": "Guatemala", "countrycode": "+502"},
    { "ind": "84", "id": "72", "name": "Guernsey", "countrycode": "+44"},
    { "ind": "85", "id": "167", "name": "Guinea", "countrycode": "+224"},
    { "ind": "86", "id": "79", "name": "Guinea-Bissau", "countrycode": "+245"},
    { "ind": "87", "id": "85", "name": "Guyana", "countrycode": "+592"},
    { "ind": "88", "id": "168", "name": "Haiti", "countrycode": "+509"},
    { "ind": "89", "id": "218", "name": "Holy See", "countrycode": "+379"},
    { "ind": "90", "id": "87", "name": "Honduras", "countrycode": "+504"},
    { "ind": "91", "id": "89", "name": "Hong Kong", "countrycode": "+852"},
    { "ind": "92", "id": "86", "name": "Hungary", "countrycode": "+36"},
    { "ind": "93", "id": "97", "name": "Iceland", "countrycode": "+354"},
    { "ind": "94", "id": "93", "name": "India", "countrycode": "+91"},
    { "ind": "95", "id": "169", "name": "Indonesia", "countrycode": "+62"},
    { "ind": "96", "id": "94", "name": "Iran", "countrycode": "+98"},
    { "ind": "97", "id": "96", "name": "Iraq", "countrycode": "+964"},
    { "ind": "98", "id": "95", "name": "Ireland", "countrycode": "+353"},
    { "ind": "99", "id": "74", "name": "Isle of Man", "countrycode": "+44"},
    { "ind": "100", "id": "92", "name": "Israel", "countrycode": "+972"},
    { "ind": "101", "id": "91", "name": "Italy", "countrycode": "+39"},
    { "ind": "102", "id": "99", "name": "Jamaica", "countrycode": "+876"},
    { "ind": "103", "id": "98", "name": "Japan", "countrycode": "+81"},
    { "ind": "104", "id": "73", "name": "Jersey", "countrycode": "+44"},
    { "ind": "105", "id": "100", "name": "Jordan", "countrycode": "+962"},
    { "ind": "106", "id": "102", "name": "Kazakhstan", "countrycode": "+7"},
    { "ind": "107", "id": "52", "name": "Kenya", "countrycode": "+254"},
    { "ind": "108", "id": "104", "name": "Kiribati", "countrycode": "+686"},
    { "ind": "109", "id": "106", "name": "Kosovo", "countrycode": "+383"},
    { "ind": "110", "id": "107", "name": "Kuwait", "countrycode": "+965"},
    { "ind": "111", "id": "103", "name": "Kyrgyzstan", "countrycode": "+996"},
    { "ind": "112", "id": "109", "name": "Laos", "countrycode": "+856"},
    { "ind": "113", "id": "114", "name": "Latvia", "countrycode": "+371"},
    { "ind": "114", "id": "171", "name": "Lebanon", "countrycode": "+961"},
    { "ind": "115", "id": "112", "name": "Lesotho", "countrycode": "+266"},
    { "ind": "116", "id": "111", "name": "Liberia", "countrycode": "+231"},
    { "ind": "117", "id": "110", "name": "Libya", "countrycode": "+218"},
    { "ind": "118", "id": "66", "name": "Liechtenstein", "countrycode": "+423"},
    { "ind": "119", "id": "113", "name": "Lithuania", "countrycode": "+370"},
    { "ind": "120", "id": "108", "name": "Luxembourg", "countrycode": "+352"},
    { "ind": "121", "id": "117", "name": "Macau", "countrycode": "+853"},
    { "ind": "122", "id": "125", "name": "Macedonia", "countrycode": "+389"},
    { "ind": "123", "id": "172", "name": "Madagascar", "countrycode": "+261"},
    { "ind": "124", "id": "132", "name": "Malawi", "countrycode": "+265"},
    { "ind": "125", "id": "118", "name": "Malaysia", "countrycode": "+60"},
    { "ind": "126", "id": "131", "name": "Maldives", "countrycode": "+960"},
    { "ind": "127", "id": "173", "name": "Mali", "countrycode": "+223"},
    { "ind": "128", "id": "115", "name": "Malta", "countrycode": "+356"},
    {
      "ind": "129",
      "id": "124",
      "name": "Marshall Islands",
      "countrycode": "+692"
    },
    { "ind": "130", "id": "119", "name": "Martinique", "countrycode": "+596"},
    { "ind": "131", "id": "170", "name": "Mauritania", "countrycode": "+222"},
    { "ind": "132", "id": "130", "name": "Mauritius", "countrycode": "+230"},
    { "ind": "133", "id": "120", "name": "Mayotte", "countrycode": "+262"},
    { "ind": "134", "id": "123", "name": "Mexico", "countrycode": "+52"},
    { "ind": "135", "id": "68", "name": "Micronesia", "countrycode": "+691"},
    { "ind": "136", "id": "122", "name": "Moldova", "countrycode": "+373"},
    { "ind": "137", "id": "121", "name": "Monaco", "countrycode": "+377"},
    { "ind": "138", "id": "127", "name": "Mongolia", "countrycode": "+976"},
    { "ind": "139", "id": "126", "name": "Montenegro", "countrycode": "+382"},
    { "ind": "140", "id": "128", "name": "Montserrat", "countrycode": "+664"},
    { "ind": "141", "id": "116", "name": "Morocco", "countrycode": "+212"},
    { "ind": "142", "id": "129", "name": "Mozambique", "countrycode": "+258"},
    { "ind": "143", "id": "133", "name": "Myanmar", "countrycode": "+95"},
    { "ind": "144", "id": "136", "name": "Namibia", "countrycode": "+264"},
    { "ind": "145", "id": "137", "name": "Nauru", "countrycode": "+674"},
    { "ind": "146", "id": "139", "name": "Nepal", "countrycode": "+977"},
    { "ind": "147", "id": "142", "name": "Netherlands", "countrycode": "+31"},
    {
      "ind": "148",
      "id": "135",
      "name": "Netherlands Antilles",
      "countrycode": "+599"
    },
    {
      "ind": "149",
      "id": "138",
      "name": "New Caledonia",
      "countrycode": "+687"
    },
    { "ind": "150", "id": "146", "name": "New Zealand", "countrycode": "+64"},
    { "ind": "151", "id": "140", "name": "Nicaragua", "countrycode": "+505"},
    { "ind": "152", "id": "174", "name": "Niger", "countrycode": "+227"},
    { "ind": "153", "id": "225", "name": "Nigeria", "countrycode": "+234"},
    { "ind": "154", "id": "141", "name": "Niue", "countrycode": "+683"},
    { "ind": "155", "id": "144", "name": "North Korea", "countrycode": "+850"},
    {
      "ind": "156",
      "id": "143",
      "name": "Northern Mariana Islands",
      "countrycode": "+1"
    },
    { "ind": "157", "id": "134", "name": "Norway", "countrycode": "+47"},
    { "ind": "158", "id": "147", "name": "Oman", "countrycode": "+968"},
    { "ind": "159", "id": "153", "name": "Pakistan", "countrycode": "+92"},
    { "ind": "160", "id": "150", "name": "Palau", "countrycode": "+680"},
    { "ind": "161", "id": "149", "name": "Panama", "countrycode": "+507"},
    {
      "ind": "162",
      "id": "155",
      "name": "Papua New Guinea",
      "countrycode": "+675"
    },
    { "ind": "163", "id": "157", "name": "Paraguay", "countrycode": "+595"},
    { "ind": "164", "id": "151", "name": "Peru", "countrycode": "+51"},
    { "ind": "165", "id": "178", "name": "Philippines", "countrycode": "+63"},
    {
      "ind": "166",
      "id": "152",
      "name": "Pitcairn Islands",
      "countrycode": "+64"
    },
    { "ind": "167", "id": "154", "name": "Poland", "countrycode": "+48"},
    { "ind": "168", "id": "148", "name": "Portugal", "countrycode": "+351"},
    { "ind": "169", "id": "156", "name": "Puerto Rico", "countrycode": "+1"},
    { "ind": "170", "id": "158", "name": "Qatar", "countrycode": "+974"},
    {
      "ind": "171",
      "id": "164",
      "name": "Republic of the Congo",
      "countrycode": "+243"
    },
    { "ind": "172", "id": "166", "name": "Reunion", "countrycode": "+262"},
    { "ind": "173", "id": "175", "name": "Romania", "countrycode": "+40"},
    { "ind": "174", "id": "159", "name": "Russia", "countrycode": "+7"},
    { "ind": "175", "id": "182", "name": "Rwanda", "countrycode": "+250"},
    { "ind": "176", "id": "88", "name": "Saint Helena", "countrycode": "+290"},
    {
      "ind": "177",
      "id": "105",
      "name": "Saint Kitts and Nevis",
      "countrycode": "+869"
    },
    { "ind": "178", "id": "229", "name": "Saint Lucia", "countrycode": "+758"},
    { "ind": "179", "id": "191", "name": "Saint Martin", "countrycode": "+1"},
    {
      "ind": "180",
      "id": "195",
      "name": "Saint Pierre and Miquelon",
      "countrycode": "+508"
    },
    {
      "ind": "181",
      "id": "232",
      "name": "Saint Vincent and the Grenadines",
      "countrycode": "+784"
    },
    { "ind": "182", "id": "230", "name": "Samoa", "countrycode": "+685"},
    { "ind": "183", "id": "180", "name": "San Marino", "countrycode": "+378"},
    {
      "ind": "184",
      "id": "197",
      "name": "Sao Tome and Principe",
      "countrycode": "+239"
    },
    { "ind": "185", "id": "184", "name": "Saudi Arabia", "countrycode": "+966"},
    { "ind": "186", "id": "193", "name": "Senegal", "countrycode": "+221"},
    { "ind": "187", "id": "196", "name": "Serbia", "countrycode": "+381"},
    { "ind": "188", "id": "200", "name": "Seychelles", "countrycode": "+248"},
    { "ind": "189", "id": "224", "name": "Sierra Leone", "countrycode": "+232"},
    { "ind": "190", "id": "187", "name": "Singapore", "countrycode": "+65"},
    { "ind": "191", "id": "188", "name": "Slovakia", "countrycode": "+421"},
    { "ind": "192", "id": "190", "name": "Slovenia", "countrycode": "+386"},
    {
      "ind": "193",
      "id": "189",
      "name": "Solomon Islands",
      "countrycode": "+677"
    },
    { "ind": "194", "id": "194", "name": "Somalia", "countrycode": "+252"},
    { "ind": "195", "id": "179", "name": "South Africa", "countrycode": "+27"},
    { "ind": "196", "id": "176", "name": "South Korea", "countrycode": "+82"},
    { "ind": "197", "id": "51", "name": "Spain", "countrycode": "+34"},
    { "ind": "198", "id": "37", "name": "Sri Lanka", "countrycode": "+94"},
    { "ind": "299", "id": "198", "name": "Sudan", "countrycode": "+249"},
    { "ind": "200", "id": "192", "name": "Suriname", "countrycode": "+597"},
    { "ind": "201", "id": "199", "name": "Svalbard", "countrycode": "+47"},
    { "ind": "202", "id": "185", "name": "Swaziland", "countrycode": "+268"},
    { "ind": "203", "id": "183", "name": "Sweden", "countrycode": "+46"},
    { "ind": "204", "id": "35", "name": "Switzerland", "countrycode": "+41"},
    { "ind": "205", "id": "201", "name": "Syria", "countrycode": "+963"},
    { "ind": "206", "id": "162", "name": "Taiwan", "countrycode": "+886"},
    { "ind": "207", "id": "202", "name": "Tajikistan", "countrycode": "+992"},
    { "ind": "208", "id": "53", "name": "Tanzania", "countrycode": "+255"},
    { "ind": "209", "id": "204", "name": "Thailand", "countrycode": "+66"},
    { "ind": "210", "id": "206", "name": "Timor-Leste", "countrycode": "+670"},
    { "ind": "211", "id": "181", "name": "Togo", "countrycode": "+228"},
    { "ind": "212", "id": "209", "name": "Tonga", "countrycode": "+676"},
    {
      "ind": "213",
      "id": "211",
      "name": "Trinidad and Tobago",
      "countrycode": "+868"
    },
    { "ind": "214", "id": "208", "name": "Tunisia", "countrycode": "+216"},
    { "ind": "215", "id": "210", "name": "Turkey", "countrycode": "+90"},
    { "ind": "216", "id": "207", "name": "Turkmenistan", "countrycode": "+993"},
    {
      "ind": "217",
      "id": "212",
      "name": "Turks and Caicos Islands",
      "countrycode": "+1"
    },
    { "ind": "218", "id": "213", "name": "Tuvalu", "countrycode": "+688"},
    {
      "ind": "219",
      "id": "219",
      "name": "U.S. Virgin Islands",
      "countrycode": "+1"
    },
    { "ind": "220", "id": "54", "name": "Uganda", "countrycode": "+256"},
    { "ind": "221", "id": "214", "name": "Ukraine", "countrycode": "+380"},
    {
      "ind": "222",
      "id": "215",
      "name": "United Arab Emirates",
      "countrycode": "+971"
    },
    { "ind": "223", "id": "71", "name": "United Kingdom", "countrycode": "+44"},
    { "ind": "224", "id": "216", "name": "United States", "countrycode": "+1"},
    { "ind": "225", "id": "177", "name": "Uruguay", "countrycode": "+598"},
    { "ind": "226", "id": "217", "name": "Uzbekistan", "countrycode": "+998"},
    { "ind": "227", "id": "221", "name": "Vanuatu", "countrycode": "+678"},
    { "ind": "228", "id": "235", "name": "Venezuela", "countrycode": "+58"},
    { "ind": "229", "id": "220", "name": "Vietnam", "countrycode": "+84"},
    {
      "ind": "230",
      "id": "222",
      "name": "Wallis and Futuna",
      "countrycode": "+681"
    },
    { "ind": "231", "id": "227", "name": "West Bank", "countrycode": "+970"},
    {
      "ind": "232",
      "id": "231",
      "name": "Western Sahara",
      "countrycode": "+212"
    },
    { "ind": "233", "id": "234", "name": "Yemen", "countrycode": "+967"},
    { "ind": "234", "id": "237", "name": "Zaire", "countrycode": "+243"},
    { "ind": "235", "id": "236", "name": "Zambia", "countrycode": "+260"},
    { "ind": "236", "id": "238", "name": "Zimbabwe", "countrycode": "+263"}
  ];

  String _country;
  bool _obscureText = true;
  String _tempcontry = '';

  @override
  void initState() {
    //_getCurrentLocation();
    _name = new TextEditingController();
    _cname = new TextEditingController();
    _email = new TextEditingController();
    _phone = new TextEditingController();
    _desc = new TextEditingController();
    _contcode = new TextEditingController();
    _city = new TextEditingController();
    _addr = new TextEditingController();
    super.initState();
    getOrgName();
    initPlatformState();
    platform.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "navigateToPage":
        navigateToPageAfterNotificationClicked(call.arguments["page"].toString(),context);
        break;
      case "locationAndInternet":
        locationThreadUpdatedLocation=true;
        if(call.arguments["TimeSpoofed"].toString()=="Yes"){
          timeSpoofed=true;
        }
        if(call.arguments["internet"].toString()=="Internet Not Available") {
          internetAvailable=false;
          Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => OfflineHomePage()));
        }
        long=call.arguments["longitude"].toString();
        lat=call.arguments["latitude"].toString();
        assign_lat=double.parse(lat);
        assign_long=double.parse(long);
        getaddress=await getAddressFromLati(lat, long);
        globalstreamlocationaddr=getaddress;
        print(call.arguments["mocked"].toString());

        setState(() {
          if(call.arguments["mocked"].toString()=="Yes"){
            fakeLocationDetected=true;
          } else{
            fakeLocationDetected=false;
          }

        });
        break;
    }
  }

  initPlatformState() async {
    final prefs = await SharedPreferences.getInstance();
    empid = prefs.getString('empid') ?? '';
    orgid = prefs.getString('orgdir') ?? '';

    _cname.text = widget.company;
    _name.text = widget.name;
    _addr.text = widget.address;
    _caddr.text = widget.clientaddress;
    _contcode.text = "+" + widget.contcode;
    _city.text = widget.city;
    _phone.text = widget.contact;
    _email.text = widget.email;
    _desc.text = widget.desc;
    clientId = widget.id;
    if (widget.sts == '1')
      SearchCountry2(_contcode.text);
  }

  getOrgName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName = prefs.getString('org_name') ?? '';
      admin_sts = prefs.getString('sstatus') ?? '0';
    });
  }

  SearchCountry(String country) {
    for (int i = 0; i < _myJson.length; i++) {
      if (country == _myJson[i]["name"]) {
        code = _myJson[i]["ind"];
        _contcode.text = _myJson[i]['countrycode'];
        _tempcontry = _myJson[i]['id'];
      }
    }
  }

  SearchCountry2(String contcode) {
    print("Shaifali----------------->>>>>>>>");
    for (int i = 0; i < _myJson.length; i++) {
      print("Paragati Mam");
      if (contcode == _myJson[i]["countrycode"]) {
        code = _myJson[i]["ind"];
        print("code");
        print(code);
        _contcode.text = _myJson[i]['countrycode'];
        print("_contcode.text");
        print(_contcode.text);
        _tempcontry = _myJson[i]['id'];
        print("_tempcontry");
        print(_tempcontry);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(_orgName, style: new TextStyle(fontSize: 20.0)),
            //new Text(AppTranslations.of(context).text("key_app_title"), style: new TextStyle(fontSize: 20.0)),
          ],
        ),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
          widget.sts == "2" ? Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PunchLocation()),
          ) : Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClientList()),
          );
        },),
        backgroundColor: appcolor,
      ),
      bottomNavigationBar: Container(
        height: 60.0,
        decoration: new BoxDecoration(
            color: Colors.white,
            boxShadow: [new BoxShadow(
              color: Colors.black12,
              blurRadius: 3.0,
            ),
            ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 1,),
                    ),
                    child: Text('CANCEL'),
                    onPressed: () {
                      widget.sts == "2" ? Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PunchLocation()),
                      ) : Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ClientList()),
                      );
                    },
                  ),

                  SizedBox(width: 10.0),
                  new Container(
                      child: widget.sts == "0" ? new RaisedButton(
                        elevation: 2.0,
                        highlightElevation: 5.0,
                        highlightColor: Colors.transparent,
                        disabledElevation: 0.0,
                        focusColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        color: buttoncolor,
                        child: (_isButtonDisabled) ? Text('WAIT...') : Text(
                          'ADD', style: TextStyle(color: Colors.white),),
                        onPressed: () async {
                          if (_isButtonDisabled)
                            return null;
                          if (_name.text == '') {
                            // ignore: deprecated_member_use
                            // FocusScope.of(context).requestFocus(__name);
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text(
                                  "Please enter the Company's name"),
                              //content: new Text(AppTranslations.of(context).text("key_enter_company_name")),
                            ));
                            return null;
                          } else if (_cname.text == '') {
                            // ignore: deprecated_member_use
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text(
                                  "Please enter the Contact Person's name"),
                              //content: new Text(AppTranslations.of(context).text("key_enter_contact_person_name")),
                            ));
                            //FocusScope.of(context).requestFocus(__cname);
                            return null;
                          } else if (_addr.text == '') {
                            // ignore: deprecated_member_use
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text(
                                  "Please enter or pick the address"),
                              //content: new Text(AppTranslations.of(context).text("key_enter_contact_person_name")),
                            ));
                            //FocusScope.of(context).requestFocus(__cname);
                            return null;
                          } else if (!(validateEmail(_email.text))) {
                            //print((validateEmail(_email.text)).toString());

                            // ignore: deprecated_member_use
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text("Please enter the Email ID"),
                              //content: new Text(AppTranslations.of(context).text("key_please_enter_email")),
                            ));
                            // FocusScope.of(context).requestFocus(__email);
                            return null;
                          } else if (_desc.text.length == "") {
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text("Please enter the Description"),
                              //content: new Text(AppTranslations.of(context).text("key_must_be_at_least_6_characters")),
                            ));
                            // FocusScope.of(context).requestFocus(__pass);
                            return null;
                          } else if (_tempcontry == '') {
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text("Please Select a Country."),
                              //content: new Text(AppTranslations.of(context).text("key_select_country")),
                            ));
                            // FocusScope.of(context).requestFocus(__phone);
                            return null;
                          } else if (_phone.text.length < 6) {
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text(
                                  "Please enter a valid Phone No."),
                              //content: new Text(AppTranslations.of(context).text("key_please_enter_valid_phone")),
                            ));
                            // FocusScope.of(context).requestFocus(__phone);
                            return null;
                          } else {
                            setState(() {
                              _isButtonDisabled = true;
                            });

                            print(globals.path +
                                "addClient?empid=$empid&orgid=$orgid&comp_name=${_cname
                                    .text}&name=${_name.text}&address=${_addr
                                    .text}&country=${_tempcontry}&city=${_city
                                    .text}&countrycode=${_contcode
                                    .text}&phone=${_phone.text}&email=${_email
                                    .text}&description=${_desc
                                    .text}&status=1&platform=android");
                            var url = globals.path + "addClient";
                            http.post(url, body: {
                              "empid": empid,
                              "orgid": orgid,
                              "comp_name": _cname.text,
                              "name": _name.text,
                              "address": _addr.text,
                              "country": _tempcontry,
                              "city": _city.text,
                              "countrycode": _contcode.text,
                              "phone": _phone.text,
                              "email": _email.text,
                              "description": _desc.text,
                              "status": "1",
                              "platform": 'android'
                            }).then((response) async {
                              if (response.statusCode == 200) {
                                print(
                                    "-----------------> After Adding Client  ---------------->");
                                print(response.body.toString());
                                res = json.decode(response.body);
                                if (res['sts'] == 'true') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ClientList()),
                                  );
                                  showDialog(context: context, child:
                                  new AlertDialog(
                                    title: new Text("ubiSales"),
                                    content: new Text(
                                        "Client added successfully"),
                                    //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
                                  ));
                                } else
                                if (res['sts'] == 'companynamealreadyexists') {
                                  showDialog(context: context, child:
                                  new AlertDialog(
                                    //title: new Text("ubiAttendance"),
                                    content: new Text(
                                        "Company name already exists"),
                                    //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
                                  ));
                                } else if (res['sts'] == 'emailalreadyexists') {
                                  showDialog(context: context, child:
                                  new AlertDialog(
                                    //title: new Text("ubiAttendance"),
                                    content: new Text(
                                        "Email ID already exists"),
                                    //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
                                  ));
                                } else
                                if (res['sts'] == 'contactalreadyexists') {
                                  showDialog(context: context, child:
                                  new AlertDialog(
                                    //title: new Text("ubiAttendance"),
                                    content: new Text("Contact already exists"),
                                    //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
                                  ));
                                } else {
                                  // ignore: deprecated_member_use
                                  showDialog(context: context, child:
                                  new AlertDialog(
                                    //title: new Text("ubiAttendance"),
                                    content: new Text(
                                        "Oops!! Poor network connection. Client could not be added."),
                                    //content: new Text(AppTranslations.of(context).text("key_poor_network_connection")),
                                  ));
                                }
                                setState(() {
                                  _isButtonDisabled = false;
                                });
                              } else {
                                setState(() {
                                  _isButtonDisabled = false;
                                });
                                // ignore: deprecated_member_use
                                showDialog(context: context, child:
                                new AlertDialog(
                                  title: new Text("Error"),
                                  // content: new Text("Unable to call service"),
                                  content: new Text("Response status: ${response
                                      .statusCode} \n Response body: ${response
                                      .body}"),
                                )
                                );
                              }
                              //   print("Response status: ${response.statusCode}");
                              //   print("Response body: ${response.body}");
                            }).catchError((onError) {
                              setState(() {
                                _isButtonDisabled = false;
                              });
                              // ignore: deprecated_member_use
                              showDialog(context: context, child:
                              new AlertDialog(
                                title: new Text("Error"),
                                content: new Text("Poor network connection."),
                              )
                              );
                            });
                          }
                          // return false;

                        },
                      ) : widget.sts == "1" ? new RaisedButton(
                        elevation: 2.0,
                        highlightElevation: 5.0,
                        highlightColor: Colors.transparent,
                        disabledElevation: 0.0,
                        focusColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        color: buttoncolor,
                        child: (_isButtonDisabled) ? Text('WAIT...') : Text(
                          'EDIT', style: TextStyle(color: Colors.white),),
                        onPressed: () async {
                          if (_isButtonDisabled)
                            return null;
                          if (_name.text == '') {
                            // ignore: deprecated_member_use
                            // FocusScope.of(context).requestFocus(__name);
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text(
                                  "Please enter the Company's name"),
                              //content: new Text(AppTranslations.of(context).text("key_enter_company_name")),
                            ));
                            return null;
                          } else if (_cname.text == '') {
                            // ignore: deprecated_member_use
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text(
                                  "Please enter the Contact Person's name"),
                              //content: new Text(AppTranslations.of(context).text("key_enter_contact_person_name")),
                            ));
                            //FocusScope.of(context).requestFocus(__cname);
                            return null;
                          } else if (_addr.text == '') {
                            // ignore: deprecated_member_use
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text(
                                  "Please enter or pick the address"),
                              //content: new Text(AppTranslations.of(context).text("key_enter_contact_person_name")),
                            ));
                            //FocusScope.of(context).requestFocus(__cname);
                            return null;
                          } else if (!(validateEmail(_email.text))) {
                            //print((validateEmail(_email.text)).toString());

                            // ignore: deprecated_member_use
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text("Please enter the Email ID"),
                              //content: new Text(AppTranslations.of(context).text("key_please_enter_email")),
                            ));
                            // FocusScope.of(context).requestFocus(__email);
                            return null;
                          } else if (_desc.text.length == "") {
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text("Please enter the Description"),
                              //content: new Text(AppTranslations.of(context).text("key_must_be_at_least_6_characters")),
                            ));
                            // FocusScope.of(context).requestFocus(__pass);
                            return null;
                          } else if (_tempcontry == '') {
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text("Please Select a Country."),
                              //content: new Text(AppTranslations.of(context).text("key_select_country")),
                            ));
                            // FocusScope.of(context).requestFocus(__phone);
                            return null;
                          } else if (_phone.text.length < 6) {
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text(
                                  "Please enter a valid Phone No."),
                              //content: new Text(AppTranslations.of(context).text("key_please_enter_valid_phone")),
                            ));
                            // FocusScope.of(context).requestFocus(__phone);
                            return null;
                          } else {
                            setState(() {
                              _isButtonDisabled = true;
                            });
                            print(globals.path +

                                "editClient?clientid=$clientId&empid=$empid&orgid=$orgid&comp_name=${_cname
                                    .text}&name=${_name.text}&address=${_addr
                                    .text}&country=${_tempcontry}&city=${_city
                                    .text}&countrycode=${_contcode
                                    .text}&phone=${_phone.text}&email=${_email
                                    .text}&description=${_desc
                                    .text}&status=1&platform=android");
                            var url = globals.path + "editClient";
                            http.post(url, body: {
                              "clientid": clientId,
                              "empid": empid,
                              "orgid": orgid,
                              "comp_name": _cname.text,
                              "name": _name.text,
                              "address": _addr.text,
                              "country": _tempcontry,
                              "city": _city.text,
                              "countrycode": _contcode.text,
                              "phone": _phone.text,
                              "email": _email.text,
                              "description": _desc.text,
                              "status": "1",
                              "platform": 'android'
                            }).then((response) async {
                              if (response.statusCode == 200) {
                                print(
                                    "-----------------> After Adding Client  ---------------->");
                                print(response.body.toString());
                                res = json.decode(response.body);
                                if (res['sts'] == 'true') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ClientList()),
                                  );
                                  showDialog(context: context, child:
                                  new AlertDialog(
                                    title: new Text("ubiSales"),
                                    content: new Text(
                                        "Client edited successfully"),
                                    //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
                                  ));
                                } else
                                if (res['sts'] == 'companynamealreadyexists') {
                                  showDialog(context: context, child:
                                  new AlertDialog(
                                    //title: new Text("ubiAttendance"),
                                    content: new Text(
                                        "Company name already exists"),
                                    //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
                                  ));
                                } else if (res['sts'] == 'emailalreadyexists') {
                                  showDialog(context: context, child:
                                  new AlertDialog(
                                    //title: new Text("ubiAttendance"),
                                    content: new Text(
                                        "Email ID already exists"),
                                    //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
                                  ));
                                } else
                                if (res['sts'] == 'contactalreadyexists') {
                                  showDialog(context: context, child:
                                  new AlertDialog(
                                    //title: new Text("ubiAttendance"),
                                    content: new Text("Contact already exists"),
                                    //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
                                  ));
                                } else {
                                  // ignore: deprecated_member_use
                                  showDialog(context: context, child:
                                  new AlertDialog(
                                    //title: new Text("ubiAttendance"),
                                    content: new Text(
                                        "Oops!! Poor network connection. Client could not be added."),
                                    //content: new Text(AppTranslations.of(context).text("key_poor_network_connection")),
                                  ));
                                }
                                setState(() {
                                  _isButtonDisabled = false;
                                });
                              } else {
                                setState(() {
                                  _isButtonDisabled = false;
                                });
                                // ignore: deprecated_member_use
                                showDialog(context: context, child:
                                new AlertDialog(
                                  title: new Text("Error"),
                                  // content: new Text("Unable to call service"),
                                  content: new Text("Response status: ${response
                                      .statusCode} \n Response body: ${response
                                      .body}"),
                                )
                                );
                              }
                              //   print("Response status: ${response.statusCode}");
                              //   print("Response body: ${response.body}");
                            }).catchError((onError) {
                              setState(() {
                                _isButtonDisabled = false;
                              });
                              // ignore: deprecated_member_use
                              showDialog(context: context, child:
                              new AlertDialog(
                                title: new Text("Error"),
                                content: new Text("Poor network connection."),
                              )
                              );
                            });
                          }
                          // return false;

                        },
                      ) : new RaisedButton(
                        elevation: 2.0,
                        highlightElevation: 5.0,
                        highlightColor: Colors.transparent,
                        disabledElevation: 0.0,
                        focusColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        color: buttoncolor,
                        child: (_isButtonDisabled) ? Text('WAIT...') : Text(
                          'ADD CLIENT', style: TextStyle(color: Colors.white),),
                        onPressed: () async {
                          if (_isButtonDisabled)
                            return null;
                          if (_name.text == '') {
                            // ignore: deprecated_member_use
                            // FocusScope.of(context).requestFocus(__name);
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text(
                                  "Please enter the Company's name"),
                              //content: new Text(AppTranslations.of(context).text("key_enter_company_name")),
                            ));
                            return null;
                          } else if (_cname.text == '') {
                            // ignore: deprecated_member_use
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text(
                                  "Please enter the Contact Person's name"),
                              //content: new Text(AppTranslations.of(context).text("key_enter_contact_person_name")),
                            ));
                            //FocusScope.of(context).requestFocus(__cname);
                            return null;
                          } else if (_addr.text == '') {
                            // ignore: deprecated_member_use
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text(
                                  "Please enter or pick the address"),
                              //content: new Text(AppTranslations.of(context).text("key_enter_contact_person_name")),
                            ));
                            //FocusScope.of(context).requestFocus(__cname);
                            return null;
                          } else if (!(validateEmail(_email.text))) {
                            //print((validateEmail(_email.text)).toString());

                            // ignore: deprecated_member_use
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text("Please enter the Email ID"),
                              //content: new Text(AppTranslations.of(context).text("key_please_enter_email")),
                            ));
                            // FocusScope.of(context).requestFocus(__email);
                            return null;
                          } else if (_desc.text.length == "") {
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text("Please enter the Description"),
                              //content: new Text(AppTranslations.of(context).text("key_must_be_at_least_6_characters")),
                            ));
                            // FocusScope.of(context).requestFocus(__pass);
                            return null;
                          } else if (_tempcontry == '') {
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text("Please Select a Country."),
                              //content: new Text(AppTranslations.of(context).text("key_select_country")),
                            ));
                            // FocusScope.of(context).requestFocus(__phone);
                            return null;
                          } else if (_phone.text.length < 6) {
                            showDialog(context: context, child:
                            new AlertDialog(
                              title: new Text("Alert"),
                              content: new Text(
                                  "Please enter a valid Phone No."),
                              //content: new Text(AppTranslations.of(context).text("key_please_enter_valid_phone")),
                            ));
                            // FocusScope.of(context).requestFocus(__phone);
                            return null;
                          } else {
                            setState(() {
                              _isButtonDisabled = true;
                            });
                            print(globals.path +
                                "addClient?empid=$empid&orgid=$orgid&comp_name=${_cname
                                    .text}&name=${_name.text}&address=${_addr
                                    .text}&country=${_tempcontry}&city=${_city
                                    .text}&countrycode=${_contcode
                                    .text}&phone=${_phone.text}&email=${_email
                                    .text}&description=${_desc
                                    .text}&status=2&platform=ios");
                            var url = globals.path + "addClient";
                            http.post(url, body: {
                              "empid": empid,
                              "orgid": orgid,
                              "comp_name": _cname.text,
                              "name": _name.text,
                              "address": _addr.text,
                              "country": _tempcontry,
                              "city": _city.text,
                              "countrycode": _contcode.text,
                              "phone": _phone.text,
                              "email": _email.text,
                              "description": _desc.text,
                              "status": "2",
                              "platform": 'android'
                            }).then((response) async {
                              if (response.statusCode == 200) {
                                print("-----------------> After adding client for approval---------------->");
                                print(response.body.toString());
                                res = json.decode(response.body);
                                //print(res['id']);
                                //finalClientId=res['id'];
                                if (res['sts'] == 'true') {
                                  //saveVisitImage();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PunchLocation(client: _cname.text,)),
                                  );
                                  showDialog(context: context, child:
                                  new AlertDialog(
                                    title: new Text("ubiSales"),
                                    content: new Text(
                                        "Client added successfully"),
                                    //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
                                  ));
                                } else {
                                  if (res['sts'] ==
                                      'companynamealreadyexists') {
                                    showDialog(context: context, child:
                                    new AlertDialog(
                                      //title: new Text("ubiAttendance"),
                                      content: new Text(
                                          "Company name already exists"),
                                      //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
                                    ));
                                  } else
                                  if (res['sts'] == 'emailalreadyexists') {
                                    showDialog(context: context, child:
                                    new AlertDialog(
                                      //title: new Text("ubiAttendance"),
                                      content: new Text(
                                          "Email ID already exists"),
                                      //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
                                    ));
                                  } else
                                  if (res['sts'] == 'contactalreadyexists') {
                                    showDialog(context: context, child:
                                    new AlertDialog(
                                      //title: new Text("ubiAttendance"),
                                      content: new Text(
                                          "Contact already exists"),
                                      //content: new Text(AppTranslations.of(context).text("key_email_already_registered")),
                                    ));
                                  } else {
                                    // ignore: deprecated_member_use
                                    showDialog(context: context, child:
                                    new AlertDialog(
                                      //title: new Text("ubiAttendance"),
                                      content: new Text(
                                          "Oops!! Poor network connection. Client could not be added."),
                                      //content: new Text(AppTranslations.of(context).text("key_poor_network_connection")),
                                    ));
                                  }
                                  setState(() {
                                    _isButtonDisabled = false;
                                  });
                                }
                              } else {
                                setState(() {
                                  _isButtonDisabled = false;
                                });
                                // ignore: deprecated_member_use
                                showDialog(context: context, child:
                                new AlertDialog(
                                  title: new Text("Error"),
                                  // content: new Text("Unable to call service"),
                                  content: new Text("Response status: ${response
                                      .statusCode} \n Response body: ${response
                                      .body}"),
                                )
                                );
                              }
                              //   print("Response status: ${response.statusCode}");
                              //   print("Response body: ${response.body}");
                            }).catchError((onError) {
                              setState(() {
                                _isButtonDisabled = false;
                              });
                              // ignore: deprecated_member_use
                              showDialog(context: context, child:
                              new AlertDialog(
                                title: new Text("Error"),
                                content: new Text("Poor network connection."),
                              )
                              );
                            });
                          }
                          // return false;

                        },
                      )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: new SafeArea(
          top: false,
          bottom: false,
          child: loader ? runloader() : new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: widget.sts == "0" ? new Text("Add Client",
                        textAlign: TextAlign.center,
                        style: new TextStyle(fontSize: 22.0, color: appcolor),
                      ) : widget.sts == "1" ? new Text("Edit Client",
                        textAlign: TextAlign.center,
                        style: new TextStyle(fontSize: 22.0, color: appcolor),
                      ) : new Text("Add Client For Approval\n and Visit Client",
                        textAlign: TextAlign.center,
                        style: new TextStyle(fontSize: 22.0, color: appcolor),
                      )
                  ),
                  //SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: new TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey
                                  .withOpacity(0.0), width: 1,),
                            ),
                            prefixIcon: Icon(
                              Icons.business,
                              color: Colors.black38,
                            ),
                            labelText: 'Company Name',
                            hintText: 'Company Name',
                            hintStyle: TextStyle(
                              color: Colors.black45,
                            )
                        ),
                        controller: _cname,
                        focusNode: __cname,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: new TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.0), width: 1,),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.black38,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () async {
                                Contact contact = await _contactPicker
                                    .selectContact();
                                setState(() {
                                  _contactpick = contact;
                                  _phone.text = _contactpick.phoneNumber;
                                  _name.text = _contactpick.fullName;
                                });
                              },
                              icon: Icon(
                                Icons.contact_phone,
                                color: Colors.black38,),
                            ),
                            labelText: 'Contact Person Name',
                            hintText: 'Contact Person Name',
                            hintStyle: TextStyle(
                              color: Colors.black45,
                            )
                        ),
                        controller: _name,
                        focusNode: __name,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: new TextFormField(
                        controller: _addr,
                        focusNode: __addr,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.0), width: 1,),
                          ),
                          labelText: "Company Address",
                          hintText: "Company Address",
                          hintStyle: TextStyle(
                              color: Colors.black45
                          ),
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(top: 0.0),
                              child: Icon(Icons.pin_drop, color: Colors
                                  .black38,)
                          ),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return PlacePicker(
                                      apiKey: AddClient.apiKey,
                                      initialPosition: AddClient
                                          .kInitialPosition,
                                      useCurrentLocation: true,
                                      usePlaceDetailSearch: true,
                                      onPlacePicked: (result) {
                                        selectedPlace = result;
                                        Navigator.of(context).pop();
                                        setState(() {});
                                      },
                                      forceSearchOnZoomChanged: true,
                                      automaticallyImplyAppBarLeading: false,
                                      //autocompleteLanguage: "ko",
                                      //region: 'au',
                                      selectInitialPosition: true,
                                      selectedPlaceWidgetBuilder: (_,
                                          selectedPlace, state,
                                          isSearchBarFocused) {
                                        print(
                                            "selectedPlace: $selectedPlace, state: $state, isSearchBarFocused: $isSearchBarFocused");
                                        return isSearchBarFocused
                                            ? Container()
                                            : Stack(
                                          children: <Widget>[
                                            FloatingCard(
                                              bottomPosition: 35.0,
                                              // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                                              leftPosition: 15.0,
                                              rightPosition: 15.0,
                                              //width: 500,
                                              //height: 200,
                                              borderRadius: BorderRadius
                                                  .circular(5.0),
                                              child: state ==
                                                  SearchingState.Searching
                                                  ? Center(
                                                  child: CircularProgressIndicator())
                                                  : Column(
                                                children: <Widget>[
                                                  SizedBox(height: 10),
                                                  Text(selectedPlace
                                                      .formattedAddress,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight
                                                            .w500),
                                                    textAlign: TextAlign
                                                        .center,),
                                                  SizedBox(height: 10),
                                                  RaisedButton(
                                                    child: Text("Select Here",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white)),
                                                    color: appcolor,
                                                    onPressed: () {
                                                      print(
                                                          "selectedPlace.name");
                                                      print(selectedPlace
                                                          .placeId);
                                                      print(selectedPlace
                                                          .geometry.location);
                                                      print(selectedPlace
                                                          .geometry.location
                                                          .toString().split(
                                                          ","));
                                                      arr = selectedPlace
                                                          .geometry.location
                                                          .toString().split(
                                                          ",");
                                                      lat = arr[0];
                                                      print("lat");
                                                      print(lat);
                                                      long = arr[1];
                                                      print("long");
                                                      print(long);
                                                      print(selectedPlace
                                                          .formattedAddress);
                                                      print(selectedPlace
                                                          .types);
                                                      print(selectedPlace
                                                          .addressComponents);
                                                      print(selectedPlace
                                                          .adrAddress);
                                                      print(selectedPlace
                                                          .formattedPhoneNumber);
                                                      print(selectedPlace.id);
                                                      print(selectedPlace
                                                          .reference);
                                                      print(selectedPlace.icon);
                                                      print(selectedPlace.name);
                                                      print(selectedPlace
                                                          .openingHours);
                                                      print(selectedPlace
                                                          .photos);
                                                      print(selectedPlace
                                                          .internationalPhoneNumber);
                                                      print(selectedPlace
                                                          .priceLevel);
                                                      print(selectedPlace
                                                          .rating);
                                                      print(selectedPlace
                                                          .scope);
                                                      print(selectedPlace.url);
                                                      print(selectedPlace
                                                          .vicinity);
                                                      print(selectedPlace
                                                          .utcOffset);
                                                      print(selectedPlace
                                                          .website);
                                                      print(selectedPlace
                                                          .reviews);
                                                      // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
                                                      // this will override default 'Select here' Button.
                                                      print(
                                                          "do something with [selectedPlace] data");
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() {
                                                        _addr.text =
                                                            selectedPlace
                                                                .formattedAddress
                                                                .toString();
                                                      });
                                                      _getAddressFromLatLng(
                                                          lat, long);
                                                    },
                                                  ),
                                                  SizedBox(height: 10),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                      /*pinBuilder: (context, state) {
                                         if (state == PinState.Idle) {
                                           return Icon(Icons.favorite_border);
                                         } else {
                                           return Icon(Icons.favorite);
                                         }
                                       },*/
                                    );
                                  },
                                ),
                              );
                            },

                            icon: Icon(
                              Icons.add_location,
                              color: Colors.black38,),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //SizedBox(height: 5.0),
                  /*widget.sts == "2" ? Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: new TextFormField(
                        controller: _caddr,
                        focusNode: __caddr,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.0), width: 1,),
                          ),
                          labelText: "Your Location",
                          hintText: "Your Location",
                          hintStyle: TextStyle(
                              color: Colors.black45
                          ),
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(top: 0.0),
                              child: Icon(Icons.my_location,
                                color: Colors.black38,)
                          ),
                        ),
                      ),
                    ),
                  ) : Center(),*/
                  widget.sts == "2" ? SizedBox(height: 5.0) : Center(),
                  Column(
                    children: <Widget>[
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 2.0, right: 2.0, top: 5.0, bottom: 5.0),
                          child: new InputDecorator(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.0),
                                  width: 1,),
                              ),
                              prefixIcon: Icon(
                                Icons.flag,
                                color: Colors.black38,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.black45,
                              ),
                            ),

                            child: DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                child: new DropdownButton<String>(
                                  iconSize: 20,
                                  icon: Icon(Icons.arrow_drop_down),
                                  isDense: true,
                                  hint: new Text("Select Country"),
                                  value: code,
                                  onChanged: (String newValue) {
                                    setState(() {
                                      code = newValue;
                                      _contcode.text = _myJson[int.parse(
                                          newValue)]['countrycode'];
                                      _tempcontry =
                                      _myJson[int.parse(newValue)]['id'];
                                    });
                                  },
                                  items: _myJson.map((Map map) {
                                    return new DropdownMenuItem<String>(
                                      value: map['ind'].toString(),
                                      child: SizedBox(
                                        width: 200.0,
                                        child: new Text(
                                          map["name"].toString(),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: new TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.0), width: 1,),
                            ),
                            prefixIcon: Icon(
                              Icons.location_city,
                              color: Colors.black38,
                            ),
                            labelText: 'City',
                            hintText: 'City',
                            hintStyle: TextStyle(
                              color: Colors.black45,
                            )
                        ),
                        controller: _city,
                        focusNode: __city,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  new Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.15,
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.085,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: new TextFormField(
                              enabled: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.0),
                                    width: 1,),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 20.0),
                              ),
                              controller: _contcode,
                              focusNode: __contcode,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.74,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: new TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.0),
                                  width: 1,),
                              ),
                              labelText: 'Phone',
                              hintText: 'Phone',
                              //hintText: AppTranslations.of(context).text("key_phone"),
                              hintStyle: TextStyle(
                                color: Colors.black45,
                              ),
                              prefixIcon: const Icon(
                                Icons.phone, color: Colors.black38,),
                            ),
                            controller: _phone,
                            focusNode: __phone,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0),

                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: new TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.0), width: 1,),
                            ),
                            prefixIcon: Icon(Icons.email),
                            labelText: 'Email',
                            hintText: 'Email',
                            //hintText: AppTranslations.of(context).text("key_email"),
                            hintStyle: TextStyle(
                              color: Colors.black45,
                            )
                        ),
                        controller: _email,
                        focusNode: __email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ),

                  SizedBox(height: 5.0),
                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: new TextFormField(
                        controller: _desc,
                        focusNode: __desc,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.0), width: 1,),
                          ),
                          labelText: "Description",
                          hintText: "Description",
                          hintStyle: TextStyle(
                              color: Colors.black45
                          ),
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(top: 0.0),
                              child: Icon(Icons.edit, color: Colors.black38,)
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                ],
              ))),
    );
  }

  runloader() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset(
                  'assets/spinner.gif', height: 50.0, width: 50.0),
            ]),
      ),
    );
  }

  _getAddressFromLatLng(lat, long) async {
    try {
      print("Shaifali");
      print(lat);
      print("Rathore");
      print(long);
      double lat1 = double.parse(lat);
      double long1 = double.parse(long);

      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          lat1, long1);
      Placemark place = p[0];
      setState(() {
        _city.text = place.locality;
        print("place.locality");
        print(place.locality);
        print("place.country");
        print(place.country);
        //locController2.text = place.country;
        SearchCountry(place.country);
      });
    } catch (e) {
      print(e);
    }
  }

  /*_getCurrentLocation() {
    geolocator.getCurrentPosition(desiredAccuracy:LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print("_currentPosition");
        print(_currentPosition);
      });
      _getAddressFromLatLng1();
    }).catchError((e) {
      print(e);
    });

  }

  _getAddressFromLatLng1() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        _city.text = place.locality;
        SearchCountry(place.country);
      });
    } catch (e) {
      print(e);
    }
  }*/

  saveVisitImage() async {
    print("clientname");
    print(_cname.text);
    print("_finalClientId");
    print(finalClientId);
    MarkVisit mk = new MarkVisit(
        empid,
        _cname.text,
        finalClientId,
        _caddr.text,
        orgid,
        lat,
        long,
        FakeLocationStatus);

    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {

     /* PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
      print("permission status");
      print(permission);
      print("permission status");

      if (permission.toString() == 'PermissionStatus.denied' &&
          globals.visitImage == 1) {
        print("PermissionStatus.denied");
        await showDialog(
          context: context,
          // ignore: deprecated_member_use
          child: new AlertDialog(
            title: new Text("Please enable Camera access to punch Visit"),
            content: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Open Settings', style: new TextStyle(
                  fontSize: 18.0, color: Colors.white)),
              color: Colors.orangeAccent,
              onPressed: () {
                PermissionHandler().openAppSettings();
              },
            ),));
        return;
      }*/
      SaveImage saveImage = new SaveImage();
      bool issave = false;
      /*setState(() {
        act1 = "";
      });*/
      var prefs = await SharedPreferences.getInstance();
      showAppInbuiltCamera = prefs.getBool("showAppInbuiltCamera") ?? false;
      issave = showAppInbuiltCamera
          ? await saveImage.saveVisitAppCamera(mk, context)
          : await saveImage.saveVisit(mk, context);
      ////print(issave);
      if (issave) {
        // ignore: deprecated_member_use
        showDialog(context: context, child:
        new AlertDialog(
          content: Text("'Visit In' punched successfully"),
        )
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PunchLocationSummary()),
        );
        /*setState(() {
          act1 = act;
        });*/
      } else {
        // ignore: deprecated_member_use
        showDialog(context: context, child:
        new AlertDialog(

          content: new Text("Selfie was not captured. Please punch again."),
        )
        );
        /*setState(() {
          act1 = act;
        });*/
      }
    } else {
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(

        content: new Text("Internet connection not found!."),
      )
      );
    }
  }


}