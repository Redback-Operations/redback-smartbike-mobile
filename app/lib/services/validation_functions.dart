import 'package:flutter/material.dart';

class ValidationFunctions {
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    final RegExp dateRegex = RegExp(
      r'^\d{4}-\d{2}-\d{2}$',
    );

    if (!dateRegex.hasMatch(value)) {
      return null; // Return null to indicate that the input is invalid
    }
    return null; // Return null if the input is valid
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final RegExp emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null; // Return null if the input is valid
  }

  static String? validateLength(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < 5) {
      return 'Minimum length is 5 characters';
    }
    if (value.length > 50) {
      return 'Maximum length is 50 characters';
    }
    return null; // Return null if the value is valid
  }
}
