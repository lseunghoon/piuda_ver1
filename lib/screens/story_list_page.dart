import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:piuda_ui/widgets/bottom_navigator.dart';
import 'package:piuda_ui/models/image_model.dart';
import 'package:piuda_ui/screens/story_detail_page.dart';
import 'package:piuda_ui/service/image_service.dart'; // ImageService를 가져옵니다
import 'package:piuda_ui/screens/home_page.dart'; // HomePage로 라우팅하기 위해 추가합니다

class StoryListPage extends StatelessWidget {
  final ImageService _imageService = ImageService(); // ImageService 인스턴스 생성

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
        title: Text('이야기책'),
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
            Text(
              '나의 20대',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1,
                ),
                itemCount: context.watch<ImageProviderModel>().imageUrls.length + 1 + dummyData.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildNewStoryButton(context);
                  } else if (index <= dummyData.length) {
                    return _buildDummyStoryCard(context, dummyData[index - 1]);
                  } else {
                    return _buildStoryCard(context, context.watch<ImageProviderModel>().imageUrls[index - 1 - dummyData.length]);
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

  Widget _buildNewStoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showPicker(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Text(
            'New Story',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, String imageUrl) {
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
          image: DecorationImage(
            image: FileImage(File(imageUrl)),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            padding: EdgeInsets.all(8.0),
            child: Text(
              '제목',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDummyStoryCard(BuildContext context, Map<String, String> data) {
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
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data['title']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center, // 텍스트 중앙 정렬
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('갤러리에서 선택'),
                onTap: () async {
                  Navigator.of(context).pop(); // 모달 닫기

                  // 갤러리에서 이미지 선택
                  String? imageUrl = await _selectAndUploadImage(context, ImageSource.gallery);

                  // 서버에서 반환된 이미지 URL 추가
                  if (imageUrl != null) {
                    context.read<ImageProviderModel>().addImageUrl(imageUrl);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('카메라로 촬영'),
                onTap: () async {
                  Navigator.of(context).pop(); // 모달 닫기

                  // 카메라로 이미지 촬영
                  String? imageUrl = await _selectAndUploadImage(context, ImageSource.camera);

                  // 서버에서 반환된 이미지 URL 추가
                  if (imageUrl != null) {
                    context.read<ImageProviderModel>().addImageUrl(imageUrl);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _selectAndUploadImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);  // 전달된 source 사용

    if (pickedFile == null) {
      print("No image selected.");
      return null;
    }

    // 이미지 파일을 제대로 선택했는지 확인
    print("Image selected from: ${source == ImageSource.gallery ? 'Gallery' : 'Camera'}");

    // 서버로 이미지 업로드 및 반환 값 받기
    final ImageService imageService = ImageService();
    String? imageUrl = await imageService.captureAndUploadImage('0');  // '0'은 targetAge 예시입니다.
    return imageUrl;
  }
}