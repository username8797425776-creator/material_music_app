import 'dart:async';
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
  StreamSubscription<Duration>? _positionSub;

  @override
  void initState() {
    super.initState();
    _positionSub = widget.service.positionStream.listen((position) {
      final seconds = position.inSeconds;
      for (final segment in widget.segments) {
        final start = segment['start']!;
        final end = segment['end']!;
        if (seconds >= start && seconds < end) {
          widget.service.seek(Duration(seconds: end));
          break;
        }
      }
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: widget.song.thumbnailUrl == null
                        ? const Icon(Icons.music_note_rounded, size: 120)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(30),
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
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                widget.song.artist,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              StreamBuilder<Duration>(
                stream: widget.service.positionStream,
                builder: (context, posSnapshot) {
                  final position = posSnapshot.data ?? Duration.zero;
                  final duration = widget.service.player.duration ?? Duration.zero;
                  final maxValue = duration.inMilliseconds > 0
                      ? duration.inMilliseconds.toDouble()
                      : 1;
                  final value = math.min(position.inMilliseconds.toDouble(), maxValue);

                  return Column(
                    children: [
                      Slider(
                        value: value,
                        min: 0,
                        max: maxValue,
                        onChanged: (newValue) {
                          widget.service.seek(
                            Duration(milliseconds: newValue.round()),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position)),
                            Text(_formatDuration(duration)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
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
                      final state = widget.service.player.playerState.processingState;
                      if (state == ProcessingState.ready ||
                          state == ProcessingState.completed) {
                        await widget.service.play();
                      } else {
                        await widget.service.pause();
                      }
                    },
                    child: StreamBuilder<PlayerState>(
                      stream: widget.service.playerStateStream,
                      builder: (context, snapshot) {
                        final playing = snapshot.data?.playing ?? false;
                        return Icon(
                          playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 36,
                        );
                      },
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
              if (widget.lyrics != null && widget.lyrics!.isNotEmpty)
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
