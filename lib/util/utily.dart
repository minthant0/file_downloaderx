import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../theme/colors.dart';

class Utility{

  Widget getLoadingUI() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SpinKitFadingCircle(
            color: AppColors.pautColor,
            size: 80,
          ),
          Text(
            'Loading...',
            style: TextStyle(fontSize: 20, color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget getErrorUI(String error) {
    print('Error');
    return Center(
      child: Text(
        error,
        style: TextStyle(color: AppColors.redColor, fontSize: 22),
      ),
    );
  }




}