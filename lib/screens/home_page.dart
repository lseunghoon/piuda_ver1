import 'package:flutter/material.dart';
import 'package:piuda_ui/models/image_model.dart';
import 'package:piuda_ui/widgets/bottom_navigator.dart';
import 'package:piuda_ui/screens/alarm_page.dart';
import 'package:piuda_ui/screens/chat_page.dart';
import 'package:provider/provider.dart';
import 'package:piuda_ui/service/image_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;
  final ImageService _apiService = ImageService(); // ImageService 인스턴스 생성
  final PageController _pageController = PageController(viewportFraction: 0.7);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<ImageProviderModel>().loadImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = context.watch<ImageProviderModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('라떼'),
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
                      fontSize: 20,
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
                  controller: _pageController,
                  itemCount: imageProvider.imageUrls.length + 1, // Add one for the add button
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    if (index == 0 && imageProvider.imageUrls.isEmpty) {
                      return _buildAddImageButton(context); // Show add button when list is empty
                    } else if (index == 0) {
                      return _buildAddImageButton(context); // First index for add button
                    } else {
                      final imageUrl = imageProvider.imageUrls[index - 1];
                      final imageId = imageUrl; // 여기서 imageId를 imageUrl로 설정

                      return _buildRemoteImageCard(
                          context, index - 1, imageProvider, imageId, imageUrl);
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle, size: 80, color: Color(0xFF0F1C43)),
              SizedBox(height: 8),
              Text(
                '과거의 나를 만나보세요',
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

  Widget _buildRemoteImageCard(BuildContext context, int index,
      ImageProviderModel imageProvider, String imageId, String imageUrl) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;

        // "과거의 나를 만나보세요" 카드 (인덱스 0)는 크기 변화에서 제외
        if (index != 0 && _pageController.position.haveDimensions) {
          double currentPage = _pageController.page ?? _pageController.initialPage.toDouble();
          // "과거의 나를 만나보세요" 카드가 아닌 다른 카드들만 크기 변화를 적용
          value = (currentPage.round() == index) ? 1 : 1;
        }

        return Transform.scale(
          scale: value,
          child: Stack(
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
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            imageUrl: imageUrl,
                            imageId: imageId, // 전달할 imageId 추가
                          ),
                        ),
                      );
                    },
                    child: Text('대화하기'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
                  Navigator.of(context).pop(); // 모달 닫기

                  // 갤러리에서 이미지 선택 및 서버로 업로드
                  final imageService = ImageService();
                  String? imageUrl =
                  await imageService.uploadImageFromGallery();

                  if (imageUrl != null) {
                    context.read<ImageProviderModel>().addImageUrl(imageUrl); // 새 이미지 URL 추가
                    // 이미지를 추가한 후 홈 화면으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('카메라로 촬영'),
                onTap: () async {
                  Navigator.of(context).pop(); // 모달 닫기

                  // 이미지 촬영, 업로드, 페르소나 생성 모두 처리
                  Map<String, dynamic>? personaData = await _apiService.captureAndUploadImageAndCreatePersona('0');

                  if (personaData != null && personaData['image_url'] != null) {
                    String imageUrl = personaData['image_url'];
                    context.read<ImageProviderModel>().addImageUrl(imageUrl); // 새 이미지 URL 추가
                    // 이미지를 추가한 후 홈 화면으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } else {
                    print("Failed to upload image or create persona.");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}