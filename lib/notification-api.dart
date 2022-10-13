import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scraping_coupons/main.dart';

class NotificationApi{
  static final notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize(callback) async{
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('notification_icon');

    IOSInitializationSettings iosInitializationSettings = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await notifications.initialize(settings, onSelectNotification: (payload) => callback());
  }

  Future notificationDetails(String? bigText) async{
    final styleInformation = BigTextStyleInformation(bigText!, contentTitle: "¡Nuevos Cupones!");

    return NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        channelDescription: 'description',
        importance: Importance.max,
        priority: Priority.max,
        styleInformation: styleInformation
      ),
      iOS: const IOSNotificationDetails(),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    String? bigText,
    Function? callBackFunction,
  }) async {
    notifications.show(id, title, body, await notificationDetails(bigText), payload: payload);
  }
    

  void onSelectNotification(String? payload) {
    // data = getData();
  }

  void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    print('id $id');
  }
}