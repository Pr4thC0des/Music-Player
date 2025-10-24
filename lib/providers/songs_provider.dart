import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song_model.dart';
import '../repositories/song_repository.dart';
import '../services/song_service.dart';

final songServiceProvider = Provider((ref) => SongService());
final songRepositoryProvider = Provider(
  (ref) => SongRepository(ref.read(songServiceProvider)),
);

// Convert to StateNotifierProvider for better control
final songsProvider = StateNotifierProvider<SongsNotifier, AsyncValue<List<SongModel>>>((ref) {
  final repository = ref.read(songRepositoryProvider);
  return SongsNotifier(repository);
});

class SongsNotifier extends StateNotifier<AsyncValue<List<SongModel>>> {
  final SongRepository repository;

  SongsNotifier(this.repository) : super(const AsyncValue.loading()) {
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      // First, check if we have cached songs and show them immediately
      final cachedSongs = repository.getCachedSongs();
      if (cachedSongs.isNotEmpty) {
        state = AsyncValue.data(cachedSongs);
        print('✅ Loaded ${cachedSongs.length} cached songs');
      }

      // Then try to fetch fresh songs from API
      final freshSongs = await repository.getSongs();
      state = AsyncValue.data(freshSongs);
      print('✅ Loaded ${freshSongs.length} fresh songs from API');
      
    } catch (e, stackTrace) {
      print('❌ API Error: $e');
      
      // If API fails, check if we have cached songs
      final cachedSongs = repository.getCachedSongs();
      if (cachedSongs.isNotEmpty) {
        // Keep showing cached songs
        state = AsyncValue.data(cachedSongs);
        print('✅ Showing ${cachedSongs.length} cached songs due to API error');
      } else {
        // Only show error if no cached songs exist
        state = AsyncValue.error(e, stackTrace);
        print('❌ No cached songs available, showing error');
      }
    }
  }

  // Method to refresh songs (pull-to-refresh)
  Future<void> refresh() async {
    try {
      final songs = await repository.fetchAndCacheSongs();
      state = AsyncValue.data(songs);
      print('✅ Refreshed ${songs.length} songs');
    } catch (e, stackTrace) {
      print('❌ Refresh failed: $e');
      // Don't change state if refresh fails - keep showing current songs
      // Only update state if we have no songs at all
      if (state.value?.isEmpty ?? true) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  // Method to get current songs count
  int get songsCount => state.value?.length ?? 0;
  
  // Method to check if we have cached songs
  bool get hasCachedSongs => repository.hasCachedSongs();
}
