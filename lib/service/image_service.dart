import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:piuda_ui/constants/constants.dart';

class ImageService {
  final String _baseUrl = baseUrl; // 서버 URL
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // 이미지 업로드 (Base64 인코딩 및 화질 저하 및 페르소나 생성)
  Future<Map<String, dynamic>?> captureAndUploadImageAndCreatePersona(String targetAge) async {
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
    List<int> compressedImageBytes = img.encodeJpg(originalImage, quality: 70);

    // 5. Base64로 인코딩
    String base64Image = base64Encode(compressedImageBytes);

    // 6. 서버로 이미지 업로드 및 URL 반환
    String? imageUrl = await uploadImage(base64Image, pickedFile.name, targetAge);

    if (imageUrl != null) {
      // 페르소나 생성
      final personaService = PersonaService();
      Map<String, dynamic>? personaData = await personaService.createPersona(imageUrl);

      if (personaData != null) {
        print("Persona creation successful: $personaData");
        return personaData; // 페르소나 생성 정보 반환
      } else {
        print("Failed to create persona.");
        return null;
      }
    } else {
      print("Failed to upload image.");
      return null;
    }
  }

  // 갤러리에서 이미지 선택 및 업로드
  Future<String?> uploadImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      print("No image selected.");
      return null;
    }

    // 이미지 파일 읽기
    final File imageFile = File(pickedFile.path);
    final imageBytes = await imageFile.readAsBytes();

    // 이미지 디코딩
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      print("Failed to decode image.");
      return null;
    }

    // 화질 저하 (리사이즈 없이 화질만 저하)
    List<int> compressedImageBytes = img.encodeJpg(originalImage, quality: 100);

    // Base64로 인코딩
    String base64Image = base64Encode(compressedImageBytes);

    // 서버로 이미지 업로드 및 URL 반환
    return await uploadImage(base64Image, pickedFile.name, '0'); // targetAge를 '0'으로 설정
  }

  // 서버로 이미지 업로드
  Future<String?> uploadImage(String base64Image, String filename, String targetAge) async {
    String? userId = await _storage.read(key: 'user_id');

    if (userId == null) {
      print("No user ID found. Please log in first.");
      return null;
    }

    try {
      // 백엔드에서 정의한 모델 구조에 맞춰서 데이터 구성
      Map<String, dynamic> body = {
        'filename': filename,
        'base64_image': base64Image,
        'user_id': userId,  // 유저 ID를 함께 보냄
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/face/aging?target_age=$targetAge'),
        headers: {
          "Content-Type": "application/json",
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

class PersonaService {
  final String _baseUrl = baseUrl; // 서버 URL
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // 페르소나 생성
  Future<Map<String, dynamic>?> createPersona(String imageUrl) async {
    String? userId = await _storage.read(key: 'user_id'); // 로그인 시 저장된 user_id 가져오기

    if (userId == null) {
      print("No user_id found. Please log in first.");
      return null;
    }

    try {
      // 서버에 전송할 데이터 구성
      Map<String, dynamic> body = {
        'image_url': imageUrl,
        'user_id': userId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/persona/create'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Persona created successfully: $responseData");

        // persona_id를 추출하여 저장
        String? personaId = responseData['persona_id'];
        if (personaId != null) {
          await _storage.write(key: 'persona_id', value: personaId);
          print("Persona ID saved successfully: $personaId");
        } else {
          print("persona_id not found in response.");
        }

        return responseData;
      } else {
        print("Failed to create persona. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}