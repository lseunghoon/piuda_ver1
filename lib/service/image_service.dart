import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class ImageService {
  final String _baseUrl = 'http://172.23.247.114:8000';
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // 이미지 업로드 (Base64 인코딩 및 화질 저하)
  Future<String?> captureAndUploadImage(String targetAge) async {
    final ImagePicker picker = ImagePicker();

    // 1. 이미지를 촬영하거나 선택
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      print("No image selected.");
      return null;
    }

    // 2. 이미지 파일 읽기
    final File imageFile = File(pickedFile.path);
    final imageBytes = await imageFile.readAsBytes();

    // 3. 이미지 디코딩
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      print("Failed to decode image.");
      return null;
    }

    // 4. 화질 저하 (리사이즈 없이 화질만 저하)
    List<int> compressedImageBytes = img.encodeJpg(originalImage, quality: 100);

    // 5. Base64로 인코딩
    String base64Image = base64Encode(compressedImageBytes);

    // 6. 서버로 이미지 업로드 및 반환 값 받기
    return await uploadImage(base64Image, pickedFile.name, targetAge);
  }

  // 서버로 이미지 업로드
  Future<String?> uploadImage(String base64Image, String filename, String targetAge) async {
    String? token = await _storage.read(key: 'access_token');

    if (token == null) {
      print("No access token found. Please log in first.");
      return null;
    }

    try {
      // 백엔드에서 정의한 모델 구조에 맞춰서 데이터 구성
      Map<String, dynamic> body = {
        'filename': filename,
        'base64_image': base64Image,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/face/transform?target_age=$targetAge'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String imageUrl = responseData; // 서버에서 반환한 이미지 URL을 가져옴
        print("Image uploaded successfully! URL: $imageUrl");
        return imageUrl;
      } else {
        print("Failed to upload image. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}