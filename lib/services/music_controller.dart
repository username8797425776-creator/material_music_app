import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/song.dart';

class MusicController {
  final YoutubeExplode _client = YoutubeExplode();
  final Map<String, List<Song>> _searchCache = {};
  final Map<String, String> _audioUrlCache = {};
  final Map<String, Future<List<Song>>> _pendingSearches = {};

  Future<List<Song>> searchSongs(String query) async {
    final text = query.trim();
    if (text.isEmpty) return const [];

    final key = text.toLowerCase();
    final cached = _searchCache[key];
    if (cached != null) return cached;

    final pending = _pendingSearches[key];
    if (pending != null) return pending;

    final request = _searchFromNetwork(text);
    _pendingSearches[key] = request;
    try {
      final songs = await request;
      _searchCache[key] = songs;
      return songs;
    } finally {
      _pendingSearches.remove(key);
    }
  }

  Future<List<Song>> _searchFromNetwork(String query) async {
    final results = await _client.search.search(query).timeout(
      const Duration(seconds: 20),
    );
    return results.map((video) {
      return Song(
        id: video.id.value,
        title: video.title,
        artist: video.author,
        thumbnailUrl: video.thumbnails.highResUrl,
        duration: video.duration,
      );
    }).toList(growable: false);
  }

  Future<String> getAudioUrl(String videoId) async {
    final cached = _audioUrlCache[videoId];
    if (cached != null) return cached;

    final manifest = await _client.videos.streams
        .getManifest(videoId)
        .timeout(const Duration(seconds: 30));
    final stream = manifest.audioOnly.withHighestBitrate();
    final url = stream.url.toString();
    _audioUrlCache[videoId] = url;
    return url;
  }

  Future<List<Song>> getRelatedSongs(String videoId) async {
    final video = await _client.videos.get(videoId).timeout(
      const Duration(seconds: 20),
    );
    final related = await _client.videos.getRelatedVideos(video) ?? const [];

    return related.map((item) {
      return Song(
        id: item.id.value,
        title: item.title,
        artist: item.author,
        thumbnailUrl: item.thumbnails.highResUrl,
        duration: item.duration,
      );
    }).toList(growable: false);
  }

  Future<String?> fetchLyrics(String artist, String title) async {
    final uri = Uri.parse(
      'https://api.lyrics.ovh/v1/${Uri.encodeComponent(artist)}/${Uri.encodeComponent(title)}',
    );
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['lyrics'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, int>>> fetchSkipSegments(String videoId) async {
    final uri = Uri(
      scheme: 'https',
      host: 'sponsor.ajay.app',
      path: '/api/skipSegments',
      queryParameters: {
        'videoID': videoId,
        'category': 'sponsor,selfpromo,interaction,intro,outro,music_offtopic',
        'actionType': 'skip',
      },
    );
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return const [];
      final decoded = jsonDecode(response.body) as List;
      return decoded.map((item) {
        final segment = item['segment'] as List;
        return {
          'start': (segment[0] as num).toInt(),
          'end': (segment[1] as num).toInt(),
        };
      }).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  void clearCaches() {
    _searchCache.clear();
    _audioUrlCache.clear();
  }

  void dispose() => _client.close();
}
