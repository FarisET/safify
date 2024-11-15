import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:safify/components/custom_button.dart';
import 'package:safify/models/user_report.dart';
import 'package:safify/utils/button_utils.dart';
import 'package:safify/utils/string_utils.dart';

class UserReportTile extends StatelessWidget {
  final UserReport userReport;
  const UserReportTile({super.key, required this.userReport});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset Name and Criticality Level
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 70,
                  child: Text(
                    userReport.incidentSubtypeDescription ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        userReport.incidentCriticalityLevel!.contains('minor')
                            ? Colors.green[100]
                            : userReport.incidentCriticalityLevel!
                                    .contains('serious')
                                ? Colors.orange[100]
                                : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ' ${capitalizeFirstLetter(userReport.incidentCriticalityLevel)}',
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            // Divider between sections
            const Divider(thickness: 1, height: 20),

            // Status Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  userReport.status == 'open'
                      ? Icons.check_box_outline_blank_rounded
                      : userReport.status == 'in progress'
                          ? Icons.autorenew_outlined
                          : Icons.check_box_outlined,
                  color: userReport.status == 'open'
                      ? Colors.blue
                      : userReport.status == 'in progress'
                          ? Colors.orange
                          : Colors.green,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  ' ${capitalizeFirstLetter(userReport.status)}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),

            // Divider
            const Divider(thickness: 1, height: 20),

            // Location Row
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Colors.red, size: 22),
                const SizedBox(width: 8),
                Text(
                  userReport.subLocationName ?? 'N/A',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Date and Time
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.blue, size: 22),
                const SizedBox(width: 8),
                Text(
                  '${userReport.dateTime?.split('T')[0]} | ${userReport.dateTime?.split('T')[1].replaceAll(RegExp(r'\.\d+Z$'), '')}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),

            // Divider
            const Divider(thickness: 1, height: 20),

            // Report Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.textsms_outlined,
                    color: Colors.purple, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userReport.reportDescription ?? 'No description provided',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Buttons and Status
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ImageButton(
                    height: double.infinity,
                    onTap: () => handleImageButton(userReport.image, context),
                  ),
                  userReport.status!.contains('completed')
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors
                                .green[100], // Background color for 'completed'
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : userReport.status!.contains('in progress')
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange[
                                    100], // Background color for 'in progress'
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'In progress',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red[
                                    100], // Background color for other statuses
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${capitalizeFirstLetter(userReport.status)}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
