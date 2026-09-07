import 'package:flutter/material.dart';
import 'package:athletes_mindful_companion/core/theme/app_theme.dart';
import 'package:athletes_mindful_companion/features/session/presentation/dashboard_screen.dart';

class AthletesMindfulCompanionApp extends StatelessWidget {
  const AthletesMindfulCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Athlete\'s Mindful Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const DashboardScreen(),
    );
  }
}