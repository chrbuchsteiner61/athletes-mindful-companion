import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/active_session_notifier.dart';
import '../../widgets/common_widgets.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _headlineAsked = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final active = ref.read(activeSessionProvider);
    if (!_headlineAsked && active.session != null && active.session!.headline == null && text.isNotEmpty) {
      await ref.read(activeSessionProvider.notifier).setHeadline(text);
      _headlineAsked = true;
    } else {
      await ref.read(activeSessionProvider.notifier).sendUserMessage(text);
    }
    _textCtrl.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _finalize() async {
    final insight = await ref.read(activeSessionProvider.notifier).finalizeReflection();
    if (insight != null && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _InsightDialog(insight: insight.insight, impulse: insight.impulse),
      );
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(activeSessionProvider);
    final messages = active.messages;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Mental Coach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded),
            tooltip: 'Reflexion abschließen',
            onPressed: messages.length > 1 ? _finalize : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                itemCount: messages.length + (active.isCoachTyping ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == messages.length && active.isCoachTyping) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _TypingBubble(),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ChatBubble(message: messages[i]),
                  );
                },
              ),
            ),
            if (active.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(active.error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
            _QuickReplies(onTap: (label) => _send(label)),
            _InputBar(
              controller: _textCtrl,
              onSend: _send,
              onVoice: (t) => _send(t),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickReplies extends StatelessWidget {
  const _QuickReplies({required this.onTap});
  final ValueChanged<String> onTap;

  static const _emotions = ['Neugier', 'Angst / Unsicherheit', 'Frust', 'Stolz', 'Ungeduld', 'Gelassenheit'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _emotions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return ActionChip(
            label: Text(_emotions[i]),
            onPressed: () => onTap(_emotions[i]),
            backgroundColor: AppTheme.sand,
            side: BorderSide(color: AppTheme.sage.withOpacity(0.3)),
          );
        },
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend, required this.onVoice});
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final ValueChanged<String> onVoice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          VoiceRecorderButton(onTranscript: onVoice),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: onSend,
              decoration: InputDecoration(hintText: 'Text eingeben…', suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded, color: AppTheme.sage),
                onPressed: () => onSend(controller.text),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const SizedBox(
        width: 48,
        height: 16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Dot(), _Dot(), _Dot(),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(color: AppTheme.sage, shape: BoxShape.circle),
    );
  }
}

class _InsightDialog extends StatelessWidget {
  const _InsightDialog({required this.insight, required this.impulse});
  final String insight;
  final String impulse;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ERKENNTNIS DER SESSION',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.sage, letterSpacing: 1)),
            const SizedBox(height: 16),
            InsightCard(insight: insight, impulse: impulse),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Impuls speichern & zurück'),
            ),
          ],
        ),
      ),
    );
  }
}
