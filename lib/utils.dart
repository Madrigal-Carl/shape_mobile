import 'package:flutter/material.dart';

String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text
      .split(' ')
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1);
      })
      .join(' ');
}

Color getStatusBackgroundColor(String status) {
  switch (status.toLowerCase()) {
    case 'active':
    case 'qualified':
      return const Color(0xFF7ADB37);
    case 'inactive':
    case 'unqualified':
      return const Color(0xFFF7F7F7);
    case 'graduated':
      return const Color(0xFFD0E8FF);
    case 'transferred':
      return const Color(0xFFF0E5C0);
    case 'dropped':
      return const Color(0xFFFCE4E4);
    default:
      return Colors.grey;
  }
}

Color getStatusTextColor(String status) {
  switch (status.toLowerCase()) {
    case 'active':
    case 'qualified':
      return Colors.white;
    case 'inactive':
    case 'unqualified':
      return const Color(0xFF3B3B3B);
    case 'graduated':
      return const Color(0xFF004A9F);
    case 'transferred':
      return const Color(0xFF7F5900);
    case 'dropped':
      return const Color(0xFFAF0000);
    default:
      return Colors.white;
  }
}
