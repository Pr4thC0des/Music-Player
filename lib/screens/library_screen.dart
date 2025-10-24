import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/songs_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../screens/mini_player.dart';
import '../screens/library_screen.dart';
import '../screens/profile_screen.dart';
import '../models/song_model.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _sortBy = 'name';
  bool _isGridView = false;
  int _currentIndex = 1; // Library tab index

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

  List<SongModel> _filterAndSortSongs(List<SongModel> songs, String query) {
    var filtered = songs;
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = songs.where((s) =>
        s.title.toLowerCase().contains(q) ||
        s.artist.toLowerCase().contains(q)
      ).toList();
    }
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'artist':
        filtered.sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
        break;
      case 'recent':
      default:
        break;
    }
    return filtered;
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40.w, height: 4.h, margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r)),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Sort by', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              _buildSortOption('name', 'Song Name', Icons.music_note),
              _buildSortOption('artist', 'Artist', Icons.person),
              _buildSortOption('recent', 'Recently Added', Icons.access_time),
              SizedBox(height: 20.h),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final sel = _sortBy == value;
    return ListTile(
      leading: Icon(icon, color: sel ? const Color(0xFF1DB954) : Colors.grey[600]),
      title: Text(label, style: TextStyle(color: sel ? const Color(0xFF1DB954) : Colors.grey[800], fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
      trailing: sel ? const Icon(Icons.check, color: Color(0xFF1DB954)) : null,
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
    );
  }

  void _onTapNav(int index) {
    if (index == _currentIndex) return;
    if (index == 0) {
      Navigator.pushReplacementNamed(context, "/playlist");
    } else if (index == 1) {
      // Already on Library
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
    setState(() => _currentIndex = index);
  }

  Widget _buildGridSongItem(SongModel song, int index, List<SongModel> songs) {
    final currentSong = ref.watch(playerProvider);
    final isCurrentSong = currentSong?.id == song.id;

    return GestureDetector(
      onTap: () => ref.read(playerProvider.notifier).setPlaylist(songs, index),
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentSong ? const Color(0xFF1DB954).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: isCurrentSong 
              ? Border.all(color: const Color(0xFF1DB954), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Album Art Container
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isCurrentSong 
                        ? const Color(0xFF1DB954).withOpacity(0.2) 
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: song.media != null && song.media!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            song.media!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.music_note,
                                size: 40.sp,
                                color: isCurrentSong 
                                    ? const Color(0xFF1DB954) 
                                    : Colors.grey[600],
                              );
                            },
                          ),
                        )
                      : Icon(
                          isCurrentSong ? Icons.music_note : Icons.music_note_outlined,
                          size: 40.sp,
                          color: isCurrentSong 
                              ? const Color(0xFF1DB954) 
                              : Colors.grey[600],
                        ),
                ),
              ),
              SizedBox(height: 12.h),
              // Song Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isCurrentSong 
                            ? const Color(0xFF1DB954) 
                            : Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      song.artist,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (isCurrentSong)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              size: 12.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Playing',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(songsProvider);
    final currentSong = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(children: [
        Column(children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.r), bottomRight: Radius.circular(30.r)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Your Library 🎵", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                      songsAsync.when(
                        data: (s) => Text("${s.length} song${s.length == 1 ? '' : 's'}", style: TextStyle(fontSize: 14.sp, color: Colors.grey[300])),
                        loading: () => Text("Loading...", style: TextStyle(fontSize: 14.sp, color: Colors.grey[300])),
                        error: (_, __) => Text("Error loading", style: TextStyle(fontSize: 14.sp, color: Colors.grey[300])),
                      ),
                    ]),
                    Row(children: [
                      IconButton(
                        onPressed: () => setState(() => _isGridView = !_isGridView),
                        icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: Colors.white),
                      ),
                      IconButton(onPressed: _showSortMenu, icon: const Icon(Icons.sort, color: Colors.white)),
                    ]),
                  ]),
                  SizedBox(height: 16.h),
                  // Search
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.grey[700], fontSize: 16.sp),
                      decoration: InputDecoration(
                        hintText: "Search in your library...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: _isSearching ? const Color(0xFF1DB954) : Colors.grey[500]),
                        suffixIcon: _isSearching
                            ? IconButton(icon: Icon(Icons.clear, color: Colors.grey[500]), onPressed: _clearSearch)
                            : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ]),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
              child: songsAsync.when(
                data: (songs) {
                  final list = _filterAndSortSongs(songs, _searchController.text);
                  if (_isGridView) {
                    return GridView.builder(
                      padding: EdgeInsets.only(bottom: currentSong != null ? 140.h : 100.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, 
                        crossAxisSpacing: 12.w, 
                        mainAxisSpacing: 12.h, 
                        childAspectRatio: 0.75,
                      ),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final song = list[i];
                        final idx = songs.indexOf(song);
                        return _buildGridSongItem(song, idx, songs);
                      },
                    );
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: currentSong != null ? 140.h : 100.h),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final song = list[i];
                        final idx = songs.indexOf(song);
                        return SongTile(song: song, index: idx, playlist: songs);
                      },
                    );
                  }
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954))),
                error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: Colors.red))),
              ),
            ),
          ),
        ]),
        if (currentSong != null)
          Positioned(bottom: 10.h, left: 0, right: 0, child: const MiniPlayer()),
      ]),
    );
  }
}
