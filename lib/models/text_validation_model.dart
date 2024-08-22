import 'package:flutter/material.dart';

class TextValidationModel {
  late TextEditingController nameController;
  late TextEditingController phoneNumberController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  late FocusNode nameFocusNode;
  late FocusNode phoneNumberFocusNode;
  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;

  bool? checkboxValue = false;

  TextValidationModel() {
    nameController = TextEditingController();
    phoneNumberController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    nameFocusNode = FocusNode();
    phoneNumberFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '성명을 입력해주세요.';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요.';
    }
    final RegExp phoneRegExp = RegExp(r'^01[0-9]{1}-[0-9]{3,4}-[0-9]{4}$');  // 하이픈 포함 형식으로 수정
    if (!phoneRegExp.hasMatch(value)) {
      return '유효한 전화번호를 입력해주세요. (예: 010-1234-5678)';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    final RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return '유효한 이메일을 입력해주세요.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    if (value.length < 8) {
      return '비밀번호는 최소 8자리여야 합니다.';
    }
    return null;
  }

  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();

    nameFocusNode.dispose();
    phoneNumberFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
  }
}