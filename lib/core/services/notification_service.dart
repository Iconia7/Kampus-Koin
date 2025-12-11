// lib/core/services/notification_service.dart

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Top-level function for background handling (Must be outside any class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await AwesomeNotifications().initialize(
    // CHANGE 1: Set the default icon path here for background notifications
    // Ensure you have 'res_app_icon.png' in android/app/src/main/res/drawable/
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelGroupKey: 'financial_channel_group',
        channelKey: 'financial_alerts',
        channelName: 'Financial Alerts',
        channelDescription: 'Notifications for deposits and repayments',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        playSound: true,
        criticalAlerts: true,
      ),
    ],
  );

  // Manually show notification in background based on data
  if (message.data.isNotEmpty) {
     final title = message.data['title'];
     final body = message.data['body'];
     final type = message.data['type'];

     if(title != null && body != null){
        if (type == 'deposit') {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                channelKey: 'financial_alerts',
                title: title,
                body: body,
                notificationLayout: NotificationLayout.BigText,
                color: Colors.green,
                backgroundColor: Colors.green,
              ),
            );
        } else {
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                channelKey: 'financial_alerts',
                title: title,
                body: body,
              ),
            );
        }
     }
  }
}

class NotificationService {
  
  // 1. Initialize
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      // CHANGE 2: Set the default icon path here for foreground/app-open notifications
      // Ensure you have 'res_app_icon.png' in android/app/src/main/res/drawable/
      'resource://drawable/res_app_icon', 
      [
        NotificationChannel(
          channelGroupKey: 'financial_channel_group',
          channelKey: 'financial_alerts',
          channelName: 'Financial Alerts',
          channelDescription: 'Notifications for deposits and repayments',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelGroupKey: 'gamified_channel_group',
          channelKey: 'gamified_updates',
          channelName: 'Goals & Rewards',
          channelDescription: 'Updates on goals and koin score',
          defaultColor: Colors.orange,
          importance: NotificationImportance.Default,
        ),
      ],
      // Channel groups
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'financial_channel_group',
          channelGroupName: 'Finance',
        ),
        NotificationChannelGroup(
          channelGroupKey: 'gamified_channel_group',
          channelGroupName: 'Rewards',
        )
      ],
      debug: true,
    );

    // Request permission immediately
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Set up background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // 2. Setup Listeners (Call this in main.dart or after login)
  void setupFirebaseListeners() {
    // Foreground Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.data.isNotEmpty) {
        final title = message.data['title'] ?? 'Notification';
        final body = message.data['body'] ?? '';
        final type = message.data['type'];
        final amount = message.data['amount'];
        final goalName = message.data['goal_name'];

        // Trigger specific Awesome Notification based on type
        if (type == 'deposit' && amount != null && goalName != null) {
          showDepositSuccess(amount, goalName);
        } else {
          // Fallback generic
          showLocalNotification(title: title, body: body);
        }
      }
    });
  }

  // 3. Event Listeners (What happens when you tap a notification)
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if (receivedAction.payload?['path'] != null) {
      print("Navigate to: ${receivedAction.payload!['path']}");
    }
  }

  // 4. Trigger Local Notification (Simple)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    int? id,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'gamified_updates', 
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> scheduleRepaymentReminders(String productName) async {
    final now = DateTime.now();
    
    // Loop to schedule 6 monthly notifications
    for (int i = 1; i <= 6; i++) {
      // Calculate date: roughly 30 days * month count
      final futureDate = now.add(Duration(days: 30 * i));
      
      // Set time to 10:00 AM on that day so it doesn't wake user up at night
      final scheduleDate = DateTime(
        futureDate.year, 
        futureDate.month, 
        futureDate.day, 
        10, 0, 0 // 10:00 AM
      );

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          // Unique ID for each month (base + index)
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000) + i,
          channelKey: 'financial_alerts',
          title: 'Installment $i Due 📅',
          body: 'Your month $i payment for $productName is due today. Pay now to keep your Koin Score high!',
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar.fromDate(
           date: scheduleDate,
           allowWhileIdle: true,
        ),
      );
    }
  }

  // 5. Trigger Rich Payment Notification (With Icons/Color)
  Future<void> showDepositSuccess(String amount, String goalName) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'financial_alerts',
        title: '💰 Deposit Confirmed!',
        body: 'Ksh. $amount has been successfuly deposited and added to "$goalName".',
        notificationLayout: NotificationLayout.BigText,
        color: Colors.green,
        backgroundColor: Colors.green, // For Android
      ),
    );
  }

    Future<void> showOrderSuccess(String productName) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'gamified_updates',
        title: 'Order Confirmed! 🛍️',
        body: 'You have successfully unlocked $productName. Go to marketplace to view your ticket!',
        notificationLayout: NotificationLayout.BigText,
        payload: {'path': '/profile'},
        color: Colors.deepPurple,
      ),
    );
  }
  
  // 6. Trigger Progress Bar Notification
  Future<void> showGoalProgress(String goalName, double progress) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 888, // Fixed ID so updates replace the old one
        channelKey: 'gamified_updates',
        title: '$goalName Progress',
        body: 'You are $progress% of the way there!',
        notificationLayout: NotificationLayout.ProgressBar,
        progress: progress, // 0 to 100
      ),
    );
  }

  // 7. Trigger Unlock Alert (Added Missing Method)
  Future<void> showUnlockAlert(String productName) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'gamified_updates',
        title: '🔓 New Item Unlocked!',
        body: 'Your Koin Score is high enough to get the $productName. Check the Marketplace!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Recommendation,
        wakeUpScreen: true,
      ),
    );
  }

  // 8. Token Sync
  Future<void> syncTokenWithServer(ApiService apiService) async {
    print("🔔 SYNC: Starting FCM Token Sync...");
    try {
      await FirebaseMessaging.instance.requestPermission();
      
      String? token = await FirebaseMessaging.instance.getToken();
      
      if (token != null) {
        try {
          await apiService.updateFcmToken(token);
          print("🔔 SYNC: ✅ Backend accepted the token!");
        } catch (apiError) {
          print("🔔 SYNC: ❌ Backend rejected the token: $apiError");
        }
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        apiService.updateFcmToken(newToken);
      });
      
    } catch (e) {
      print("🔔 SYNC: ❌ General Error during sync: $e");
    }
  }
}