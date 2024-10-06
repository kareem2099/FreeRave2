import 'package:flutter/material.dart';
import '../Widgets/drawer_widget.dart';
import 'friend_requests_screen.dart';
import 'friends_list_screen.dart';
import 'search_friends_screen.dart';

class ConnectionsScreen extends StatelessWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
      ),
      drawer: const DrawerWidget(), // Drawer with the friends list
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildConnectionOptions(context),
      ),
    );
  }

  // Connection Options (Search Friends, Friend Requests, Friends List)
  Widget _buildConnectionOptions(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              ConnectionButton(
                text: 'Search Friends',
                screen: SearchFriendsScreen(),
                icon: Icons.search,
              ),
              ConnectionButton(
                text: 'Friend Requests',
                screen: FriendRequestsScreen(currentUserId: '',),
                icon: Icons.person_add,
              ),
              ConnectionButton(
                text: 'My Friends List',
                screen: FriendsListScreen(),
                icon: Icons.list,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Button Widget for Connection Options
class ConnectionButton extends StatelessWidget {
  final String text;
  final Widget screen;
  final IconData icon;

  const ConnectionButton({
    super.key,
    required this.text,
    required this.screen,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _navigateToScreen(context, screen),
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
