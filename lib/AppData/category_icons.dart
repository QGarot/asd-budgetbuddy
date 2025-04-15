import 'package:flutter/material.dart';

class CategoryIcons {
  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return Icons.shopping_cart;
      case 'rent':
        return Icons.home;
      case 'entertainment':
        return Icons.movie;
      case 'dining':
        return Icons.restaurant;
      case 'travel':
        return Icons.flight;
      case 'utilities':
        return Icons.electrical_services;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }
}
