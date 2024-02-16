import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class NetworkProvider extends ChangeNotifier {
  bool isLoading = true;
  String error = '';
  List<String> fileList=[];

  //
  Future<List<String>> getList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    fileList = prefs.getStringList('save') ?? [];
    print(fileList.length);
    notifyListeners();
    return fileList;
  }

}

