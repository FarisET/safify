// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:provider/provider.dart';
import 'package:safify/Admin%20Module/providers/announcement_provider.dart';
import 'package:safify/models/announcement_notif.dart';
import 'package:safify/services/pdf_download_service.dart';
import 'package:safify/utils/date_utils.dart';
import 'package:safify/widgets/pdf_download_dialog.dart';

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
                    'Download Report',
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
                ListTile(
                  leading: Icon(Icons.announcement,
                      color: Theme.of(context).secondaryHeaderColor),
                  title: Text(
                    'Announcement',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: mainHeaderSize,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                  onTap: () {
                    _showAnnouncementDialog(context);
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
    return showDialog<void>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return PDFdownloadDialog(pdfDownloadService: pdfDownloadService);
      },
    );
  }

  void _showAnnouncementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String body = '';

        return AlertDialog(
          title: Text('Create Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Alert Title'),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Alert Body'),
                onChanged: (value) {
                  body = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Send'),
              onPressed: () {
                // Perform action to send the announcement
                _sendAnnouncement(context, title, body);
              },
            ),
          ],
        );
      },
    );
  }

  void _sendAnnouncement(BuildContext context, String title, String body) {
    final announcementProvider =
        Provider.of<AnnouncementProvider>(context, listen: false);

    // Create an Announcement object
    Announcement announcement = Announcement(
      messageTitle: title,
      messageBody: body,
    );

    // Call the provider method to send the announcement
    announcementProvider.sendAlert(announcement).then((_) {
      // Handle success, e.g., show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.blue,
          content: Text('Announcement sent successfully'),
        ),
      );
    }).catchError((error) {
      // Handle error, e.g., show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to send announcement'),
        ),
      );
    });
  }
}
