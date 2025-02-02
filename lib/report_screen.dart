import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'user_data.dart';

class ReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('گزارش داده‌ها'),
        backgroundColor: Colors.lightGreen.shade800,
      ),
      body: FutureBuilder<List<UserData>>(
        future: _fetchDataFromHive(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('خطا در بازیابی داده: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('داده‌ای برای نمایش وجود ندارد!'));
          }

          final List<UserData> data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              // Calculate جمع بدهکاری safely
              final rateAsInt = int.tryParse(item.rate) ?? 0; // Default to 0 if parsing fails
              final totalDebt = item.hours * rateAsInt;

              return Card(
               color: null,
                margin: EdgeInsets.all(4),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('نوع درآمد: ${item.type}', style: TextStyle(fontSize: 16)),
                      Text('تعداد ساعت: ${item.hours}', style: TextStyle(fontSize: 16)),
                      Text('مبلغ هر ساعت: ${item.rate}', style: TextStyle(fontSize: 16)),
                      Text('نام صاحب کار: ${item.owner}', style: TextStyle(fontSize: 16)),
                      Text('وضعیت پرداخت: ${item.paymentStatusText}', style: TextStyle(fontSize: 16)),
                      Text(
                        'جمع بدهکاری: $totalDebt تومان',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                      ), // Display جمع بدهکاری
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<UserData>> _fetchDataFromHive() async {
    try {
      final box = Hive.box<UserData>('userDataBox');
      return box.values.toList();
    } catch (e) {
      throw e;
    }
  }
}