// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';

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
                  onTap: () {
                    // Navigate to Add Category page
                    //  Navigator.pushNamed(context, '/addCategory');
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
            onTap: () {
              // Navigate to Settings page
              //  Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}
