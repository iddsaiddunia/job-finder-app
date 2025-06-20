class JobFinderProfile {
  String email;
  String fullName;
  String skills;
  String education;

  JobFinderProfile({
    required this.email,
    required this.fullName,
    required this.skills,
    required this.education,
  });

  factory JobFinderProfile.fromJson(Map<String, dynamic> json) {
    return JobFinderProfile(
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      skills: json['skills'] ?? '',
      education: json['education'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'full_name': fullName,
        'skills': skills,
        'education': education,
      };
}
