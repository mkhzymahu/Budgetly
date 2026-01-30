import 'package:flutter/material.dart';

const List<String> categories = [
  'Food',
  'Travel',
  'Bills',
  'Shopping',
  'Entertainment',
  'Other',
];

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Food':
      return Icons.restaurant;
    case 'Travel':
      return Icons.directions_car;
    case 'Bills':
      return Icons.receipt;
    case 'Shopping':
      return Icons.shopping_bag;
    case 'Entertainment':
      return Icons.movie;
    default:
      return Icons.category;
  }
}
