import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

/// Provides the audio player instance
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

/// A separate StateProvider for playing status
final isPlayingProvider = StateProvider<bool>((ref) => false);

/// Loop modes
enum LoopModeOption { none, one, all }

/// Provider to track loop mode
final loopModeProvider = StateProvider<LoopModeOption>((ref) => LoopModeOption.none);

class PlayerNotifier extends StateNotifier<SongModel?> {
  final AudioPlayer player;
  List<SongModel> playlist = [];
  int currentIndex = 0;
  final Ref ref;

  PlayerNotifier(this.ref, this.player) : super(null) {
    // Update playing status
    player.playingStream.listen((playing) {
      ref.read(isPlayingProvider.notifier).state = playing;
    });

    // Handle song completion
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        final loopMode = ref.read(loopModeProvider);
        if (loopMode == LoopModeOption.one) {
          // Replay current song
          playSong(playlist[currentIndex]);
        } else if (loopMode == LoopModeOption.all) {
          next(); // will loop to start if at end
        }
      }
    });
  }

  Future<void> setPlaylist(List<SongModel> songs, int startIndex) async {
    playlist = songs;
    currentIndex = startIndex;
    await playSong(playlist[currentIndex]);
  }

  Future<void> playSong(SongModel song) async {
    state = song;
    await player.setUrl(song.streamUrl);
    player.play();
  }

  void playPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  Future<void> next() async {
    if (playlist.isEmpty) return;
    final loopMode = ref.read(loopModeProvider);
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
    } else if (loopMode == LoopModeOption.all) {
      currentIndex = 0; // loop back
    } else {
      return; // stop at end
    }
    await playSong(playlist[currentIndex]);
  }

  Future<void> previous() async {
    if (currentIndex > 0) {
      currentIndex--;
      await playSong(playlist[currentIndex]);
    }
  }

  Future<void> stop() async {
    await player.stop();  // updated to use player
    state = null;
  }

  void clearCurrentSong() {
    state = null;
  }

  void muteUnmute() {
    if (player.volume > 0) {
      player.setVolume(0);
    } else {
      player.setVolume(1);
    }
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, SongModel?>((ref) {
  final player = ref.read(audioPlayerProvider);
  return PlayerNotifier(ref, player);
});
