// ignore_for_file: non_constant_identifier_names

class CountByIncidentSubTypes {
  final String? incident_subtype_description;
  final int? incident_count;

  const CountByIncidentSubTypes({
    required this.incident_subtype_description, 
    required this.incident_count,
    });
    
    factory CountByIncidentSubTypes.fromJson(Map<String, dynamic> json) {
      return CountByIncidentSubTypes(
       incident_subtype_description: json['incident_subtype_description'] ?? '',
       incident_count: json['incident_count'] ?? 0,
 
     );
        
    }
}
