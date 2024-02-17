import 'package:flutter/material.dart';
import 'package:flutter_file_view/flutter_file_view.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:power_file_view/power_file_view.dart';
import 'package:power_point_x/page/download.dart';
import 'package:power_point_x/page/file_list.dart';
import 'package:power_point_x/providers/api_provider.dart';
import 'package:power_point_x/theme/colors.dart';
import 'package:provider/provider.dart';

import 'controller/landingPageController.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterFileView.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //App status bar color
    FlutterStatusbarcolor.setStatusBarColor(AppColors.grayColor);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PowerPointX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void initialization() async {
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    initialization();
    super.initState();
  }

  buildBottomNavigationMenu(context, landingPageController) {
    return Obx(() => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: SizedBox(
          child: BottomNavigationBar(
            showUnselectedLabels: true,
            showSelectedLabels: true,
            onTap: landingPageController.changeTabIndex,
            currentIndex: landingPageController.tabIndex.value,
            backgroundColor: AppColors.blueColor,
            unselectedItemColor: Colors.white.withOpacity(0.5),
            selectedItemColor: AppColors.whiteColor,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Download', backgroundColor: AppColors.blueColor),
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'File List', backgroundColor: AppColors.blueColor),
            ],
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    final LandingPageController landingPageController =
    Get.put(LandingPageController(), permanent: false);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NetworkProvider(), // You should provide your ViewModel here.
        ),
      ],
      child: MaterialApp(
        color: Colors.white,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            actionsIconTheme: IconThemeData(color: Colors.white),
            backgroundColor: AppColors.primaryColor,
            toolbarHeight: 50,
            title: Text('PowerPointX',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20, color: Colors.white),),
          ),
          body: Obx(() => IndexedStack(
            index: landingPageController.tabIndex.value,
            children: const [
              DownloadPage(),
              FileListPage(),
            ],
          )),
          bottomNavigationBar: buildBottomNavigationMenu(context, landingPageController),
        ),
      ),
    );
  }
}
