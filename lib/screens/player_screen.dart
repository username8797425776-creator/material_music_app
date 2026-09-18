import 'package:flutter/material.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({
    super.key,
    required this.title,
    required this.artist,
    required this.cover,
  });

  final String title;
  final String artist;
  final String? cover;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
        title: const Text('Now playing'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: cover == null
                        ? const Icon(Icons.music_note, size: 110)
                        : Image.network(
                            cover!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                artist,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: const Slider(value: 0.4, onChanged: null),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1:32'),
                    Text('3:11'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    iconSize: 36,
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  const SizedBox(width: 18),
                  FloatingActionButton.large(
                    onPressed: () {},
                    child: const Icon(Icons.pause_rounded),
                  ),
                  const SizedBox(width: 18),
                  IconButton(
                    onPressed: () {},
                    iconSize: 36,
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
