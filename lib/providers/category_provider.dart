import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  List<Category> get categories => [..._categories];

  late Box<Category> _categoryBox;

  /// Initialize and load categories from Hive
  CategoryProvider() {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _categoryBox = await Hive.openBox<Category>('categories');

    if (_categoryBox.isEmpty) {
      // Add default categories only once
      List<Category> defaultCategories = [
        Category(id: '1', name: 'Groceries'),
        Category(id: '2', name: 'Rent'),
        Category(id: '3', name: 'Salary'),
        Category(id: '4', name: 'Entertainment'),
      ];

      for (var category in defaultCategories) {
        _categoryBox.put(category.id, category);
      }
    }

    _categories = _categoryBox.values.toList(); // Load categories
    notifyListeners();
  }


  /// Add a new category and save it in Hive
  Future<void> addCategory(String name) async {
    Category newCategory = Category(id: DateTime.now().toString(), name: name);
    _categories.add(newCategory);
    await _categoryBox.put(newCategory.id, newCategory); // Save in Hive
    notifyListeners();
  }

  /// Delete a category from the list and Hive
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((cat) => cat.id == id);
    await _categoryBox.delete(id); // Remove from Hive
    notifyListeners();
  }
}
