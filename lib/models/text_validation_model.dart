import 'package:flutter/material.dart';

class TextValidationModel {
  late TextEditingController textController1;
  late TextEditingController textController2;
  late TextEditingController textController3;
  late TextEditingController textController4;
  late TextEditingController textController5;
  late TextEditingController textController6;

  late FocusNode textFieldFocusNode1;
  late FocusNode textFieldFocusNode2;
  late FocusNode textFieldFocusNode3;
  late FocusNode textFieldFocusNode4;
  late FocusNode textFieldFocusNode5;
  late FocusNode textFieldFocusNode6;

  bool? checkboxValue = false;

  TextValidationModel() {
    textController1 = TextEditingController();
    textController2 = TextEditingController();
    textController3 = TextEditingController();
    textController4 = TextEditingController();
    textController5 = TextEditingController();
    textController6 = TextEditingController();

    textFieldFocusNode1 = FocusNode();
    textFieldFocusNode2 = FocusNode();
    textFieldFocusNode3 = FocusNode();
    textFieldFocusNode4 = FocusNode();
    textFieldFocusNode5 = FocusNode();
    textFieldFocusNode6 = FocusNode();
  }

  // 전화번호 유효성 검증 로직
  String? textController1Validator(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요.';  // 입력값이 비어있을 때 에러 메시지
    }
    // 정규식을 사용해 하이픈 없이 10~11자리의 전화번호 형식 확인 (한국 형식: 01012345678 또는 0101234567)
    final RegExp phoneRegExp = RegExp(r'^01[0-9]{8,9}$');
    if (!phoneRegExp.hasMatch(value)) {
      return '올바른 형식으로 전화번호를 입력해주세요. (예: 01012345678)';  // 형식이 맞지 않을 때 에러 메시지
    }
    return null;  // 유효한 입력인 경우 null 반환 (에러 없음)
  }

  String? textController2Validator(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';  // 입력값이 비어있을 때 에러 메시지
    }
    if (value.length < 6) {
      return '비밀번호는 최소 6자 이상이어야 합니다.';  // 길이 확인
    }
    return null;  // 유효한 입력인 경우 null 반환 (에러 없음)
  }


  String? textController3Validator(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요.';  // 입력값이 비어있을 때 에러 메시지
    }
    // 정규식을 사용해 하이픈 없이 10~11자리의 전화번호 형식 확인 (한국 형식: 01012345678 또는 0101234567)
    final RegExp phoneRegExp = RegExp(r'^01[0-9]{8,9}$');
    if (!phoneRegExp.hasMatch(value)) {
      return '올바른 형식으로 전화번호를 입력해주세요. (예: 01012345678)';  // 형식이 맞지 않을 때 에러 메시지
    }
    return null;  // 유효한 입력인 경우 null 반환 (에러 없음)
  }

  String? textController4Validator(String? value) {
    if (value == null || value.isEmpty) {
      return '인증번호를 입력해주세요.';  // 입력값이 비어있을 때 에러 메시지
    }
    // 정규식을 사용해 6자리 숫자 형식 확인
    final RegExp codeRegExp = RegExp(r'^\d{6}$');
    if (!codeRegExp.hasMatch(value)) {
      return '6자리 숫자로 된 인증번호를 입력해주세요.';  // 형식이 맞지 않을 때 에러 메시지
    }
    return null;  // 유효한 입력인 경우 null 반환 (에러 없음)
  }

  String? textController5Validator(String? value) {
    return null;
  }

  String? textController6Validator(String? value) {
    return null;
  }

  void dispose() {
    textController1.dispose();
    textController2.dispose();
    textController3.dispose();
    textController4.dispose();
    textController5.dispose();
    textController6.dispose();

    textFieldFocusNode1.dispose();
    textFieldFocusNode2.dispose();
    textFieldFocusNode3.dispose();
    textFieldFocusNode4.dispose();
    textFieldFocusNode5.dispose();
    textFieldFocusNode6.dispose();
  }
}