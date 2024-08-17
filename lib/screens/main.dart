import 'package:flutter/material.dart';
import 'dart:async'; // Timer를 사용하기 위해 추가
import 'package:piuda_ui/screens/signin_page.dart'; // 로그인 페이지를 임포트

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // 앱이 시작되면 SplashScreen을 가장 먼저 표시
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3초 후에 로그인 페이지로 이동
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // 배경색
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image/green.png',
                width: 200, // 이미지의 너비
                height: 200, // 이미지의 높이
                fit: BoxFit.cover, // 이미지가 어떻게 잘려서 들어갈지 결정
              ),
              SizedBox(height: 20),
              Text(
                '마 함 피우자',
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}