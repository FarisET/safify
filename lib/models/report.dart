class Reports {
  final int? id;
  final String? user_id;
  final String? description;
  final String? dateTime;
  // final Stream location;
  final String? subLocationName;
//  final String incidentType;
  final String? subLocationID;
  final String? incidentSubtypeDescription;
  final String? incidentCriticalityLevel;
  final String? incidentCriticalityID;
  final String? image; // You may need to adjust this property's type
  final String? status;

  Reports(
      {required this.user_id,
      required this.id,
      required this.description,
      required this.dateTime,
      //   required this.location,
      required this.subLocationID,
      required this.subLocationName,
      //  required this.incidentType,
      required this.incidentSubtypeDescription,
      required this.incidentCriticalityLevel,
      required this.incidentCriticalityID,
      required this.image,
      required this.status});

  factory Reports.fromJson(Map<String, dynamic> json) {
    return Reports(
      user_id: json['user_id'] as String?,
      id: json['user_report_id'],
      description: json['report_description'] as String?,
      dateTime: json['date_time'],
      //   location: json['location_name'],
      subLocationName: json['sub_location_name'] as String?,
      subLocationID: json['sub_location_id'] as String?,
      //   incidentType: json['incident_type_description'],
      incidentSubtypeDescription: json['incident_subtype_description'],
      incidentCriticalityLevel: json['incident_criticality_level'] as String?,
      incidentCriticalityID: json['incident_criticality_id'] as String?,
      image: json['image'] as String?,
      status: json[
          'status'], // You may need to adjust this based on the actual data type
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'user_report_id': id,
      'report_description': description,
      'date_time': dateTime,
      'sub_location_name': subLocationName,
      'sub_location_id': subLocationID,
      'incident_subtype_description': incidentSubtypeDescription,
      'incident_criticality_level': incidentCriticalityLevel,
      'incident_criticality_id': incidentCriticalityID,
      'image': image,
      'status': status,
    };
  }
}
