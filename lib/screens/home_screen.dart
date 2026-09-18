import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/music_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onSongTap,
    required this.controller,
  });

  final Function(Song) onSongTap;
  final MusicController controller;

  Future<List<Song>> _loadTrending() async {
    return controller.searchSongs('trending songs');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse Music'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Song>>(
          future: _loadTrending(),
          builder: (context, snapshot) {
            final songs = snapshot.data ?? const [];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Good evening',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: songs.length > 4 ? 4 : songs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => onSongTap(song),
                        child: SizedBox(
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
                                      child: song.thumbnailUrl == null
                                          ? const Icon(Icons.music_note_rounded, size: 56)
                                          : Image.network(
                                              song.thumbnailUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    song.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    song.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
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
                Text(
                  'For you',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (songs.isEmpty)
                  const Center(child: Text('No tracks yet'))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: songs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: song.thumbnailUrl == null
                              ? Container(
                                  width: 52,
                                  height: 52,
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  child: const Icon(Icons.music_note_rounded),
                                )
                              : Image.network(
                                  song.thumbnailUrl!,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        title: Text(song.title),
                        subtitle: Text(song.artist),
                        onTap: () => onSongTap(song),
                        trailing: const Icon(Icons.more_vert_rounded),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
