import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:piuda_ui/widgets/bottom_navigator.dart';
import 'package:piuda_ui/service/story_service.dart';
import 'package:piuda_ui/screens/story_detail_page.dart';

class StoryListPage extends StatefulWidget {
  @override
  _StoryListPageState createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {
  final StoryService _storyService = StoryService();
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // FlutterSecureStorage 인스턴스 생성
  List<Map<String, String>> _storyList = [];

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    try {
      // SecureStorage에서 user_id를 가져옵니다.
      String? userId = await _storage.read(key: 'user_id');

      if (userId != null) {
        // userId를 getUserStory에 인자로 전달
        List<Map<String, String>> stories = await _storyService.getUserStory(userId);
        setState(() {
          _storyList = stories;
        });
      } else {
        print("No user ID found in storage.");
      }
    } catch (e) {
      print("Failed to load stories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                itemCount: _storyList.length, // 더미 데이터를 제거하고 _storyList 사용
                itemBuilder: (context, index) {
                  return _buildStoryCard(context, _storyList[index]);
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
    final title = data['recallbook_title'] ?? '제목 없음';
    final imageUrl = data['recallbook_paint'] ?? '';
    final description = data['recallbook_context'] ?? 'No description available';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryDetailPage(
              title: title,
              imageUrl: imageUrl,
              description: description,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // 컨테이너의 배경색을 흰색으로 설정
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Stack(
          children: [
            FutureBuilder<ImageProvider>(
              future: _loadImage(imageUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Text(
                      '로딩 중', // 로딩 중일 때 표시할 텍스트
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Icon(Icons.error, color: Colors.red),
                  );
                } else if (snapshot.hasData) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: snapshot.data!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                } else {
                  return Container(); // snapshot.connectionState == ConnectionState.done인데 데이터가 없을 경우
                }
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<ImageProvider> _loadImage(String imageUrl) async {
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else {
      return FileImage(File(imageUrl));
    }
  }
}