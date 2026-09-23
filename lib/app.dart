import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_music_app/models/song.dart';
import 'package:material_music_app/screens/home_screen.dart';
import 'package:material_music_app/screens/library_screen.dart';
import 'package:material_music_app/screens/player_screen.dart';
import 'package:material_music_app/screens/search_screen.dart';
import 'package:material_music_app/screens/settings_screen.dart';
import 'package:material_music_app/services/audio_player_service.dart';
import 'package:material_music_app/services/music_controller.dart';
import 'package:material_music_app/theme/app_theme.dart';
import 'package:material_music_app/widgets/mini_player_bar.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Pulse Music',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainShell(),
      );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  late final MusicController _musicController;
  late final AudioPlayerService _audioPlayerService;
  Song? _currentSong;
  String? _currentLyrics;
  List<Map<String, int>> _segments = const [];
  bool _openingSong = false;

  @override
  void initState() {
    super.initState();
    _musicController = MusicController();
    _audioPlayerService = AudioPlayerService(_musicController);
  }

  Future<void> openSong(Song song) async {
    if (_openingSong) return;
    setState(() => _openingSong = true);

    try {
      // Start resolving the stream immediately; lyrics and SponsorBlock are secondary.
      final audioFuture = _musicController.getAudioUrl(song.id);
      final metadataFuture = Future.wait<dynamic>([
        _musicController.fetchLyrics(song.artist, song.title),
        _musicController.fetchSkipSegments(song.id),
      ]);
      final audioUrl = await audioFuture;
      await _audioPlayerService.playUrl(audioUrl);
      final metadata = await metadataFuture;

      if (!mounted) return;
      setState(() {
        _currentSong = song;
        _currentLyrics = metadata[0] as String?;
        _segments = (metadata[1] as List<Map<String, int>>?) ?? const [];
      });

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlayerScreen(
            song: song,
            service: _audioPlayerService,
            lyrics: _currentLyrics,
            segments: _segments,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to play this track. Check your connection.')),
        );
      }
    } finally {
      if (mounted) setState(() => _openingSong = false);
    }
  }

  @override
  void dispose() {
    unawaited(_audioPlayerService.dispose());
    _musicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onSongTap: openSong, controller: _musicController),
      SearchScreen(onSongTap: openSong, controller: _musicController),
      const LibraryScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentSong != null)
            MiniPlayerBar(
              title: _currentSong!.title,
              artist: _currentSong!.artist,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PlayerScreen(
                  song: _currentSong!,
                  service: _audioPlayerService,
                  lyrics: _currentLyrics,
                  segments: _segments,
                ),
              )),
            ),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search_rounded), label: 'Search'),
              NavigationDestination(icon: Icon(Icons.library_music_outlined), selectedIcon: Icon(Icons.library_music_rounded), label: 'Library'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
            ],
          ),
        ],
      ),
    );
  }
}
