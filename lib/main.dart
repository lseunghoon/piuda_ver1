import 'package:flutter/material.dart';
import 'dart:async';
import 'package:piuda_ui/screens/signin_page.dart';
import 'package:piuda_ui/screens/home_page.dart';
import 'package:piuda_ui/models/image_model.dart';
import 'package:piuda_ui/models/auth_model.dart';
import 'package:provider/provider.dart';
import 'package:piuda_ui/screens/story_list_page.dart';
import 'package:permission_handler/permission_handler.dart'; // permission_handler 패키지 임포트

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomAuthProvider()), // AuthProvider 등록
        ChangeNotifierProvider(create: (_) => ImageProviderModel()), // ImageProviderModel 등록
        Provider(create: (_) => AuthService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
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
    // 권한 요청 후 페이지 이동
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    // 마이크 권한 요청
    PermissionStatus status = await Permission.microphone.request();

    if (status.isGranted) {
      // 3초 후에 로그인 상태를 확인하여 적절한 페이지로 이동
      Timer(Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              final authProvider = Provider.of<CustomAuthProvider>(context, listen: false);
              return authProvider.isLoggedIn ? HomePage() : LoginPage();
            },
          ),
        );
      });
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // 권한이 거부되거나 영구적으로 거부된 경우 처리
      showPermissionDeniedDialog();
    }
  }

  void showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("권한 필요"),
          content: Text("앱을 사용하려면 마이크 권한이 필요합니다. 설정에서 권한을 허용해주세요."),
          actions: <Widget>[
            TextButton(
              child: Text("설정으로 이동"),
              onPressed: () {
                openAppSettings(); // 설정으로 이동
              },
            ),
            TextButton(
              child: Text("닫기"),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image/latte.png',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20),
              Text(
                '라떼는 말이야',
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