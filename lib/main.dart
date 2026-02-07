import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/routes/app_pages.dart';
import 'app/style/app_color.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    FirebaseOptions firebaseOptions = Platform.isIOS
        ? const FirebaseOptions(
            apiKey: 'AIzaSyDs1BXE6XgW7RaCwLx9jrSnfuAmnlQSZ3I',
            appId: '1:1043350175679:ios:eda4a92cb5b984c34fab0a',
            messagingSenderId: '1043350175679',
            projectId: 'fre-kantin',
          )
        : const FirebaseOptions(
            apiKey: 'AIzaSyCNjnbWpe0UZ6ykxAz0mTVjctZwO2T-WjA',
            appId: '1:1043350175679:android:595d191fc9ca134b4fab0a',
            messagingSenderId: '1043350175679',
            projectId: 'fre-kantin',
          );
    await Firebase.initializeApp(options: firebaseOptions);
  } catch (e) {
    throw ('error init firebase main');
  }
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return GetMaterialApp(
          builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaler: const TextScaler.linear(1.10)),
              child: child!,
            );
          },
          theme: ThemeData(
            scaffoldBackgroundColor: AppColor.white,
            appBarTheme: AppBarTheme(color: AppColor.white),
            fontFamily: 'Raleway',
          ),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
