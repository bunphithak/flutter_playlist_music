import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables
    if (kReleaseMode) {
      await dotenv.load(fileName: ".env.prod");
    } else {
      await dotenv.load(fileName: ".env");
    }

    // Initialize GetStorage
    await GetStorage.init();

    runApp(const MyApp());
  } catch (e) {
    print('Error initializing app: $e');
    runApp(const MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),  // iPhone 15 Pro Max logical resolution
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: "Nung Music",
          locale: Get.deviceLocale,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          defaultTransition: Transition.fade,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: "IBMPlexSansThai",
          ),
        );
      },
    );
  }
}