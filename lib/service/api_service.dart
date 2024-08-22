import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String _baseUrl = 'http://49.142.181.186:8000'; // 베이스 URL
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // 오디오 업로드
  Future<void> uploadAudio(List<int> audioData, String filename) async {
    Map<String, dynamic> body = {
      'data': audioData,
      'filename': filename,
    };

    String? token = await _storage.read(key: 'access_token');

    if (token == null) {
      print("No access token found. Please log in first.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/upload'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Audio uploaded successfully!");
      } else {
        print("Failed to upload audio. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // 이미지 업로드 (Base64 인코딩)
  Future<void> uploadImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(bytes);

      String? token = await _storage.read(key: 'access_token');

      if (token == null) {
        print("No access token found. Please log in first.");
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/upload-image'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"image": base64Image}),
      );

      if (response.statusCode == 200) {
        print('Image uploaded successfully!');
      } else {
        print('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

// 다른 API 메소드들을 여기에 추가할 수 있습니다.
}