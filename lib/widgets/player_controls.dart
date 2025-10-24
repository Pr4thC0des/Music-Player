import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/player_provider.dart';

class PlayerControls extends ConsumerStatefulWidget {
  final Function(LoopModeOption)? onLoopModeChanged; // Add callback

  const PlayerControls({super.key, this.onLoopModeChanged});

  @override
  ConsumerState<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends ConsumerState<PlayerControls> {
  bool _showVolumeSlider = false;
  double _volume = 1.0;

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(playerProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final playerNotifier = ref.read(playerProvider.notifier);
    final loopMode = ref.watch(loopModeProvider);

    if (currentSong == null) return const SizedBox.shrink();

    _volume = playerNotifier.player.volume;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Volume Slider
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => SizeTransition(
              sizeFactor: anim,
              axisAlignment: -1,
              child: child,
            ),
            child: _showVolumeSlider
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Slider(
                      key: const ValueKey("slider"),
                      min: 0,
                      max: 1,
                      divisions: 10,
                      value: _volume,
                      activeColor: Colors.tealAccent,
                      onChanged: (value) {
                        setState(() {
                          _volume = value;
                        });
                        playerNotifier.player.setVolume(value);
                      },
                      onChangeEnd: (value) {
                        if (value == 0) {
                          setState(() {
                            _showVolumeSlider = false;
                          });
                        }
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          
          // Control Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Volume
              _compactButton(
                icon: _volume > 0 ? Icons.volume_up : Icons.volume_off,
                onTap: () {
                  setState(() {
                    _showVolumeSlider = !_showVolumeSlider;
                  });
                },
              ),

              // Previous
              _compactButton(
                icon: Icons.skip_previous,
                onTap: () => playerNotifier.previous(),
              ),

              // Play / Pause (bigger but more compact)
              InkWell(
                onTap: () => playerNotifier.playPause(),
                borderRadius: BorderRadius.circular(30.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPlaying
                          ? [Colors.redAccent, Colors.orange]
                          : [Colors.greenAccent, Colors.teal],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 28.sp,
                    color: Colors.white,
                  ),
                ),
              ),

              // Next
              _compactButton(
                icon: Icons.skip_next,
                onTap: () => playerNotifier.next(),
              ),

              // Loop with popup callback
              _compactButton(
                icon: loopMode == LoopModeOption.none
                    ? Icons.repeat
                    : loopMode == LoopModeOption.one
                        ? Icons.repeat_one
                        : Icons.repeat,
                color: loopMode == LoopModeOption.none ? Colors.grey : Colors.tealAccent,
                onTap: () {
                  final notifier = ref.read(loopModeProvider.notifier);
                  final current = notifier.state;

                  LoopModeOption newMode;
                  if (current == LoopModeOption.none) {
                    newMode = LoopModeOption.all;
                  } else if (current == LoopModeOption.all) {
                    newMode = LoopModeOption.one;
                  } else {
                    newMode = LoopModeOption.none;
                  }

                  notifier.state = newMode;

                  // Trigger popup message
                  widget.onLoopModeChanged?.call(newMode);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Compact button widget to save space
  Widget _compactButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade800.withOpacity(0.6),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: color,
        ),
      ),
    );
  }
}
