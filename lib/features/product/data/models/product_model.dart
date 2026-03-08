import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart'; // Hive generator

@HiveType(typeId: 0)
class ProductModel extends Product {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String barcode;
  @override
  @HiveField(3)
  final double price;
  @override
  @HiveField(4)
  final int stock;
  @override
  @HiveField(5)
  final DateTime? expiryDate;
  @override
  @HiveField(6)
  final int damagedStock;
  @override
  @HiveField(7)
  final double buyingPrice;

  const ProductModel({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stock,
    this.buyingPrice = 0.0,
    this.expiryDate,
    this.damagedStock = 0,
  }) : super(
          id: id,
          name: name,
          barcode: barcode,
          price: price,
          buyingPrice: buyingPrice,
          stock: stock,
          expiryDate: expiryDate,
          damagedStock: damagedStock,
        );

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      barcode: product.barcode,
      price: product.price,
      buyingPrice: product.buyingPrice,
      stock: product.stock,
      expiryDate: product.expiryDate,
      damagedStock: product.damagedStock,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      buyingPrice: buyingPrice,
      stock: stock,
      expiryDate: expiryDate,
      damagedStock: damagedStock,
    );
  }
}
