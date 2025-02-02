import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart'; // Import intl package for number formatting
import 'user_data.dart';

class ReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('گزارش داده‌ها', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightGreen.shade800,
        elevation: 4, // Add shadow to the app bar
      ),
      body: FutureBuilder<List<UserData>>(
        future: _fetchDataFromHive(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.lightGreen.shade700, // Customize progress indicator color
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'خطا در بازیابی داده: ${snapshot.error}',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'داده‌ای برای نمایش وجود ندارد!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
              ),
            );
          }

          final List<UserData> data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              // Calculate جمع بدهکاری safely
              final rateAsInt = int.tryParse(item.rate) ?? 0; // Default to 0 if parsing fails
              final totalDebt = item.hours * rateAsInt;

              // Format values with commas
              final formattedRate = NumberFormat('#,###', 'fa_IR').format(rateAsInt); // Format مبلغ هر ساعت
              final formattedTotalDebt = NumberFormat('#,###', 'fa_IR').format(totalDebt); // Format جمع بدهکاری

              return Card(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Add margins for spacing
                color: Colors.transparent, // Transparent background
                elevation: 0, // No shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  side: BorderSide(color: Colors.grey.shade300, width: 1), // Light border
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Increased padding for better readability
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نوع درآمد: ${item.type}',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'تعداد ساعت: ${item.hours}',
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'مبلغ هر ساعت: $formattedRate تومان', // Display formatted مبلغ هر ساعت
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                              textAlign: TextAlign.right, // Align text to the right
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'نام صاحب کار: ${item.owner}',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'وضعیت پرداخت: ${item.paymentStatusText}',
                            style: TextStyle(
                              fontSize: 15,
                              color: item.paymentStatus == 1 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: item.paymentStatus == 1, // True if paid, False if unpaid
                            activeColor: Colors.green,
                            onChanged: (value) {
                              _updatePaymentStatus(index, value ? 1 : 0, context);
                            },
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 1,
                        color: Colors.grey.shade400,
                        height: 16,
                      ),
                      Text(
                        'جمع بدهکاری: $formattedTotalDebt تومان', // Display formatted جمع بدهکاری
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
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

  /// Fetch data from Hive
  Future<List<UserData>> _fetchDataFromHive() async {
    try {
      final box = Hive.box<UserData>('userDataBox');
      return box.values.toList();
    } catch (e) {
      throw e;
    }
  }

  /// Update payment status in Hive
  void _updatePaymentStatus(int index, int status, BuildContext context) async {
    try {
      final box = Hive.box<UserData>('userDataBox');
      final key = box.keyAt(index)!; // Get the key for the item at the given index
      final updatedItem = box.get(key)!;
      updatedItem.setPaymentStatus(status); // Update payment status
      box.put(key, updatedItem); // Save changes back to the database

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 1 ? 'پرداخت شده' : 'پرداخت نشده'),
          backgroundColor: status == 1 ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در به‌روزرسانی وضعیت پرداخت: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}