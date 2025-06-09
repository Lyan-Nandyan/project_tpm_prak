import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/favoritePage.dart';
import 'pages/map_page.dart';
import 'pages/profile.dart';
import 'pages/chatbot_page.dart'; // Import halaman chatbot baru

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    Home(),
    Favoritepage(),
    ChatbotPage(), // Tambahkan halaman chatbot di sini
    MapPage(),
    Profile(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildIconWithBackground(IconData iconData, int itemIndex) {
    bool isActive = _currentIndex == itemIndex;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blueGrey : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: _buildIconWithBackground(Icons.home, 0),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildIconWithBackground(Icons.favorite, 1),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: _buildIconWithBackground(Icons.chat, 2),
              label: 'Chatbot',
            ),
            BottomNavigationBarItem(
              icon: _buildIconWithBackground(Icons.map, 3),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: _buildIconWithBackground(Icons.person, 4),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
