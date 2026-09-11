import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _keyCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await ref.read(secureStorageProvider).getLlmApiKey();
    _keyCtrl.text = key ?? '';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveKey() async {
    final v = _keyCtrl.text.trim();
    if (v.isEmpty) {
      await ref.read(secureStorageProvider).deleteLlmApiKey();
    } else {
      await ref.read(secureStorageProvider).saveLlmApiKey(v);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API-Schlüssel gespeichert.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('LLM-API-Schlüssel (Mistral)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.sage, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            const Text('Ohne Schlüssel läuft die App im Offline-Modus mit der Regel-basierten Mock-Engine.',
                style: TextStyle(fontSize: 13, color: AppTheme.muted)),
            const SizedBox(height: 12),
            TextField(
              controller: _keyCtrl,
              obscureText: true,
              enabled: !_loading,
              decoration: const InputDecoration(hintText: 'sk-…'),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _saveKey, child: const Text('Speichern')),
            const SizedBox(height: 32),
            const Text('Datenschutz',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.sage, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            const Text(
                'Alle Daten liegen lokal auf deinem Gerät. Bei Nutzung der LLM-API werden nur anonymisierte Transkripte gesendet.',
                style: TextStyle(fontSize: 13, color: AppTheme.muted)),
          ],
        ),
      ),
    );
  }
}
