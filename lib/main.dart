// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/theme/app_theme.dart';
import 'package:kampus_koin_app/routing/app_router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Kampus Koin',
      theme: AppTheme.lightTheme, // Apply our custom theme
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
