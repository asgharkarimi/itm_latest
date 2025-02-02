import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'strings.dart';
import 'user_data.dart';
import 'report_screen.dart';

class UserDataForm extends StatefulWidget {
  @override
  _UserDataFormState createState() => _UserDataFormState();
}

class _UserDataFormState extends State<UserDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _hoursController = TextEditingController();
  final _rateController = TextEditingController();
  final _ownerController = TextEditingController();

  final List<String> _incomeTypes = [
    Strings.incomeTypeHourly,
    Strings.incomeTypeHectare,
    Strings.incomeTypeTrailerService,
    Strings.incomeTypeFertilizerService,
  ];

  String? _selectedIncomeType = Strings.incomeTypeHourly; // Default value

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate() && _selectedIncomeType != null) {
      try {
        // Create a new UserData object with default payment status (0 = پرداخت نشده)
        final userData = UserData(
          type: _selectedIncomeType!,
          hours: int.tryParse(_hoursController.text) ?? 0,
          rate: _rateController.text,
          owner: _ownerController.text,
        );

        // Save to Hive
        final box = Hive.box<UserData>('userDataBox');
        box.add(userData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Strings.dataSavedSuccessfully),
            backgroundColor: Colors.green.shade600,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ذخیره داده: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Strings.pleaseFillAllFields),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _navigateToReportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.appTitle),
        backgroundColor: Colors.lightGreen.shade800,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      Strings.formTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreen.shade800,
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedIncomeType,
                      decoration: InputDecoration(
                        labelText: Strings.labelIncomeType,
                      ),
                      items: _incomeTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedIncomeType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Strings.errorSelectIncomeType;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _hoursController,
                      decoration: InputDecoration(
                        labelText: _selectedIncomeType == Strings.incomeTypeHectare
                            ? 'هکتار' // For "کشت هکتاری"
                            : _selectedIncomeType == Strings.incomeTypeTrailerService
                            ? 'سرویس تریلی' // For "سرویس تریلی"
                            : _selectedIncomeType == Strings.incomeTypeFertilizerService
                            ? 'کود' // For "کودپاش"
                            : Strings.labelHours, // Default label
                        hintText: _selectedIncomeType == Strings.incomeTypeHectare
                            ? 'مساحت کاشته شده براساس هکتار' // For "کشت هکتاری"
                            : _selectedIncomeType == Strings.incomeTypeTrailerService
                            ? 'تعداد سرویس تریلی' // For "سرویس تریلی"
                            : _selectedIncomeType == Strings.incomeTypeFertilizerService
                            ? 'تعداد کیسه کود' // For "کودپاش"
                            : '', // Default hint
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _selectedIncomeType == Strings.incomeTypeHectare
                              ? 'لطفاً مساحت را وارد کنید'
                              : _selectedIncomeType == Strings.incomeTypeTrailerService
                              ? 'لطفاً تعداد سرویس تریلی را وارد کنید'
                              : _selectedIncomeType == Strings.incomeTypeFertilizerService
                              ? 'لطفاً تعداد کیسه کود را وارد کنید'
                              : Strings.errorEnterHours;
                        }
                        final parsedValue = int.tryParse(value);
                        if (parsedValue == null || parsedValue < 0) {
                          return 'لطفاً عدد معتبر وارد کنید';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _rateController,
                      decoration: InputDecoration(
                        labelText: _selectedIncomeType == Strings.incomeTypeHectare
                            ? 'مبلغ هر هکتار' // For "کشت هکتاری"
                            : _selectedIncomeType == Strings.incomeTypeTrailerService
                            ? 'مبلغ هر تریلی' // For "سرویس تریلی"
                            : _selectedIncomeType == Strings.incomeTypeFertilizerService
                            ? 'مبلغ هر کیسه کود' // For "کودپاش"
                            : Strings.labelRate, // Default label
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _selectedIncomeType == Strings.incomeTypeHectare
                              ? 'لطفاً مبلغ هر هکتار را وارد کنید'
                              : _selectedIncomeType == Strings.incomeTypeTrailerService
                              ? 'لطفاً مبلغ هر تریلی را وارد کنید'
                              : _selectedIncomeType == Strings.incomeTypeFertilizerService
                              ? 'لطفاً مبلغ هر کیسه کود را وارد کنید'
                              : Strings.errorEnterRate;
                        }
                        final parsedValue = int.tryParse(value);
                        if (parsedValue == null || parsedValue < 0) {
                          return 'لطفاً عدد معتبر وارد کنید';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _ownerController,
                      decoration: InputDecoration(
                        labelText: Strings.labelOwner,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Strings.errorEnterOwner;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveData,
                  child: Text(
                    Strings.buttonSave,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50),
                    backgroundColor: Colors.lightGreen.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _navigateToReportScreen,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50),
                    backgroundColor: Colors.lightGreen.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'گزارش گیری',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}