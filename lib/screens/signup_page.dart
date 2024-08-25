import 'package:flutter/material.dart';
import 'package:piuda_ui/screens/home_page.dart';
import 'package:piuda_ui/service/auth_service.dart';
import 'package:piuda_ui/models/text_validation_model.dart';
import 'package:flutter/services.dart';
import 'package:piuda_ui/models/phonenum_format.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _validationModel = TextValidationModel(); // TextValidationModel 인스턴스 생성
  String _selectedGender = '남성'; // 성별 선택 초기값
  DateTime? _selectedDate;
  final AuthService _authService = AuthService();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black, // 헤더 색상
              onSurface: Colors.black, // 텍스트 색상 (일반)
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // 버튼 텍스트 색상
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      String name = _validationModel.nameController.text.trim();
      String phoneNumber = _validationModel.phoneNumberController.text.trim().replaceAll('-', ''); // 하이픈 제거
      String password = _validationModel.passwordController.text.trim();
      String birthDate = _selectedDate != null ? "${_selectedDate!.toLocal()}".split(' ')[0] : '';

      try {
        bool isRegistered = await _authService.registerWithEmailAndPassword(
            name, phoneNumber, password, birthDate, _selectedGender); // gender를 추가하여 실제 데이터로 전송

        if (isRegistered) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
          );
        }
      } catch (e) {
        // 예외 발생 시 중복된 항목에 대한 메시지 처리
        if (e.toString().contains('phone number')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미 사용 중인 전화번호입니다.')),
          );
        } else if (e.toString().contains('email')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미 사용 중인 이메일입니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _validationModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('회원가입', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView( // SingleChildScrollView로 감싸기
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              // 성명 입력 필드
              TextFormField(
                controller: _validationModel.nameController,
                decoration: InputDecoration(
                  labelText: '성명',
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
                validator: _validationModel.validateName, // 유효성 검사 추가
              ),
              SizedBox(height: 16),
              // 전화번호 입력 필드
              TextFormField(
                controller: _validationModel.phoneNumberController,
                decoration: InputDecoration(
                  labelText: '전화번호',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
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
                validator: _validationModel.validatePhoneNumber, // 유효성 검사 추가
              ),
              SizedBox(height: 16),
              // 비밀번호 입력 필드
              TextFormField(
                controller: _validationModel.passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
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
                obscureText: true,
                validator: _validationModel.validatePassword, // 유효성 검사 추가
              ),
              SizedBox(height: 16),
              // 생년월일 입력 필드
              TextFormField(
                decoration: InputDecoration(
                  labelText: '생년월일',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
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
                readOnly: true,
                onTap: () => _selectDate(context),
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? "${_selectedDate!.toLocal()}".split(' ')[0]
                      : '',
                ),
              ),
              SizedBox(height: 16),
              // 성별 선택 필드
              Text('성별', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('남성'),
                      value: '남성',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                      activeColor: Colors.black,  // 선택된 상태에서의 체크 표시 색상
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('여성'),
                      value: '여성',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                      activeColor: Colors.black,  // 선택된 상태에서의 체크 표시 색상
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // 회원가입 버튼
              ElevatedButton(
                onPressed: _register,
                child: Text('회원가입'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}