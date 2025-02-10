import 'package:flutter/material.dart';
import 'package:safify/User%20Module/pages/user_form.dart';

class UserActionsModalSheet extends StatelessWidget {
  const UserActionsModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(shrinkWrap: true, children: [
      //black divider
      Container(
        height: 4,
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.sizeOf(context).height * .015,
            horizontal: MediaQuery.sizeOf(context).width * .4),
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(8)),
      ),
      IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close)),

      //report incident
      _OptionItem(
          icon: Icon(Icons.copy_all_rounded, color: Colors.blue[600], size: 26),
          name: 'Report Incident',
          description: 'Capture an incident, hazard or a feedback',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserForm()),
            );
          }),
      Divider(
        color: Colors.black54,
        endIndent: MediaQuery.sizeOf(context).width * .04,
        indent: MediaQuery.sizeOf(context).width * .04,
      ),
      _OptionItem(
          // icon: Icon(Icons.copy_all_rounded, color: Colors.blue[600], size: 26),
          icon: Icon(Icons.search_rounded, color: Colors.blue[600], size: 26),
          name: 'Start Inspection',
          description: 'perform a routine inspection',
          comingSoon: true,
          onTap: () {}),

      //separator or divider
      Divider(
        color: Colors.black54,
        endIndent: MediaQuery.sizeOf(context).width * .04,
        indent: MediaQuery.sizeOf(context).width * .04,
      )
    ]);
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final String description;
  final VoidCallback onTap;
  final bool comingSoon;

  const _OptionItem({
    required this.icon,
    required this.name,
    required this.onTap,
    required this.description,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: comingSoon ? null : onTap, // Disable tap if coming soon
      child: Stack(
        children: [
          ListTile(
            leading: Container(
              decoration: BoxDecoration(
                color: Colors.blue[100], // Light blue color
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
              padding: const EdgeInsets.all(8.0), // Adjust padding as needed
              child: icon, // Your icon widget
            ),
            title: Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).secondaryHeaderColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (comingSoon) // Show "Coming Soon" if true
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Coming Soon",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600], // Gray color
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: CircleAvatar(
              backgroundColor: Colors.blue[100],
              radius: 12,
              child: const Icon(
                Icons.arrow_forward_ios_outlined,
                size: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
