import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EnergyBarometer extends StatefulWidget {
  const EnergyBarometer({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final int initialValue;
  final ValueChanged<int> onChanged;

  @override
  State<EnergyBarometer> createState() => _EnergyBarometerState();
}

class _EnergyBarometerState extends State<EnergyBarometer> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.muted, letterSpacing: 0.5)),
            Text('${_value.round()}/10',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink)),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _value,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: AppTheme.sage,
          onChanged: (v) {
            setState(() => _value = v);
            widget.onChanged(v.round());
          },
        ),
      ],
    );
  }
}

class EmotionChips extends StatefulWidget {
  const EmotionChips({
    super.key,
    required this.options,
    required this.onSelectionChanged,
    this.maxSelections = 2,
  });

  final List<String> options;
  final ValueChanged<List<String>> onSelectionChanged;
  final int maxSelections;

  @override
  State<EmotionChips> createState() => _EmotionChipsState();
}

class _EmotionChipsState extends State<EmotionChips> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.options.map((label) {
        final selected = _selected.contains(label);
        return FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: (v) {
            setState(() {
              if (v) {
                if (_selected.length >= widget.maxSelections) {
                  _selected.remove(_selected.first);
                }
                _selected.add(label);
              } else {
                _selected.remove(label);
              }
              widget.onSelectionChanged(_selected.toList());
            });
          },
        );
      }).toList(),
    );
  }
}

class VoiceRecorderButton extends StatefulWidget {
  const VoiceRecorderButton({super.key, required this.onTranscript});

  final ValueChanged<String> onTranscript;

  @override
  State<VoiceRecorderButton> createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton> {
  bool _recording = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _recording = !_recording);
        if (!_recording) {
          widget.onTranscript('[Sprachnotiz erfasst]');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _recording ? AppTheme.sage.withOpacity(0.15) : AppTheme.sand,
          shape: BoxShape.circle,
        ),
        child: Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded,
            color: AppTheme.sage, size: 28),
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.insight,
    required this.impulse,
  });

  final String insight;
  final String impulse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF1EC), Color(0xFFF5F1E8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.sage.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline_rounded, color: AppTheme.sage, size: 20),
              SizedBox(width: 6),
              Text('ERKENNTNIS',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.sage, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),
          Text(insight, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.4)),
          const SizedBox(height: 18),
          Row(
            children: const [
              Icon(Icons.flag_outlined, color: AppTheme.sage, size: 20),
              SizedBox(width: 6),
              Text('TRAININGSTRANSFER',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.sage, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),
          Text('“$impulse”',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4)),
        ],
      ),
    );
  }
}

class TrendBar extends StatelessWidget {
  const TrendBar({
    super.key,
    required this.label,
    required this.percentage,
    required this.delta,
  });

  final String label;
  final int percentage;
  final int delta;

  @override
  Widget build(BuildContext context) {
    final deltaText = '${delta >= 0 ? '+' : ''}$delta%';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.ink)),
              Text('$percentage%  $deltaText',
                  style: TextStyle(
                    fontSize: 13,
                    color: delta >= 0 ? AppTheme.sage : Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: AppTheme.sand,
              color: AppTheme.sage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});
  final dynamic message;

  @override
  Widget build(BuildContext context) {
    final isCoach = message.role.name == 'coach';
    return Align(
      alignment: isCoach ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCoach ? Colors.white : AppTheme.sage,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isCoach ? Radius.zero : const Radius.circular(16),
            bottomRight: isCoach ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: Text(
          message.content as String,
          style: TextStyle(
            color: isCoach ? AppTheme.ink : Colors.white,
            fontSize: 15,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
