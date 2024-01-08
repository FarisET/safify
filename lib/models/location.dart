// ignore_for_file: non_constant_identifier_names

class Location {
  final String Location_ID;
  final String  Location_Name;

  const Location({
    required this.Location_ID, 
    required this. Location_Name,
    });
    
    factory Location.fromJson(Map<String, dynamic> json) {
      return Location(
       Location_ID: json['location_id'] ?? '',
       Location_Name: json['location_name'] ?? ''
        );
        
    }
}

    
