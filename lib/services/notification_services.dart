import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationServices {
  final _fcm = FirebaseMessaging.instance;
  late String? _fcmToken;

  Future<void> init() async {
    _fcmToken = await FirebaseMessaging.instance.getToken();

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      _fcmToken = fcmToken;
    }).onError(print);
    print('FCM TOKEN IS $_fcmToken');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }
}
