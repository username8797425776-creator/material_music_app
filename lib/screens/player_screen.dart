import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import '../services/audio_player_service.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.song,
    required this.service,
    this.lyrics,
    this.segments = const [],
  });

  final Song song;
  final AudioPlayerService service;
  final String? lyrics;
  final List<Map<String, int>> segments;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.service.positionStream.listen((position) {
      if (!mounted) return;
      setState(() => _position = position);

      for (final segment in widget.segments) {
        final start = segment['start']!;
        final end = segment['end']!;
        if (position.inSeconds >= start && position.inSeconds < end) {
          widget.service.seek(Duration(seconds: end));
          break;
        }
      }
    });

    widget.service.durationStream.listen((duration) {
      if (!mounted) return;
      if (duration != null) setState(() => _duration = duration);
    });

    widget.service.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state.playing);
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = _duration.inMilliseconds > 0
        ? _duration.inMilliseconds.toDouble()
        : 1.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
        title: const Text('Now playing'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: widget.song.thumbnailUrl == null
                        ? const Icon(Icons.music_note_rounded, size: 110)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.network(
                              widget.song.thumbnailUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.song.title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                widget.song.artist,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              Slider(
                value: math.min(_position.inMilliseconds.toDouble(), maxValue),
                max: maxValue,
                onChanged: (value) {
                  widget.service.seek(Duration(milliseconds: value.round()));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_position)),
                    Text(_formatDuration(_duration)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    iconSize: 36,
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  const SizedBox(width: 18),
                  FloatingActionButton.large(
                    onPressed: () async {
                      if (_isPlaying) {
                        await widget.service.pause();
                      } else {
                        await widget.service.play();
                      }
                    },
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 18),
                  IconButton(
                    onPressed: () {},
                    iconSize: 36,
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (widget.lyrics != null && widget.lyrics!.trim().isNotEmpty)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.lyrics!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                )
              else
                const Text('Lyrics unavailable for this track'),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
