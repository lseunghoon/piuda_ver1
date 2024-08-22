import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class CustomAuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _phoneNumber = '';
  String _password = '';

  bool get isLoggedIn => _isLoggedIn;
  String get phoneNumber => _phoneNumber;
  String get password => _password;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void setPhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void clear() {
    _phoneNumber = '';
    _password = '';
    notifyListeners();
  }
}

class AuthService {
  final String baseUrl = 'http://49.142.181.186:8000'; // FastAPI 서버 URL "http://49.142.181.186:8000";
  final storage = FlutterSecureStorage();

  // 이메일/비밀번호로 회원가입
  Future<bool> registerWithEmailAndPassword(String name, String phoneNumber, String password, String birthDate, String gender) async {
    final url = Uri.parse('$baseUrl/signup');
    final body = jsonEncode({
      'name': name,
      'phone_number': phoneNumber,
      'password': password,
      'birthdate': birthDate,
      'gender': gender,
    });

    try {
      final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: body);

      if (response.statusCode == 200) {
        print('User registered successfully.');
        return true;
      } else {
        print('Failed to register user: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  // 이메일/비밀번호로 로그인
  Future<bool> signInWithPhoneNumberAndPassword(String phoneNumber, String password) async {
    final url = Uri.parse('$baseUrl/token');
    final body = {
      'username': phoneNumber,
      'password': password,
    };

    try {
      final response = await http.post(url, headers: {"Content-Type": "application/x-www-form-urlencoded"}, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'access_token', value: data['access_token']);

        // JWT 토큰을 디코딩하고 user_id 추출
        Map<String, dynamic> decodedToken = JwtDecoder.decode(data['access_token']);

        if (decodedToken.containsKey('user_id')) {
          String userId = decodedToken['user_id'];
          await storage.write(key: 'user_id', value: userId);
        } else {
          print('user_id not found in token');
          return false;
        }

        print('User logged in successfully.');
        return true;
      } else {
        print('Failed to log in: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'user_id'); // user_id도 삭제
      print('User logged out successfully.');
    } catch (e) {
      print('Failed to log out: $e');
    }
  }

  // 현재 로그인한 사용자 가져오기 (토큰 사용)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final url = Uri.parse('$baseUrl/me');
    final token = await storage.read(key: 'access_token');
    final userId = await storage.read(key: 'user_id');

    if (token == null || userId == null) {
      return null;
    }

    try {
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to get user info: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}