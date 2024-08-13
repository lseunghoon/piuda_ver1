import 'package:flutter/material.dart';
import 'package:piuda_ui/models/text_validation_model.dart';  // 모델을 임포트

class ResetPage extends StatefulWidget {
  const ResetPage({super.key});

  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  late TextValidationModel _model;
  final _formKey = GlobalKey<FormState>();  // GlobalKey를 생성하여 Form을 관리

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

  void _sendVerificationCode() {
    // 여기에 전화번호를 확인하고 인증번호를 전송하는 로직을 추가하세요
    print('인증번호 전송: ${_model.textController3.text}');
  }

  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      // 모든 입력이 유효한 경우 실행될 로직
      print("유효성 검사 통과");
    } else {
      // 유효성 검사에 실패한 경우
      print("유효성 검사 실패");
    }

    // textController4의 값을 출력
    String? validationResult = _model.textController4Validator(_model.textController4.text);
    if (validationResult != null) {
      print('textController4Validator 반환값: $validationResult');
    } else {
      print('textController4의 값이 유효합니다: ${_model.textController4.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 재설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,  // Form에 key를 할당하여 유효성 검사를 제어
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
                  controller: _model.textController3, // textController3 할당
                  focusNode: _model.textFieldFocusNode3, // textFieldFocusNode3 할당
                  autofocus: true,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: '01012345678',
                  ),
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    letterSpacing: 0,
                  ),
                  validator: (value) => _model.textController3Validator(value), // 전화번호 검증 로직 추가
                ),
              ),
              Align(
                alignment: AlignmentDirectional(-1, 0),
                child: Text(
                  '인증번호',
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    letterSpacing: 0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 20),
                child: TextFormField(
                  controller: _model.textController4, // textController4 할당
                  focusNode: _model.textFieldFocusNode4, // textFieldFocusNode4 할당
                  autofocus: true,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: '_ _ _ _ _ _',
                  ),
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    letterSpacing: 0,
                  ),
                  validator: (value) => _model.textController4Validator(value), // 인증번호 검증 로직 추가
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                child: ElevatedButton(
                  onPressed: _validateAndSubmit,  // 버튼 클릭 시 유효성 검사와 출력 실행
                  child: Text('Next'),
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
            ],
          ),
        ),
      ),
    );
  }
}