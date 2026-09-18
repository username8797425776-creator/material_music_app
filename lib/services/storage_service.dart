import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const _favoritesKey = 'favorites';
  static const _playlistsKey = 'playlists';
  static const _recentKey = 'recent';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_favoritesKey);
    await Hive.openBox<List>(_playlistsKey);
    await Hive.openBox<String>(_recentKey);
  }

  Box<String> get favoritesBox => Hive.box<String>(_favoritesKey);
  Box<List> get playlistsBox => Hive.box<List>(_playlistsKey);
  Box<String> get recentBox => Hive.box<String>(_recentKey);

  Future<void> saveFavorite(String id) async {
    final box = favoritesBox;
    if (!box.containsKey(id)) {
      await box.put(id, id);
    }
  }

  Future<void> removeFavorite(String id) async {
    await favoritesBox.delete(id);
  }

  bool isFavorite(String id) => favoritesBox.containsKey(id);

  Future<void> saveRecent(String id) async {
    final box = recentBox;
    await box.put(id, id);
  }

  List<String> recentTracks() => recentBox.values.toList();
}
