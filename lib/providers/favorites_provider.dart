import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/song_model.dart';
import 'songs_provider.dart';

// Favorites Provider
class FavoritesNotifier extends StateNotifier<Set<int>> {
  final Box _favoritesBox = Hive.box("favoritesBox");

  FavoritesNotifier() : super(<int>{}) {
    _loadFavorites();
  }

  void _loadFavorites() {
    final favoriteIds = _favoritesBox.get("favorite_song_ids", defaultValue: <int>[]) as List;
    state = favoriteIds.cast<int>().toSet();
  }

  void toggleFavorite(SongModel song) {
    final newState = Set<int>.from(state);
    
    if (newState.contains(song.id)) {
      newState.remove(song.id);
    } else {
      newState.add(song.id);
    }
    
    state = newState;
    _saveFavorites();
  }

  void _saveFavorites() {
    _favoritesBox.put("favorite_song_ids", state.toList());
  }

  bool isFavorite(int songId) {
    return state.contains(songId);
  }

  void clearAllFavorites() {
    state = <int>{};
    _saveFavorites();
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier();
});

// Provider to get favorite songs from all songs
final favoriteSongsProvider = Provider<List<SongModel>>((ref) {
  final allSongs = ref.watch(songsProvider);
  final favoriteIds = ref.watch(favoritesProvider);
  
  return allSongs.when(
    data: (songs) => songs.where((song) => favoriteIds.contains(song.id)).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});
