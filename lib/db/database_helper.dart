import 'package:safify/dummy.dart';
import 'package:safify/models/incident_sub_type.dart';
import 'package:safify/models/incident_types.dart';
import 'package:safify/models/location.dart';
import 'package:safify/models/sub_location.dart';
import 'package:safify/models/user_form_report.dart';
import 'package:safify/services/ReportServices.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    print("initializing database...");
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'locations.db');

    // print("deleting database...");
    // await deleteDatabase(path);
    // print("database deleted...");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print("creating db for the first time..");
        await db.execute(
          'CREATE TABLE locations(location_id TEXT PRIMARY KEY, location_name TEXT)',
        );
        await db.execute(
          'CREATE TABLE sublocations(sub_location_id TEXT PRIMARY KEY, location_id TEXT, sub_location_name TEXT, FOREIGN KEY (location_id) REFERENCES locations (location_id))',
        );

        // make tables for incident types and subtypes
        await db.execute(
          'CREATE TABLE incident_types(incident_type_id TEXT PRIMARY KEY, incident_type_description TEXT)',
        );

        await db.execute(
          'CREATE TABLE incident_subtypes(incident_subtype_id TEXT PRIMARY KEY, incident_type_id TEXT, incident_subtype_description TEXT, FOREIGN KEY (incident_type_id) REFERENCES incident_types (incident_type_id))',
        );
        await db.execute('''
          CREATE TABLE user_form_reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sublocationId TEXT NOT NULL,
            incidentSubtypeId TEXT NOT NULL,
            description TEXT NOT NULL,
            date TEXT NOT NULL,
            criticalityId TEXT NOT NULL,
            imagePath TEXT
          ) 
          ''');

        ///
        await db.insert(
          'locations',
          Location(locationId: 'LT1', locationName: 'Main Entrance').toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Insert one sublocation
        await db.insert(
          'sublocations',
          const SubLocation(
            sublocationId: 'SLT1',
            location_id: 'LT1',
            sublocationName: 'Reception Desk',
          ).toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Insert incident types and subtype

        await db.insert(
          'incident_types',
          const IncidentType(
            incidentTypeId: 'ITY1',
            incidentTypeDescription: 'safety',
          ).toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await db.insert(
          'incident_subtypes',
          const IncidentSubType(
            incidentSubtypeId: 'ISTY1',
            incidentTypeId: 'ITY1',
            incidentSubtypeDescription: 'Physical Injury',
          ).toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      },
    );
  }

  Future<void> insertUserFormReport(UserFormReport) async {
    final db = await database;
    await db.insert(
      'user_form_reports',
      UserFormReport.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<int, UserFormReport>> getUserFormReports() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_form_reports');
    return {for (var item in maps) item['id']: UserFormReport.fromJson(item)};
  }

  Future<void> deleteUserFormReport(int id) async {
    final db = await database;
    await db.delete(
      'user_form_reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Batch insert for multiple locations and sublocations
  Future<void> insertLocationsAndSublocations(
      List<Location> locations, List<SubLocation> sublocations) async {
    final db = await database;
    Batch batch = db.batch();

    for (var location in locations) {
      batch.insert(
        'locations',
        location.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var sublocation in sublocations) {
      batch.insert(
        'sublocations',
        sublocation.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> insertLocation(Location location) async {
    final db = await database;
    await db.insert(
      'locations',
      location.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertSublocation(SubLocation sublocation) async {
    final db = await database;
    await db.insert(
      'sublocations',
      sublocation.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Location>> getLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('locations');
    return List.generate(maps.length, (i) {
      return Location.fromJson(maps[i]);
    });
  }

  Future<List<SubLocation>> getAllSubLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sublocations');
    return List.generate(maps.length, (i) {
      return SubLocation.fromJson(maps[i], maps[i]['location_id']);
    });
  }

  Future<List<SubLocation>> getSublocations(String locationId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sublocations',
      where: 'location_id = ?',
      whereArgs: [locationId],
    );
    return List.generate(maps.length, (i) {
      return SubLocation.fromJson(maps[i], locationId);
    });
  }

  Future<List<IncidentType>> getIncidentTypes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('incident_types');
    return List.generate(maps.length, (i) {
      return IncidentType.fromJson(maps[i]);
    });
  }

  Future<List<IncidentSubType>> getAllIncidentSubtypes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('incident_subtypes');
    return List.generate(maps.length, (i) {
      return IncidentSubType.fromJson(maps[i], maps[i]['incident_type_id']);
    });
  }

  Future<void> updateLocation(Location location) async {
    final db = await database;
    await db.update(
      'locations',
      location.toJson(),
      where: 'location_id = ?',
      whereArgs: [location.locationId],
    );
  }

  Future<void> updateSublocation(SubLocation sublocation) async {
    final db = await database;
    await db.update(
      'sublocations',
      sublocation.toJson(),
      where: 'sublocation_id = ?',
      whereArgs: [sublocation.sublocationId],
    );
  }

  Future<void> deleteLocation(String id) async {
    final db = await database;

    await db.delete(
      'locations',
      where: 'location_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSublocation(String id) async {
    final db = await database;
    await db.delete(
      'sublocations',
      where: 'sublocation_id = ?',
      whereArgs: [id],
    );
  }
}
