import 'package:safify/models/location.dart';
import 'package:safify/models/sub_location.dart';

List<List> parseLocationsAndSubLocations(Map<String, dynamic> locationsJson) {
  List<Location> locations = [];
  List<SubLocation> subLocations = [];

  for (var locationJson in locationsJson['locations']) {
    Location location = Location.fromJson(locationJson);
    locations.add(location);

    if (locationJson.containsKey('sub_locations')) {
      for (var subLocationJson in locationJson['sub_locations']) {
        SubLocation subLocation =
            SubLocation.fromJson(subLocationJson, location.locationId);
        subLocations.add(subLocation);
      }
    }
  }

  return [locations, subLocations];
}
