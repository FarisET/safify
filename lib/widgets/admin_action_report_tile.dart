import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safify/Action%20Team%20Module/providers/action_reports_provider.dart';
import 'package:safify/Action%20Team%20Module/providers/all_action_reports_approveal_provider.dart';
import 'package:safify/Admin%20Module/providers/delete_action_report_provider.dart';
import 'package:safify/components/custom_button.dart';
import 'package:safify/models/action_report.dart';
import 'package:safify/services/report_service.dart';
import 'package:safify/utils/button_utils.dart';

class AdminActionReportTile extends StatelessWidget {
  final ActionReport report;

  const AdminActionReportTile({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final approvalStatusProvider = Provider.of<ApprovalStatusProvider>(context);
    final fetchAllRepsProvider =
        Provider.of<ActionReportsProvider>(context, listen: false);
    return Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            report.incident_subtype_description!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all()),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_outline,
                              color: Colors.black, size: 20),
                          Flexible(
                            child: Text(
                              ' ${report.reported_by}',
                              style: const TextStyle(),
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: Colors.black, size: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                              '${report.date_time?.split('T')[0]} | ${report.date_time?.split('T')[1].replaceAll(RegExp(r'\.\d+Z$'), '')}'),
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.textsms_outlined,
                            color: Colors.black, size: 20),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              //    item.report_description!.isNotEmpty ?
                              report.report_description!.isNotEmpty
                                  ? report.report_description!
                                  : '-',
                              style: const TextStyle(),
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note_alt_outlined,
                            color: Colors.black, size: 20),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '${report.resolution_description}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.04,
                    ),
                    SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ImageButton(
                              height: double.infinity,
                              onTap: () {
                                handleImageButton(report.proof_image, context);
                              }),
                          ApproveButton(
                              height: double.infinity,
                              isApproved: report.status!.contains('approved'),
                              onTap: () async {
                                if (report.action_report_id != null &&
                                    report.user_report_id != null) {
                                  ReportServices().postapprovedActionReport(
                                      report.user_report_id,
                                      report.action_report_id);
                                  approvalStatusProvider
                                      .updateStatus(report.status!);
                                  fetchAllRepsProvider
                                      .fetchAllActionReports(context);
                                }
                              }),
                          Visibility(
                              visible: report.status != 'approved',
                              child: RejectButton(onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Reject?"),
                                      content: const Text(
                                          "Are you sure you want to reject this report?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            DeleteActionReportProvider
                                                deleteActionReportProvider =
                                                Provider.of<
                                                        DeleteActionReportProvider>(
                                                    context,
                                                    listen: false);

                                            deleteActionReportProvider
                                                .deleteActionReport(
                                                    '${report.action_report_id}')
                                                .then((success) async {
                                              if (success) {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  backgroundColor:
                                                      Colors.greenAccent,
                                                  content:
                                                      Text('Report deleted'),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ));
                                                await Provider.of<
                                                            ActionReportsProvider>(
                                                        context,
                                                        listen: false)
                                                    .fetchAllActionReports(
                                                        context);

                                                //PUSH NOTIFICATION
                                              }
                                            });
                                          },
                                          child: const Text("Confirm"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }))
                        ],
                      ),
                    ),
                  ]),
            ],
          ),
        ));
  }
}
