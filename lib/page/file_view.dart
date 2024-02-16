import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../theme/colors.dart';
class FileViewPage extends StatelessWidget {
  final String filePath;
  const FileViewPage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actionsIconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primaryColor,
        toolbarHeight: 50,
        title: Text('View',style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20, color: Colors.white),),
      ),
      body: Container(
        child: PDFView(
          filePath: filePath,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: false,
          onRender: (_pages) {
          },
          onError: (error) {
            print(error.toString());
          },
          onPageError: (page, error) {
            print('$page: ${error.toString()}');
          },
          onViewCreated: (PDFViewController pdfViewController) {
            // _controller.complete(pdfViewController);
          },
        ),
      ),
    );
  }
}

