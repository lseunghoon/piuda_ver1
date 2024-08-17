import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:piuda_ui/widgets/bottom_navigator.dart'; // 필요한 파일을 추가
import 'alarm_page.dart'; // AlarmPage import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<File?> _images = []; // 이미지를 저장할 리스트
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 0; // 선택된 페이지 인덱스

  // 이미지를 선택하는 함수
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  // 옵션을 보여주는 함수
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
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('카메라로 촬영'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('홈'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AlarmPage()), // AlarmPage로 이동
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
          // 상단 이미지 섹션
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
          // 이미지 추가 버튼과 이미지 목록이 있는 스크롤 가능한 영역
          Expanded(
            child: Center(
              child: Container(
                height: 300,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.7),
                  itemCount: _images.length + 1, // 이미지 수 + 추가 버튼
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // 첫 번째 항목은 추가 버튼
                      var scale = _selectedIndex == index ? 1.0 : 0.8;
                      return TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 350),
                        tween: Tween(begin: scale, end: scale),
                        curve: Curves.ease,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: GestureDetector(
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
                        ),
                      );
                    } else {
                      // 나머지 항목들은 이미지들
                      var scale = _selectedIndex == index ? 1.0 : 0.8;
                      return TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 350),
                        tween: Tween(begin: scale, end: scale),
                        curve: Curves.ease,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                            image: _images[index - 1] != null
                                ? DecorationImage(
                              image: FileImage(_images[index - 1]!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 2), // 하단 네비게이션 바 추가
    );
  }
}