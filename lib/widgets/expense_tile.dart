import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final Function(Expense) onEdit;
  final String? searchQuery;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onDelete,
    required this.onEdit,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id),
      dismissThresholds: const {
        DismissDirection.endToStart: 0.4,
        DismissDirection.startToEnd: 0.4,
      },
      background: _buildSwipeBackground(isLeft: true),
      secondaryBackground: _buildSwipeBackground(isLeft: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        } else {
          onEdit(expense);
          return false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
          _showDeleteSnackbar(context);
        }
      },
      child: _buildExpenseCard(context),
    );
  }

  Widget _buildSwipeBackground({required bool isLeft}) {
    return Container(
      color: isLeft ? Colors.blue.shade50 : Colors.red.shade50,
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: isLeft ? 24 : 20),
      child: Row(
        mainAxisAlignment:
            isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isLeft)
            const Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Colors.blue,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          if (!isLeft)
            const Row(
              children: [
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 24,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${expense.title}"'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: expense.isIncome
                ? Colors.green.shade100
                : Colors.red.shade100,
            child: Icon(
              _getCategoryIcon(expense.category),
              color: expense.isIncome ? Colors.green : Colors.red,
            ),
          ),
          title: _buildHighlightedText(expense.title, context),
          subtitle: Text(
            '${expense.category} • ${_formatDate(expense.date)}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${expense.isIncome ? '+' : '-'}₹${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: expense.isIncome ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(expense.date),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildHighlightedText(String text, BuildContext context) {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery!.toLowerCase();
    
    if (!lowerText.contains(lowerQuery)) {
      return Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final matches = <TextSpan>[];
    int start = 0;
    
    while (start < text.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      
      if (index == -1) {
        matches.add(TextSpan(
          text: text.substring(start),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ));
        break;
      }
      
      if (index > start) {
        matches.add(TextSpan(
          text: text.substring(start, index),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ));
      }
      
      matches.add(TextSpan(
        text: text.substring(index, index + searchQuery!.length),
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          backgroundColor: Colors.yellow,
          color: Colors.black,
        ),
      ));
      
      start = index + searchQuery!.length;
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(
          fontWeight: FontWeight.w500,
        ),
        children: matches,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (date.year == yesterday.year && 
        date.month == yesterday.month && 
        date.day == yesterday.day) {
      return 'Yesterday';
    }
    
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}