import 'package:hive/hive.dart';

part 'song_model.g.dart';

@HiveType(typeId: 0)
class SongModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String? media; // Make this nullable

  @HiveField(4)
  final String streamUrl;

  @HiveField(5)
  final int? duration;

  @HiveField(6)
  final String? homeMedia; // Add this field for home_media

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.media, // Remove required since it can be null
    required this.streamUrl,
    this.duration,
    this.homeMedia,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json["id"] as int,
      title: json["title"] as String,
      artist: json["artist"] as String,
      media: json["media"] as String?, // Handle null media
      streamUrl: json["stream_url"] as String,
      duration: json["duration"] as int?,
      homeMedia: json["home_media"] as String?, // Add home_media field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "artist": artist,
      "media": media,
      "stream_url": streamUrl,
      "duration": duration,
      "home_media": homeMedia,
    };
  }

  SongModel copyWith({int? duration}) {
    return SongModel(
      id: id,
      title: title,
      artist: artist,
      media: media,
      streamUrl: streamUrl,
      duration: duration ?? this.duration,
      homeMedia: homeMedia,
    );
  }
}
