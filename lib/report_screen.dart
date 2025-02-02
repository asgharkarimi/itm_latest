import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart'; // Import intl package for number formatting

import 'user_data.dart';

class ReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('گزارش داده‌ها', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.lightGreen.shade800,
          elevation: 4,
          bottom: TabBar(
            tabs: [
              Tab(text: 'لیست کارها'),
              Tab(text: 'نمودار درامدی'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // First tab: لیست کارها
            FutureBuilder<List<UserData>>(
              future: _fetchDataFromHive(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.lightGreen.shade700,
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
                    final rateAsInt = int.tryParse(item.rate) ?? 0;
                    final totalDebt = item.hours * rateAsInt;
                    final formattedRate = NumberFormat('#,###', 'fa_IR').format(rateAsInt);
                    final formattedTotalDebt = NumberFormat('#,###', 'fa_IR').format(totalDebt);

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      color: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
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
                                    'مبلغ هر ساعت: $formattedRate تومان',
                                    style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                                    textAlign: TextAlign.right,
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
                                  value: item.paymentStatus == 1,
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
                              'جمع بدهکاری: $formattedTotalDebt تومان',
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

            // Second tab: نمودار درامدی
            FutureBuilder<List<UserData>>(
              future: _fetchDataFromHive(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.lightGreen.shade700,
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
                final double receivedIncome = data
                    .where((item) => item.paymentStatus == 1)
                    .map((item) => (int.tryParse(item.rate) ?? 0) * item.hours)
                    .reduce((a, b) => a + b)
                    .toDouble();
                final double unreceivedIncome = data
                    .where((item) => item.paymentStatus == 0)
                    .map((item) => (int.tryParse(item.rate) ?? 0) * item.hours)
                    .reduce((a, b) => a + b)
                    .toDouble();
                final totalIncome = receivedIncome + unreceivedIncome;

                // Filter unpaid users for the list view
                final List<UserData> unpaidUsers = data.where((item) => item.paymentStatus == 0).toList();

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Title for the chart section
                      Text(
                        'نسبت درامد وصول شده به درامد وصول نشده',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 14),

                      // Pie Chart
                      SizedBox(
                        height: 200, // Set a fixed height for the chart
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: receivedIncome,
                                color: Colors.green.shade400,
                                title: '${(receivedIncome / totalIncome * 100).toStringAsFixed(1)}%',
                                titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                value: unreceivedIncome,
                                color: Colors.orange.shade400,
                                title: '${(unreceivedIncome / totalIncome * 100).toStringAsFixed(1)}%',
                                titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                            centerSpaceRadius: 40, // Add space in the center of the pie chart
                            startDegreeOffset: -90, // Start from the top
                          ),
                        ),
                      ),

                      // Legend for the pie chart
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegend('درامد وصول شده', Colors.green.shade400),
                          _buildLegend('درامد وصول نشده', Colors.orange.shade400),
                        ],
                      ),

                      // Title for the list section
                      SizedBox(height: 16),
                      Divider(),
                      Text(
                        'لیست افراد بدهکار',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),

                      // List of unpaid users
                      Expanded(
                        child: ListView.builder(
                          itemCount: unpaidUsers.length,
                          itemBuilder: (context, index) {
                            final item = unpaidUsers[index];
                            final rateAsInt = int.tryParse(item.rate) ?? 0;
                            final totalDebt = item.hours * rateAsInt;
                            final formattedTotalDebt = NumberFormat('#,###', 'fa_IR').format(totalDebt);

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.shade100,
                                child: Text(
                                  (index + 1).toString(), // Display serial number
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                'نام: ${item.owner}',
                                style: TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                              subtitle: Text(
                                'مبلغ بدهی: $formattedTotalDebt تومان',
                                style: TextStyle(fontSize: 14, color: Colors.red.shade700),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build a legend for the pie chart
  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
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
      final key = box.keyAt(index)!;
      final updatedItem = box.get(key)!;
      updatedItem.setPaymentStatus(status);
      box.put(key, updatedItem);
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