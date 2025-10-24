import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/player_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const Color spotGreen = Color(0xFF1DB954);

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red[600]),
            SizedBox(width: 8.w),
            const Text("Logout"),
          ],
        ),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.r),
                    bottomRight: Radius.circular(30.r),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {Navigator.pushReplacementNamed(context, '/playlist');
                              },
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "Profile",
                              style: GoogleFonts.quicksand(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Nexotech",
                          style: GoogleFonts.quicksand(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Music Lover",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[300],
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
                  child: ListView(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildStatCard("Songs Played", "1,234")),
                          SizedBox(width: 16.w),
                          Expanded(child: _buildStatCard("Hours Listened", "89")),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      _buildProfileOption(
                        icon: Icons.favorite,
                        color: Colors.red,
                        title: "My Favorites",
                        subtitle: "View your favorite songs",
                        onTap: () => Navigator.pushNamed(context, "/favorites"),
                      ),
                      _buildProfileOption(
                        icon: Icons.download,
                        color: Colors.blue,
                        title: "Downloaded Music",
                        subtitle: "Offline songs",
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        icon: Icons.history,
                        color: Colors.orange,
                        title: "Recently Played",
                        subtitle: "Your listening history",
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        icon: Icons.notifications,
                        color: Colors.teal,
                        title: "Notifications",
                        subtitle: "Manage notifications",
                        onTap: () {},
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _logout(context),
                          icon: Icon(Icons.logout),
                          label: Text(
                            "Logout",
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: spotGreen)),
          SizedBox(height: 4.h),
          Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        title: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.grey[800])),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
    );
  }
}
