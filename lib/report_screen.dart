import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for number formatting

import 'hive_service.dart'; // Import the HiveService class

class ReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: Text('گزارش‌ها'),
                floating: true,
                // AppBar appears when scrolling up
                snap: true,
                // AppBar snaps into view when scrolling up
                pinned: true,
                // AppBar stays pinned at the top
                bottom: TabBar(
                  labelColor: Colors.white,
                  tabs: [
                    Tab(text: 'لیست کارها'),
                    Tab(text: 'نمودار درآمدها'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              // First tab: لیست کارها
              FutureBuilder(
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  }

                  final List data = snapshot.data!;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      final rateAsInt = int.tryParse(item.rate) ?? 0;
                      final totalDebt = item.hours * rateAsInt;
                      final formattedRate =
                          NumberFormat('#,###', 'fa_IR').format(rateAsInt);
                      final formattedTotalDebt =
                          NumberFormat('#,###', 'fa_IR').format(totalDebt);

                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        color: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'نوع درآمد: ${item.type}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'تعداد ساعت: ${item.hours}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'مبلغ هر ساعت: $formattedRate تومان',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade800,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'نام صاحب کار: ${item.owner}',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black87),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'وضعیت پرداخت: ${item.paymentStatusText}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: item.paymentStatus == 1
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Switch(
                                    value: item.paymentStatus == 1,
                                    activeColor: Colors.green,
                                    onChanged: (value) {
                                      _updatePaymentStatus(
                                          index, value ? 1 : 0, context);
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
                                'جمع مطالبات: $formattedTotalDebt تومان',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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

              // Second tab: نمودار درآمدها
              // Second tab: نمودار درآمدها
              FutureBuilder(
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  final List data = snapshot.data!;
                  final double receivedIncome = data
                      .where((item) => item.paymentStatus == 1)
                      .map(
                          (item) => (int.tryParse(item.rate) ?? 0) * item.hours)
                      .reduce((a, b) => a + b)
                      .toDouble();
                  final double unreceivedIncome = data
                      .where((item) => item.paymentStatus == 0)
                      .map(
                          (item) => (int.tryParse(item.rate) ?? 0) * item.hours)
                      .reduce((a, b) => a + b)
                      .toDouble();
                  final totalIncome = receivedIncome + unreceivedIncome;

                  // Format the incomes for display
                  final formattedReceivedIncome =
                      NumberFormat('#,###', 'fa_IR').format(receivedIncome);
                  final formattedUnreceivedIncome =
                      NumberFormat('#,###', 'fa_IR').format(unreceivedIncome);

                  // Filter unpaid users for the list view
                  final List unpaidUsers =
                      data.where((item) => item.paymentStatus == 0).toList();

                  return CustomScrollView(
                    slivers: [
                      // SliverAppBar for the chart (parallax effect)
                      SliverAppBar(
                        expandedHeight: 300, // Height of the chart section
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            color: Colors.grey.shade100, // Background color
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    'نسبت درامد وصول شده به درامد وصول نشده',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 18),
                                // Pie Chart
                                Container(
                                  child: SizedBox(
                                    height: 160,
                                    // Set a fixed height for the chart
                                    child: PieChart(
                                      PieChartData(
                                        sections: [
                                          PieChartSectionData(
                                            value: receivedIncome,
                                            color: Colors.green.shade400,
                                            title:
                                                '${(receivedIncome / totalIncome * 100).toStringAsFixed(1)}%',
                                            titleStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          PieChartSectionData(
                                            value: unreceivedIncome,
                                            color: Colors.orange.shade400,
                                            title:
                                                '${(unreceivedIncome / totalIncome * 100).toStringAsFixed(1)}%',
                                            titleStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                        centerSpaceRadius: 40,
                                        startDegreeOffset: -90,
                                      ),
                                    ),
                                  ),
                                ),
                                // Display calculated incomes
                                SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'درامد وصول شده: $formattedReceivedIncome تومان',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'درامد وصول نشده: $formattedUnreceivedIncome تومان',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Add a title for the list of unpaid users
                      if (unpaidUsers.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  'لیست افراد بدهکار', // Add this title
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                                // Optional: Add a divider below the title
                              ],
                            ),
                          ),
                        ),

                      // SliverList for the unpaid users list
                      if (unpaidUsers.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = unpaidUsers[index];
                              final rateAsInt = int.tryParse(item.rate) ?? 0;
                              final totalDebt = item.hours * rateAsInt;
                              final formattedTotalDebt =
                                  NumberFormat('#,###', 'fa_IR')
                                      .format(totalDebt);

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange.shade100,
                                  child: Text(
                                    (index + 1).toString(),
                                    // Display serial number
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  'نام: ${item.owner}', // User's name
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                                subtitle: Text(
                                  'مبلغ بدهی: $formattedTotalDebt تومان',
                                  // Debt amount
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.red.shade700),
                                ),
                              );
                            },
                            childCount: unpaidUsers.length,
                          ),
                        )
                      else
                        // If no unpaid users exist, show a message
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'هیچ کاربر بدهکاری وجود ندارد.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
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
  Future<List<dynamic>> _fetchDataFromHive() async {
    try {
      final box = HiveService.getUserDataBox(); // Use the singleton pattern
      return box.values.toList();
    } catch (e) {
      throw e;
    }
  }

  /// Update payment status in Hive
  void _updatePaymentStatus(int index, int status, BuildContext context) async {
    try {
      final box = HiveService.getUserDataBox(); // Use the singleton pattern
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
