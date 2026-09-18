import 'package:flutter/material.dart';
import 'package:material_music_app/screens/playlist_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlists = [
      ('Liked Songs', 24),
      ('Recently Played', 18),
      ('Downloads', 42),
      ('Focus', 16),
      ('Night Drives', 31),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Your Library')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: playlists.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (name, count) = playlists[index];
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
            title: Text(name),
            subtitle: Text('$count tracks'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlaylistScreen(name: name, trackCount: count),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
