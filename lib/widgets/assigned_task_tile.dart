// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Action Team Module/pages/action_report_form.dart';
import '../Action Team Module/providers/fetch_assigned_tasks_provider.dart';
 
class AssignedTaskTile extends StatefulWidget {
  const AssignedTaskTile({super.key});

  @override
  State<AssignedTaskTile> createState() => _AssignedTaskTileState();
}

class _AssignedTaskTileState extends State<AssignedTaskTile> {
  

  @override
  void initState() {
    super.initState();
    Provider.of<AssignedTaskProvider>(context, listen: false).fetchAssignedTasks(context); 
     }





  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<AssignedTaskProvider>(
        builder: (context, assignProvider,_) { 
          if(assignProvider.tasks.isNotEmpty) {
             return ListView.builder(
                itemCount: assignProvider.tasks.length,
                itemBuilder: (context, i) {
                  var item = assignProvider.tasks[i];
            
                  return Card(
                    color: item.status!.contains('open') ? Colors.red[50] : (item.status!.contains('in progress') ? Colors.orange[50] : Colors.green[50]),
                    shape: RoundedRectangleBorder(
                      borderRadius:BorderRadius.circular(4),
                    ),
                      // side: BorderSide(
                      //   // color: item.status!.contains('open')?Colors.redAccent:Colors.greenAccent,
                      //    width:1)),                     
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom:0.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item.incident_subtype_description!,
                                      style: TextStyle(
                                        color: Colors.blue[800],
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),),
                                    //   Text('ID: ${item.id}'
                                    //   ,                                      style: TextStyle(
                                    //     color: Colors.blue[800],
                                    //  //   fontSize: 18,
                                    //     fontWeight: FontWeight.bold,
                                    //   ),
                                    //   ),
                                      Padding(
                                      padding: const EdgeInsets.only(bottom:8.0),
                                      child: Text('${item.incident_criticality_level}',
                                      style: TextStyle(
                                      color:  item.incident_criticality_level!.contains('minor') 
                                        ? Colors.green
                                        : (item.incident_criticality_level!.contains('serious') ? Colors.orange : Colors.red),
                                        fontWeight: FontWeight.bold)
                                      ),),
                                      
                                    ],
                                  ),
                                ),

                            
                            Row(
                              children: [
                                Icon(Icons.location_city,
                                color: Colors.blue,
                                size:20),
                                Text(' ${item.sub_location_name}')
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.timer,
                                color: Colors.blue,
                                size:20),
                                Text(' ${item.date_of_assignment?.split('T')[0]} | ${item.date_of_assignment?.split('T')[1].replaceAll(RegExp(r'\.\d+Z$'), '')}')
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.edit,
                                color: Colors.blue,
                                size:20),
                                Expanded(
                                  child: Text(' ${item.report_description}',
                                  style: TextStyle(
                                  //  fontSize: 16
                                   ),),
                                )
                              ],
                            ),
                            //TODO: try image
                            // Padding(
                            //   padding: const EdgeInsets.only(bottom:4.0),
                            //   child: Text('By: Faris Ejaz'),
                            // ),
                            //TODO: get user name dynamically
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                
                                      Visibility(
                                        visible: !item.status!.contains('approved'),
                                        child: FilledButton(
                                        onPressed: () async {
                                          //Add to Assigned form
                                                                            //  Fluttertoast.showToast(msg: '${item.id}');  
                                           SharedPreferences prefs = await SharedPreferences.getInstance();
                                        // //                                        if (item != null && item.user_id != null) {   
                                        //                                           if(item.user_id != null)  {                                  
                                        //                                            await prefs.setString("this_user_id", (item.user_id!));
                                        //                                           }
                                            if (item.user_report_id != null) {                                       
                                             await prefs.setInt("user_report_id", (item.user_report_id!));
                                             print('user_report_id: ${prefs.getInt("user_report_id")}');
                                          }
                                        
                                        
                                                      //                          if(prefs.getString('user_id') !=null && prefs.getInt('user_report_id') !=null) {
                                              Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => ActionReportForm()),
                                            );
                                                     //                           } 
                                          // print('user_id: ${prefs.getString('this_user_id')}');  
                                          // print('id: ${item.id}');  
                                          
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.greenAccent),
                                        ),
                                        child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal:18.0,vertical: 0),
                                          child: Text('Start', style: TextStyle(color: Colors.black)),
                                        ),
                                                                            ),
                                      ), item.status!.contains('assined') ? Text('Assigned', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)) :
                                item.status!.contains('approval pending') ? Text('Approval pending', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)) :
                                Text('${item.status}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                                                //TODO: change status color dynamically
                              ],
                          ),
                   ]),

                          
                      
                      
                      
                          ],),
                      )
                  );
                },
            
                );
            
          } else if(assignProvider.tasks.isEmpty && assignProvider.isLoading) {
            return CircularProgressIndicator();
          }
            return Text('Failed to load reports');
  })
    );

  }  
     // padding: const EdgeInsets.only(bottom:8.0),
      //child: Container(
      //     decoration: BoxDecoration(
      //       color: Colors.white,
      //       borderRadius: BorderRadius.circular(12),
      // //       border: Border(
      // //       left: BorderSide(
      // //     color: status!=null && status ? Colors.green : Colors.red,
      // //     width: 1.0, // Adjust the width as needed
      // //   ),
      // // ),
      //     ),

}    


   

    
  