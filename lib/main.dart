import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/auth/screens/splash_screen.dart';
import 'package:shivay_construction/utils/helpers/fcm_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Background message handler for Firebase Cloud Messaging
/// This function is called when the app receives a notification while in the background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background message handling
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDb5umsAk8xikoV7MovgxItpZEjUhYdIxE',
      appId: '1:1244065804:android:1c3c4bb1445c3639a67e29',
      messagingSenderId: '1244065804',
      projectId: 'shivay-construction',
      storageBucket: 'shivay-construction.firebasestorage.app',
    ),
  );

  // Handle the background message
  await FCMHelper.firebaseMessagingBackgroundHandler(message);
}

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for Android
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDb5umsAk8xikoV7MovgxItpZEjUhYdIxE',
        appId: '1:1244065804:android:1c3c4bb1445c3639a67e29',
        messagingSenderId: '1244065804',
        projectId: 'shivay-construction',
        storageBucket: 'shivay-construction.firebasestorage.app',
      ),
    );

    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize Firebase Cloud Messaging
    await FCMHelper.initialize();
  }

  // Set device orientation to portrait only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shivay Construction',
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: kColorWhite,
            ),
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
