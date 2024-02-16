import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/api_provider.dart';
import '../util/file_type.dart';
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
    print('FileList');
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
          print(provider.fileList.length);
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
                print(filePath);
                Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: FileViewPage(filePath: filePath,)));
              },
              child: Text(fileName),
            ),
          );
        });
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
