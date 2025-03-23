import 'package:flutter/material.dart';
import 'package:gridguardian/screens/add_device_screen.dart';
import 'package:gridguardian/screens/devices_screen.dart';
import 'package:gridguardian/screens/home_screen.dart';
import 'package:gridguardian/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Bottom Navigation Index
  int _selectedIndex = 0;

  // Page Controller for Bottom Navigation
  final PageController _pageController = PageController();

  // Drawer List
  late List<Widget> _drawerItems;

  @override
  void initState() {
    super.initState();
    _drawerItems = [
      ListTile(
        leading: Icon(Icons.home),
        title: Text('Home'),
        onTap: () => _onItemTapped(0),
      ),
      ListTile(
        leading: Icon(Icons.devices),
        title: Text('Devices'),
        onTap: () => _onItemTapped(1),
      ),
      ListTile(
        leading: Icon(Icons.add_circle_outline),
        title: Text('Add Device'),
        onTap: () => _onItemTapped(2),
      ),
      ListTile(
        leading: Icon(Icons.person),
        title: Text('Profile'),
        onTap: () => _onItemTapped(3),
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Handle Drawer and Bottom Navigation Item Taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.only(top: 30, left: 10),
          children: _drawerItems,
        ),
      ),

      // App Bar
      appBar: AppBar(
        title: Text("GridGuardian"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      // Body with PageView and Bottom Navigation
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          HomeScreen(),
          DevicesScreen(),
          AddDeviceScreen(),
          ProfileScreen(),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color.fromARGB(255, 63, 137, 101),
        ),
        child: BottomNavigationBar(
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.devices),
              label: 'Devices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'Add Device',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
