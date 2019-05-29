import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:simple_permissions/simple_permissions.dart';
//import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:printing/printing.dart';

CreateDeptpdf(pdata, HeaderText, Total, pdfName, name) async {
  final res  = await SimplePermissions.requestPermission(Permission. WriteExternalStorage);
  bool checkPermission=await SimplePermissions.checkPermission(Permission.WriteExternalStorage);
  if(res.toString()=="PermissionStatus.authorized") {
  // print(pdata);
  final Document pdf = Document(deflate: zlib.encode);
  List<List<String>> list = new List<List<String>>();
  List<String> a2 = new List<String>();

  if(name=='dept'){
    a2.add('Department');
    a2.add('Total');
    a2.add('Present');
    a2.add('Absent');
    list.add(a2);
    for (var i = 0; i < pdata.length; i++) {
      List<String> a1 = new List<String>();
        a1.add(pdata[i].Name.toString());
        a1.add(pdata[i].Total.toString());
        a1.add(pdata[i].Present.toString());
        a1.add(pdata[i].Absent.toString());
      list.add(a1);
    }
  }else {
    a2.add('Name');
    if (name != 'absent') {
      a2.add('TimeIn');
      a2.add('TimeIn Location');
      a2.add('TimeOut');
      a2.add('TimeOut Location');
    }
    list.add(a2);
    for (var i = 0; i < pdata.length; i++) {
      List<String> a1 = new List<String>();
      a1.add(pdata[i].Name.toString());
      if (name != 'absent') {
        a1.add(pdata[i].TimeIn.toString());
        a1.add(pdata[i].CheckInLoc.toString());
        a1.add(pdata[i].TimeOut.toString());
        a1.add(pdata[i].CheckOutLoc.toString());
      }
      list.add(a1);
    }
  }

  pdf.addPage(MultiPage(
      pageFormat:
          PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      crossAxisAlignment: CrossAxisAlignment.start,
      header: (Context context) {
        if (context.pageNumber == 1) {
          return null;
        }
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            decoration: const BoxDecoration(
                border:
                    BoxBorder(bottom: true, width: 0.5, color: PdfColors.grey)),
            child: Text(HeaderText,
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      footer: (Context context) {
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      build: (Context context) => <Widget>[
            Header(
                level: 0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(HeaderText, textScaleFactor: 2),
                      PdfLogo()
                    ])),
            Bullet(text: "Total: "+ Total),

            Table.fromTextArray(context: context, data: list),
          ]));
  /*String dir =
      (await getExternalStorageDirectory()).absolute.path + "/documents/"; */
  String dir = (await getExternalStorageDirectory()).absolute.path;
  String file = "$dir/ubiattendance_files/";
  await new Directory('$file').create(recursive: true);
  File f = File(file + pdfName + '.pdf');
  print(f);
  f.writeAsBytesSync(pdf.save());
  return file+ pdfName + '.pdf';
}
}
