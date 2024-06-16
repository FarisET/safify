// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:safify/Action%20Team%20Module/providers/fetch_assigned_tasks_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/ReportServices.dart';
import '../../widgets/image_utils.dart';
import 'action_team_home_page.dart';

class ActionReportForm extends StatefulWidget {
  const ActionReportForm({super.key});

  @override
  _ActionReportState createState() => _ActionReportState();
}

class _ActionReportState extends State<ActionReportForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController incidentController = TextEditingController();
  final TextEditingController rootCauseController1 = TextEditingController();
  final TextEditingController rootCauseController2 = TextEditingController();
  final TextEditingController rootCauseController3 = TextEditingController();
  final TextEditingController rootCauseController4 = TextEditingController();
  final TextEditingController rootCauseController5 = TextEditingController();
  final TextEditingController reportedByController = TextEditingController();
  final TextEditingController resolutionDescController =
      TextEditingController();
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController workApprovalController = TextEditingController();
  XFile? incidentSiteImg;
  XFile? workPrfImg;
  bool _confirmedExit = false;

  bool isSubmitting = false;

  bool proofOfWorkError = false;

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

  void _processData() {
    if (mounted) {
      setState(() {
        _formKey.currentState?.reset();
      });
    }
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
                      MaterialPageRoute(
                          builder: (context) => ActionTeamHomePage()),
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
          title: Text("Investigation Report",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).secondaryHeaderColor,
              )),
          bottom: TabBar(
            overlayColor:
                MaterialStateProperty.all<Color>(Colors.blue.shade100),
            indicatorColor: Theme.of(context).primaryColor,
            controller: _tabController,
            tabs: [
              Tab(
                  child: Text(
                ("Incident Details"),
                style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              )),
              Tab(
                  child: Text(
                ("Root Cause Analysis"),
                style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
              )),
              Tab(
                  child: Text(
                ("Resolution Details"),
                style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
              )),
            ],
          ),
        ),
        body: Form(
          // autovalidateMode: AutovalidateMode
          // .onUserInteraction, // Validation occurs when the user interacts with the form
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: reportedByController,
                                decoration: InputDecoration(
                                  labelText: 'Reported By',
                                  hintText: 'Enter your name',
                                  prefixIcon:
                                      Icon(Icons.person, color: Colors.blue),
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
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '* Required';
                                  }
                                  return null;
                                },
                                //                  onChanged: (value) => setState(() => description = value),
                              ),
                              // requiredLabel(true),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: incidentController,
                                decoration: InputDecoration(
                                  labelText: 'Incident detail',
                                  hintText: 'Describe the incident in detail',
                                  prefixIcon: Icon(Icons.description,
                                      color: Colors.blue),
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
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: OutlinedButton(
                              style: ElevatedButton.styleFrom(
                                side: BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              onPressed: () {
                                _showBottomSheet1();
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 22.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.image),
                                    Flexible(
                                      child: Text(
                                        incidentSiteImg != null
                                            ? 'Image Added'
                                            : 'Add Image of enviroment',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
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
                scrollDirection: Axis.vertical,
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
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.sizeOf(context).width * 0.05,
                                vertical:
                                    MediaQuery.sizeOf(context).height * 0.02),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Answer the series of questions to find the root cause of the incident',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.01,
                                ),
                                Text(
                                  'Note: The root cause is the underlying reason for the incident. It is the cause that, if corrected, would prevent the incident from happening again. The five whys technique is a simple but effective tool for uncovering the root cause of a problem.',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
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
                                      labelText:
                                          'why do you think it happened?',
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
                                      labelText:
                                          'why do you think that happened?',
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
                                      labelText:
                                          'why do you think that happened?',
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
                                icon: Icon(Icons.arrow_forward_ios)),
                          ],
                        ),
                        SizedBox(
                          height: 18,
                        )
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
                          child: Text(
                            'Give proof of your incident resolution to get approval of work.',
                            textAlign: TextAlign.left,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextFormField(
                          validator: (value) =>
                              value!.isEmpty ? '*Required' : null,
                          controller: resolutionDescController,
                          decoration: InputDecoration(
                            labelText: 'Resolution',
                            hintText: 'Describe resolution in a few words',
                            prefixIcon:
                                Icon(Icons.description, color: Colors.blue),
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
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          //  onChanged: (value) => setState(() => resolutionDescController = value),
                          maxLines: 3,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: OutlinedButton(
                                style: ElevatedButton.styleFrom(
                                  side: BorderSide(
                                      color: proofOfWorkError
                                          ? Colors.red
                                          : Colors.blue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                onPressed: () {
                                  _showBottomSheet();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 22.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.attach_file,
                                          color: proofOfWorkError
                                              ? Colors.red
                                              : Colors.blue),
                                      Text(
                                        workPrfImg != null
                                            ? 'Image Added'
                                            : 'Proof of work',
                                        style: TextStyle(
                                            color: proofOfWorkError
                                                ? Colors.red
                                                : Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                                visible: proofOfWorkError,
                                child: requiredLabel(true)),
                          ],
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
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      _formKey.currentState!.validate();
                                      if (workPrfImg != null &&
                                          resolutionDescController
                                              .text.isNotEmpty &&
                                          reportedByController
                                              .text.isNotEmpty) {
                                        int flag = await handleReportSubmitted(
                                            context, this);
                                        if (flag == 1) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Colors.blue,
                                                content:
                                                    Text('Report Submitted'),
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                            await Provider.of<
                                                        AssignedTaskProvider>(
                                                    context,
                                                    listen: false)
                                                .fetchAssignedTasks(context)
                                                .then((_) {
                                              // setState(() {
                                              //   workPrfImg = null;
                                              //   incidentSiteImg = null;
                                              // });
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ActionTeamHomePage()),
                                              );
                                              _processData();
                                            });
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                    'Failed to Submit Form'),
                                              ),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.red,
                                              content:
                                                  Text('Failed to Submit Form'),
                                            ),
                                          );
                                        }
                                      } else {
                                        if (workPrfImg == null) {
                                          setState(() {
                                            proofOfWorkError = true;
                                          });
                                        }
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
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.03,
                                  child: isSubmitting
                                      ? Row(
                                          children: [
                                            Text(
                                              'Submitting',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
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
                                            )
                                          ],
                                        )
                                      : Center(child: Text('Submit')),
                                ),
                              )),
                        ],
                      ),
                      SizedBox(height: 18)
                    ],
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  Padding requiredLabel(bool isRequired) {
    return isRequired
        ? Padding(
            padding: const EdgeInsets.only(top: 2, left: 8),
            child: Text("* Required",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                )),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 2, left: 8),
            child: Text(
              ' (optional)',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.normal,
                  fontSize: 12),
            ),
          );
  }

  void _showBottomSheet() {
    setState(() {
      proofOfWorkError = false;
    });

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
                        _pickImageFromCamera();
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
                        _pickImageFromGallery();
                      },
                      child: Image.asset('assets/images/add_image.png')),
                ],
              )
            ],
          );
        });
  }

  void _showBottomSheet1() {
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
                        _pickImageFromCamera1();
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
                        _pickImageFromGallery1();
                      },
                      child: Image.asset('assets/images/add_image.png')),
                ],
              )
            ],
          );
        });
  }

  Future _pickImageFromGallery1() async {
    XFile? returnedImage1 =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage1 != null) {
      setState(() {
        incidentSiteImg = returnedImage1;
      });
      Fluttertoast.showToast(msg: 'Image selected');
    }
  }

  Future _pickImageFromCamera1() async {
    XFile? returnedImage1 =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage1 != null) {
      setState(() {
        incidentSiteImg = returnedImage1;
      });
      Fluttertoast.showToast(msg: 'Image captured');
    }
  }

  Future _pickImageFromGallery() async {
    XFile? returnedImage1 =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage1 != null) {
      setState(() {
        workPrfImg = returnedImage1;
      });
      Fluttertoast.showToast(msg: 'Image selected');
    }
  }

  Future _pickImageFromCamera() async {
    XFile? returnedImage1 =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage1 != null) {
      setState(() {
        workPrfImg = returnedImage1;
      });
      Fluttertoast.showToast(msg: 'Image captured');
    }
  }

  Future<int> handleReportSubmitted(
      BuildContext context, _ActionReportState userFormState) async {
    _formKey.currentState!.validate();
    setState(() {
      isSubmitting = true;
    });
    // await Future.delayed(Duration(seconds: 2));

    print("pressed");

    // return -1;

    ReportServices reportServices = ReportServices(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //    String? user_id = prefs.getString("this_user_id");
    int? userReportId = prefs.getInt("user_report_id");

//    print(userFormState.incidentSiteImg.toString());

    if (userReportId != null) {
      if (incidentSiteImg != null) {
        int flag = await reportServices.uploadActionReportWithImagesFuture(
            userFormState.incidentController.text, //desciption
            userFormState.rootCauseController1.text,
            userFormState.rootCauseController2.text,
            userFormState.rootCauseController3.text,
            userFormState.rootCauseController4.text,
            userFormState.rootCauseController5.text,
            userFormState.resolutionDescController.text,
            userFormState.reportedByController.text,
            userFormState.incidentSiteImg,
            userFormState.workPrfImg,
            userReportId);

        setState(() {
          isSubmitting = false;
        });
        return flag;
      } else {
        int flag = await reportServices.postActionReport(
            userFormState.incidentController.text, //desciption
            userFormState.rootCauseController1.text,
            userFormState.rootCauseController2.text,
            userFormState.rootCauseController3.text,
            userFormState.rootCauseController4.text,
            userFormState.rootCauseController5.text,
            userFormState.resolutionDescController.text,
            userFormState.reportedByController.text,
            userFormState.workPrfImg,
            userReportId);

        setState(() {
          isSubmitting = false;
        });
        return flag;
      }
    }
    return 0;
  }
}
