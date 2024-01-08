// ignore_for_file: non_constant_identifier_names

class IncidentSubType {
  final String Incident_SubType_ID;
  final String Incident_SubType_Description;
//  final String Incident_Type_ID;

  const IncidentSubType({
    required this.Incident_SubType_ID, 
    required this.Incident_SubType_Description,
  //  required this.Incident_Type_ID, 
    });
    
    factory IncidentSubType.fromJson(Map<String, dynamic> json) {
      return IncidentSubType(
       Incident_SubType_ID: json['incident_subtype_id'],
       Incident_SubType_Description: json['incident_subtype_description'],
  //     Incident_Type_ID: json['incident_type_id'],
 
     );
        
    }
}
