import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_file_view/flutter_file_view.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:power_point_x/page/file_view.dart';
import 'package:power_point_x/page/power_file_view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/colors.dart';
import '../util/file_type.dart';
import '../util/permission_util.dart';
import 'file_pdf_view.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  TextEditingController urlController = TextEditingController();
  bool isVisible = false;
  String fileUrl="";

  @override
  Widget build(BuildContext context) {
    print('download');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.fromLTRB(0, 50, 0, 10),
        child: Column(
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter file url',
              ),
              onChanged: (text) {
                setState(() {
                  //you can access nameController in its scope to get
                  // the value of text entered as shown below
                  //fullName = nameController.text;
                });
              },
            ),
            Container(
              width: 300,
              margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: ElevatedButton(
                onPressed: () async {
                  //showAlertDialog(context);
                  isVisible=false;
                  FocusScope.of(context).requestFocus(FocusNode());

                  final fileType = FileUtil.getFileType(urlController.text.toString());
                  final fileName = FileUtil.getFileName(urlController.text.toString());
                  String savePath = await getFilePath(fileType, fileName);
                  if(fileType.toString()=='pdf'){
                    onTap(context, urlController.text.toString());
                  }else{
                    onTapOther(context, urlController.text.toString(), savePath);
                  }

                },
                child: const Text('Download',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18, color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: StadiumBorder(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future onTap(BuildContext context, String downloadUrl) async {
    bool result = await InternetConnectionChecker().hasConnection;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isGranted = await PermissionUtil.check();
    if (isGranted) {
      PermissionStatus requestStatus = await Permission.storage.request();
      if (requestStatus.isGranted) {
        var dir = await getTemporaryDirectory();
        if(dir != null){
          final fileName = FileUtil.getFileName(downloadUrl);
          String fileType = FileUtil.getFileType(downloadUrl);
          String savePath = await getFilePath(fileType, fileName);
          //  String namePath = dir.path + "/$fileName";
          try {
            await Dio().download(
                downloadUrl,
                savePath,
                onReceiveProgress: (received, total) {
                  if (total != -1) {
                    showSnack('Downloading...'+(received / total * 100).toStringAsFixed(0) + "%");
                    //you can build progressbar feature too
                  }
                });
            fileUrl=savePath;
            print(savePath);
            List<String> fileslist=[];
            fileslist= prefs.getStringList('save')??[];
            fileslist.add(savePath);
            print(fileslist.length);
            List<String> saveList=[];
            saveList.clear();
            for(int i = 0; i < fileslist.length; i++){
              saveList.add(fileslist[i]);
            }
            await prefs.setStringList('save', saveList);
            showSnackSuccess('Success Download',savePath);
          } on DioError catch (e) {
            print(e.message);
          }
          //output:  /storage/emulated/0/Download/banner.png
        }
        return true;
      } else {

        showAlertDialog(context);
        return false;
      }
      // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: FileViewPage(filePath: downloadUrl,)));
    } else {
      debugPrint('no permission');
    }
    if(result == true) {

    }else{

      showSnack('No Internet');
    }
  }

  showAlertDialog(context) => showCupertinoDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('Permission Denied'),
      content: const Text('Allow access to gallery and photos'),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => openAppSettings(),
          child: const Text('Settings'),
        ),
      ],
    ),
  );

  void showSnack(String string){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
           // Icon(Icons.wifi_off,color: Colors.white,),
            Container(
              margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child:  Text(string,style: TextStyle(fontSize: 15,color: Colors.white),),
            )
          ],
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
      ),);
  }

  void showSnackSuccess(String string,String url){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 10),
        content: Row(
          children: [
            Expanded(flex: 1,child: Container(child: Text(string,style: TextStyle(fontSize: 15,color: Colors.white)))),
            Expanded(flex: 1,child: Container(alignment:Alignment.centerRight,child: InkWell(
              onTap: (){
                Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: MyPdfViewPage(filePath: url,)));
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: Text('Show',style: TextStyle(fontSize: 18,color: Colors.greenAccent)),
            )))

          ],
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
      ),);
  }

  Future getFilePath(String type, String assetPath) async {
    final _directory = await getTemporaryDirectory();
    return "${_directory.path}/fileview/${base64.encode(utf8.encode(assetPath))}.$type";
  }

  Future onTapOther(BuildContext context, String downloadUrl, String downloadPath) async {
    bool isGranted = await PermissionUtil.check();
    if (isGranted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) {
          return PowerFileViewPage(
            downloadUrl: downloadUrl,
            downloadPath: downloadPath,
          );
        }),
      );
    } else {
      debugPrint('no permission');
    }
  }

}
