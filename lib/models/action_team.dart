// ignore_for_file: non_constant_identifier_names

class ActionTeam {
  final String ActionTeam_ID;
  final String  ActionTeam_Name;

  const ActionTeam({
    required this.ActionTeam_ID, 
    required this. ActionTeam_Name,
    });
    
    factory ActionTeam.fromJson(Map<String, dynamic> json) {
      return ActionTeam(
       ActionTeam_ID: json['action_team_id'] ?? '',
       ActionTeam_Name: json['action_team_name'] ?? ''
        );
        
    }
}

    
