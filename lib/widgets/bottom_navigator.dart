import 'package:flutter/material.dart';
import 'package:piuda_ui/screens/home_page.dart';
import 'package:piuda_ui/screens/story_list_page.dart';
import 'package:piuda_ui/screens/account_page.dart';
import 'package:piuda_ui/screens/setting_page.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  CustomBottomNavigationBar({required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        if (currentIndex != 0) {
          Navigator.of(context).pushReplacement(
            _createRoute(StoryListPage()),
          );
        }
        break;
      case 1:
        if (currentIndex != 1) {
          Navigator.of(context).pushReplacement(
            _createRoute(HomePage()),
          );
        }
        break;
      case 2:
        if (currentIndex != 2) {
          Navigator.of(context).pushReplacement(
            _createRoute(AccountPage()), // AccountPage로 이동
          );
        }
        break;
      case 3:
        if (currentIndex != 3) {
          Navigator.of(context).pushReplacement(
            _createRoute(SettingsPage2()), // SettingsPage로 이동
          );
        }
        break;
    }
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final fadeAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 300), // 전환 지속 시간
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      backgroundColor: Color(0xFFF7EEE4),
      selectedItemColor: Color(0xFF0F1C43),
      unselectedItemColor: Color(0xFF0F1C43),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) => _onItemTapped(context, index),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: '자서전',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: '계정',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '설정',
        ),
      ],
    );
  }
}