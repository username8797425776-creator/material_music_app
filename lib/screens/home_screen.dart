import 'package:flutter/material.dart';
import 'package:material_music_app/models/song.dart';
import 'package:material_music_app/services/music_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MusicController();

    final mockSongs = [
      const Song(
        id: 'dQw4w9WgXcQ',
        title: 'Never Gonna Give You Up',
        artist: 'Rick Astley',
        thumbnailUrl: null,
      ),
      const Song(
        id: 'ScMzIvxBSi4',
        title: 'A Sky Full of Stars',
        artist: 'Coldplay',
        thumbnailUrl: null,
      ),
      const Song(
        id: '2Vv-BfVoR4g',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        thumbnailUrl: null,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse Music'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Good evening',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: mockSongs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final song = mockSongs[index];
                  return SizedBox(
                    width: 180,
                    child: Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.music_note_rounded, size: 56),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(song.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                            Text(
                              song.artist,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border_rounded),
                    label: const Text('Liked'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.queue_music_rounded),
                    label: const Text('Mixes'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('For you', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockSongs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final song = mockSongs[index];
                return ListTile(
                  leading: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.album_rounded),
                  ),
                  title: Text(song.title),
                  subtitle: Text(song.artist),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
