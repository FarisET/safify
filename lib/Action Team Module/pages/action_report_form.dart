// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../User Module/services/ReportServices.dart';
import '../../widgets/image_utils.dart';
import 'action_team_home_page.dart';


class ActionReportForm extends StatefulWidget {
  const ActionReportForm({super.key});

  @override
  _ActionReportState createState() => _ActionReportState();
}

class _ActionReportState extends State<ActionReportForm>  with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController incidentController = TextEditingController();
  final TextEditingController rootCauseController1 = TextEditingController();
  final TextEditingController rootCauseController2 = TextEditingController();
  final TextEditingController rootCauseController3 = TextEditingController();
  final TextEditingController rootCauseController4 = TextEditingController();
  final TextEditingController rootCauseController5 = TextEditingController();
  final TextEditingController reportedByController = TextEditingController();
  final TextEditingController resolutionDescController = TextEditingController();
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController workApprovalController = TextEditingController();
  File? incidentSiteImg;
  File? workPrfImg;
  bool _confirmedExit=false;

  ImageUtils imageUtils = ImageUtils();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    incidentController.dispose();
    rootCauseController1.dispose();
    rootCauseController2.dispose();
    rootCauseController3.dispose();
    rootCauseController4.dispose();
    rootCauseController5.dispose();
    workApprovalController.dispose();
    reportedByController.dispose();
    resolutionDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
  onWillPop: () async {
    if (_confirmedExit) {
      // If the exit is confirmed, replace the current route with the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ActionTeamHomePage()),
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
                });
                
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ActionTeamHomePage()),
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
          title: Text("Investigation Report"),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "Incident Details"),
              Tab(text: "Root Cause Analysis"),
              Tab(text: "Work Approval"),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Incident Details tab
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: TextFormField(
                                    controller: reportedByController,          
                                    decoration: InputDecoration(
                                      labelText: 'Reported By',
                                      hintText: 'Enter your name',
                                      prefixIcon: Icon(Icons.person, color: Colors.blue),
                                      fillColor: Colors.blue,
                                      labelStyle: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.blue),
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.green),
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter Something';
                                      }
                                      return null;
                                    },
                 //                  onChanged: (value) => setState(() => description = value),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: TextFormField(
                                    controller: incidentController,          
                                    decoration: InputDecoration(
                                      labelText: 'Incident detail',
                                      hintText: 'Describe the incident in detail',
                                      prefixIcon: Icon(Icons.description, color: Colors.blue),
                                      fillColor: Colors.blue,
                                      labelStyle: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.blue),
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.green),
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                    ),
                 //                  onChanged: (value) => setState(() => description = value),
                                    maxLength: 200,
                                  ),
                                ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: OutlinedButton(
                                        style: ElevatedButton.styleFrom(
                                          side: BorderSide(
                                            color: Colors.blue
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ClipRRect(
                                              clipBehavior: Clip.hardEdge,
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Wrap(
                                                    direction: Axis.horizontal,
                                                    alignment: WrapAlignment.spaceAround,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              _pickImageFromCamera1();
                                                            },
                                                            icon: Icon(Icons.camera),
                                                            iconSize: 50,
                                                            color: Colors.blue,
                                                          ),
                                                          Text(
                                                            'Camera',
                                                            style: TextStyle(
                                                              color: Colors.blue,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              _pickImageFromGallery1();
                                                            },
                                                            icon: Icon(Icons.browse_gallery),
                                                            iconSize: 50,
                                                            color: Colors.blue,
                                                          ),
                                                          Text(
                                                            'Gallery',
                                                            style: TextStyle(
                                                              color: Colors.blue,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical:22.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.attach_file),
                                            Text(incidentSiteImg != null ? 'Image Added' : 'Add Image of surrounding enviroment'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  ),
          
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: IconButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              onPressed: () {
                                _tabController.animateTo(1);
                              },
                              icon: Icon(Icons.arrow_forward_ios),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Root Cause Analysis tab
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Text('Answer the series of quesitons to find the root cause of the incident',
                                textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold),
                              )),
      
                                  Stepper(
                                    currentStep: _currentStep,
                                    onStepTapped: (step) {
                                      setState(() {
                                        _currentStep = step;
                                      });
                                    },
                                    onStepContinue: () {
                                      if (_currentStep < 4) {
                                        setState(() {
                                          _currentStep++;
                                        });
                                      }
                                    },
                                    onStepCancel: () {
                                      if (_currentStep > 0) {
                                        setState(() {
                                          _currentStep--;
                                        });
                                      }
                                    },
                                    steps: [
                                      Step(
                                        title: Text("Problem Statement"),
                                        content: Column(
                                          children: [
                                            TextFormField(
                                              controller: rootCauseController1,
                                              decoration: InputDecoration(
                                                labelText: 'what is the problem?',
                                                hintText: 'define in one line',
                                              ),
                                            ),
                                          ],
                                        ),
                                        isActive: _currentStep == 0,
                                      ),
                                      Step(
                                        title: Text("Why is that?"),
                                        content: Column(
                                          children: [
                                            TextFormField(
                                              controller: rootCauseController2,
                                              decoration: InputDecoration(
                                                labelText: 'why do you think it happened?',
                                                hintText: 'what caused it?',
                                              ),
                                            ),
                                          ],
                                        ),
                                        isActive: _currentStep == 1,
                                      ),
                                      Step(
                                        title: Text("Why is that?"),
                                        content: Column(
                                          children: [
                                            TextFormField(
                                              controller: rootCauseController3,
                                              decoration: InputDecoration(
                                                labelText: 'why do you think that happened?',
                                                hintText: 'Cause of previous cause',
                                              ),
                                            ),
                                          ],
                                        ),
                                        isActive: _currentStep == 2,
                                      ),
                                      Step(
                                        title: Text("Why is that?"),
                                        content: Column(
                                          children: [
                                            TextFormField(
                                              controller: rootCauseController4,
                                              decoration: InputDecoration(
                                                labelText: 'why do you think that happened?',
                                                hintText: 'Cause of previous cause',
                                              ),
                                            ),
                                          ],
                                        ),
                                        isActive: _currentStep == 3,
                                      ),
                                      Step(
                                        title: Text("Root Cause"),
                                        content: Column(
                                          children: [
                                            TextFormField(
                                              controller: rootCauseController5,
                                              decoration: InputDecoration(
                                                labelText: 'why is that?',
                                                hintText: 'cause of previous cause',
                                              ),
                                            ),
                                          ],
                                        ),
                                        isActive: _currentStep == 4,
                                      ),
                                    ],
                                  ),
                                  
                                    
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                 onPressed: () {
                                _tabController.animateTo(0);
                                        },
                                        icon: Icon(Icons.arrow_back_ios),
                                      ),
                        IconButton(
                          onPressed: () {
                            _tabController.animateTo(2);
                          },
                          icon: Icon(Icons.arrow_forward_ios)
                        ),
                        ],  
                            ),
                        SizedBox(height: 18,)
                      ],
                    ),
                  ),
                ),
              ),
              // Work Approval tab
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                                 Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Text('Give proof of your incident resolution to get approval of work.',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
      
                        
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: TextFormField(
                                    controller: resolutionDescController,          
                                    decoration: InputDecoration(
                                      labelText: 'Resolution',
                                      hintText: 'Describe resolution in a few words',
                                      prefixIcon: Icon(Icons.description, color: Colors.blue),
                                      fillColor: Colors.blue,
                                      labelStyle: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.blue),
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.green),
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                    ),
                                //  onChanged: (value) => setState(() => resolutionDescController = value),
                                    maxLines: 3,
                                  ),
                                ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: OutlinedButton(
                                        style: ElevatedButton.styleFrom(
                                          side: BorderSide(
                                            color: Colors.blue
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ClipRRect(
                                              clipBehavior: Clip.hardEdge,
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Wrap(
                                                    direction: Axis.horizontal,
                                                    alignment: WrapAlignment.spaceAround,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              _pickImageFromCamera();
                                                            },
                                                            icon: Icon(Icons.camera),
                                                            iconSize: 50,
                                                            color: Colors.blue,
                                                          ),
                                                          Text(
                                                            'Camera',
                                                            style: TextStyle(
                                                              color: Colors.blue,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              _pickImageFromGallery();
                                                            },
                                                            icon: Icon(Icons.browse_gallery),
                                                            iconSize: 50,
                                                            color: Colors.blue,
                                                          ),
                                                          Text(
                                                            'Gallery',
                                                            style: TextStyle(
                                                              color: Colors.blue,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical:22.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.attach_file),
                                            Text(workPrfImg != null ? 'Image Added' : 'Proof of work'),
                                          ],
                                        ),
                                      ),
                                    ),
                                                                ),
                                  ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                 onPressed: () {
                                _tabController.animateTo(1);
                                        },
                                        icon: Icon(Icons.arrow_back_ios),
                                      ),
                        ElevatedButton(
                          onPressed: () {
                           
                              if (_formKey.currentState!.validate()) {
                                handleReportSubmitted(context, this);
                               ScaffoldMessenger.of(context).showSnackBar(

                                  const SnackBar(
                                   backgroundColor: Colors.blue, 
                                    content: Text('Report Submmitted'),
                                  ),
                                );
                            //    dispose();
                            setState(() {
                              workPrfImg=null;
                              incidentSiteImg=null;
                            });
                                  Navigator.pushReplacement(
                                   context,
                                    MaterialPageRoute(builder: (context) => ActionTeamHomePage()),
                                  );
                             } else {
                               Text('Form invalid');
                             }
                            
                          },
                          child: Text('Submit')
                        ),
                        ],  
                            ),
                    SizedBox(height: 18)
                  ],
                ),
              ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }

    Future _pickImageFromGallery1() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage != null) {
      setState(() {
        incidentSiteImg = File(returnedImage.path);
      });
       Fluttertoast.showToast(msg: 'Image selected');
    }
  }

  Future _pickImageFromCamera1() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage != null) {
      setState(() {
        incidentSiteImg = File(returnedImage.path);
      });
      Fluttertoast.showToast(msg: 'Image captured');
    }
  }

      Future _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage != null) {
      setState(() {
        workPrfImg = File(returnedImage.path);
      });
       Fluttertoast.showToast(msg: 'Image selected');
    }
  }

  Future _pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage != null) {
      setState(() {
        workPrfImg = File(returnedImage.path);
      });
      Fluttertoast.showToast(msg: 'Image captured');
    }
  }

    void handleReportSubmitted(BuildContext context, _ActionReportState userFormState) async {
    ReportServices reportServices = ReportServices(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
  //    String? user_id = prefs.getString("this_user_id");
      int? userReportId = prefs.getInt("user_report_id");  
      print('user_report_id:$userReportId');
    //  print('user_id:$user_id'); 
      // print(userFormState.incidentController.text);  
      // print(userFormState.rootCauseController1.text);  
      // print(userFormState.rootCauseController2.text);  
      // print(userFormState.rootCauseController3.text);  
      // print(userFormState.rootCauseController4.text);  
      // print(userFormState.resolutionDescController.text);  
      // print(userFormState.incidentSiteImg!.toString());  


      if (userReportId != null) {      
        await reportServices.postActionReport(
          userFormState.incidentController.text, //desciption
          userFormState.rootCauseController1.text,
          userFormState.rootCauseController2.text,
          userFormState.rootCauseController3.text,
          userFormState.rootCauseController4.text,
          userFormState.rootCauseController5.text,
          userFormState.resolutionDescController.text,
          userFormState.reportedByController.text,
          userFormState.incidentSiteImg.toString(),
          userFormState.workPrfImg.toString(),
          userReportId


      );
  }
  }




}
