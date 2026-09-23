import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/music_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onSongTap, required this.controller});

  final ValueChanged<Song> onSongTap;
  final MusicController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Song>> _trendingFuture;

  @override
  void initState() {
    super.initState();
    _trendingFuture = widget.controller.searchSongs('trending songs');
  }

  Future<void> _refresh() async {
    widget.controller.clearCaches();
    setState(() {
      _trendingFuture = widget.controller.searchSongs('trending songs');
    });
    await _trendingFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse Music'),
        actions: [
          IconButton(
            onPressed: _refresh,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Song>>(
            future: _trendingFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 260),
                    Center(child: Text('Could not load music. Pull to retry.')),
                  ],
                );
              }
              final songs = snapshot.data ?? const <Song>[];
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Good evening', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: songs.length > 4 ? 4 : songs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => _SongCard(
                        song: songs[index],
                        onTap: () => widget.onSongTap(songs[index]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('For you', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  for (final song in songs)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: _Artwork(song: song, size: 52),
                      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () => widget.onSongTap(song),
                      trailing: const Icon(Icons.play_arrow_rounded),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  const _SongCard({required this.song, required this.onTap});
  final Song song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 180,
          child: Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _Artwork(song: song, size: double.infinity)),
                  const SizedBox(height: 8),
                  Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      );
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.song, required this.size});
  final Song song;
  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: size == double.infinity ? double.infinity : size,
          height: size == double.infinity ? double.infinity : size,
          child: song.thumbnailUrl == null
              ? ColoredBox(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: const Icon(Icons.music_note_rounded),
                )
              : Image.network(
                  song.thumbnailUrl!,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: const Icon(Icons.music_note_rounded),
                  ),
                ),
        ),
      );
}
