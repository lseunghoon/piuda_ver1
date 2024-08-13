import 'package:flutter/material.dart';
import 'package:piuda_ui/models/text_validation_model.dart';  // 모델을 임포트

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late TextValidationModel _model;

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2021),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _model.textController5.text) {
      setState(() {
        _model.textController6.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              controller: _model.textController5, // textController5 할당
              focusNode: _model.textFieldFocusNode5, // textFieldFocusNode5 할당
              decoration: InputDecoration(
                labelText: '성명',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _model.textController6, // textController6 할당
              focusNode: _model.textFieldFocusNode6, // textFieldFocusNode6 할당
              decoration: InputDecoration(
                labelText: '생년월일',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () {
                _selectDate(context);
              },
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // 다음 버튼의 동작을 구현
              },
              child: Text('Next'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}