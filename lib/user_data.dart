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
  final String status;

  UserData({
    required this.type,
    required this.hours,
    required this.rate,
    required this.owner,
    required this.status,
  });
}