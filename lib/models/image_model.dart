import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageProviderModel with ChangeNotifier {
  List<String> _imageUrls = [];  // 이미지 파일 경로들

  List<String> get imageUrls => _imageUrls;

  final ImagePicker _picker = ImagePicker();

  // 이미지 선택
  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final File imageFile = File(image.path);
      _imageUrls.add(imageFile.path);  // 선택된 이미지의 파일 경로를 리스트에 추가
      notifyListeners();
    }
  }

  // 로컬 파일 시스템 또는 서버로 이미지 업로드 (로컬에서 경로를 리스트에 추가하는 방식으로 대체)
  Future<void> _uploadImage(File file) async {
    // 업로드 로직을 여기에 추가하거나 로컬 저장소에 대한 처리를 여기에 구현합니다.
    // 이 예제에서는 로컬 경로만 리스트에 추가합니다.
    _imageUrls.add(file.path);
    notifyListeners();
  }

  // 저장된 이미지 URL 불러오기 (로컬 저장소에서 불러오는 것으로 가정)
  Future<void> loadImages() async {
    // 로컬 파일 시스템에서 이미지 경로들을 불러와 `_imageUrls`에 추가하는 로직을 작성할 수 있습니다.
    // 예를 들어, 디렉터리에서 파일 목록을 읽어오는 방식으로 구현할 수 있습니다.
    notifyListeners();
  }

  // 이미지 삭제
  Future<void> deleteImage(String imagePath) async {
    try {
      // 로컬 파일 시스템에서 이미지 삭제
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }

      // 이미지 경로 리스트에서 해당 이미지 제거
      _imageUrls.remove(imagePath);
      notifyListeners();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}