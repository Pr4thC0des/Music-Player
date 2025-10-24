import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/songs_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import '../screens/mini_player.dart';
import '../screens/favorites_screen.dart';
import '../screens/library_screen.dart';
import '../screens/profile_screen.dart';
import '../models/song_model.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({super.key});

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  int _currentIndex = 0;
  static const spotGreen = Color(0xFF1DB954);

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

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(playerProvider);

    final tabs = [
      _buildHomeTab(),
      const FavoritesScreen(),
      const LibraryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: tabs),
          if (currentSong != null)
            Positioned(bottom: 10.h, left: 0, right: 0, child: const MiniPlayer()),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25.r), topRight: Radius.circular(25.r)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25.r), topRight: Radius.circular(25.r)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: spotGreen,
            unselectedItemColor: Colors.grey[600],
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
              BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    final songsAsync = ref.watch(songsProvider);

    return Column(
      children: [
        // Top curved header with search and logout
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
                Row(children: [
                  // Logout button
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12.r)),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () => _logout(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Hello, Nexotech 👋",
                          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text("Find your favorite songs",
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey[300])),
                    ]),
                  ),
                  Image.asset("lib/icons/Logo_SVG.png", width: 50, height: 50),
                ]),
                SizedBox(height: 16.h),
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.grey[700], fontSize: 16.sp),
                    decoration: InputDecoration(
                      hintText: "Search songs, artists...",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.search, color: _isSearching ? spotGreen : Colors.grey[500]),
                      suffixIcon: _isSearching
                          ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
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
        // Songs list
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.w),
            child: songsAsync.when(
              data: (songs) {
                final filtered = _isSearching
                    ? songs.where((s) {
                        final q = _searchController.text.toLowerCase();
                        return s.title.toLowerCase().contains(q) || s.artist.toLowerCase().contains(q);
                      }).toList()
                    : songs;
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(_isSearching ? Icons.search_off : Icons.music_off, size: 80, color: Colors.grey[400]),
                      SizedBox(height: 16.h),
                      Text(_isSearching ? "No songs found" : "No songs available",
                          style: TextStyle(fontSize: 18.sp, color: Colors.grey[600])),
                      if (_isSearching) ...[
                        SizedBox(height: 8.h),
                        Text("Try searching with different keywords", style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
                      ]
                    ]),
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  padding: EdgeInsets.only(bottom: 120.h),
                  itemBuilder: (context, index) {
                    final song = filtered[index];
                    final orig = songs.indexOf(song);
                    return SongTile(song: song, index: orig, playlist: songs);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: spotGreen)),
              error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: Colors.red))),
            ),
          ),
        ),
      ],
    );
  }
}
