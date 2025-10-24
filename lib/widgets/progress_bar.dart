import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/player_provider.dart';

class ProgressBarWidget extends ConsumerWidget {
  const ProgressBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.read(audioPlayerProvider);

    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = player.duration ?? Duration.zero;

        return Column(
          children: [
            Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
              onChanged: (value) {
                player.seek(Duration(seconds: value.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position)),
                  Text(_formatDuration(duration)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}";
  }
}
