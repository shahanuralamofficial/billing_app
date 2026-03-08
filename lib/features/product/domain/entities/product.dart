import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String barcode;
  final double price; // Selling Price
  final double buyingPrice;
  final int stock;
  final DateTime? expiryDate;
  final int damagedStock;

  const Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    this.buyingPrice = 0.0,
    this.stock = 0,
    this.expiryDate,
    this.damagedStock = 0,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        barcode,
        price,
        buyingPrice,
        stock,
        expiryDate,
        damagedStock,
      ];
}
