import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageProviderModel with ChangeNotifier {
  List<String> _imageUrls = [];  // 이미지 파일 경로들

  List<String> get imageUrls => _imageUrls;

  final ImagePicker _picker = ImagePicker();

  // 이미지 선택
  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final File imageFile = File(image.path);
      await _uploadImage(imageFile);  // 이미지 업로드
      notifyListeners();
    }
  }

  // 이미지를 Base64로 인코딩한 후 서버로 업로드
  Future<void> _uploadImage(File file) async {
    try {
      // 파일을 Base64로 인코딩
      final bytes = await file.readAsBytes();
      String base64Image = base64Encode(bytes);

      // 서버로 POST 요청을 통해 전송
      final response = await http.post(
        Uri.parse('http://your-server.com/upload-image'), // 서버의 URL로 변경
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image": base64Image}),
      );

      if (response.statusCode == 200) {
        print('Image uploaded successfully!');
        // 성공적으로 업로드한 이미지를 로컬 리스트에 추가할 수 있습니다.
        _imageUrls.add(file.path);
        notifyListeners();
      } else {
        print('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
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