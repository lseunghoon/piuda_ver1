import 'package:flutter/material.dart';
import 'package:piuda_ui/models/text_validation_model.dart';
import 'package:piuda_ui/screens/signup_page.dart';
import 'package:piuda_ui/screens/pw_reset_page.dart';
import 'package:piuda_ui/screens/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextValidationModel _model;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _model = TextValidationModel();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _validateAndLogin() {
    if (_formKey.currentState!.validate()) {
      print("로그인 성공: 전화번호 - ${_model.textController1.text}, 비밀번호 - ${_model.textController2.text}");
      // 유효성 검증 성공 시 홈 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      print("유효성 검사 실패");
      //일단 로그인 누르면 바로 홈페이지로 가도록 함
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey, // Form key 추가
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 391,
                    height: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://picsum.photos/seed/642/600',
                        width: 300,
                        height: 252,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(40, 40, 40, 40),
                    child: Text(
                      'Welcome to Piuda',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Readex Pro',
                        fontSize: 30,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Container(
                    width: 362,
                    height: 411,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(-1, 0),
                          child: Text(
                            '전화번호',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 20),
                          child: TextFormField(
                            controller: _model.textController1,
                            focusNode: _model.textFieldFocusNode1,
                            autofocus: true,
                            obscureText: false,
                            decoration: InputDecoration(
                                hintText: '010-0000-0000'
                            ),
                            style: TextStyle(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                            validator: (value) => _model.textController1Validator(value), // 전화번호 검증 로직 추가
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(-1, 0),
                          child: Text(
                            '비밀번호',
                            style: TextStyle(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 20),
                          child: TextFormField(
                            controller: _model.textController2,
                            focusNode: _model.textFieldFocusNode2,
                            autofocus: true,
                            obscureText: true, // 비밀번호는 보통 감춰지도록 처리
                            decoration: InputDecoration(
                                hintText: '비밀번호를 입력해주세요'
                            ),
                            style: TextStyle(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                            validator: (value) => _model.textController2Validator(value), // 비밀번호 검증 로직 추가
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(-1, 0),
                              child: Checkbox(
                                value: _model.checkboxValue ??= true,
                                onChanged: (newValue) {
                                  setState(() => _model.checkboxValue = newValue!);
                                },
                              ),
                            ),
                            Text(
                              '자동 로그인',
                              style: TextStyle(
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                          child: ElevatedButton(
                            onPressed: _validateAndLogin, // 로그인 버튼 클릭 시 유효성 검사 및 로그인 처리
                            child: Text('로그인'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              textStyle: TextStyle(fontSize: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(1, 0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPage()));
                                  },
                                  child: Text('비밀번호 재설정'),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                                    child: Text(
                                      '|',
                                      style: TextStyle(
                                        fontFamily: 'Readex Pro',
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                                  },
                                  child: Text('회원가입'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}