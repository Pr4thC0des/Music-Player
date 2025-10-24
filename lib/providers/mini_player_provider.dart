import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song_model.dart';

class MiniPlayerNotifier extends StateNotifier<SongModel?> {
  MiniPlayerNotifier() : super(null);

  void show(SongModel song) {
    state = song;
  }

  void hide() {
    state = null;
  }
}

final miniPlayerProvider =
    StateNotifierProvider<MiniPlayerNotifier, SongModel?>(
        (ref) => MiniPlayerNotifier());
