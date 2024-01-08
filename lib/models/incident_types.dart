// ignore_for_file: non_constant_identifier_names

class IncidentType {
  final String Incident_Type_ID;
  final String  Incident_Type_Description;

  const IncidentType({
    required this.Incident_Type_ID, 
    required this. Incident_Type_Description,
    });
    
    factory IncidentType.fromJson(Map<String, dynamic> json) {
      return IncidentType(
       Incident_Type_ID: json['incident_type_id'] ?? '',
       Incident_Type_Description: json['incident_type_description'] ?? ''
        );
        
    }
}

    
