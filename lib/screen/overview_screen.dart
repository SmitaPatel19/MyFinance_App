import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        if (transactionProvider.transactions.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text("Financial Overview",
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.teal,
            ),
            body: const Center(
              child: Text("No transactions available",
                  style: TextStyle(fontSize: 16)),
            ),
          );
        }

        double totalIncome = transactionProvider.getTotalIncome();
        double totalExpense = transactionProvider.getTotalExpense();
        double balance = totalIncome - totalExpense;
        Map<String, double> categoryTotals =
        transactionProvider.getSpendingByCategory();

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text("Financial Overview",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.teal,
          ),
          backgroundColor: Colors.teal.shade50,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _balanceCard(totalIncome, totalExpense, balance),
                const SizedBox(height: 20),
                Expanded(
                    child: _spendingChart(categoryTotals, totalExpense)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _balanceCard(double income, double expense, double balance) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Current Month",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoTile(Icons.arrow_upward, "Income", income, Colors.green),
                _infoTile(Icons.arrow_downward, "Expense", expense, Colors.red),
                _infoTile(
                    Icons.account_balance_wallet, "Balance", balance, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _spendingChart(Map<String, double> categoryTotals, double totalExpense) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Spending Breakdown",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 30),
            Expanded(
              flex: 3,
              child: Center(
                child: totalExpense > 0
                    ? PieChart(
                  PieChartData(
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    borderData: FlBorderData(show: false),
                    sections: categoryTotals.entries.map((e) {
                      double percentage = (e.value / totalExpense) * 100;
                      return PieChartSectionData(
                        value: e.value,
                        title: "${e.key}\n${percentage.toStringAsFixed(1)}%",
                        color: Colors.primaries[e.key.hashCode %
                            Colors.primaries.length],
                        radius: 90,
                        titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      );
                    }).toList(),
                  ),
                )
                    : const Text(
                  "No expenses available",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryTotals.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.primaries[
                              e.key.hashCode % Colors.primaries.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.key,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${(e.value / totalExpense * 100).toStringAsFixed(1)}%",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, double amount, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 5),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        Text("\$${amount.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
