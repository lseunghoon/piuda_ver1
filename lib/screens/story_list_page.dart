import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:piuda_ui/widgets/bottom_navigator.dart';
import 'package:piuda_ui/models/image_model.dart';
import 'package:piuda_ui/screens/story_detail_page.dart';

class StoryListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    List<Map<String, String>> dummyData = [
      {'title': '제목1', 'imageUrl': ''}, // 이미지 URL은 빈 문자열로 설정하여 더미 이미지 사용
      {'title': '제목2', 'imageUrl': ''},
      {'title': '제목3', 'imageUrl': ''},
      {'title': '제목4', 'imageUrl': ''},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('나의 자서전'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            // 알림 페이지로 이동
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 검색 기능 추가
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1,
                ),
                itemCount: context.watch<ImageProviderModel>().imageUrls.length + dummyData.length,
                itemBuilder: (context, index) {
                  if (index < dummyData.length) {
                    return _buildStoryCard(context, dummyData[index]);
                  } else {
                    return _buildStoryCard(context, {'title': '제목', 'imageUrl': context.watch<ImageProviderModel>().imageUrls[index - dummyData.length]});
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildStoryCard(BuildContext context, Map<String, String> data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryDetailPage(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
          image: data['imageUrl']!.isNotEmpty
              ? DecorationImage(
            image: FileImage(File(data['imageUrl']!)),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            padding: EdgeInsets.all(8.0),
            child: Text(
              data['title']!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // 텍스트 중앙 정렬
            ),
          ),
        ),
      ),
    );
  }
}