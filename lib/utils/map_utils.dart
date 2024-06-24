import 'package:safify/models/sub_location.dart';

Map<String, List<SubLocation>> makeSublocationMap(
    List<SubLocation> allSubLocations) {
  Map<String, List<SubLocation>> locationToSubLocationsMap = {};
  for (var subLocation in allSubLocations) {
    if (locationToSubLocationsMap.containsKey(subLocation.location_id)) {
      locationToSubLocationsMap[subLocation.location_id]!.add(subLocation);
    } else {
      locationToSubLocationsMap[subLocation.location_id] = [subLocation];
    }
  }
  return locationToSubLocationsMap;
}
