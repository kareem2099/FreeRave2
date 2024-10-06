import 'package:flutter/material.dart';

List<BottomNavigationBarItem> bottomNavItems = const [
  BottomNavigationBarItem(
    backgroundColor: Colors.deepPurpleAccent,
    icon: Icon(Icons.home),
    label: 'Home',
    activeIcon: Icon(Icons.home),

  ),
  BottomNavigationBarItem(
    backgroundColor: Colors.lightBlueAccent,
    icon: Icon(Icons.chat),
    label: 'chat'
  ),
  BottomNavigationBarItem(
    backgroundColor: Colors.red,
    icon: Icon(Icons.settings),
    label: 'settings'
  ),
  BottomNavigationBarItem(
    backgroundColor: Colors.amberAccent,
    icon: Icon(Icons.person),
    label: 'profile'
  ),
];