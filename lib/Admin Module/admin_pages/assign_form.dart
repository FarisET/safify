// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../User Module/services/ReportServices.dart';
import '../../models/action_team.dart';
import '../../models/department.dart';
import '../../widgets/build_dropdown_menu_util.dart';
import '../providers/action_team_provider.dart';
import '../providers/department_provider.dart';
import 'admin_home_page.dart';

class AssignForm extends StatefulWidget {
  const AssignForm({super.key, Key});

  @override
  State<AssignForm> createState() => _AssignFormState();
}

class _AssignFormState extends State<AssignForm> {
  final _formKey = GlobalKey<FormState>();
  int selectedChipIndex = -1;
  List<bool> isSelected = [false, false, false];
  List<String> chipLabels = ['Minor', 'Serious', 'Critical'];
  List<String> chipLabelsid = ['CRT1', 'CRT2', 'CRT3'];
  String actionTeam = '';
  List<String> dropdownMenuEntries = [];
  String? user_id;
  bool _confirmedExit = false;

  void _processData() {
    // Process your data and upload to the server
    _formKey.currentState?.reset();
  }

  Color? _getSelectedColor(int index) {
    if (isSelected[index]) {
      if (index == 0) {
        return Colors.greenAccent;
      } else if (index == 1) {
        return Colors.orangeAccent;
      } else if (index == 2) {
        return Colors.redAccent;
      }
    }
    return null;
  }

  int id = 0; // auto-generated
  String description = '';
  DateTime date = DateTime.now();
  bool status = false; // how to update, initially false, will be changed by admin.
  String incident_criticality_id = '';
  File? selectedImage; // Declare selectedImage as nullable
  String title = "PPE Violation";
  String? SelectedDepartment;
  

  DropdownMenuItem<String> buildDepartmentMenuItem(Department type) {
    return DropdownMenuItemUtil.buildDropdownMenuItem<Department>(
      type,
      type.Department_ID,
      type.Department_Name,
      // Add the condition to check if it's selected based on your logic
    );
  }

