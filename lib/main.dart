import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';
import 'package:kampus_koin_app/core/services/notification_service.dart';
import 'package:kampus_koin_app/core/theme/app_theme.dart';
import 'package:kampus_koin_app/routing/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // 2. Initialize Notification Service
  // This method now handles:
  // - Channel creation
  // - Permission requests
  // - Registering the Background Handler (so we don't need it in main.dart anymore)
  await NotificationService.initializeNotification();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  
  @override
  void initState() {
    super.initState();
    
    // 3. Listen for Notification Taps (Navigation logic)
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationService.onActionReceivedMethod,
    );

    // 4. Setup Logic that requires Ref (Foreground Listeners & Sync)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService = ref.read(notificationServiceProvider);
      final apiService = ref.read(apiServiceProvider);

      // A. Activate the "Data-Only" foreground listener
      // This ensures we parse the 'type' (deposit/repayment) correctly even when app is open
      notificationService.setupFirebaseListeners();
      
      // B. Sync FCM token with backend
      notificationService.syncTokenWithServer(apiService);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Kampus Koin',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}