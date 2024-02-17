import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_view/flutter_file_view.dart';
import 'package:page_transition/page_transition.dart';
import 'package:power_point_x/page/file_pdf_view.dart';
import 'package:power_point_x/page/power_file_view_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/api_provider.dart';
import '../util/file_type.dart';
import '../util/permission_util.dart';
import 'file_view.dart';

class FileListPage extends StatefulWidget {
  const FileListPage({super.key});

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    final provider = Provider.of<NetworkProvider>(context, listen: false);
    provider.getList();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
    super.initState();
  }

  Future<dynamic> _refresh() {
    final provider = Provider.of<NetworkProvider>(context, listen: false);
    return provider.getList().then((data) {
      build_api(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: Container(
            child: build_api(context),
          ),
        )
    );
  }

  Widget build_api(BuildContext context) {
    final provider = Provider.of<NetworkProvider>(context, listen: false);
    provider.getList();
    return Consumer(
        builder: (context, NetworkProvider provider, child) {
          if(provider.fileList.length!=0){
            List<String> list= provider.fileList ;
            return _buildPosts(context, list!);
          }else if(provider.fileList.length==0) {
            return const Center(
              child: Text('No File Exit',style: TextStyle(fontSize: 15,color: Colors.redAccent),),
            );
          }else{
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }
    );
  }

  ListView _buildPosts(BuildContext context, List<String> posts) {
    return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          String filePath = posts[index];
          final fileName = FileUtil.getFileName(filePath);
          return Container(
            margin: const EdgeInsets.only(top: 10.0),
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ElevatedButton(
              onPressed: () async {
                final fileType = FileUtil.getFileType(posts[index]);
                if(fileType.toString()=='pdf'){
                  Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: MyPdfViewPage(filePath: filePath,)));
                }else{

                  print(filePath);
                  FileViewController? controller;

                  if (filePath.contains('http://') || filePath.contains('https://')) {
                    controller = FileViewController.network(filePath);
                  } else {
                    controller = FileViewController.asset('assets/files/$filePath');
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => FileViewPage(controller: controller!),
                    ),
                  );
                }

              },
              child: Text(fileName),
            ),
          );
        });
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
