import 'package:flutter/material.dart';
import 'package:freerave/main_screens/chat_screen.dart';
import 'package:freerave/main_screens/home_screen/home_screen.dart';
import 'package:freerave/main_screens/profile/screen/profile_screen.dart';
import 'package:freerave/main_screens/settings_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../widget/bottom_navigation_bar.dart';

class MainNavigation extends StatefulWidget {
  final StreamChatClient client; // Add client parameter here

  const MainNavigation({super.key, required this.client}); // Accept client in constructor

  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      StreamChat(client: widget.client, child: const HomeScreen()), // Wrap HomeScreen
      const ChatScreen(),
      const SettingsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],  // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedFontSize: 14.0,
        unselectedFontSize: 14.0,
        onTap: _onItemTapped,
        items: bottomNavItems,  // Use the items from the separate file
      ),
    );
  }
}
