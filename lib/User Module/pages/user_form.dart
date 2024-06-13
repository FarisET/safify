// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, deprecated_member_use

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:safify/User%20Module/pages/home_page.dart';
import 'package:safify/User%20Module/providers/fetch_user_report_provider.dart';
import 'package:safify/models/location.dart';
import 'package:safify/widgets/drawing_canvas_utils.dart';
import 'package:safify/widgets/image_utils.dart';

import '../../models/ sub_location.dart';
import '../../models/incident_sub_type.dart';
import '../../models/incident_types.dart';
import '../../widgets/build_dropdown_menu_util.dart';
import '../../widgets/form_date_picker.dart';
import '../providers/incident_subtype_provider.dart';

import '../providers/incident_type_provider.dart';
import '../providers/location_provider.dart';
import '../providers/sub_location_provider.dart';
import '../services/ReportServices.dart';
import 'home.dart';

class UserForm extends StatefulWidget {
  // ignore: avoid_types_as_parameter_names
  const UserForm({super.key, Key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  int selectedChipIndex = -1;
  List<bool> isSelected = [false, false, false];
  List<String> chipLabels = ['Minor', 'Major', 'Critical'];
  List<String> chipLabelsid = ['CRT1', 'CRT2', 'CRT3'];
  String incidentType = '';
  String incidentSubType = '';
  List<String> dropdownMenuEntries = [];
  final TextEditingController _textFieldController = TextEditingController();
  bool _confirmedExit = false;
  bool isFirstIncidentDropdownSelected = false;
  bool isFirstLocationDropdownSelected = false;
  File? _imageFile;
  final ImageUtils _imageService = ImageUtils();
  bool _isEditing = false;
  ImageStream? _imageStream;
  bool isSubmitting = false;

  void _processData() {
    if (mounted) {
      setState(() {
        _formKey.currentState?.reset();
      });
    }
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
  //String location = '';
  String description = '';
  DateTime date = DateTime.now();
  bool status =
      false; // how to update, initially false, will be changed by admin.
  String risklevel = '';
  String title = "PPE Violation";
  String? SelectedIncidentType;
  String? SelectedLocationType;
  String SelectedSubLocationType = '';
  File? returnedImage;
  bool isRiskLevelSelected = false;
  ImageUtils imageUtils = ImageUtils();
  DropdownMenuItem<String> buildIncidentMenuItem(IncidentType type) {
    return DropdownMenuItemUtil.buildDropdownMenuItem<IncidentType>(
        type, type.Incident_Type_ID, type.Incident_Type_Description
        // Add the condition to check if it's selected based on your logic
        );
  }

  DropdownMenuItem<String> buildSubIncidentMenuItem(IncidentSubType type) {
    return DropdownMenuItemUtil.buildDropdownMenuItem<IncidentSubType>(
        type, type.Incident_SubType_ID, type.Incident_SubType_Description
        // Add the condition to check if it's selected based on your logic
        );
  }

  DropdownMenuItem<String> buildLocationMenuItem(Location type) {
    return DropdownMenuItemUtil.buildDropdownMenuItem<Location>(
        type, type.Location_ID, type.Location_Name
        // Add the condition to check if it's selected based on your logic
        );
  }

  DropdownMenuItem<String> buildSubLocationMenuItem(SubLocation type) {
    return DropdownMenuItemUtil.buildDropdownMenuItem<SubLocation>(
        type, type.Sub_Location_ID, type.Sub_Location_Name
        // Add the condition to check if it's selected based on your logic
        );
  }

  void _editImage() {
    setState(() {
      _isEditing = true;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<IncidentProviderClass>(context, listen: false)
          .getIncidentPostData();
      if (SelectedIncidentType != null) {
        Provider.of<SubIncidentProviderClass>(context, listen: false)
            .getSubIncidentPostData(SelectedIncidentType!);
      }

      Provider.of<LocationProviderClass>(context, listen: false)
          .getLocationPostData();
      if (SelectedIncidentType != null) {
        Provider.of<SubLocationProviderClass>(context, listen: false)
            .getSubLocationPostData(SelectedLocationType!);
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
            MaterialPageRoute(builder: (context) => HomePage2()),
          );
          return false; // Prevent the user from going back
        } else {
          // Show the confirmation dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Confirm Exit'),
              content: Text(
                  'Do you want to leave this page? Any unsaved changes will be lost.'),
              actions: [
                TextButton(
                  onPressed: () {
                    // If the user confirms, set _confirmedExit to true and pop the dialog
                    setState(() {
                      _confirmedExit = true;
                    });

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage2()),
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).secondaryHeaderColor),
            onPressed: () {
              // Add your navigation logic here, such as pop or navigate back
              Navigator.of(context).pop();
            },
          ),
          title: Text("Report an Incident",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).secondaryHeaderColor,
              )),
          actions: [
            IconButton(
              icon: Image.asset('assets/images/safify_icon.png'),
              onPressed: () {
                // Handle settings button press
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width * 0.05,
              vertical: MediaQuery.sizeOf(context).height * 0.02),
          child: Form(
            key: _formKey,
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FormDatePicker(
                                  date: date,
                                  onChanged: (newDateTime) {
                                    // Handle the updated date
                                    setState(() {
                                      date = newDateTime;
                                    });
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Divider(
                                    thickness: 1,
                                    color: Theme.of(context).highlightColor,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'What type of incident did you witness?',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Consumer<IncidentProviderClass>(
                                  builder: (context, selectedVal, child) {
                                    if (selectedVal.loading) {
                                      return Center(
                                        child:
                                            CircularProgressIndicator(), // Display a loading indicator
                                      );
                                    } else {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .highlightColor),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: FormField<String>(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Category is required';
                                            }
                                            return null;
                                          },
                                          builder:
                                              (FormFieldState<String> state) {
                                            return DropdownButton<String>(
                                              value:
                                                  selectedVal.selectedIncident,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              isExpanded: true,
                                              icon: Icon(Icons.arrow_drop_down,
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor),
                                              underline: Container(),
                                              items: [
                                                DropdownMenuItem<String>(
                                                  value:
                                                      null, // Placeholder value
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 8.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Category',
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .secondaryHeaderColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                        ),
                                                        Text(
                                                          ' (required)',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .hintColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (selectedVal.incidentPost !=
                                                    null)
                                                  ...selectedVal.incidentPost!
                                                      .map((type) {
                                                    return buildIncidentMenuItem(
                                                        type);
                                                  }).toList(),
                                              ],
                                              onChanged: (v) {
                                                selectedVal.setIncidentType(v);
                                                incidentType = v!;
                                                SelectedIncidentType = v;
                                                Provider.of<SubIncidentProviderClass>(
                                                        context,
                                                        listen: false)
                                                    .selectedSubIncident = null;
                                                Provider.of<SubIncidentProviderClass>(
                                                        context,
                                                        listen: false)
                                                    .getSubIncidentPostData(v);
                                                isFirstIncidentDropdownSelected =
                                                    v != null;
                                                setState(() {});
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
                                if (isFirstIncidentDropdownSelected)
                                  Consumer<SubIncidentProviderClass>(
                                      builder: (context, selectedValue, child) {
                                    if (SelectedIncidentType != null) {
                                      if (selectedValue.loading) {
                                        return Center(
                                          child:
                                              CircularProgressIndicator(), // Display a loading indicator
                                        );
                                      } else {
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .highlightColor),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: FormField<String>(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Sub Cateogry is required';
                                              }
                                              return null;
                                            },
                                            builder:
                                                (FormFieldState<String> state) {
                                              return DropdownButton<String>(
                                                value: selectedValue
                                                    .selectedSubIncident,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                                isExpanded: true,
                                                icon: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor),
                                                underline: Container(),
                                                items: [
                                                  DropdownMenuItem<String>(
                                                    value:
                                                        null, // Placeholder value
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10.0,
                                                          vertical: 8.0),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Sub Category',
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .secondaryHeaderColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                          ),
                                                          Text(
                                                            ' (required)',
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .hintColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 12),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (selectedValue
                                                          .subIncidentPost !=
                                                      null)
                                                    ...selectedValue
                                                        .subIncidentPost!
                                                        .map((type) {
                                                      return buildSubIncidentMenuItem(
                                                          type);
                                                    }).toList(),
                                                ],
                                                onChanged: (v) {
                                                  selectedValue
                                                      .setSubIncidentType(v);
                                                  incidentSubType = v!;
                                                },
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    } else {
                                      return Text(
                                          'Please select a incident first',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ));

                                      // return Container(
                                      //     width: double.infinity,
                                      //     decoration: BoxDecoration(
                                      //       color: Colors.grey[100],
                                      //       border:
                                      //           Border.all(color: Colors.grey),
                                      //       borderRadius:
                                      //           BorderRadius.circular(5),
                                      //     ),
                                      //     child: Padding(
                                      //       padding: const EdgeInsets.symmetric(
                                      //           horizontal: 5.0, vertical: 12),
                                      //       child: Row(
                                      //         mainAxisAlignment:
                                      //             MainAxisAlignment.spaceBetween,
                                      //         children: const [
                                      // Text(
                                      //     'Please select a incident first',
                                      //     style: TextStyle(
                                      //       color: Colors.grey,
                                      //     )),
                                      //           Icon(Icons.arrow_drop_down,
                                      //               color: Colors.grey)
                                      //         ],
                                      //       ),
                                      //     ));
                                    }
                                  }),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Where did you witness the incident?',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Consumer<LocationProviderClass>(
                                  builder: (context, selectedVal, child) {
                                    if (selectedVal.loading) {
                                      return Center(
                                        child:
                                            CircularProgressIndicator(), // Display a loading indicator
                                      );
                                    } else {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .highlightColor),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: FormField<String>(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Location is required';
                                            }
                                            return null;
                                          },
                                          builder:
                                              (FormFieldState<String> state) {
                                            return DropdownButton<String>(
                                              value:
                                                  selectedVal.selectedLocation,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              isExpanded: true,
                                              icon: Icon(Icons.arrow_drop_down,
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor),
                                              underline: Container(),
                                              items: [
                                                DropdownMenuItem<String>(
                                                  value:
                                                      null, // Placeholder value
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 8.0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Location',
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .secondaryHeaderColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                        ),
                                                        Text(
                                                          ' (required)',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .hintColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (selectedVal.LocationPost !=
                                                    null)
                                                  ...selectedVal.LocationPost!
                                                      .map((type) {
                                                    return buildLocationMenuItem(
                                                        type);
                                                  }).toList(),
                                              ],
                                              onChanged: (v) {
                                                selectedVal.setLocation(v);
                                                //    incidentType = v!;
                                                SelectedLocationType = v!;
                                                Provider.of<SubLocationProviderClass>(
                                                        context,
                                                        listen: false)
                                                    .selectedSubLocation = null;
                                                Provider.of<SubLocationProviderClass>(
                                                        context,
                                                        listen: false)
                                                    .getSubLocationPostData(v);
                                                isFirstLocationDropdownSelected =
                                                    v != null;
                                                setState(() {});
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
                                if (isFirstLocationDropdownSelected)
                                  Consumer<SubLocationProviderClass>(
                                      builder: (context, selectedValue, child) {
                                    if (SelectedLocationType != null) {
                                      if (selectedValue.loading) {
                                        return Center(
                                          child:
                                              CircularProgressIndicator(), // Display a loading indicator
                                        );
                                      } else {
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .hintColor),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: FormField<String>(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Sub Location is required';
                                              }
                                              return null;
                                            },
                                            builder:
                                                (FormFieldState<String> state) {
                                              return DropdownButton<String>(
                                                value: selectedValue
                                                    .selectedSubLocation,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                                isExpanded: true,
                                                icon: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor),
                                                underline: Container(),
                                                items: [
                                                  DropdownMenuItem<String>(
                                                    value:
                                                        null, // Placeholder value
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10.0,
                                                          vertical: 8.0),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Sub Location',
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .secondaryHeaderColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                          ),
                                                          Text(
                                                            ' (required)',
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .hintColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 12),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (selectedValue
                                                          .subLocationtPost !=
                                                      null)
                                                    ...selectedValue
                                                        .subLocationtPost!
                                                        .map((type) {
                                                      return buildSubLocationMenuItem(
                                                          type);
                                                    }).toList(),
                                                ],
                                                onChanged: (v) {
                                                  selectedValue
                                                      .setSubLocationType(v);
                                                  SelectedSubLocationType = v!;
                                                },
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    } else {
                                      return Text(
                                          'Please select a location first',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ));
                                    }
                                  }),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 22.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Add image of the incident',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ' (optional)',
                                        style: TextStyle(
                                            color: Theme.of(context).hintColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Builder(builder: (context) {
                                          return ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              // primary
                                              // : returnedImage == null
                                              //     ? Theme.of(context).primaryColor
                                              //     : Theme.of(context).hintColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    10.0), // Set your desired radius here
                                              ),
                                            ),
                                            onPressed: () {
                                              _showBottomSheet();
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.image),
                                                  Text(returnedImage != null
                                                      ? '  Image Added'
                                                      : ' Add Image'),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Description',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ' (optional)',
                                        style: TextStyle(
                                            color: Theme.of(context).hintColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                                TextFormField(
                                  controller: _textFieldController,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Describe the incident in a few words',
                                    fillColor: Colors.blue,
                                    labelStyle: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context).hintColor),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.green),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      setState(() => description = value),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'How severe was the incident?',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ' (required)',
                                        style: TextStyle(
                                            color: Theme.of(context).hintColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children:
                                      List.generate(chipLabels.length, (index) {
                                    return ChoiceChip(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: isSelected[index]
                                              ? Colors.transparent
                                              : Theme.of(context).hintColor,
                                          width:
                                              1.0, // Set your desired border width
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            20.0), // Set your desired border radius
                                      ),
                                      backgroundColor: isSelected[index]
                                          ? null
                                          : Colors.white,
                                      label: Text(
                                        chipLabels[index],
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      selected: isSelected[index],
                                      selectedColor: _getSelectedColor(index),
                                      onSelected: (bool selected) {
                                        setState(() {
                                          for (int i = 0;
                                              i < isSelected.length;
                                              i++) {
                                            isSelected[i] =
                                                i == index ? selected : false;
                                            risklevel = chipLabelsid[index];
                                          }
                                          isRiskLevelSelected = true;
                                        });
                                      },
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        OverflowBar(
                          alignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: Text('CANCEL',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )),
                                )),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              //_formKey.currentState!.validate()
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (isFirstIncidentDropdownSelected &&
                                          isFirstLocationDropdownSelected &&
                                          isRiskLevelSelected &&
                                          (incidentSubType != '') &&
                                          (SelectedSubLocationType != '')) {
                                        print("pressed");
                                        int flag = await handleReportSubmitted(
                                            context, this, returnedImage);
                                        if (flag == 1) {
                                          // Show loading indicator
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              content: Text('Report Submitted'),
                                              duration: Duration(seconds: 3),
                                            ));

                                            await Provider.of<
                                                        UserReportsProvider>(
                                                    context,
                                                    listen: false)
                                                .fetchReports(context)
                                                .then((_) {
                                              // Fetch reports completed, proceed with other tasks
                                              setState(() {
                                                returnedImage = null;
                                                Provider.of<IncidentProviderClass>(
                                                        context,
                                                        listen: false)
                                                    .selectedIncident = null;
                                                Provider.of<LocationProviderClass>(
                                                        context,
                                                        listen: false)
                                                    .selectedLocation = null;
                                              });
                                              _processData();
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomePage2()),
                                              );
                                            });
                                          } else {
                                            throw Exception("not mounted");
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              content: Text(
                                                  'Failed to Submit Report'),
                                              duration: Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.redAccent,
                                            content: Text(
                                                'Please fill in all required fields'),
                                          ),
                                        );
                                      }
                                    },
                              child: SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: isSubmitting
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Submitting',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            SizedBox(
                                              height: MediaQuery.sizeOf(context)
                                                      .height *
                                                  0.02,
                                              width: MediaQuery.sizeOf(context)
                                                      .height *
                                                  0.02,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        )
                                      : Text(
                                          'Submit',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageGallery(BuildContext context) async {
    ImageUtils imageUtils = ImageUtils();
    File? image = await imageUtils.pickImageFromGallery();
    if (image != null) {
      // Create an ImageStream from the selected image
      final ImageStream imageStream =
          FileImage(image).resolve(ImageConfiguration());

      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DrawingCanvas(imageStream: imageStream)),
      );

      if (editedImage != null) {
        File? finalImg = await imageUtils.imageToMemoryFile(editedImage);

        setState(() {
          returnedImage = finalImg;
        });
        Fluttertoast.showToast(msg: 'Image edited and saved');
      } else {
        setState(() {
          returnedImage = image;
        });
        Fluttertoast.showToast(msg: 'Image editing failed');
      }
    } else {
      Fluttertoast.showToast(msg: 'No Image Selected');
    }
  }

  Future<void> _pickImageCamera(BuildContext context) async {
    ImageUtils imageUtils = ImageUtils();
    File? image = await imageUtils.pickImageFromCamera();
    if (image != null) {
      // Create an ImageStream from the selected image
      final ImageStream imageStream =
          FileImage(image).resolve(ImageConfiguration());

      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DrawingCanvas(imageStream: imageStream)),
      );

      if (editedImage != null) {
        File? finalImg = await imageUtils.imageToMemoryFile(editedImage);

        setState(() {
          returnedImage = finalImg;
        });
        Fluttertoast.showToast(msg: 'Image edited and saved');
      } else {
        setState(() {
          returnedImage = image;
        });
        Fluttertoast.showToast(msg: 'Image editing failed');
      }
    } else {
      Fluttertoast.showToast(msg: 'No Image Selected');
    }
  }

  Future _pickImageFromGallery() async {
    XFile? returnedImage1 =
        (await ImagePicker().pickImage(source: ImageSource.gallery));
    //  if (returnedImage != null) {
    //    uploadImage(returnedImage);

    if (returnedImage1 != null) {
      setState(() {
        returnedImage = returnedImage1 as File?;
      });
      //  Fluttertoast.showToast(msg: 'Image captured');
      Navigator.pop(context);
    } else {
      Text('No image selected');
      Navigator.pop(context);
    }
  }

  // Future _pickImageFromCamera() async {
  //   XFile? returnedImage1 =
  //       (await ImagePicker().pickImage(source: ImageSource.camera));
  //   //  if (returnedImage != null) {
  //   //    uploadImage(returnedImage);

  //   if (returnedImage1 != null) {
  //     setState(() {
  //       returnedImage = returnedImage1 as File?;
  //     });
  //     //  Fluttertoast.showToast(msg: 'Image captured');
  //     Navigator.pop(context);
  //   } else {
  //     Text('No image selected');
  //     Navigator.pop(context);
  //   }
  // }

  // Future _pickImageFromCamera() async {
  //   XFile? returnedImage1 =
  //       (await ImagePicker().pickImage(source: ImageSource.camera));
  //   //  if (returnedImage != null) {
  //   //    uploadImage(returnedImage);

  //   if (returnedImage1 != null) {
  //     setState(() {
  //       returnedImage = returnedImage1;
  //       _isEditing = false;
  //       _imageStream = FileImage(_imageFile!).resolve(ImageConfiguration());
  //     });
  //     //   Fluttertoast.showToast(msg: 'Image captured');
  //     Navigator.pop(context);
  //   } else {
  //     Text('No image selected');
  //     Navigator.pop(context);
  //   }
  // }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: MediaQuery.sizeOf(context).height * .03,
                bottom: MediaQuery.sizeOf(context).height * .05),
            children: [
              //pick profile picture label
              Text('Add Image',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).secondaryHeaderColor)),

              //for adding some space
              SizedBox(height: MediaQuery.sizeOf(context).height * .02),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(MediaQuery.sizeOf(context).width * .3,
                              MediaQuery.sizeOf(context).height * .15)),
                      onPressed: () async {
                        // _pickImageFromCamera();
                        _pickImageCamera(context);
                      },
                      child: Image.asset('assets/images/camera.png')),

                  //take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(MediaQuery.sizeOf(context).width * .3,
                              MediaQuery.sizeOf(context).height * .15)),
                      onPressed: () async {
                        //_pickImageFromGallery();
                        _pickImageGallery(context);
                      },
                      child: Image.asset('assets/images/add_image.png')),
                ],
              )
            ],
          );
        });
  }

  Future<int> handleReportSubmitted(BuildContext context,
      _UserFormState userFormState, File? selectedImage) async {
    setState(() {
      isSubmitting = true;
    });
    // print(isSubmitting);
    // await Future.delayed(Duration(seconds: 3));
    // print("tesing submit button");

    // print(isSubmitting);

    // return 0;

    if (selectedImage != null) {
      // Upload image first
      //   bool imageUploaded = await uploadImage(selectedImage);

      //if (imageUploaded) {
      // If image upload is successful, proceed with report submission
      ReportServices reportServices = ReportServices(context);
      int flag = await reportServices.uploadReportWithImage(
        userFormState.returnedImage,
        //  userFormState.id,
        userFormState.SelectedSubLocationType,
        userFormState.incidentSubType,
        userFormState.description,
        userFormState.date,
        userFormState.risklevel,
      );
      setState(() {
        isSubmitting = false;
      });

      return flag;
    } else {
      ReportServices reportServices = ReportServices(context);
      int flag = await reportServices.postReport(
        //userFormState.returnedImage,
        //  userFormState.id,
        userFormState.SelectedSubLocationType,
        userFormState.incidentSubType,
        userFormState.description,
        userFormState.date,
        userFormState.risklevel,
        // userFormState.status,
      );
      setState(() {
        isSubmitting = false;
      });
      return flag;
    }
  }
}
