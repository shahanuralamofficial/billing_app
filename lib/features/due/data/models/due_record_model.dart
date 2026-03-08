import 'package:hive/hive.dart';
import '../../domain/entities/due_record.dart';

part 'due_record_model.g.dart';

@HiveType(typeId: 4)
class DueRecordModel extends DueRecord {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String customerName;
  @override
  @HiveField(2)
  final String phoneNumber;
  @override
  @HiveField(3)
  final double amount;
  @override
  @HiveField(4)
  final DateTime date;
  @override
  @HiveField(5)
  final String? note;
  @override
  @HiveField(6)
  final bool isPaid;

  const DueRecordModel({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.amount,
    required this.date,
    this.note,
    this.isPaid = false,
  }) : super(
          id: id,
          customerName: customerName,
          phoneNumber: phoneNumber,
          amount: amount,
          date: date,
          note: note,
          isPaid: isPaid,
        );

  factory DueRecordModel.fromEntity(DueRecord entity) {
    return DueRecordModel(
      id: entity.id,
      customerName: entity.customerName,
      phoneNumber: entity.phoneNumber,
      amount: entity.amount,
      date: entity.date,
      note: entity.note,
      isPaid: entity.isPaid,
    );
  }

  DueRecord toEntity() {
    return DueRecord(
      id: id,
      customerName: customerName,
      phoneNumber: phoneNumber,
      amount: amount,
      date: date,
      note: note,
      isPaid: isPaid,
    );
  }
}
