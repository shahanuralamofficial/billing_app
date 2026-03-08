import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_management/core/data/hive_database.dart';
import '../../domain/entities/due_record.dart';
import '../../data/models/due_record_model.dart';

class DueListPage extends StatefulWidget {
  const DueListPage({super.key});

  @override
  State<DueListPage> createState() => _DueListPageState();
}

class _DueListPageState extends State<DueListPage> {
  List<DueRecord> dues = [];

  @override
  void initState() {
    super.initState();
    _loadDues();
  }

  void _loadDues() {
    setState(() {
      dues = HiveDatabase.dueBox.values.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalDue = dues.where((d) => !d.isPaid).fold<double>(0, (sum, d) => sum + d.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bakir Khata (Due Ledger)', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.redAccent, Colors.orangeAccent]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Total Outstanding Due', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text('৳${totalDue.toStringAsFixed(2)}', 
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: dues.isEmpty
                ? const Center(child: Text('No due records found.'))
                : ListView.builder(
                    itemCount: dues.length,
                    itemBuilder: (context, index) {
                      final due = dues[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: due.isPaid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            child: Icon(due.isPaid ? Icons.check : Icons.person, 
                              color: due.isPaid ? Colors.green : Colors.red),
                          ),
                          title: Text(due.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${due.phoneNumber}\n${DateFormat('dd MMM yyyy').format(due.date)}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('৳${due.amount}', 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  color: due.isPaid ? Colors.green : Colors.red,
                                  fontSize: 16
                                )),
                              if (!due.isPaid)
                                const Text('Unpaid', style: TextStyle(color: Colors.red, fontSize: 10)),
                            ],
                          ),
                          onLongPress: () => _togglePaid(due),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDueDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _togglePaid(DueRecord due) async {
    final model = DueRecordModel(
      id: due.id,
      customerName: due.customerName,
      phoneNumber: due.phoneNumber,
      amount: due.amount,
      date: due.date,
      isPaid: !due.isPaid,
    );
    await HiveDatabase.dueBox.put(due.id, model);
    _loadDues();
  }

  void _showAddDueDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Due'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Customer Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Due Amount'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                final due = DueRecordModel(
                  id: id,
                  customerName: nameController.text,
                  phoneNumber: phoneController.text,
                  amount: double.tryParse(amountController.text) ?? 0,
                  date: DateTime.now(),
                );
                await HiveDatabase.dueBox.put(id, due);
                _loadDues();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
