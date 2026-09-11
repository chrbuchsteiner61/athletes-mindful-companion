import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/pre_session/pre_session_screen.dart';
import 'presentation/screens/coach/coach_screen.dart';
import 'presentation/screens/archive/archive_screen.dart';
import 'presentation/screens/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: AthletesMindfulCompanionApp()));
}

class AthletesMindfulCompanionApp extends StatelessWidget {
  const AthletesMindfulCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Athlete's Mindful Companion",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const RootScaffold(),
    );
  }
}

class RootScaffold extends ConsumerStatefulWidget {
  const RootScaffold({super.key});

  @override
  ConsumerState<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends ConsumerState<RootScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(
            onStartPreSession: () => _startPreSession(),
            onStartPostSession: () => _startPostSession(),
          ),
          const ArchiveScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: const Color(0xFFFAF8F3),
        indicatorColor: AppTheme.sage.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.archive_outlined), selectedIcon: Icon(Icons.archive_rounded), label: 'Archiv'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Einst.'),
        ],
      ),
    );
  }

  Future<void> _startPreSession() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PreSessionScreen()),
    );
    if (result == true && mounted) {
      _startPostSession();
    }
  }

  Future<void> _startPostSession() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachScreen(onFinished: () => Navigator.of(context).pop()),
      ),
    );
    if (mounted) setState(() => _index = 0);
  }
}
