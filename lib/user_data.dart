import 'package:hive/hive.dart';

part 'user_data.g.dart'; // This will be generated

@HiveType(typeId: 0)
class UserData {
  @HiveField(0)
  final String type;

  @HiveField(1)
  final int hours;

  @HiveField(2)
  final String rate;

  @HiveField(3)
  final String owner;

  @HiveField(4)
  int paymentStatus; // Payment status (0 = unpaid, 1 = paid)

  UserData({
    required this.type,
    required this.hours,
    required this.rate,
    required this.owner,
    this.paymentStatus = 0, // Default: 0 (پرداخت نشده)
  });

  String get paymentStatusText {
    return paymentStatus == 1 ? 'پرداخت شده' : 'پرداخت نشده';
  }

  void setPaymentStatus(int status) {
    paymentStatus = status;
  }
}