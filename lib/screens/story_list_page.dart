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
  bool _isLoading = true;

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

        // 각 story의 recallbook_id를 출력하여 확인합니다.
        for (var story in stories) {
          print("Loaded story recallbook_id: ${story['recallbook_id']}");
          await _loadImage(story['recallbook_paint'] ?? '');
        }

        setState(() {
          _storyList = stories;
          _isLoading = false; // 이미지 로딩이 완료된 후 로딩 상태를 false로 설정
        });
      } else {
        print("No user ID found in storage.");
      }
    } catch (e) {
      print("Failed to load stories: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStory(int index) async {
    // FlutterSecureStorage에서 recallbook_id를 가져옵니다.
    String? recallbookId = await _storyService.getSavedRecallbookId();

    if (recallbookId != null && recallbookId.isNotEmpty) {
      bool success = await _storyService.deleteStory(recallbookId);

      if (success) {
        setState(() {
          _storyList.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('자서전이 삭제됐습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('스토리 삭제에 실패했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print("Recallbook ID is empty, cannot delete.");
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF0F1C43))) // 로딩 중일 때 전체 인디케이터 표시
          : Padding(
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
                itemCount: _storyList.length, // _storyList 사용
                itemBuilder: (context, index) {
                  return _buildStoryCard(context, _storyList[index], index);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildStoryCard(BuildContext context, Map<String, String> data, int index) {
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
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
              image: DecorationImage(
                image: _loadImageProvider(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
              ),
              padding: EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            right: 5,
            top: 5,
            child: GestureDetector(
              onTap: () {
                _deleteStory(index); // 삭제 기능 호출
              },
              child: Container(
                padding: EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: Color(0xFF0F1C43),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _loadImageProvider(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else {
      return FileImage(File(imageUrl));
    }
  }

  Future<void> _loadImage(String imageUrl) async {
    // 캐시를 사용하지 않도록 _loadImage에서 아무런 처리를 하지 않음
    if (imageUrl.startsWith('http')) {
      // 캐시를 사용하지 않기 위해 따로 이미지 로드를 하지 않음
    } else {
      await File(imageUrl).exists(); // 로컬 파일이 존재하는지 확인
    }
  }
}