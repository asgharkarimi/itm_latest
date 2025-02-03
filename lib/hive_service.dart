import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'user_data.dart';

class HiveService {
  static late Box<UserData> _userDataBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserDataAdapter());
    try {
      _userDataBox = await Hive.openBox<UserData>('userDataBox');
    } catch (e) {
      print("Hive box opening failed: $e");
      await Hive.deleteBoxFromDisk('userDataBox'); // Delete corrupted box
      _userDataBox = await Hive.openBox<UserData>('userDataBox');
    }
  }

  static Box<UserData> getUserDataBox() => _userDataBox;
}
