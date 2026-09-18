import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlists = [
      'Liked Songs',
      'Recently Played',
      'Downloads',
      'Focus',
      'Night Drives',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Your Library')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: playlists.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = playlists[index];
          return ListTile(
            leading: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.queue_music_rounded),
            ),
            title: Text(item),
            subtitle: const Text('24 tracks'),
            trailing: const Icon(Icons.chevron_right_rounded),
          );
        },
      ),
    );
  }
}
