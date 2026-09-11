import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/models.dart';
import '../../providers/active_session_notifier.dart';

class PreSessionScreen extends ConsumerStatefulWidget {
  const PreSessionScreen({super.key});

  @override
  ConsumerState<PreSessionScreen> createState() => _PreSessionScreenState();
}

class _PreSessionScreenState extends ConsumerState<PreSessionScreen> {
  int _step = 0;
  SportType _sport = SportType.golf;
  bool _competition = false;
  int _energy = 7;
  String? _focus;
  final _focusCtrl = TextEditingController();
  final _anchorCtrl = TextEditingController();

  static const _focusOptions = ['Pre-Shot Routine einhalten', 'Fehler schnell abhaken', 'Rhythmus halten'];

  @override
  void dispose() {
    _focusCtrl.dispose();
    _anchorCtrl.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    await ref.read(activeSessionProvider.notifier).startSession(
          sport: _sport,
          isCompetition: _competition,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_step == 0) {
              Navigator.of(context).pop();
            } else {
              setState(() => _step--);
            }
          },
        ),
        title: const Text('Vorbereitung'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_step + 1) / 4,
                minHeight: 4,
                backgroundColor: AppTheme.sand,
                color: AppTheme.sage,
              ),
              const SizedBox(height: 8),
              Text('Schritt ${_step + 1} von 4',
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
              const SizedBox(height: 24),
              Expanded(child: _stepContent()),
              const SizedBox(height: 16),
              if (_step < 3)
                FilledButton(
                  onPressed: _next,
                  child: Text(_step == 0 ? 'Weiter' : 'Weiter'),
                )
              else
                FilledButton(
                  onPressed: _finish,
                  child: const Text('Zur Reflexion bereit'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepContent() {
    switch (_step) {
      case 0:
        return _stepSetup();
      case 1:
        return _stepEnergy();
      case 2:
        return _stepFocus();
      case 3:
        return _stepAnchor();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _stepSetup() {
    return ListView(
      children: [
        const Text('Worum geht es heute?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.ink)),
        const SizedBox(height: 24),
        const Text('Sportart', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.muted, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: SportType.values.map((s) {
            return ChoiceChip(
              label: Text(_sportName(s)),
              selected: _sport == s,
              onSelected: (v) => setState(() => _sport = s),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text('Art der Einheit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.muted, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(label: const Text('Training'), selected: !_competition, onSelected: (_) => setState(() => _competition = false)),
            ChoiceChip(label: const Text('Wettkampf'), selected: _competition, onSelected: (_) => setState(() => _competition = true)),
          ],
        ),
      ],
    );
  }

  Widget _stepEnergy() {
    return ListView(
      children: [
        const Text('Wie steht es um deine Energie und mentale Präsenz heute?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.ink)),
        const SizedBox(height: 32),
        EnergyBarometer(
          label: 'KÖRPERLICHE ENERGIE',
          initialValue: _energy,
          onChanged: (v) => setState(() => _energy = v),
        ),
        const SizedBox(height: 24),
        const Text('Diese Basis hilft uns, deinen Fokus passend zu wählen.',
            style: TextStyle(fontSize: 14, color: AppTheme.muted)),
      ],
    );
  }

  Widget _stepFocus() {
    return ListView(
      children: [
        const Text('Wähle deinen Hauptfokus für heute',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.ink)),
        const SizedBox(height: 24),
        ..._focusOptions.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FocusTile(
                label: f,
                selected: _focus == f,
                onTap: () => setState(() {
                  _focus = f;
                  _focusCtrl.text = f;
                }),
              ),
            )),
        const SizedBox(height: 12),
        TextField(
          controller: _focusCtrl,
          decoration: const InputDecoration(hintText: 'Eigenes Wort…'),
          onChanged: (v) => setState(() => _focus = v.isEmpty ? null : v),
        ),
      ],
    );
  }

  Widget _stepAnchor() {
    return ListView(
      children: [
        const Text('Mit welchen 2 Worten beschreibst du das Gefühl, das du heute verkörpern willst?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.ink)),
        const SizedBox(height: 24),
        TextField(
          controller: _anchorCtrl,
          decoration: const InputDecoration(hintText: 'z. B. „Ruhig und vertrauend“'),
          autofocus: true,
        ),
        const SizedBox(height: 16),
        const Text('Diese Worte sind dein mentaler Anker für die Einheit.',
            style: TextStyle(fontSize: 14, color: AppTheme.muted)),
      ],
    );
  }

  void _next() async {
    if (_step == 0 && ref.read(activeSessionProvider).session == null) {
      await _startSession();
    }
    if (_step == 1) {
      await ref.read(activeSessionProvider.notifier).setEnergyPre(_energy);
    }
    if (_step == 2 && _focus != null) {
      await ref.read(activeSessionProvider.notifier).setPrimaryFocus(_focus!);
    }
    setState(() => _step++);
  }

  Future<void> _finish() async {
    final words = _anchorCtrl.text.split(RegExp(r'[\s,]+')).where((s) => s.isNotEmpty).toList();
    if (words.isNotEmpty) {
      await ref.read(activeSessionProvider.notifier).setAnchorWords(words);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  String _sportName(SportType s) => switch (s) {
        SportType.golf => 'Golf',
        SportType.tennis => 'Tennis',
        SportType.running => 'Laufen',
        SportType.general => 'Allgemein',
      };
}

class _FocusTile extends StatelessWidget {
  const _FocusTile({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.sage.withOpacity(0.12) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? AppTheme.sage : AppTheme.sand),
          ),
          child: Row(
            children: [
              Icon(selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: AppTheme.sage, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      ),
    );
  }
}
