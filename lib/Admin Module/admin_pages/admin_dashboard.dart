import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safify/Admin%20Module/providers/action_team_efficiency_provider.dart';
import 'package:safify/Admin%20Module/providers/analytics_incident_reported_provider.dart';
import 'package:safify/Admin%20Module/providers/analytics_incident_resolved_provider.dart';
import 'package:safify/Admin%20Module/providers/fetch_countOfLocations_provider%20copy.dart';
import 'package:safify/Admin%20Module/providers/fetch_countOfSubtypes_provider.dart';
import 'package:safify/User%20Module/pages/login_page.dart';
import 'package:safify/User%20Module/services/UserServices.dart';
import 'package:safify/models/action_team_efficiency.dart';
import 'package:safify/models/count_incidents_by_location.dart';
import 'package:safify/models/count_incidents_by_subtype.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final double mainHeaderSize = 18;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<CountIncidentsResolvedProvider>(context, listen: false)
          .getCountResolvedPostData();
      Provider.of<CountIncidentsReportedProvider>(context, listen: false)
          .getCountReportedPostData();
      Provider.of<CountByIncidentSubTypesProviderClass>(context, listen: false)
          .getcountByIncidentSubTypesPostData();
      Provider.of<CountByLocationProviderClass>(context, listen: false)
          .getcountByIncidentLocationPostData();
      Provider.of<ActionTeamEfficiencyProviderClass>(context, listen: false)
          .getactionTeamEfficiencyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final countResolvedProvider =
        Provider.of<CountIncidentsResolvedProvider>(context)
            .totalIncidentsResolved;
    final countReportedProvider =
        Provider.of<CountIncidentsReportedProvider>(context)
            .totalIncidentsReported;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text(
          "Reporting Analytics",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: mainHeaderSize,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Show confirmation dialog before logging out
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Confirmation'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Logout'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          handleLogout(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: ListTile(
                contentPadding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                leading: Icon(
                  Icons.personal_injury,
                  color: Colors.blue,
                  size: 31,
                ),
                title: Text('Total Incidents Reported'),
                trailing: CircleAvatar(
                  maxRadius: 16,
                  child: Text(countReportedProvider!),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: ListTile(
                contentPadding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                leading: Icon(
                  Icons.check_box,
                  color: Colors.blue,
                  size: 31,
                ),
                title: Text('Total Incidents Resolved'),
                trailing: CircleAvatar(
                  maxRadius: 16,
                  child: Text(countResolvedProvider!),
                ),
              ),
            ),
          ),
          _buildIncidentSubtypeChart(),
          _buildIncidentLocationChart(),
          _buildActionTeamEfficiencyChart(),
        ],
      ),
    );
  }

  Widget _buildIncidentSubtypeChart() {
    final countByIncidentSubTypeProvider =
        Provider.of<CountByIncidentSubTypesProviderClass>(context)
            .countByIncidentSubTypes;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        elevation: 3,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.category,
                    color: Colors.blue,
                    size: 31,
                  ),
                  Text(
                    'Types of Incidents Breakdown',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text('')
                ],
              ),
              SizedBox(
                  height: 200,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    title: ChartTitle(text: 'Incident Subtypes'),
                    series: <CartesianSeries>[
                      ColumnSeries<CountByIncidentSubTypes, String>(
                        dataSource: countByIncidentSubTypeProvider ??
                            [], // Ensure it's not null
                        xValueMapper: (CountByIncidentSubTypes data, _) =>
                            data.incident_subtype_description,
                        yValueMapper: (CountByIncidentSubTypes data, _) =>
                            data.incident_count,
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentLocationChart() {
    final countByLocationProvider =
        Provider.of<CountByLocationProviderClass>(context, listen: false)
            .countByLocation;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        elevation: 3,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 31,
                  ),
                  Text(
                    'Incidents breakdown by location',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text('')
                ],
              ),
              SizedBox(
                height: 200,
                child: SfCircularChart(
                  title: ChartTitle(text: 'Incident Locations'),
                  legend: Legend(isVisible: true),
                  series: <CircularSeries>[
                    PieSeries<CountByLocation, String>(
                      dataSource: countByLocationProvider,
                      xValueMapper: (CountByLocation data, _) =>
                          data.location_name,
                      yValueMapper: (CountByLocation data, _) =>
                          data.incident_count,
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTeamEfficiencyChart() {
    final actionTeamEfficiencyProvider =
        Provider.of<ActionTeamEfficiencyProviderClass>(context, listen: false)
            .actionTeamEfficiency;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        elevation: 3,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.group,
                    color: Colors.blue,
                    size: 31,
                  ),
                  Text(
                    'Action Team Efficiencies',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text('')
                ],
              ),
              SizedBox(
                height: 200,
                child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  title: const ChartTitle(text: 'Team Efficiency'),
                  series: <CartesianSeries>[
                    BarSeries<ActionTeamEfficiency, String>(
                      dataSource: actionTeamEfficiencyProvider,
                      xValueMapper: (ActionTeamEfficiency data, _) =>
                          data.action_team_name,
                      yValueMapper: (ActionTeamEfficiency data, _) =>
                          double.tryParse(data.efficiency_value ?? '0') ?? 0.0,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleLogout(BuildContext context) async {
    UserServices userServices = UserServices();
    await userServices.logout();
  }
}

// class CountByIncidentSubTypes {
//   final String incident_subtype_description;
//   final int incident_count;

//   CountByIncidentSubTypes(
//       this.incident_subtype_description, this.incident_count);
// }

// class CountByLocation {
//   final String location_name;
//   final int incident_count;

//   CountByLocation(this.location_name, this.incident_count);
// }

// class ActionTeamEfficiency {
//   final String action_team_name;
//   final double efficiency_value;

//   ActionTeamEfficiency(this.action_team_name, this.efficiency_value);
// }
