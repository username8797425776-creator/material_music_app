class Song {
  final String id;
  final String title;
  final String artist;
  final String? thumbnailUrl;
  final Duration? duration;
  final String? album;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.thumbnailUrl,
    this.duration,
    this.album,
  });

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      duration: map['duration'] != null
          ? Duration(milliseconds: map['duration'] as int)
          : null,
      album: map['album'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration?.inMilliseconds,
      'album': album,
    };
  }
}

class PlaylistModel {
  final String id;
  final String name;
  final List<Song> songs;

  const PlaylistModel({
    required this.id,
    required this.name,
    required this.songs,
  });
}
