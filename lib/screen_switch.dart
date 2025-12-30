import 'package:flutter/material.dart';
import 'main.dart';
import 'storage_screen.dart';

class ScreenSwitch extends StatefulWidget {
  const ScreenSwitch({super.key});

  @override
  State<ScreenSwitch> createState() => _ScreenSwitchState();
}

class _ScreenSwitchState extends State<ScreenSwitch> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    const DataEntryPage(),
    const StorageScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage_rounded, size: 30),
            label: 'Storage',
          ),
        ],
      ),
    );
  }
}
