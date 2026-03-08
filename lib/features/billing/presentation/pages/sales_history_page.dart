import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/data/hive_database.dart';
import '../../data/models/sale_model.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  List<SaleModel> sales = [];

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  void _loadSales() {
    final loadedSales = HiveDatabase.saleBox.values.toList();
    // Sort by date descending
    loadedSales.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    setState(() {
      sales = loadedSales;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalSalesAmount = sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Total Lifetime Sales', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text('৳${totalSalesAmount.toStringAsFixed(2)}', 
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: sales.isEmpty
                ? const Center(child: Text('No sales found.'))
                : ListView.builder(
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ExpansionTile(
                          leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
                          title: Text('৳${sale.totalAmount.toStringAsFixed(2)}', 
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(sale.dateTime)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const Divider(),
                                  ...sale.itemModels.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${item.quantity} x ${item.product.name}'),
                                        Text('৳${(item.quantity * item.product.price).toStringAsFixed(2)}'),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
