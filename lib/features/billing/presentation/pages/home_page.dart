import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../product/presentation/bloc/product_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Management',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCards(context),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildQuickActions(context),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Product Inventory',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildProductList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scanner'),
        label: const Text('New Sale'),
        icon: const Icon(Icons.qr_code_scanner),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Shop Management',
                style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text('Shop Management System'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.store, color: AppTheme.primaryColor, size: 40),
            ),
            decoration: BoxDecoration(color: AppTheme.primaryColor),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.point_of_sale_outlined),
            title: const Text('Billing / New Sale'),
            onTap: () {
              Navigator.pop(context);
              context.push('/scanner');
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Add Product'),
            onTap: () {
              Navigator.pop(context);
              context.push('/products/add');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text('Product List'),
            onTap: () {
              Navigator.pop(context);
              context.push('/products');
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Due Ledger (Bakir Khata)'),
            onTap: () {
              Navigator.pop(context);
              context.push('/dues');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.store_outlined),
            title: const Text('Shop Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push('/shop');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('App Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final totalProducts = state.products.length;
        final lowStockCount = state.products.where((p) => p.stock <= 5).length;
        final totalValue = state.products.fold<double>(0, (sum, p) => sum + (p.price * p.stock));

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _statCard(
                'Total Items',
                totalProducts.toString(),
                Icons.inventory_2,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _statCard(
                'Low Stock',
                lowStockCount.toString(),
                Icons.warning_amber_rounded,
                Colors.orange,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(title,
                style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _quickActionItem(context, 'New Sale', Icons.add_shopping_cart, Colors.green, () => context.push('/scanner')),
          _quickActionItem(context, 'Add Item', Icons.post_add, Colors.blue, () => context.push('/products/add')),
          _quickActionItem(context, 'Inventory', Icons.list_alt, Colors.purple, () => context.push('/products')),
          _quickActionItem(context, 'Reports', Icons.bar_chart, Colors.orange, () {}),
        ],
      ),
    );
  }

  Widget _quickActionItem(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state.products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No products available. Add some!'),
            ),
          );
        }

        final recentProducts = state.products.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: recentProducts.length,
          itemBuilder: (context, index) {
            final product = recentProducts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ListTile(
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Stock: ${product.stock} | ৳${product.price}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/products/edit/${product.id}', extra: product),
              ),
            );
          },
        );
      },
    );
  }
}
