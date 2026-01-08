import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class FCMHelper {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'shivay_construction_channel';
  static const String _channelName = 'Shivay Construction Notifications';
  static const String _channelDesc = 'Important notifications from Jinee';
  static const String _payloadKey = 'screen';

  static bool _isHandlingNotification = false;
  static bool _channelsInitialized = false;

  static Future<void> initialize() async {
    try {
      await _initializeChannel();
      await _initializeLocalNotifications();
      await _requestPermissions();
      _setupMessageHandlers();
      await _printFcmToken();
    } catch (e) {
      log('FCM initialization error: $e');
    }
  }

  static Future<void> _initializeChannel() async {
    if (_channelsInitialized) return;

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
    );

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      _channelsInitialized = true;
      log('Notification channel initialized successfully');
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        try {
          if (response.payload != null && response.payload!.isNotEmpty) {
            final data = _decodePayload(response.payload!);
            _handleNotificationTap(data);
          } else {
            _handleNotificationTap({});
          }
        } catch (e) {
          log('Error handling notification response: $e');
        }
      },
    );
  }

  static Future<void> _requestPermissions() async {
    final NotificationSettings settings = await _firebaseMessaging
        .requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
    log('Notification permissions: ${settings.authorizationStatus}');
  }

  static Future<void> _printFcmToken() async {
    final String? token = await _firebaseMessaging.getToken();
    log('FCM Token: $token');
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      log('FCM Token refreshed: $newToken');
    });
  }

  static void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log('Foreground message received: ${message.notification?.title}');
      await _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      log('Notification tapped (background): ${message.data}');
      _handleNotificationTap(message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) async {
      if (message != null) {
        log('Notification tapped (terminated): ${message.data}');
        _handleNotificationTap(message.data);
      }
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
    log('Background message: ${message.notification?.title}');

    final FlutterLocalNotificationsPlugin localNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await _initializeChannelInBackground(localNotificationsPlugin);

    if (message.notification != null) {
      await _showBackgroundNotification(message, localNotificationsPlugin);
    }
  }

  static Future<void> _initializeChannelInBackground(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
    );

    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      log('Background: Channel created successfully');
    }
  }

  static Future<void> _showBackgroundNotification(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final RemoteNotification? notification = message.notification;

    if (notification != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('notification_sound'),
            enableVibration: true,
            visibility: NotificationVisibility.public,
            icon: '@drawable/ic_notification',
            color: Color(0xFF0A1F44),
            styleInformation: BigTextStyleInformation(''),
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await plugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: _encodePayload(message.data),
      );
    }
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final Map<String, dynamic> data = message.data;

    if (notification != null) {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('notification_sound'),
            enableVibration: true,
            visibility: NotificationVisibility.public,
            icon: '@drawable/ic_notification',
            color: Color(0xFF0A1F44),
            styleInformation: BigTextStyleInformation(''),
          );

      const DarwinNotificationDetails darwinNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'notification_sound.mp3',
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: _encodePayload(data),
      );
    }
  }

  static void _handleNotificationTap(Map<String, dynamic> data) {
    if (_isHandlingNotification) return;
    _isHandlingNotification = true;

    log('Handling notification tap with data: $data');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final String? token = await SecureStorageHelper.read('token');
        final bool isAuthenticated = token != null && token.isNotEmpty;

        if (isAuthenticated) {
          final String? screenType = data[_payloadKey];

          if (screenType != null && screenType.isNotEmpty) {
            log('Navigating to screen: $screenType');
            _navigateToScreen(screenType, data);
          } else {
            log('No specific screen, app is now open');
          }
        } else {
          log('User not authenticated, going to login');
          // Get.offAllNamed(AppRoutes.login);
        }
      } catch (e) {
        log('Error handling notification: $e');
      } finally {
        _isHandlingNotification = false;
      }
    });
  }

  static void _navigateToScreen(String screen, Map<String, dynamic> data) {
    log('Would navigate to: $screen with data: $data');

    // Add your navigation logic here when screens are ready
    // Example:
    // switch (screen) {
    //   case 'orders':
    //     Get.to(() => OrdersScreen());
    //     break;
    //   case 'profile':
    //     Get.to(() => ProfileScreen());
    //     break;
    //   default:
    //     log('Unknown screen type: $screen');
    // }
  }

  static String _encodePayload(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      log('Error encoding payload: $e');
      return '{}';
    }
  }

  static Map<String, dynamic> _decodePayload(String payload) {
    try {
      if (payload.isEmpty) return {};
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (e) {
      log('Error decoding payload: $e');
      return {};
    }
  }

  static Future<void> reset() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    _isHandlingNotification = false;
  }
}
