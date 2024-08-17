import 'package:flutter/material.dart';
import 'package:piuda_ui/widgets/bottom_navigator.dart';

class ProfileChangePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 이전 페이지로 돌아가기
          },
        ),
      ),
      body: Center(
        child: Text('프로필 수정 페이지', style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 2), // 하단 네비게이션 바 추가
    );
  }
}