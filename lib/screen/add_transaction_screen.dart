import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';


class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  bool isIncome = true;
  String? selectedCategory;
  DateTime selectedDate = DateTime.now();

  void submitData() {
    final enteredTitle = titleController.text;
    final enteredAmount = double.tryParse(amountController.text) ?? 0;

    if (enteredTitle.isEmpty || enteredAmount <= 0 || selectedCategory == null) {
      return;
    }

    Provider.of<TransactionProvider>(context, listen: false).addTransaction(
      Transaction(
        id: DateTime.now().toString(),
        title: enteredTitle,
        amount: enteredAmount,
        category: selectedCategory!,
        isIncome: isIncome,
        date: selectedDate,
      ),
    );

    Navigator.pop(context);
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Transaction",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.teal.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                          value: cat.name, child: Text(cat.name));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value.toString();
                      });
                    },
                  ),
                  SizedBox(height: 12),
                  ListTile(
                    title:
                    Text("Date: ${selectedDate.toLocal()}".split(' ')[0]),
                    leading: Icon(Icons.calendar_today, color: Colors.teal),
                    trailing: Icon(Icons.arrow_drop_down),
                    onTap: _pickDate,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    tileColor: Colors.teal.shade100,
                  ),
                  SizedBox(height: 12),
                  SwitchListTile(
                    title: Text('Income?',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    value: isIncome,
                    onChanged: (val) => setState(() => isIncome = val),
                    secondary: Icon(
                        isIncome ? Icons.trending_up : Icons.trending_down,
                        color: isIncome ? Colors.green : Colors.red),
                    tileColor: Colors.teal.shade100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: submitData,
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Add Transaction",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding:
                      EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}