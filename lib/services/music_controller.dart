import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/song.dart';

class MusicController {
  final YoutubeExplode _client = YoutubeExplode();

  // Search
  Future<List<Song>> searchSongs(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final results = await _client.search.search(trimmed);
    return results.map((video) {
      return Song(
        id: video.id.value,
        title: video.title,
        artist: video.author,
        thumbnailUrl: video.thumbnails.highResUrl,
        duration: video.duration,
      );
    }).toList();
  }

  // Audio URL
  Future<String> getAudioUrl(String videoId) async {
    final manifest = await _client.videos.streams.getManifest(videoId);
    final stream = manifest.audioOnly.withHighestBitrate();
    return stream.url.toString();
  }

  // Similar songs
  Future<List<Song>> getRelatedSongs(String videoId) async {
    final video = await _client.videos.get(videoId);
    final list = await _client.videos.getRelatedVideos(video) ?? const [];

    return list.map((item) {
      return Song(
        id: item.id.value,
        title: item.title,
        artist: item.author,
        thumbnailUrl: item.thumbnails.highResUrl,
        duration: item.duration,
      );
    }).toList();
  }

  // Lyrics from Lyrics.ovh
  Future<String?> fetchLyrics(String artist, String title) async {
    final uri = Uri.parse(
      'https://api.lyrics.ovh/v1/${Uri.encodeComponent(artist)}/${Uri.encodeComponent(title)}',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['lyrics'] as String?;
    } catch (_) {
      return null;
    }
  }

  // SponsorBlock skip segments for the video
  Future<List<Map<String, int>>> fetchSkipSegments(String videoId) async {
    final uri = Uri(
      scheme: 'https',
      host: 'sponsor.ajay.app',
      path: '/api/skipSegments',
      queryParameters: {
        'videoID': videoId,
        'category': [
          'sponsor',
          'selfpromo',
          'interaction',
          'intro',
          'outro',
          'music_offtopic',
        ].join(','),
        'actionType': 'skip',
      },
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 404 || response.statusCode == 204) {
        return const [];
      }
      if (response.statusCode != 200) {
        return const [];
      }

      final decoded = jsonDecode(response.body) as List;
      return decoded.map((item) {
        final segment = item['segment'] as List;
        return {
          'start': (segment[0] as num).toInt(),
          'end': (segment[1] as num).toInt(),
        };
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> dispose() async {
    _client.close();
  }
}
