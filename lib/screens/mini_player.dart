import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/player_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(playerProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final playerNotifier = ref.read(playerProvider.notifier);

    if (currentSong == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: currentSong.media != null
                ? Image.network(
                    currentSong.media!,
                    width: 45.w,
                    height: 45.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 45.w,
                        height: 45.w,
                        color: Colors.grey[600],
                        child: const Icon(Icons.music_note, color: Colors.white),
                      );
                    },
                  )
                : Container(
                    width: 45.w,
                    height: 45.w,
                    color: Colors.grey[600],
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentSong.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  currentSong.artist,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Reduced padding and removed extra SizedBoxes
          IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white, size: 28),
            onPressed: () => playerNotifier.previous(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            constraints: BoxConstraints.tight(Size(32.w, 32.w)),
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white, size: 32),
            onPressed: () => playerNotifier.playPause(),
            padding: EdgeInsets.symmetric(horizontal: 14),
            constraints: BoxConstraints.tight(Size(32.w, 32.w)),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
            onPressed: () => playerNotifier.next(),
            padding: EdgeInsets.symmetric(horizontal: 14),
            constraints: BoxConstraints.tight(Size(32.w, 32.w)),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up,
                color: Colors.white, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, "/player");
            },
            padding: EdgeInsets.symmetric(horizontal: 10),
            constraints: BoxConstraints.tight(Size(32.w, 32.w)),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: () async {
              await playerNotifier.player.stop();
              playerNotifier.clearCurrentSong();
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(Size(28.w, 28.w)),
          ),
        ],
      ),
    );
  }
}
