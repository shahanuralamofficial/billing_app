import 'package:hive_flutter/hive_flutter.dart';
import '../../features/product/data/models/product_model.dart';
import '../../features/shop/data/models/shop_model.dart';
import '../../features/billing/data/models/sale_model.dart';
import '../../features/due/data/models/due_record_model.dart';

class HiveDatabase {
  static const String productBoxName = 'products';
  static const String shopBoxName = 'shop';
  static const String saleBoxName = 'sales';
  static const String dueBoxName = 'dues';
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProductModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ShopModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SaleModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(CartItemModelAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(DueRecordModelAdapter());

    // Open Boxes
    await Hive.openBox<ProductModel>(productBoxName);
    await Hive.openBox<ShopModel>(shopBoxName);
    await Hive.openBox<SaleModel>(saleBoxName);
    await Hive.openBox<DueRecordModel>(dueBoxName);
    await Hive.openBox(settingsBoxName);
  }

  static Box<ProductModel> get productBox => Hive.box<ProductModel>(productBoxName);
  static Box<ShopModel> get shopBox => Hive.box<ShopModel>(shopBoxName);
  static Box<SaleModel> get saleBox => Hive.box<SaleModel>(saleBoxName);
  static Box<DueRecordModel> get dueBox => Hive.box<DueRecordModel>(dueBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
}
