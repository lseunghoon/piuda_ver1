import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:piuda_ui/service/auth_service.dart';
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
      String? userId = await authService.signInWithPhoneNumberAndPassword(phoneNumber, password);

      if (userId != null) {
        // 로그인 성공
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // 로그인 실패
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
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), // 둥근 모서리 정도 설정
                          borderSide: BorderSide(
                            color: Colors.black, // 기본 테두리 색상: 검은색
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.black, // 활성화된 상태의 테두리 색상: 검은색
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.black, // 포커스된 상태의 테두리 색상: 검은색
                            width: 2.0, // 포커스된 상태의 테두리 두께
                          ),
                        ),
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
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), // 둥근 모서리 정도 설정
                          borderSide: BorderSide(
                            color: Colors.black, // 기본 테두리 색상: 검은색
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.black, // 활성화된 상태의 테두리 색상: 검은색
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.black, // 포커스된 상태의 테두리 색상: 검은색
                            width: 2.0, // 포커스된 상태의 테두리 두께
                          ),
                        ),
                      ),
                      validator: _validationModel.validatePassword,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                      _validateAndLogin,
                      //     () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => HomePage()),
                      //   );
                      // },
                      child: Text('로그인'),
                      style: ElevatedButton.styleFrom(
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
                          child: Text('회원가입',style: TextStyle(color: Colors.black),),
                        ),
                        Text('|'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPage()));
                          },
                          child: Text('비밀번호 재설정',style: TextStyle(color: Colors.black),),
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