// ignore_for_file: non_constant_identifier_names

class ActionTeamEfficiency {
  final String? action_team_name;
  final String? efficiency_value;

  const ActionTeamEfficiency({
    required this.action_team_name, 
    required this.efficiency_value,
    });
    
    factory ActionTeamEfficiency.fromJson(Map<String, dynamic> json) {
      return ActionTeamEfficiency(
       action_team_name: json['action_team_name'] ?? '',
       efficiency_value: json['efficiency_value'] ?? '',
 
     );
        
    }
}
