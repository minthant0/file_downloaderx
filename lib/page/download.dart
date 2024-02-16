import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:power_point_x/page/file_view.dart';
import 'package:power_point_x/util/utily.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/file_type.dart';
import '../util/permission_util.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  late TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('doenload');
    return Container(
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
            margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: ElevatedButton(
              onPressed: () async {
                if(urlController.text!=''){
                  onTap(context, urlController.text);
                }else{
                  showSnack('Please set url');
                }
              },
              child: const Text('Download',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18, color: Colors.white),),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                shape: StadiumBorder(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future onTap(BuildContext context, String downloadUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isGranted = await PermissionUtil.check();

    if (isGranted) {
      PermissionStatus requestStatus = await Permission.storage.request();
      if (requestStatus.isGranted) {
        var dir = await DownloadsPathProvider.downloadsDirectory;
        if(dir != null){
          final fileName = FileUtil.getFileName(downloadUrl);
          String savePath = dir.path + "/$fileName";
          String namePath = dir.path + "/$fileName";

          try {
            await Dio().download(
                downloadUrl,
                savePath,
                onReceiveProgress: (received, total) {
                  if (total != -1) {
                    showSnack((received / total * 100).toStringAsFixed(0) + "%");
                    //you can build progressbar feature too
                  }
                });
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
            showSnack('Success Download');
          } on DioError catch (e) {
            print(e.message);
          }
          //output:  /storage/emulated/0/Download/banner.png
        }
        return true;
      } else {
        return false;
      }

     // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: FileViewPage(filePath: downloadUrl,)));
    } else {
      debugPrint('no permission');
    }
  }

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


}
