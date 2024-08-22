import 'dart:io';
import 'package:flutter/material.dart';
import 'package:piuda_ui/models/image_model.dart';
import 'package:piuda_ui/widgets/bottom_navigator.dart';
import 'package:piuda_ui/screens/alarm_page.dart';
import 'package:piuda_ui/screens/chat_page.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piuda_ui/service/api_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;
  final ApiService _apiService = ApiService(); // ApiService 인스턴스 생성

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<ImageProviderModel>().loadImages();
      // notifyListeners()는 loadImages 내부에서 호출되므로 여기서 별도로 호출할 필요는 없습니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = context.watch<ImageProviderModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('홈'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AlarmPage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(8.0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/642/600'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '34°',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '흐린 날이에요.\n오후도 화이팅하세요.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Container(
                height: 300,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.7),
                  itemCount: imageProvider.imageUrls.length + 1,  // Add one for the add button
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    if (index == 0 && imageProvider.imageUrls.isEmpty) {
                      return _buildAddImageButton(context);  // Show add button when list is empty
                    } else if (index == 0) {
                      return _buildAddImageButton(context);  // First index for add button
                    } else {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatBotPage(
                                imageUrl: imageProvider.imageUrls[index - 1],  // 이미지 URL 전달
                              ),
                            ),
                          );
                        },
                        child: _buildRemoteImageCard(context, index - 1, imageProvider),  // Remote images only
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 2),
    );
  }

  Widget _buildAddImageButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle, color: Colors.blue, size: 80),
              SizedBox(height: 8),
              Text(
                '과거의 나를 불러오세요.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemoteImageCard(BuildContext context, int index, ImageProviderModel imageProvider) {
    final imageUrl = imageProvider.imageUrls[index];

    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: GestureDetector(
            onTap: () {
              imageProvider.deleteImage(imageUrl);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 이미지 선택 후 서버에 업로드하는 메서드
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
                  XFile? image = await _pickImageFromGallery(context);
                  Navigator.of(context).pop();
                  if (image != null) {
                    await _apiService.uploadImage(File(image.path)); // 이미지 업로드 호출
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('카메라로 촬영'),
                onTap: () async {
                  XFile? image = await _pickImageFromCamera(context);
                  Navigator.of(context).pop();
                  if (image != null) {
                    await _apiService.uploadImage(File(image.path)); // 이미지 업로드 호출
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

// 헬퍼 메서드: pickImage를 개별적으로 호출하고 결과를 반환
  Future<XFile?> _pickImageFromGallery(BuildContext context) async {
    return await ImagePicker().pickImage(source: ImageSource.gallery);
  }

  Future<XFile?> _pickImageFromCamera(BuildContext context) async {
    return await ImagePicker().pickImage(source: ImageSource.camera);
  }
}