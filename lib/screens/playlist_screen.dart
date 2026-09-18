import 'package:flutter/material.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({
    super.key,
    required this.name,
    required this.trackCount,
  });

  final String name;
  final int trackCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: trackCount,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.music_note_rounded),
            ),
            title: Text('Track ${index + 1}'),
            subtitle: Text('Playlist • $name'),
            trailing: const Icon(Icons.play_arrow_rounded),
          );
        },
      ),
    );
  }
}
