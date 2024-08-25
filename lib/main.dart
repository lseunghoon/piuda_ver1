import 'package:flutter/material.dart';
import 'dart:async';
import 'package:piuda_ui/screens/signin_page.dart';
import 'package:piuda_ui/screens/home_page.dart';
import 'package:piuda_ui/models/image_model.dart';
import 'package:piuda_ui/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'godic',
        primaryColor: Color(0xFFF7EEE4), // 앱바 색상으로 적용
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFFF7EEE4), // 앱의 주요 색상
          secondary: Color(0xFF0F1C43), // 보조 색상 (버튼 색상 등)
          surface: Color(0xFFF4A261), // 표면 색상
        ),
        scaffoldBackgroundColor: Color(0xFFF7EEE4), // 앱 배경화면 색상
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFF7EEE4), // 앱바의 배경색
          foregroundColor: Color(0xFF0F1C43), // 앱바의 텍스트 및 아이콘 색상
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0F1C43), // 버튼의 배경색
            foregroundColor: Colors.white, // 버튼의 텍스트 색상
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // 둥근 모서리
            ),
          ),
        ),
      ),
      locale: Locale('ko', 'KR'), // 한국어로 설정
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // 영어
        const Locale('ko', 'KR'), // 한국어
      ],
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