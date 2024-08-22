import 'package:flutter/material.dart';
import 'package:piuda_ui/screens/home_page.dart';
import 'package:piuda_ui/screens/story_list_page.dart';
import 'package:piuda_ui/screens/account_page.dart';
import 'package:piuda_ui/screens/board_page.dart';

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
            _createRoute(BoardPage()),
          );
        }
        break;
      case 2:
        if (currentIndex != 2) {
          Navigator.of(context).pushReplacement(
            _createRoute(HomePage()),
          );
        }
        break;
      case 3:
        if (currentIndex != 3) {
          Navigator.of(context).pushReplacement(
            _createRoute(AccountPage()), // AccountPage로 이동
          );
        }
        break;
      case 4:
      // 설정 페이지로 이동 (추후 추가)
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
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) => _onItemTapped(context, index),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: '이야기책',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: '게시판',
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