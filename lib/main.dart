import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'views/client/login_page.dart';
import 'widgets/app_colors.dart';

void main() {
  runApp(const ServiceBookingApp());
}

class ServiceBookingApp extends StatelessWidget {
  const ServiceBookingApp({super.key});

    ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'DEVMOB-ServiceBooking',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const LoginPage(),
      ),
    );
  }
}