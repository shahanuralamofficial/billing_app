import 'package:equatable/equatable.dart';
import 'cart_item.dart';

class Sale extends Equatable {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime dateTime;

  const Sale({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.dateTime,
  });

  @override
  List<Object?> get props => [id, items, totalAmount, dateTime];
}
