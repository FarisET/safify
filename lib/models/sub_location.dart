// ignore_for_file: non_constant_identifier_names

class SubLocation {
  final String Sub_Location_ID;
  final String Sub_Location_Name;
//  final String Incident_Type_ID;
  final String location_id;

  const SubLocation({
    required this.Sub_Location_ID,
    required this.Sub_Location_Name,
    required this.location_id,
    //  required this.Incident_Type_ID,
  });

  factory SubLocation.fromJson(Map<String, dynamic> json, String locationID) {
    return SubLocation(
      Sub_Location_ID: json['sub_location_id'] ?? '',
      Sub_Location_Name: json['sub_location_name'] ?? '',
      location_id: locationID,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub_location_id': Sub_Location_ID,
      'sub_location_name': Sub_Location_Name,
      'location_id': location_id
      //    'incident_type_id': Incident_Type_ID,
    };
  }

  @override
  String toString() {
    return 'SubLocation{Sub_Location_ID: $Sub_Location_ID, Sub_Location_Name: $Sub_Location_Name, location_id: $location_id}';
  }
}
