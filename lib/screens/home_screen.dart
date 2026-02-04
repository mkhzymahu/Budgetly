import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../widgets/expense_tile.dart';
import '../utils/date_helpers.dart';
import '../utils/categories.dart';
import 'package:intl/intl.dart';
import 'add_expense_screen.dart';
import '../widgets/currency_coin.dart';
import '../widgets/currency_dropdown.dart';
import '../widgets/edit_expense_modal.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> _expenses = [];
  String _selectedMonthYear = '';
  List<String> _monthYearOptions = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  bool? _selectedType; // null = all, true = income, false = expense
  
  // Currency related state
  String _selectedCurrency = 'INR';
  bool _isCurrencyMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _monthYearOptions = DateHelpers.getMonthYearOptions();
    _selectedMonthYear = _monthYearOptions.last;

    // Add some sample data for testing
    _addSampleData();
  }

  void _addSampleData() {
    final sampleExpenses = [
      Expense(
        id: '1',
        title: 'Salary',
        amount: 50000,
        category: 'Other',
        date: DateTime(2024, 1, 15),
        isIncome: true,
        currency: 'INR',
      ),
      Expense(
        id: '2',
        title: 'Groceries',
        amount: 2500,
        category: 'Food',
        date: DateTime(2024, 1, 20),
        isIncome: false,
        currency: 'INR',
      ),
      Expense(
        id: '3',
        title: 'Movie Tickets',
        amount: 800,
        category: 'Entertainment',
        date: DateTime(2024, 2, 5),
        isIncome: false,
        currency: 'INR',
      ),
      Expense(
        id: '4',
        title: 'Freelance Work',
        amount: 15000,
        category: 'Other',
        date: DateTime(2024, 2, 10),
        isIncome: true,
        currency: 'INR',
      ),
      Expense(
        id: '5',
        title: 'Electricity Bill',
        amount: 1200,
        category: 'Bills',
        date: DateTime(2024, 3, 1),
        isIncome: false,
        currency: 'INR',
      ),
      Expense(
        id: '6',
        title: 'Online Shopping',
        amount: 3500,
        category: 'Shopping',
        date: DateTime(2024, 3, 15),
        isIncome: false,
        currency: 'INR',
      ),
    ];

    setState(() {
      _expenses.addAll(sampleExpenses);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addExpense() async {
    final selectedMonth = DateHelpers.parseMonthYear(_selectedMonthYear);
    final defaultDate = DateHelpers.getDefaultDateForMonth(selectedMonth);

    final expense = await Navigator.push<Expense>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddExpenseScreen(
          initialDate: defaultDate,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    if (expense != null) {
      setState(() {
        _expenses.insert(0, expense);
      });
    }
  }

  void _deleteExpense(int index) {
    final filteredExpenses = _getFilteredExpenses();
    final expenseToDelete = filteredExpenses[index];
    final originalIndex = _expenses.indexWhere(
      (e) => e.id == expenseToDelete.id,
    );

    if (originalIndex != -1) {
      setState(() {
        _expenses.removeAt(originalIndex);
      });
    }
  }

  void _editExpense(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index == -1) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: EditExpenseModal(
              expense: expense,
              onSave: (updatedExpense) {
                setState(() {
                  _expenses[index] = updatedExpense;
                });
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated "${updatedExpense.title}"'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              onCancel: () => Navigator.pop(context),
            ),
          ),
        );
      },
    );
  }

  List<Expense> _getFilteredExpenses() {
    if (_expenses.isEmpty) return [];

    final selectedDate = DateHelpers.parseMonthYear(_selectedMonthYear);

    return _expenses.where((expense) {
      // Month filter
      final matchesMonth = DateHelpers.isSameMonth(expense.date, selectedDate);

      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          expense.category.toLowerCase().contains(_searchQuery.toLowerCase());

      // Type filter (income/expense)
      final matchesType =
          _selectedType == null || expense.isIncome == _selectedType;

      // Category filter
      final matchesCategory =
          _selectedCategory == null || expense.category == _selectedCategory;

      return matchesMonth && matchesSearch && matchesType && matchesCategory;
    }).toList();
  }

  String _formatAmount(double amount, {bool showSymbol = true}) {
    final currencySymbol = CurrencyUtils.getSymbol(_selectedCurrency);
    final formattedAmount = NumberFormat.currency(
      decimalDigits: 2,
      symbol: showSymbol ? currencySymbol : '',
    ).format(amount);
    
    return formattedAmount;
  }

  void _handleCurrencyChange(String newCurrency) {
    setState(() {
      _selectedCurrency = newCurrency;
      _isCurrencyMenuOpen = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Currency changed to $newCurrency'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showCurrencyDropdown() {
    setState(() {
      _isCurrencyMenuOpen = true;
    });
    
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: CurrencyDropdown(
            selectedCurrency: _selectedCurrency,
            onCurrencyChanged: _handleCurrencyChange,
            onClose: () {
              setState(() {
                _isCurrencyMenuOpen = false;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filteredExpenses = _getFilteredExpenses();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Filter Chips
          Text(
            'Filter by Type:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              // All Chip
              FilterChip(
                selected: _selectedType == null,
                label: const Text('All'),
                onSelected: (selected) {
                  setState(() {
                    _selectedType = null;
                  });
                },
                selectedColor: Colors.blue.shade100,
                checkmarkColor: Colors.blue,
                labelStyle: TextStyle(
                  color: _selectedType == null
                      ? Colors.blue
                      : Colors.grey.shade700,
                ),
              ),
              // Income Chip
              FilterChip(
                selected: _selectedType == true,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_upward, size: 14),
                    const SizedBox(width: 4),
                    Text('Income (${_formatAmount(_totalIncome)})'),
                  ],
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? true : null;
                  });
                },
                selectedColor: Colors.green.shade100,
                checkmarkColor: Colors.green,
                labelStyle: TextStyle(
                  color: _selectedType == true
                      ? Colors.green
                      : Colors.grey.shade700,
                ),
              ),
              // Expense Chip
              FilterChip(
                selected: _selectedType == false,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_downward, size: 14),
                    const SizedBox(width: 4),
                    Text('Expense (${_formatAmount(_totalExpense)})'),
                  ],
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? false : null;
                  });
                },
                selectedColor: Colors.red.shade100,
                checkmarkColor: Colors.red,
                labelStyle: TextStyle(
                  color: _selectedType == false
                      ? Colors.red
                      : Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Category Filter
          Text(
            'Filter by Category:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // "All" category
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _selectedCategory == null,
                      label: const Text('All'),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                      selectedColor: Colors.blue.shade100,
                      checkmarkColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: _selectedCategory == null
                            ? Colors.blue
                            : Colors.grey.shade700,
                      ),
                    ),
                  );
                }

                final category = categories[index - 1];
                final categoryCount = filteredExpenses
                    .where((e) => e.category == category)
                    .length;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: _selectedCategory == category,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getCategoryIcon(category), size: 14),
                        const SizedBox(width: 4),
                        Text('$category ($categoryCount)'),
                      ],
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category
                          ? Colors.blue
                          : Colors.grey.shade700,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthFilter() {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Month:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMonthYear,
                    isExpanded: true,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                    ),
                    items: _monthYearOptions.map((monthYear) {
                      return DropdownMenuItem<String>(
                        value: monthYear,
                        child: Text(monthYear),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonthYear = value!;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_selectedMonthYear != _monthYearOptions.last)
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonthYear = _monthYearOptions.last;
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.blue, size: 20),
                tooltip: 'Reset to current month',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_expenses.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first transaction',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    // When there are expenses but filtered list is empty
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 72, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(
          'No matching transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _searchQuery.isNotEmpty
              ? 'No results for "$_searchQuery"'
              : 'Try changing your filters',
          style: TextStyle(color: Colors.grey.shade500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _searchQuery = '';
              _searchController.clear();
              _selectedCategory = null;
              _selectedType = null;
            });
          },
          icon: const Icon(Icons.clear_all),
          label: const Text('Clear All Filters'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
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

  double get _totalIncome {
    final filteredExpenses = _getFilteredExpenses();
    return filteredExpenses
        .where((e) => e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get _totalExpense {
    final filteredExpenses = _getFilteredExpenses();
    return filteredExpenses
        .where((e) => !e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get _balance => _totalIncome - _totalExpense;

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _getFilteredExpenses();
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green.shade800, Colors.green.shade600],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budgetly',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              letterSpacing: -0.5,
                            ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM d').format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  
                  // Currency Coin Button
                  GestureDetector(
                    onTap: _showCurrencyDropdown,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Stack(
                        children: [
                          // Animated Currency Coin
                          CurrencyCoin(
                            currentCurrency: _selectedCurrency,
                            onTap: _showCurrencyDropdown,
                            isMenuOpen: _isCurrencyMenuOpen,
                          ),
                          
                          // Currency code badge
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade900,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _selectedCurrency,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight - 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Balance Card
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Balance',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                CurrencyUtils.getFlag(_selectedCurrency),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedCurrency,
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatAmount(_balance),
                      style: TextStyle(
                        color: _balance >= 0
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Income vs Expense
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: Colors.green.shade600,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Income',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatAmount(_totalIncome),
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey.shade300,
                        ),

                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: Colors.red.shade600,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatAmount(_totalExpense),
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Search Bar
              _buildSearchBar(),

              // Month Filter
              _buildMonthFilter(),

              // Filter Chips (Type & Category)
              if (_expenses.isNotEmpty) _buildFilterChips(),

              // Transaction Count Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  12,
                ),
                child: Row(
                  children: [
                    Text(
                      'Transactions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        filteredExpenses.length.toString(),
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (filteredExpenses.isNotEmpty && _totalIncome > 0)
                      Text(
                        '${(_totalExpense / _totalIncome * 100).toStringAsFixed(0)}% spent',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              // Transaction List or Empty State
              if (filteredExpenses.isEmpty)
                SizedBox(
                  height: 200,
                  child: _buildEmptyState(),
                )
              else
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  itemCount: filteredExpenses.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    return ExpenseTile(
                      expense: expense,
                      onDelete: () => _deleteExpense(index),
                      onEdit: _editExpense,
                      searchQuery: _searchQuery,
                    );
                  },
                ),

              // Add bottom padding for FAB
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
    );
  }
}
