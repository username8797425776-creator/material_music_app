import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import 'music_controller.dart';

class AudioPlayerService {
  final MusicController musicController;
  final AudioPlayer _player = AudioPlayer();

  AudioPlayerService(this.musicController);
  AudioPlayer get player => _player;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> playSong(Song song) async {
    final url = await musicController.getAudioUrl(song.id);
    await playUrl(url);
  }

  Future<void> playUrl(String url) async {
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> pause() => _player.pause();
  Future<void> play() => _player.play();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration duration) => _player.seek(duration);
  Future<void> dispose() => _player.dispose();
}
