import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safify/widgets/search_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/ReportServices.dart';
import '../../models/action_team.dart';
import '../providers/all_action_team_provider.dart';
import 'admin_home_page.dart';

class AssignForm extends StatefulWidget {
  const AssignForm({super.key});

  @override
  State<AssignForm> createState() => _AssignFormState();
}

class _AssignFormState extends State<AssignForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController searchController = TextEditingController();
  String actionTeam = '';
  String? selectedRiskLevel;
  String? selectedFilter;
  bool isSubmitting = false;
  List<ActionTeam> filteredActionTeams = [];
  int selectedChipIndex = -1;
  List<bool> isSelected = [false, false, false];
  List<String> chipLabels = ['Minor', 'Serious', 'Critical'];
  List<String> chipLabelsid = ['CRT1', 'CRT2', 'CRT3'];
  String? user_id;
  bool _confirmedExit = false;
  bool isRiskLevelSelected = false;
  String? incident_criticality_id = '';

  void _processData() {
    _formKey.currentState?.reset();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<AllActionTeamProviderClass>(context, listen: false)
          .fetchAllActionTeams();
      filterActionTeams('');
    });
  }

  void filterActionTeams(String query) {
    final allActionTeams =
        Provider.of<AllActionTeamProviderClass>(context, listen: false)
                .allActionTeams ??
            [];
    setState(() {
      filteredActionTeams = allActionTeams.where((team) {
        final matchesQuery =
            team.ActionTeam_Name.toLowerCase().contains(query.toLowerCase());
        final matchesFilter =
            selectedFilter == null || team.department_name == selectedFilter;
        return matchesQuery && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final actionTeamProvider =
        Provider.of<AllActionTeamProviderClass>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        if (isSubmitting) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            color: Colors.white,
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).secondaryHeaderColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Assign Task',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      CustomSearchBar(
                        controller: searchController,
                        onSearchChanged: filterActionTeams,
                        onFilterChanged: (filter) {
                          setState(() {
                            selectedFilter = filter;
                          });
                          filterActionTeams(searchController.text);
                        },
                        filterOptions: actionTeamProvider.allActionTeams
                                ?.map((team) => team.department_name)
                                .whereType<String>()
                                .toSet()
                                .toList() ??
                            [],
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: Consumer<AllActionTeamProviderClass>(
                          builder: (context, provider, child) {
                            if (provider.loading) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return ListView.builder(
                                itemCount: filteredActionTeams.length,
                                itemBuilder: (context, index) {
                                  final actionTeam = filteredActionTeams[index];
                                  return ListTile(
                                    title: Text(actionTeam.ActionTeam_Name),
                                    subtitle: Text(actionTeam.department_name ??
                                        'No Department'),
                                    onTap: () {
                                      setState(() {
                                        this.actionTeam =
                                            actionTeam.ActionTeam_ID;
                                      });
                                    },
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: selectedRiskLevel,
                        decoration: InputDecoration(
                          labelText: 'Select Risk Level',
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        items: List.generate(chipLabels.length, (index) {
                          return DropdownMenuItem<String>(
                            value: chipLabelsid[index],
                            child: Text(chipLabels[index]),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            selectedRiskLevel = value;
                            incident_criticality_id = value!;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a risk level' : null,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (actionTeam != '' &&
                                      selectedRiskLevel != null) {
                                    int flag = await handleReportSubmitted(
                                        context, this);

                                    if (flag == 1) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.blue,
                                            content: Text('Task Assigned'),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                        _processData();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AdminHomePage()),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.redAccent,
                                            content:
                                                Text('Failed: Please retry'),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.redAccent,
                                          content: Text('Assignment Failed'),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.redAccent,
                                        content: Text(
                                            'Please Fill all required fields'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              child: isSubmitting
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Assigning..",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 20),
                                        SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.03,
                                          width: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.03,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Center(
                                      child: Text(
                                        "Assign",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<int> handleReportSubmitted(
      BuildContext context, _AssignFormState userFormState) async {
    setState(() {
      isSubmitting = true;
    });

    ReportServices reportServices = ReportServices(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user_id = prefs.getString("this_user_id");
    int? user_report_id = prefs.getInt("user_report_id");

    if (user_id != null && user_report_id != null) {
      int flag = await reportServices.postAssignedReport(
        user_report_id,
        user_id,
        userFormState.actionTeam,
        userFormState.incident_criticality_id!,
      );
      setState(() {
        isSubmitting = false;
      });
      return flag;
    }
    setState(() {
      isSubmitting = false;
    });
    return 0;
  }
}
