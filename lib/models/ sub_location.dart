// ignore_for_file: non_constant_identifier_names

class SubLocation {
  final String Sub_Location_ID;
  final String Sub_Location_Name;
//  final String Incident_Type_ID;

  const SubLocation({
    required this.Sub_Location_ID, 
    required this.Sub_Location_Name,
  //  required this.Incident_Type_ID, 
    });
    
    factory SubLocation.fromJson(Map<String, dynamic> json) {
      return SubLocation(
       Sub_Location_ID: json['sub_location_id'],
       Sub_Location_Name: json['sub_location_name'],
  //     Incident_Type_ID: json['incident_type_id'],
 
     );
        
    }
}
