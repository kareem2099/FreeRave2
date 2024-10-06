import 'package:flutter/material.dart';
import 'package:freerave/main_screens/home_screen/public_chat/cubit/stream_channel_service.dart';
import 'package:freerave/main_screens/home_screen/public_chat/widget/chat_navigator.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../widget/grid_items.dart';
import 'connections/screens/connections_screen.dart';
import 'cut_loose/views/cut_loose_view.dart';
import 'note/screen/notes_screen.dart';
import 'quiz/screens/home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late final StreamChannelService _channelService;
  late final ChatNavigator _chatNavigator;

  @override
  void initState() {
    super.initState();
    final client = StreamChat.of(context).client;
    _channelService = StreamChannelService(client);
    _chatNavigator = ChatNavigator(_channelService,client);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FreeRave'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 80,
              ),
              itemCount: gridItems.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _handleGridItemTap(context, index);
                  },
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(seconds: 1),
                    child: GridTile(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            gridItems[index].icon,
                            size: 50,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              gridItems[index].label,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleGridItemTap(BuildContext context, int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ConnectionsScreen(),
        ),
      );
    } else if (index == 1) {
      _chatNavigator.navigateToChat(context, 'public-chat');
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NotesScreen(),
        ),
      );
    } else if (index == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CutLooseView(),
        ),
      );
    } else if (index == 7) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreenQuiz(),
        ),
      );
    }
  }
}
