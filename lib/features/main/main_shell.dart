import 'package:flutter/material.dart';

import '../home/screens/home_screen.dart';
import 'section_placeholder_screen.dart';

/// оболонка з нижньою панеллю навігації на 4 розділи
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0; // яка вкладка вибрана

  // const-список сторінок: створюється один раз, не перестворюється при build
  static const List<Widget> _pages = [
    HomeScreen(),
    SectionPlaceholderScreen(title: 'Ділянки', icon: Icons.grid_on_outlined),
    SectionPlaceholderScreen(title: 'Рослини', icon: Icons.eco_outlined),
    SectionPlaceholderScreen(
      title: 'Календар',
      icon: Icons.calendar_today_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack зберігає стан усіх вкладок, показуючи лише вибрану.
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          // icon — коли вкладка не вибрана, selectedIcon — коли вибрана.
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Головна',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_on_outlined),
            selectedIcon: Icon(Icons.grid_on),
            label: 'Ділянки',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco),
            label: 'Рослини',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Календар',
          ),
        ],
      ),
    );
  }
}