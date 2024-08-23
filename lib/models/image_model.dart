import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageProviderModel with ChangeNotifier {
  List<String> _imageUrls = [];  // 서버에서 반환된 이미지 URL을 저장하는 리스트

  List<String> get imageUrls => _imageUrls;

  // SharedPreferences 키 설정
  final String _storageKey = 'saved_image_urls';

  ImageProviderModel() {
    loadImages();  // 객체 생성 시 로컬에서 이미지를 불러옵니다.
  }

  // 서버에서 반환된 이미지 URL 추가 및 로컬 저장
  void addImageUrl(String imageUrl) async {
    _imageUrls.add(imageUrl);
    notifyListeners();
    await _saveImagesToLocal();  // 로컬에 저장
  }

  // 저장된 이미지 URL 불러오기
  Future<void> loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    _imageUrls = prefs.getStringList(_storageKey) ?? [];
    notifyListeners();
  }

  // 이미지 삭제 및 로컬에서 제거
  Future<void> deleteImage(String imageUrl) async {
    try {
      _imageUrls.remove(imageUrl);
      notifyListeners();
      await _saveImagesToLocal();  // 로컬에서 업데이트
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // 이미지 URL 리스트를 로컬에 저장
  Future<void> _saveImagesToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _imageUrls);
  }
}