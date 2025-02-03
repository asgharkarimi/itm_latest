import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static late Box<dynamic> _userDataBox;

  // Private constructor to prevent instantiation
  HiveService._();

  // Static method to initialize the service
  static Future<void> init() async {
    await Hive.initFlutter(); // Initialize Hive
    _userDataBox = await Hive.openBox('userDataBox'); // Open the box
  }

  // Method to get the box instance
  static Box<dynamic> getUserDataBox() {
    return _userDataBox;
  }
}