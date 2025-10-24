import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/songs_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../screens/mini_player.dart';
import '../models/song_model.dart';
import '../screens/playlist_screen.dart';


class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
  }

  List<SongModel> _filterFavorites(List<SongModel> favorites, String query) {
    if (query.isEmpty) return favorites;
    final lower = query.toLowerCase();
    return favorites.where((s) {
      return s.title.toLowerCase().contains(lower)
          || s.artist.toLowerCase().contains(lower);
    }).toList();
  }

  void _showClearFavoritesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text("Clear All Favorites"),
        content: const Text(
          "Remove all songs from favorites? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(favoritesProvider.notifier).clearAllFavorites();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(playerProvider);
    final allSongs = ref.watch(songsProvider);
    final favoriteIds = ref.watch(favoritesProvider);
    final favoriteSongs = allSongs.when(
      data: (songs) => songs.where((s) => favoriteIds.contains(s.id)).toList(),
      loading: () => <SongModel>[],
      error: (_, __) => <SongModel>[],
    );

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          Column(
            children: [
              // Top curved header with search and clear-all
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.r),
                    bottomRight: Radius.circular(30.r),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(context, "/playlist"),
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your Favorites ❤️",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "${favoriteSongs.length} favorite song${favoriteSongs.length == 1 ? '' : 's'}",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (favoriteSongs.isNotEmpty)
                              GestureDetector(
                                onTap: _showClearFavoritesDialog,
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.clear_all,
                                    color: Colors.red[300],
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        if (favoriteSongs.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: Colors.grey[700], fontSize: 16.sp),
                              decoration: InputDecoration(
                                hintText: "Search your favorites...",
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: _isSearching ? const Color(0xFF1DB954) : Colors.grey[500],
                                ),
                                suffixIcon: _isSearching
                                    ? IconButton(
                                        icon: Icon(Icons.clear, color: Colors.grey[500]),
                                        onPressed: _clearSearch,
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
              // Favorites list or empty state
              Expanded(
                child: favoriteSongs.isEmpty
                    ? _buildEmptyState()
                    : _buildFavoritesList(favoriteSongs, currentSong),
              ),
            ],
          ),
          if (currentSong != null)
            Positioned(
              bottom: 10.h,
              left: 0,
              right: 0,
              child: const MiniPlayer(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 80.sp,
                color: Colors.pink[300],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "No Favorites Yet",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Tap the ❤️ icon on songs to add them here!",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.music_note),
              label: const Text("Browse Music"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(List<SongModel> songs, SongModel? currentSong) {
    final filtered = _isSearching ? _filterFavorites(songs, _searchController.text) : songs;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.w),
      child: ListView.builder(
        itemCount: filtered.length,
        padding: EdgeInsets.only(bottom: currentSong != null ? 140.h : 100.h),
        itemBuilder: (context, index) {
          final song = filtered[index];
          return SongTile(song: song, index: index, playlist: songs);
        },
      ),
    );
  }
}
