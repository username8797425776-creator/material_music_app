import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/music_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.onSongTap,
    required this.controller,
  });

  final Function(Song) onSongTap;
  final MusicController controller;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  List<Song> _results = const [];
  bool _loading = false;

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() => _loading = true);

    try {
      final songs = await widget.controller.searchSongs(query);
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
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchBar(
              controller: _queryController,
              hintText: 'Search songs, artists',
              leading: const Icon(Icons.search_rounded),
              trailing: [
                IconButton(
                  onPressed: _search,
                  icon: const Icon(Icons.arrow_forward_rounded),
                )
              ],
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_results.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Search for a song or artist'),
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
                        child: item.thumbnailUrl == null
                            ? Container(
                                width: 52,
                                height: 52,
                                color: Theme.of(context).colorScheme.primaryContainer,
                                child: const Icon(Icons.music_note_rounded),
                              )
                            : Image.network(
                                item.thumbnailUrl!,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                              ),
                      ),
                      title: Text(item.title),
                      subtitle: Text(item.artist),
                      trailing: const Icon(Icons.play_arrow_rounded),
                      onTap: () => widget.onSongTap(item),
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
    _queryController.dispose();
    super.dispose();
  }
}
