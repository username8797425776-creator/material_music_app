import 'package:flutter/material.dart';
import 'package:material_music_app/models/song.dart';
import 'package:material_music_app/services/music_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = MusicController();
  final TextEditingController _query = TextEditingController();
  List<Song> _results = [];
  bool _loading = false;

  Future<void> _search() async {
    final q = _query.text.trim();
    if (q.isEmpty) return;

    setState(() => _loading = true);

    try {
      final songs = await _controller.searchSongs(q);
      if (!mounted) return;
      setState(() => _results = songs);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchBar(
              controller: _query,
              hintText: 'Search songs, artists or albums',
              leading: const Icon(Icons.search),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_results.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Try searching for a song or artist'),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: item.thumbnailUrl != null
                            ? Image.network(
                                item.thumbnailUrl!,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 52,
                                height: 52,
                                color: Theme.of(context).colorScheme.primaryContainer,
                                child: const Icon(Icons.music_note_rounded),
                              ),
                      ),
                      title: Text(item.title),
                      subtitle: Text(item.artist),
                      trailing: const Icon(Icons.play_arrow_rounded),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _query.dispose();
    _controller.dispose();
    super.dispose();
  }
}
