// ignore_for_file: non_constant_identifier_names

class AssignTask {
  final int? user_report_id; 
  final String? report_description;
  final String? date_of_assignment;
  final String? sub_location_name;
  final String? incident_subtype_description;
  final Map<String, dynamic>? image;
  final String? incident_criticality_level;
  final String? status;
  
  AssignTask({
    required this.user_report_id,
    required this.report_description,
    required this.date_of_assignment,
    required this.sub_location_name,
    required this.incident_subtype_description,
    required this.image,
    required this.incident_criticality_level,
    required this.status,
  });

  factory AssignTask.fromJson(Map<String, dynamic> json) {
    return AssignTask(
      user_report_id: json['user_report_id'],
      report_description: json['report_description'],
      date_of_assignment: json['date_of_assignment'],
      sub_location_name: json['sub_location_name'],
      incident_subtype_description: json['incident_subtype_description'],
      image: json['image'],
      incident_criticality_level: json['incident_criticality_level'],
      status: json['status'],
    );
  }
}
