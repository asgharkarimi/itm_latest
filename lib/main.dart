import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'user_data.dart';
import 'user_form.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();
  // Register adapter for UserData
  Hive.registerAdapter(UserDataAdapter());
  // Open box
  await Hive.openBox<UserData>('userDataBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter RTL Persian App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        // Changed to light green
        fontFamily: 'Vazir',
        // فونت فارسی (اختیاری)
        scaffoldBackgroundColor: Colors.grey[50],
        // پس‌زمینه خاکستری ملایم
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            backgroundColor: Colors.lightGreen.shade600,
            // Changed to light green
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: Colors.lightGreen.withOpacity(0.2),
            // Changed to light green
            elevation: 3,
          ),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fa', 'IR'), // فارسی برای ایران
      ],
      locale: const Locale('fa', 'IR'),
      // زبان پیش‌فرض فارسی
      home: UserDataForm(),
    );
  }
}

// git init
// git add README.md
// git commit -m "first commit"
// git branch -M main
// git remote add origin https://github.com/asgharkarimi/itm_latest.git
// git push -u origin main