  DropdownMenuItem<String> buildActionTeamMenuItem(ActionTeam type) {
  return DropdownMenuItemUtil.buildDropdownMenuItem<ActionTeam>(
    type,
    type.ActionTeam_ID,
    type.ActionTeam_Name
    // Add the condition to check if it's selected based on your logic
  );
}


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<DepartmentProviderClass>(context, listen: false).getDepartmentPostData();
    if (SelectedDepartment != null) {
    Provider.of<ActionTeamProviderClass>(context, listen: false).getActionTeamPostData(SelectedDepartment!);
      }   
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
  onWillPop: () async {
    if (_confirmedExit) {
      // If the exit is confirmed, replace the current route with the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminHomePage()),
      );
      return false; // Prevent the user from going back
    } else {
      // Show the confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Exit'),
          content: Text('Do you want to leave this page? Any unsaved changes will be lost.'),
          actions: [
            TextButton(
              onPressed: () {
                // If the user confirms, set _confirmedExit to true and pop the dialog
                setState(() {
                  _confirmedExit = true;
                  SelectedDepartment=null;
                });
                _processData();
                
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AdminHomePage()),
                   );

              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                // If the user cancels, do nothing and pop the dialog
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
          ],
        ),
      );
      return false;
    }
  },  
        child: Scaffold(
        backgroundColor: Colors.blue[300],
        appBar: AppBar(
          title: const Text('Assign Task'),
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
                      Expanded(
                        child: ListView(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Consumer<DepartmentProviderClass>(
                              builder: (context, selectedVal, child) {
                                if (selectedVal.loading) {
                                  return Center(
                                    child: CircularProgressIndicator(), // Display a loading indicator
                                  );
                                } else {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: FormField<String>(
                                      builder: (FormFieldState<String> state) {
                                        return DropdownButton<String>(
                                          value: selectedVal.selectedDepartment,
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          isExpanded: true,
                                          icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                                          underline: Container(),
                                          items: [
                                            DropdownMenuItem<String>(
                                              value: null, // Placeholder value
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 8.0),
                                                child: Text('Select department'),
                                              ),
                                            ),
                                            if (selectedVal.departmentPost != null) ...selectedVal.departmentPost!.map((type) {
                                              return buildDepartmentMenuItem(type);
                                            }).toList(),
                                          ],
                                          onChanged: (v) {
                                            print('Selected Department: $v');
                                            selectedVal.setDepartmentType(v);
                                            SelectedDepartment = v!;
                                            Provider.of<ActionTeamProviderClass>(context, listen: false).selectedActionTeam = null;
                                           Provider.of<ActionTeamProviderClass>(context, listen: false).getActionTeamPostData(v);
                                          },
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                            ),    
                             SizedBox(
                                    height: 10,
                                  ),
                                  Consumer<ActionTeamProviderClass>(
                                    builder: (context, selectedValue, child) {
                                      if (SelectedDepartment != null){ 
                                      if (selectedValue.loading) {
                                        return Center(
                                          child: CircularProgressIndicator(), // Display a loading indicator
                                        );
                                      } 
                                     else  {                                 
                                         return Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.blue),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: FormField<String>(
                                            builder: (FormFieldState<String> state) {
                                              return DropdownButton<String>(
                                                  value: selectedValue.selectedActionTeam,
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                  isExpanded: true,
                                                  icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                                                  underline: Container(),
                                                  items: [
                                                    DropdownMenuItem<String>(
                                                      value: null, // Placeholder value
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left:8.0),
                                                        child: Text('Select action team'),
                                                      ),
                                                    ),
                                                    if (selectedValue.actionTeamPost != null)
                                                      ...selectedValue.actionTeamPost!.map((type) {
                                                        return buildActionTeamMenuItem(type);
                                                      }).toList(),                                               
                                                    ],
                                                  onChanged: (v) {
                                                    print('Selected Action Team: $v');
                                                    selectedValue.setActionTeam(v);
                                                    actionTeam = v!;
                  
                  
                  
                                                  },
                                                );
                  
                                            },
                                          ),
                                        );
                                        }
                                      } 
                                        else {
                                           return Container(
                                            width: double.infinity,
                                          decoration: BoxDecoration(
                                            color:Colors.grey[100],
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child:Padding(
                                            padding: const EdgeInsets.symmetric(horizontal:5.0,vertical: 12),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: const [
                                                Text('Please select a department first',
                                                style: TextStyle(color: Colors.grey,)),
                                                Icon(Icons.arrow_drop_down, color: Colors.grey)
                                              ],
                                            ),
                                          )
                                                
                                          );
                                              
                                              }
                                              }
                                            ),
                                  SizedBox(height: 15,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: List.generate(chipLabels.length, (index) {
                                                  return ChoiceChip(
                                                    backgroundColor: isSelected[index] ? null : Colors.blue,
                                                    label: Text(chipLabels[index],
                                                    style: TextStyle(color: Colors.white),),
                                                    selected: isSelected[index],
                                                    selectedColor: _getSelectedColor(index),
                                                    onSelected: (bool selected) {
                                                      setState(() {
                                                        for (int i = 0; i < isSelected.length; i++) {
                                                          isSelected[i] = i == index ? selected : false;
                                                          incident_criticality_id = chipLabelsid[index];
                                                          print('crit level: $incident_criticality_id');
                                                        }
                                                      });
                                                    },
                                                  );
                                                }),
                                              ),
      
                        
                        
                                      ],
                                    ),
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
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          handleReportSubmitted(context, this);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.blue,
                                              content: Text('Task Assigned'),
                                            ),
                                          );
                                          _processData();
                                        //  SharedPreferences prefs = await SharedPreferences.getInstance();
                                          // prefs.remove('this_user_id');
                                          // prefs.remove('user_report_id');
                                          setState(() {
                                            SelectedDepartment = null;
                                          });
      
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => AdminHomePage()),
                                          );
                                
                                        }
                                      },
                                      child: Text('Assign'),
                                    ),
                                  ),
                              ]
                                            ),
                                )
                                )
                                ),
                                    ),)
                              ),
    );
                            }

  void handleReportSubmitted(BuildContext context, _AssignFormState userFormState) async {
    ReportServices reportServices = ReportServices(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
      String? user_id = prefs.getString("this_user_id");
      int? user_report_id = prefs.getInt("user_report_id");   
      if (user_id != null && user_report_id != null) {      
        await reportServices.postAssignedReport(
      user_report_id,
      user_id,
      userFormState.actionTeam,
      userFormState.incident_criticality_id,
    );
  }
  }
}

