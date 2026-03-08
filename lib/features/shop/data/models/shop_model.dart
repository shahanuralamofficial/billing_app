import 'package:hive/hive.dart';
import '../../domain/entities/shop.dart';

part 'shop_model.g.dart';

@HiveType(typeId: 1)
class ShopModel extends Shop {
  @override
  @HiveField(0)
  final String name;
  @override
  @HiveField(1)
  final String addressLine1;
  @override
  @HiveField(2)
  final String addressLine2;
  @override
  @HiveField(3)
  final String phoneNumber;
  @override
  @HiveField(4)
  final String paymentNumber;
  @override
  @HiveField(6)
  final String paymentMethod;
  @override
  @HiveField(5)
  final String footerText;

  const ShopModel({
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.phoneNumber,
    required this.paymentNumber,
    required this.paymentMethod,
    required this.footerText,
  }) : super(
          name: name,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          phoneNumber: phoneNumber,
          paymentNumber: paymentNumber,
          paymentMethod: paymentMethod,
          footerText: footerText,
        );

  factory ShopModel.fromEntity(Shop shop) {
    return ShopModel(
      name: shop.name,
      addressLine1: shop.addressLine1,
      addressLine2: shop.addressLine2,
      phoneNumber: shop.phoneNumber,
      paymentNumber: shop.paymentNumber,
      paymentMethod: shop.paymentMethod,
      footerText: shop.footerText,
    );
  }

  Shop toEntity() => this;
}
