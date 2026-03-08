import 'package:equatable/equatable.dart';

class DueRecord extends Equatable {
  final String id;
  final String customerName;
  final String phoneNumber;
  final double amount;
  final DateTime date;
  final String? note;
  final bool isPaid;

  const DueRecord({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.amount,
    required this.date,
    this.note,
    this.isPaid = false,
  });

  @override
  List<Object?> get props => [id, customerName, phoneNumber, amount, date, note, isPaid];
}
