import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'report_screen.dart';
import 'strings.dart';
import 'user_data.dart';

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

  Future _saveData() async {
    if (_formKey.currentState!.validate() && _selectedIncomeType != null) {
      try {
        // Remove commas from the rate input before saving
        final hours = int.tryParse(_hoursController.text) ?? 0;
        final rate = _rateController.text.replaceAll(',', ''); // Remove commas
        final parsedRate = int.tryParse(rate) ?? 0;

        // Create a new UserData object with default payment status (0 = پرداخت نشده)
        final userData = UserData(
          type: _selectedIncomeType!,
          hours: hours,
          rate: parsedRate.toString(), // Save the unformatted rate
          owner: _ownerController.text,
        );

        // Save to Hive
        final box = Hive.box('userDataBox');
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
        title: Center(child: Text('فرم ورود اطلاعات')),
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
                        labelText:
                            _selectedIncomeType == Strings.incomeTypeHectare
                                ? 'هکتار' // For "کشت هکتاری"
                                : _selectedIncomeType ==
                                        Strings.incomeTypeTrailerService
                                    ? 'سرویس تریلی' // For "سرویس تریلی"
                                    : _selectedIncomeType ==
                                            Strings.incomeTypeFertilizerService
                                        ? 'کود' // For "کودپاش"
                                        : Strings.labelHours, // Default label
                        hintText: _selectedIncomeType ==
                                Strings.incomeTypeHectare
                            ? 'مساحت کاشته شده براساس هکتار' // For "کشت هکتاری"
                            : _selectedIncomeType ==
                                    Strings.incomeTypeTrailerService
                                ? 'تعداد سرویس تریلی' // For "سرویس تریلی"
                                : _selectedIncomeType ==
                                        Strings.incomeTypeFertilizerService
                                    ? 'تعداد کیسه کود' // For "کودپاش"
                                    : '', // Default hint
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _selectedIncomeType ==
                                  Strings.incomeTypeHectare
                              ? 'لطفاً مساحت را وارد کنید'
                              : _selectedIncomeType ==
                                      Strings.incomeTypeTrailerService
                                  ? 'لطفاً تعداد سرویس تریلی را وارد کنید'
                                  : _selectedIncomeType ==
                                          Strings.incomeTypeFertilizerService
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
                        labelText:
                            _selectedIncomeType == Strings.incomeTypeHectare
                                ? 'مبلغ هر هکتار' // For "کشت هکتاری"
                                : _selectedIncomeType ==
                                        Strings.incomeTypeTrailerService
                                    ? 'مبلغ هر تریلی' // For "سرویس تریلی"
                                    : _selectedIncomeType ==
                                            Strings.incomeTypeFertilizerService
                                        ? 'مبلغ هر کیسه کود' // For "کودپاش"
                                        : Strings.labelRate, // Default label
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        // Allow only digits
                        ThousandsSeparatorInputFormatter(),
                        // Add thousands separator
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _selectedIncomeType ==
                                  Strings.incomeTypeHectare
                              ? 'لطفاً مبلغ هر هکتار را وارد کنید'
                              : _selectedIncomeType ==
                                      Strings.incomeTypeTrailerService
                                  ? 'لطفاً مبلغ هر تریلی را وارد کنید'
                                  : _selectedIncomeType ==
                                          Strings.incomeTypeFertilizerService
                                      ? 'لطفاً مبلغ هر کیسه کود را وارد کنید'
                                      : Strings.errorEnterRate;
                        }
                        final parsedValue = int.tryParse(value.replaceAll(
                            ',', '')); // Remove commas for parsing
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

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final formattedText = _formatAsYouType(text);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _formatAsYouType(String value) {
    if (value.isEmpty) return value;

    final removeCommas = value.replaceAll(',', '');
    final parsedNumber = int.tryParse(removeCommas);

    if (parsedNumber == null) return value;

    return NumberFormat('#,###').format(parsedNumber);
  }
}
