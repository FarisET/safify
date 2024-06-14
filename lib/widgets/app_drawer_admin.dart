// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:safify/User%20Module/services/pdf_download_service.dart';
import 'package:safify/utils/date_utils.dart';

class AppDrawer extends StatelessWidget {
  final String? username;
  final double mainHeaderSize = 18;

  AppDrawer({required this.username});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 0.15,
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    Icons.person,
                    size: 24,
                    color: Theme.of(context).cardColor,
                  ),
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                ),
                SizedBox(width: 16),
                Text(
                  username!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.person_add,
                      color: Theme.of(context).secondaryHeaderColor),
                  title: Text(
                    'Add User',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: mainHeaderSize,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                  onTap: () {
                    // Navigate to Add User page
                    Navigator.pushNamed(context, '/create_user_form');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.location_on,
                      color: Theme.of(context).secondaryHeaderColor),
                  title: Text(
                    'Add Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: mainHeaderSize,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                  subtitle: Text("Coming soon"),
                  onTap: () {
                    // Navigate to Add Location page
                    //    Navigator.pushNamed(context, '/addLocation');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.category,
                      color: Theme.of(context).secondaryHeaderColor),
                  title: Text(
                    'Add Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: mainHeaderSize,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                  subtitle: Text("Coming soon"),
                  onTap: () {
                    // Navigate to Add Category page
                    //  Navigator.pushNamed(context, '/addCategory');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.download,
                      color: Theme.of(context).secondaryHeaderColor),
                  title: Text(
                    'Download PDF',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: mainHeaderSize,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                  onTap: () async {
                    // Navigate to Add Category page
                    //  Navigator.pushNamed(context, '/addCategory');
                    final pdfService = PDFDownloadService();
                    // await pdfService.downloadPDF(
                    //     'https://api.arya.ai/images/test.pdf', "dummy.pdf");
                    // // await Future.delayed(Duration(seconds: 1));
                    // print("Download PDF");
                    // await pdfService.getPdf(null, null, null);
                    // Navigator.of(context).pop();
                    await _showDateInputDialog(context, pdfService);
                  },
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings,
                color: Theme.of(context).secondaryHeaderColor),
            title: Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: mainHeaderSize,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            subtitle: Text("Coming soon"),
            onTap: () {
              // Navigate to Settings page
              //  Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDateInputDialog(
      BuildContext context, PDFDownloadService pdfDownloadService) async {
    final _formKey = GlobalKey<FormState>();
    String day = '';
    String month = '';
    String year = '';

    return showDialog<void>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Download Report',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Note: Please specify time period for the report. You can specify a day, month, or year. Press 'Get all' to get all reports so far.",
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                ),
                Form(
                  key: _formKey,
                  child: ListBody(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Year (yyyy)',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => year = value,
                        validator: (value) {
                          if (double.tryParse(value!) == null) {
                            return 'Please enter a valid year';
                          }
                          if (value!.isEmpty) {
                            return 'Please enter a year';
                          }
                          if (value.length != 4) {
                            return 'Please enter a valid year';
                          }
                          if (int.parse(value) > DateTime.now().year.toInt()) {
                            return 'Please enter a valid year';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Month (mm)',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => month = value,
                        validator: (value) {
                          if (double.tryParse(value!) == null) {
                            return 'Please enter a valid year';
                          }
                          if (month.isNotEmpty &&
                              (int.parse(month) < 1 || int.parse(month) > 12)) {
                            return 'Please enter a number between 1 and 12';
                          }
                          if (day.isNotEmpty && month.isEmpty) {
                            return 'Please enter a month';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Day (dd)',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => day = value,
                        validator: (value) {
                          if (double.tryParse(value!) == null) {
                            return 'Please enter a valid year';
                          }
                          if (day.isNotEmpty &&
                              (int.parse(day) < 1 || int.parse(day) > 31)) {
                            return 'Please enter a number between 1 and 31';
                          }
                          if (!isValidDate(int.tryParse(day),
                              int.tryParse(month), int.tryParse(year))) {
                            return 'Please enter a valid date';
                          }
                          ;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Download'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.of(context).pop();
                  pdfDownloadService.getPdf(day, month, year);
                }
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.blue),
              ),
              child: Text(
                'Get all',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => pdfDownloadService.getPdf(null, null, null),
            ),
          ],
        );
      },
    );
  }
}
