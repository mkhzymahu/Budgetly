import 'package:flutter/material.dart';

class CurrencyManager {
  static final ValueNotifier<String> currentCurrency =
      ValueNotifier<String>('USD');

  static const Map<String, String> symbols = {
    'USD': '\$',
    'EUR': '€',
    'PKR': '₨',
    'GBP': '£',
    'JPY': '¥',
  };
}
