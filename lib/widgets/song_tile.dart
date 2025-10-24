import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/song_model.dart';
import '../providers/player_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongTile extends ConsumerWidget {
  final SongModel song;
  final int index;
  final List<SongModel> playlist;

  const SongTile({
    super.key,
    required this.song,
    required this.index,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerNotifier = ref.read(playerProvider.notifier);
    final currentSong = ref.watch(playerProvider);
    final isCurrentSong = currentSong?.id == song.id;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 0),
      decoration: BoxDecoration(
        color: isCurrentSong 
            ? Colors.green.withOpacity(0.15) 
            : Colors.grey[300], // Changed to light blue
        borderRadius: BorderRadius.circular(16.r),
        border: isCurrentSong 
            ? Border.all(color: Colors.green.withOpacity(0.3), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: song.media != null
              ? Image.network(
                  song.media!,
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[200], // Light blue for error container
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.music_note, color: Colors.lightBlue[800], size: 30),
                    );
                  },
                )
              : Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[600], // Light blue for default container
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.music_note, color: Colors.lightBlue[800], size: 30),
                ),
        ),
        title: Text(
          song.title,
          style: TextStyle(
            fontSize: 16.sp, 
            fontWeight: FontWeight.bold,
            color: isCurrentSong ? Colors.green[700] : Colors.grey[800], // Dark text for light background
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: TextStyle(
            fontSize: 14.sp, 
            color: isCurrentSong ? Colors.green[600] : Colors.grey[600], // Darker text for better contrast
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Duration badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isCurrentSong 
                    ? Colors.green.withOpacity(0.2) 
                    : Colors.grey[200], // Light blue for duration badge
                borderRadius: BorderRadius.circular(20.r),
                border: isCurrentSong
                    ? Border.all(color: Colors.green.withOpacity(0.4), width: 1)
                    : Border.all(color: Colors.lightBlue.withOpacity(0.3), width: 1), // Light blue border
              ),
              child: Text(
                song.duration != null
                    ? _formatDuration(song.duration!)
                    : "--:--",
                style: TextStyle(
                  fontSize: 12.sp, 
                  fontWeight: FontWeight.w600,
                  color: isCurrentSong ? Colors.green[700] : Colors.black, // Dark text for light background
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Play indicator for current song
            if (isCurrentSong)
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.music_note,
                  color: Colors.green[600],
                  size: 18,
                ),
              ),
          ],
        ),
        onTap: () async {
          // 🎵 Start playback from selected song
          await playerNotifier.setPlaylist(playlist, index);
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return "--:--";
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
