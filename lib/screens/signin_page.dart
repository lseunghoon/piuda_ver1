import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:piuda_ui/models/auth_model.dart';
import 'package:piuda_ui/screens/home_page.dart';
import 'package:piuda_ui/screens/signup_page.dart'; // 회원가입 페이지 임포트
import 'package:piuda_ui/screens/pw_reset_page.dart'; // 비밀번호 재설정 페이지 임포트
import 'package:piuda_ui/models/text_validation_model.dart';
import 'package:piuda_ui/models/phonenum_format.dart'; // PhoneNumberInputFormatter 클래스 임포트

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late TextValidationModel _validationModel;

  @override
  void initState() {
    super.initState();
    _validationModel = TextValidationModel();
  }

  @override
  void dispose() {
    _validationModel.dispose();
    super.dispose();
  }

  void _validateAndLogin() async {
    if (_formKey.currentState!.validate()) {
      String phoneNumber = _validationModel.phoneNumberController.text.trim().replaceAll('-', '');
      String password = _validationModel.passwordController.text.trim();

      final authService = Provider.of<AuthService>(context, listen: false);
      bool isLoggedIn = await authService.signInWithPhoneNumberAndPassword(phoneNumber, password);

      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인에 실패했습니다. 전화번호와 비밀번호를 확인해주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _validationModel.phoneNumberController,
                      focusNode: _validationModel.phoneNumberFocusNode,
                      decoration: InputDecoration(
                        labelText: '전화번호',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능하도록 필터링
                        PhoneNumberInputFormatter(), // 전화번호 포맷 적용
                      ],
                      validator: _validationModel.validatePhoneNumber,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _validationModel.passwordController,
                      focusNode: _validationModel.passwordFocusNode,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      validator: _validationModel.validatePassword,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }, //_validateAndLogin,
                      child: Text('로그인'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                          },
                          child: Text('회원가입'),
                        ),
                        Text('|', style: TextStyle(color: Colors.grey)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPage()));
                          },
                          child: Text('비밀번호 재설정'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}