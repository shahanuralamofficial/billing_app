import 'package:hive/hive.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/cart_item.dart';
import '../../../product/data/models/product_model.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 2)
class SaleModel extends Sale {
  @override
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final List<CartItemModel> itemModels;
  
  @override
  @HiveField(2)
  final double totalAmount;
  
  @override
  @HiveField(3)
  final DateTime dateTime;

  SaleModel({
    required this.id,
    required this.itemModels,
    required this.totalAmount,
    required this.dateTime,
  }) : super(
          id: id,
          items: itemModels.map((m) => m.toEntity()).toList(),
          totalAmount: totalAmount,
          dateTime: dateTime,
        );

  factory SaleModel.fromEntity(Sale sale) {
    return SaleModel(
      id: sale.id,
      itemModels: sale.items.map((i) => CartItemModel.fromEntity(i)).toList(),
      totalAmount: sale.totalAmount,
      dateTime: sale.dateTime,
    );
  }
}

@HiveType(typeId: 3)
class CartItemModel {
  @HiveField(0)
  final ProductModel product;
  @HiveField(1)
  final int quantity;

  CartItemModel({required this.product, required this.quantity});

  factory CartItemModel.fromEntity(CartItem item) {
    return CartItemModel(
      product: ProductModel.fromEntity(item.product),
      quantity: item.quantity,
    );
  }

  CartItem toEntity() {
    return CartItem(
      product: product.toEntity(),
      quantity: quantity,
    );
  }
}
