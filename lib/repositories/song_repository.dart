import 'package:hive/hive.dart';
import '../models/song_model.dart';
import '../services/song_service.dart';

class SongRepository {
  final SongService service;
  
  // Access the typed box that was opened in main.dart
  Box<SongModel> get songBox => Hive.box<SongModel>('songsBox');

  SongRepository(this.service);

  Future<List<SongModel>> getSongs() async {
    try {
      // Try to fetch fresh data from API
      final songs = await service.fetchSongs();
      
      // Clear and update cache with SongModel objects
      await songBox.clear();
      for (var song in songs) {
        await songBox.put(song.id, song); // Store SongModel directly
      }
      
      return songs;
    } catch (e) {
      print('API Error: $e');
      
      // Fallback to cached songs
      if (songBox.isNotEmpty) {
        print('Returning ${songBox.length} cached songs');
        return songBox.values.toList();
      } else {
        throw Exception('No network connection and no cached songs available');
      }
    }
  }

  Future<List<SongModel>> fetchAndCacheSongs() async {
    final songs = await service.fetchSongs();
    
    await songBox.clear();
    for (var song in songs) {
      await songBox.put(song.id, song);
    }
    
    return songs;
  }

  List<SongModel> getCachedSongs() {
    return songBox.values.toList();
  }

  SongModel? getCachedSong(int id) {
    return songBox.get(id);
  }

  // Add this method that was missing
  bool hasCachedSongs() {
    return songBox.isNotEmpty;
  }

  // Additional helper methods
  int get cachedSongsCount => songBox.length;
  
  Future<void> clearCache() async {
    await songBox.clear();
  }
}
