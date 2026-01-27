import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class Validators {
  // 🔹 Regex reutilizables
  static final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$",
  );

  static final RegExp _phoneRegExp = RegExp(r'^[0-9]{6,12}$');
  static final RegExp _nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
  static final RegExp _usaCodeRegExp = RegExp(r'^[0-9]{3}$');

  // =======================================================
  // EMAIL
  // =======================================================
  String? email(BuildContext context, String email) {
    final s = S.of(context);

    if (email.isEmpty) return s.fieldRequired;
    if (!_emailRegExp.hasMatch(email)) return s.invalidEmail;

    return null;
  }

  // =======================================================
  // PHONE
  // =======================================================
  String? phone(BuildContext context, String phone) {
    final s = S.of(context);

    if (phone.isEmpty) return s.fieldRequired;
    if (!_phoneRegExp.hasMatch(phone)) return s.invalidPhone;

    return null;
  }

  // =======================================================
  // PASSWORD
  // =======================================================
  String? password(BuildContext context, String password) {
    final s = S.of(context);

    if (password.isEmpty) return s.fieldRequired;
    if (password.length < 6) return s.passwordMin;
    if (password.length > 20) return s.passwordMax;

    return null;
  }

  String? confirmPassword(
    BuildContext context,
    String password,
    String confirm,
  ) {
    final s = S.of(context);

    if (password != confirm) return s.passwordMismatch;
    return null;
  }

  // =======================================================
  // SIMPLE TEXT
  // =======================================================
  String? text(BuildContext context, String value) {
    final s = S.of(context);

    if (value.isEmpty) return s.fieldRequired;
    return null;
  }

  // =======================================================
  // NAME
  // =======================================================
  String? name(BuildContext context, String name) {
    final s = S.of(context);

    if (name.isEmpty) return s.fieldRequired;
    if (!_nameRegExp.hasMatch(name)) return s.invalidName;

    return null;
  }

  // =======================================================
  // LAST NAME
  // =======================================================
  String? lastName(BuildContext context, String lastName) {
    final s = S.of(context);

    if (lastName.isEmpty) return s.fieldRequired;
    if (!_nameRegExp.hasMatch(lastName)) return s.invalidLastName;

    return null;
  }

  // =======================================================
  // USA CODE (3 digits)
  // =======================================================
  String? usaCode(BuildContext context, String code) {
    final s = S.of(context);

    if (code.isEmpty) return s.fieldRequired;
    if (!_usaCodeRegExp.hasMatch(code)) return s.invalidCode;

    return null;
  }

  // =======================================================
  // MEMBER ID
  // =======================================================
  String? memberId(BuildContext context, String id) {
    final s = S.of(context);

    if (id.isEmpty) return s.fieldRequired;
    if (id.length != 8) return s.invalidMemberId;

    return null;
  }
}

final validators = Validators();
