import 'package:flutter/material.dart';

class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Today\'s session'),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Take a moment to arrive.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'A short reset can change the way you enter your next effort.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.waves_outlined, size: 32),
                        const SizedBox(height: 18),
                        Text(
                          'Pre-performance reset',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text('Breathe, notice, and choose your intention.'),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start session'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const _PromptCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: const ListTile(
        leading: Icon(Icons.lightbulb_outline),
        title: Text('Reflection prompt'),
        subtitle: Text('What do you want to bring to your next attempt?'),
      ),
    );
  }
}