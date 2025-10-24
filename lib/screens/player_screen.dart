import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/player_provider.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/favorites_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(playerProvider);

    if (currentSong == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.music_off,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.h),
                Text(
                  "No song playing",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => _slideDownTransition(context),
                  child: const Text("Go back to playlist"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top row with back arrow and "Now Playing" centered
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Custom slide down transition
                      _slideDownTransition(context);
                    },
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Now Playing',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // More options button
                  GestureDetector(
                    onTap: () {
                      _showOptionsBottomSheet(context, ref);
                    },
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // 🎵 Album Art
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 350.w,
                      maxHeight: 350.h,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: currentSong.media != null
                          ? Image.network(
                              currentSong.media!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(Icons.music_note, size: 80, color: Colors.white),
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(Icons.music_note, size: 80, color: Colors.white),
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // 🎶 Song Info
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentSong.title,
                      style: GoogleFonts.quicksand(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      currentSong.artist,
                      style : GoogleFonts.quicksand(
                        fontSize: 18,
                        color: Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),

              // 📊 Progress Bar
              const ProgressBarWidget(),
              SizedBox(height: 20),

              // 🎛 Controls - Pass context for popup messages
              PlayerControls(onLoopModeChanged: (loopMode) => _showLoopModePopup(context, loopMode)),
              SizedBox(height: 50), // Increased spacing since no more loop text
            ],
          ),
        ),
      ),
    );
  }

  // Show popup message for loop mode changes
  void _showLoopModePopup(BuildContext context, LoopModeOption loopMode) {
    String message;
    IconData icon;
    Color backgroundColor;

    switch (loopMode) {
      case LoopModeOption.none:
        message = "🚫 Looping is off";
        icon = Icons.repeat;
        backgroundColor = Colors.grey[700]!;
        break;
      case LoopModeOption.one:
        message = "🔂 Repeating current song";
        icon = Icons.repeat_one;
        backgroundColor = Colors.orange[600]!;
        break;
      case LoopModeOption.all:
        message = "🔁 Looping all songs";
        icon = Icons.repeat;
        backgroundColor = Colors.green[600]!;
        break;
    }

    // Custom toast-like popup
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 45.h,
        left: 20.w,
        right: 20.w,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove popup after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // Alternative: Using SnackBar (simpler but less customizable)
  void _showLoopModeSnackBar(BuildContext context, LoopModeOption loopMode) {
    String message;
    switch (loopMode) {
      case LoopModeOption.none:
        message = "🚫 Looping is off";
        break;
      case LoopModeOption.one:
        message = "🔂 Repeating current song";
        break;
      case LoopModeOption.all:
        message = "🔁 Looping all songs";
        break;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
        ),
        margin: EdgeInsets.only(
          bottom: 150.h,
          left: 20.w,
          right: 20.w,
        ),
      ),
    );
  }

  // Custom slide down transition method
  void _slideDownTransition(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // Return to the previous route (playlist screen)
          Navigator.of(context).popUntil((route) => route.isFirst);
          return Container(); // This won't be used as we're popping
        },
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide down animation
          const begin = Offset(0.0, -1.0); // Start from top
          const end = Offset.zero; // End at center
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );

    // Alternative simpler approach - just pop with custom animation
    Navigator.of(context).pop();
  }

  void _showOptionsBottomSheet(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(playerProvider);
    if (currentSong == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            
            // Song info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: currentSong.media != null
                      ? Image.network(
                          currentSong.media!,
                          width: 60.w,
                          height: 60.w,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 60.w,
                          height: 60.w,
                          color: Colors.grey[700],
                          child: const Icon(Icons.music_note, color: Colors.white),
                        ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSong.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentSong.artist,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            
            // Options
            _buildOptionItem(
              context,
              icon: Icons.queue_music,
              title: "View Queue",
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement queue view
              },
            ),
            // In your _buildOptionItem method, update the "Add to Favorites" option:
            _buildOptionItem(
              context,
              icon: ref.watch(favoritesProvider.notifier).isFavorite(currentSong.id) 
                  ? Icons.favorite 
                  : Icons.favorite_border,
              title: ref.watch(favoritesProvider.notifier).isFavorite(currentSong.id)
                  ? "Remove from Favorites"
                  : "Add to Favorites",
              onTap: () {
                ref.read(favoritesProvider.notifier).toggleFavorite(currentSong);
                Navigator.pop(context);
                
                // Show confirmation message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ref.read(favoritesProvider.notifier).isFavorite(currentSong.id)
                          ? "Added to favorites ❤️"
                          : "Removed from favorites 💔",
                    ),
                    backgroundColor: Colors.lightBlue[100],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            _buildOptionItem(
              context,
              icon: Icons.playlist_add,
              title: "Add to Playlist",
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement add to playlist
              },
            ),
            _buildOptionItem(
              context,
              icon: Icons.share,
              title: "Share",
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }
}
