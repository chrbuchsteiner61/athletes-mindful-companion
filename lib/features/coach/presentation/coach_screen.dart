import 'package:flutter/material.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Coach')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'A calm place to think out loud.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('Write down what is on your mind and return to it when you are ready.'),
                const SizedBox(height: 24),
                TextField(
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'What are you noticing today?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Save note'),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}