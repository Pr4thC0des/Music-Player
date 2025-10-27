# 🎵 Flutter Music Player App

Welcome to the Flutter Music Player App — a sleek, feature-rich mobile music player built using Flutter, Riverpod, Hive, and Cloudinary for seamless music streaming and management. Whether you're a music enthusiast, developer, or just love beautiful apps, this project offers a compact yet powerful audio experience with smooth navigation, offline caching, and personalized features.

---

## 🚀 Project Overview

This Flutter app is designed as a comprehensive music player with:

- **Robust backend integration** with Django REST API and Cloudinary for media hosting
- **Local data persistence** for offline playback using Hive database with typed adapters
- **Advanced UI/UX** using Flutter’s Material 3 theming, smooth animations, and responsive design powered by ScreenUtil
- **State management** with Riverpod for scalable and maintainable code architecture
- Fully implemented screens for playlists, favorites, player, and profile management
- Intuitive navigation with named routes, custom back navigation, and error handling

---

## 🎯 Key Features

- **Effortless Music Browsing:** View, play, and manage playlists and favorites with easy navigation  
- **Offline Capability:** Cache song metadata and favorites locally using Hive—enjoy music without internet  
- **Backend API Integration:** Fetch songs, albums, profiles directly from a Django backend with secure REST API calls  
- **Dynamic UI Themes:** Dark theme with Material 3 color scheme seeded from custom colors for a modern look  
- **Profile Screen with Custom Navigation:** Seamless return to profile screen with custom back button gestures  
- **Image & Media Management:** Stream song album art and tracks from Cloudinary CDN with graceful error handling  
- **Smooth Animations & Responsive Sizing:** UI elements scale and animate smoothly across devices with ScreenUtil  

---

## 🛠️ Tech Stack

| Technology          | Purpose                         |
|---------------------|---------------------------------|
| Flutter             | Cross-platform mobile UI        |
| Riverpod            | State management                |
| Hive + Hive Flutter | Local JSON and typed storage    |
| Django REST API     | Backend API                     |
| Cloudinary CDN      | Media hosting and delivery      |
| ScreenUtil          | Responsive UI scaling           |
| Material 3          | Modern theming and widgets      |

---

## 🖼️ App Screenshots

| Main Screen | Favorites | Library 1 | Library 2 |
|--------------|------------|------------|------------|
| ![Main Screen](assets/images/mainscreen.png) | ![Favorites](assets/images/favorites.png) | ![Library 1](assets/images/library-1.png) | ![Library 2](assets/images/library-2.png) |

| Sort | Profile | Logout |
|------|----------|---------|
| ![Sort](assets/images/sort.png) | ![Profile](assets/images/profile.png) | ![Logout](assets/images/logout.png) |

---

## 📦 Installation & Setup

1. **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/flutter-music-player.git
    cd flutter-music-player
    ```

2. **Install dependencies**
    ```bash
    flutter pub get
    ```

3. **Configure backend URL & Hive**

   Update your backend API URLs and ensure Hive initialization is properly done in `main.dart`.

4. **Run the app**
    ```bash
    flutter run
    ```

---

## 🙌 Contribution

Contributions are warmly welcome! Whether optimizing code, fixing bugs, or expanding feature set — pull requests and issues are appreciated.

Please fork the repo and create your branch from `main`.

---

## 💡 Tips & Gotchas

- Always register Hive adapters before opening boxes to avoid typeId errors  
- Define either `home` or `initialRoute` with proper routes to prevent Navigator route errors  
- Handle network image exceptions gracefully to avoid crashes on missing album art  
- Use `pushReplacementNamed` for custom back navigation when overriding back button behavior  

---

## 📞 Contact

For questions or support, open an issue in the repo or reach out via email: **prathulkm@gmail.com**

---

Enjoy a smooth and rich music experience powered by Flutter! 🎶

---

*This README was thoughtfully crafted to help developers and users get the best out of the Flutter Music Player project.*
