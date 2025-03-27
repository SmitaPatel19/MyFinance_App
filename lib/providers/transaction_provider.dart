import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myfinance/models/transaction_model.dart' as app_tx;

class TransactionProvider with ChangeNotifier {
  List<app_tx.Transaction> _transactions = [];
  List<app_tx.Transaction> get transactions => [..._transactions];

  final firestore.CollectionReference _firestoreTransactions =
  firestore.FirebaseFirestore.instance.collection('transactions');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Box<app_tx.Transaction> _transactionBox;

  TransactionProvider() {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    _transactionBox = await Hive.openBox<app_tx.Transaction>('transactions');
    loadTransactions();
  }

  Future<void> addTransaction(app_tx.Transaction transaction) async {
    await _transactionBox.add(transaction);

    User? user = _auth.currentUser;
    if (user != null) {
      await _firestoreTransactions.add({
        'userId': user.uid,
        'id': transaction.id,
        'description': transaction.title,
        'amount': transaction.amount,
        'isIncome': transaction.isIncome,
        'category': transaction.category,
        'date': transaction.date.toIso8601String(), // Ensuring date consistency
        'timestamp': firestore.FieldValue.serverTimestamp(),
      });
    }

    _transactions.add(transaction);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    int index = _transactions.indexWhere((tx) => tx.id == id);
    if (index != -1) {
      await _transactionBox.deleteAt(index);
      _transactions.removeAt(index);

      User? user = _auth.currentUser;
      if (user != null) {
        var snapshot = await _firestoreTransactions
            .where('userId', isEqualTo: user.uid)
            .where('id', isEqualTo: id)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
      notifyListeners();
    }
  }

  Future<void> updateTransaction(int index, app_tx.Transaction newTransaction) async {
    await _transactionBox.putAt(index, newTransaction);
    _transactions[index] = newTransaction;

    User? user = _auth.currentUser;
    if (user != null) {
      var snapshot = await _firestoreTransactions
          .where('userId', isEqualTo: user.uid)
          .where('id', isEqualTo: newTransaction.id)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({
          'description': newTransaction.title,
          'amount': newTransaction.amount,
          'isIncome': newTransaction.isIncome,
          'category': newTransaction.category,
          'date': newTransaction.date.toIso8601String(),
          'timestamp': firestore.FieldValue.serverTimestamp(),
        });
      }
    }
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _transactions = _transactionBox.values.toList();

    User? user = _auth.currentUser;
    if (user != null) {
      var snapshot = await _firestoreTransactions
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      _transactions = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return app_tx.Transaction(
          id: data['id'],
          title: data['description'],
          amount: (data['amount'] as num).toDouble(),
          isIncome: data['isIncome'] ?? false,
          category: data['category'] ?? 'Unknown',
          date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
        );
      }).toList();
    }
    notifyListeners();
  }

  double getTotalIncome() {
    return _transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double getTotalExpense() {
    return _transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  Map<String, double> getSpendingByCategory() {
    Map<String, double> spending = {};
    for (var tx in _transactions.where((tx) => !tx.isIncome)) {
      spending[tx.category] = (spending[tx.category] ?? 0) + tx.amount;
    }
    return spending;
  }
}
