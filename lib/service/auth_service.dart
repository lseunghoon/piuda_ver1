import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:piuda_ui/constants/constants.dart';

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
  final String _baseUrl = baseUrl; // 서버 URL
  final storage = FlutterSecureStorage();


  Future<bool> registerWithEmailAndPassword(
      String name, String phoneNumber, String password, String birthDate, String gender) async {
    final url = Uri.parse('$_baseUrl/user/create');
    final body = jsonEncode({
      'name': name,
      'phone_number': phoneNumber,
      'password': password,
      'birth': birthDate,
      'gender': gender,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

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

  // 전화번호와 비밀번호로 로그인
  Future<String?> signInWithPhoneNumberAndPassword(String phoneNumber, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final body = jsonEncode({
      'phone_number': phoneNumber,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",  // JSON 형식으로 요청
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // user_id 저장
        String? userId = data['user_id'];
        if (userId != null) {
          await storage.write(key: 'user_id', value: userId); // user_id를 저장
          print('User logged in successfully. User ID: $userId');
          return userId; // 로그인 성공 시 user_id 반환
        } else {
          print('user_id is null');
          return null;
        }
      } else {
        print('Failed to log in: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await storage.delete(key: 'user_id'); // user_id 삭제
      print('User logged out successfully.');
    } catch (e) {
      print('Failed to log out: $e');
    }
  }

  // 현재 로그인한 사용자 가져오기 (user_id 사용)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userId = await storage.read(key: 'user_id');

    if (userId == null) {
      return null;
    }

    final url = Uri.parse('$_baseUrl/user/$userId');

    try {
      final response = await http.get(url);

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