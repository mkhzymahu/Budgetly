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

class CurrencyUtils {
  static final Map<String, CurrencyData> currencies = {
    'USD': CurrencyData(symbol: '\$', name: 'US Dollar', flag: '🇺🇸'),
    'EUR': CurrencyData(symbol: '€', name: 'Euro', flag: '🇪🇺'),
    'GBP': CurrencyData(symbol: '£', name: 'British Pound', flag: '🇬🇧'),
    'JPY': CurrencyData(symbol: '¥', name: 'Japanese Yen', flag: '🇯🇵'),
    'INR': CurrencyData(symbol: '₹', name: 'Indian Rupee', flag: '🇮🇳'),
    'AUD': CurrencyData(symbol: 'A\$', name: 'Australian Dollar', flag: '🇦🇺'),
    'CAD': CurrencyData(symbol: 'C\$', name: 'Canadian Dollar', flag: '🇨🇦'),
    'CNY': CurrencyData(symbol: '¥', name: 'Chinese Yuan', flag: '🇨🇳'),
    'KRW': CurrencyData(symbol: '₩', name: 'South Korean Won', flag: '🇰🇷'),
    'RUB': CurrencyData(symbol: '₽', name: 'Russian Ruble', flag: '🇷🇺'),
    'BRL': CurrencyData(symbol: 'R\$', name: 'Brazilian Real', flag: '🇧🇷'),
  };

  static String getSymbol(String currencyCode) {
    return currencies[currencyCode]?.symbol ?? '\$';
  }

  static String getFlag(String currencyCode) {
    return currencies[currencyCode]?.flag ?? '🇺🇸';
  }

  static String getName(String currencyCode) {
    return currencies[currencyCode]?.name ?? 'US Dollar';
  }

  static List<String> getCurrencyCodes() {
    return currencies.keys.toList();
  }
}

class CurrencyData {
  final String symbol;
  final String name;
  final String flag;

  CurrencyData({required this.symbol, required this.name, required this.flag});
}
