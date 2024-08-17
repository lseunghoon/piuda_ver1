import 'package:flutter/material.dart';
import 'package:piuda_ui/widgets/bottom_navigator.dart';
import 'package:piuda_ui/screens/profile_change_page.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('계정'),
        centerTitle: true,
        leading: Icon(Icons.notifications),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '마이페이지',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('김석희 님', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('010-4006-4**4', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileChangePage()), // ProfileChangePage로 이동
                );
              },
              child: Text('프로필 수정'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            Divider(height: 40, thickness: 1),
            ListTile(
              title: Text('기본 설정'),
              onTap: () {},
            ),
            ListTile(
              title: Text('알림 설정'),
              onTap: () {},
            ),
            ListTile(
              title: Text('캐릭터 설정'),
              onTap: () {},
            ),
            Spacer(),
            TextButton(
              onPressed: () {},
              child: Text(
                '로그아웃',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 3), // 하단 네비게이션 바 추가
    );
  }
}