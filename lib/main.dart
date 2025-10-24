import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/song_model.dart'; // Add this import 
import 'screens/playlist_screen.dart';
import 'screens/player_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register the SongModel adapter
  Hive.registerAdapter(SongModelAdapter());

  // Open Hive boxes with proper types
  await Hive.openBox<SongModel>("songsBox"); // Typed box for SongModel
  await Hive.openBox("app_data");            // Keep as dynamic for general data
  await Hive.openBox("favoritesBox");        // Keep as dynamic for favorites

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Music Player',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          initialRoute: "/",
          routes: {
            "/": (context) => const PlaylistScreen(),
            "/playlist": (context) => const PlaylistScreen(),
            "/favorites": (context) => const FavoritesScreen(),
            "/player": (context) => const PlayerScreen(),
            "/profile": (context) => const ProfileScreen()
          },
        );
      },
    );
  }
}
