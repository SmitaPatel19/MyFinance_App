import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<TransactionProvider>(context).transactions;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Transactions", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.teal.shade50,
      body:
          transactions.isEmpty
              ? Center(
                child: Text(
                  "No transactions yet!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: transactions.length,
                itemBuilder: (ctx, index) {
                  final tx = transactions[index];
                  bool isIncome =
                      tx.isIncome; // Check if it's income or expense
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isIncome
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                        radius: 28,
                        child: Icon(
                          isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isIncome ? Colors.green : Colors.red,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        tx.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        "${tx.category} - \$${tx.amount.toStringAsFixed(2)}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => Provider.of<TransactionProvider>(
                              context,
                              listen: false,
                            ).deleteTransaction(tx.id),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddTransactionPage()),
            ),
        backgroundColor: Colors.teal,
        elevation: 6,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
