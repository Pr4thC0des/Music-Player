import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

class SongService {
  static const String baseUrl = "http://templerun.click/api/song/";

  Future<List<SongModel>> fetchSongs() async {
    final url = Uri.parse("${baseUrl}songs/");
    print("🔎 Fetching songs from $url");

    final response = await http.get(url);

    print("🔎 Response status: ${response.statusCode}");
    print("🔎 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      final List data = jsonMap['songs'];
      if (data.isNotEmpty) {
        print("🔎 First song object: ${data.first}");
        
        List<SongModel> songs = [];
        
        for (var json in data) {
          SongModel song = SongModel.fromJson(json);
          
          // Calculate actual duration if not provided by API
          if (song.duration == null) {
            print("🔎 Calculating duration for: ${song.title}");
            int? calculatedDuration = await _calculateDuration(song.streamUrl);
            song = song.copyWith(duration: calculatedDuration);
            print("🔎 Duration for ${song.title}: ${calculatedDuration}s");
          }
          
          songs.add(song);
        }
        
        return songs;
      }
      throw Exception("No songs found");
    } else {
      throw Exception("Failed to load songs: ${response.statusCode}");
    }
  }

  Future<int?> _calculateDuration(String audioUrl) async {
    AudioPlayer? tempPlayer;
    try {
      print("🔎 Calculating duration for URL: $audioUrl");
      tempPlayer = AudioPlayer();
      
      // Set audio source
      await tempPlayer.setUrl(audioUrl);
      
      // Wait for the duration to be available
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final duration = tempPlayer.duration;
      print("🔎 Raw duration: $duration");
      
      return duration?.inSeconds ?? 180; // Default to 3 minutes if null
      
    } catch (e) {
      print("❌ Error calculating duration for $audioUrl: $e");
      return 180; // Default to 3 minutes if calculation fails
    } finally {
      // Always dispose of the temp player
      await tempPlayer?.dispose();
    }
  }
}
