import 'package:flutter/material.dart';
import 'package:piuda_ui/screens/home_page.dart';
import 'package:piuda_ui/models/auth_model.dart';
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

  DateTime? _selectedDate;
  final AuthService _authService = AuthService();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
      String email = _validationModel.emailController.text.trim();
      String password = _validationModel.passwordController.text.trim();
      String birthDate = _selectedDate != null ? "${_selectedDate!.toLocal()}".split(' ')[0] : '';

      try {
        bool isRegistered = await _authService.registerWithEmailAndPassword(
            name, phoneNumber, password, birthDate, 'gender'); // gender는 실제 데이터로 교체 필요

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
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, color: Colors.green),
                  SizedBox(width: 8),
                  Icon(Icons.circle_outlined),
                  SizedBox(width: 8),
                  Icon(Icons.circle_outlined),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _validationModel.nameController,
                decoration: InputDecoration(
                  labelText: '성명',
                  border: OutlineInputBorder(),
                ),
                validator: _validationModel.validateName,  // 유효성 검사 추가
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '생년월일',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(),
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
              TextFormField(
                controller: _validationModel.phoneNumberController,
                decoration: InputDecoration(
                  labelText: '전화번호',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능하도록 필터링
                  PhoneNumberInputFormatter(), // 전화번호 포맷 적용
                ],
                validator: _validationModel.validatePhoneNumber,  // 유효성 검사 추가
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _validationModel.emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                ),
                validator: _validationModel.validateEmail,  // 유효성 검사 추가
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _validationModel.passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validationModel.validatePassword,  // 유효성 검사 추가
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _register,
                child: Text('회원가입'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}