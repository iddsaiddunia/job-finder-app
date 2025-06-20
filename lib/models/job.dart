class Job {
  String title;
  String company;
  String location;
  String skills;
  String salary;
  String description;
  String requirements;

  Job({
    required this.title,
    required this.company,
    required this.location,
    required this.skills,
    required this.salary,
    required this.description,
    required this.requirements,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      skills: json['skills'] ?? '',
      salary: json['salary'] ?? '',
      description: json['description'] ?? '',
      requirements: json['requirements'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'company': company,
        'location': location,
        'skills': skills,
        'salary': salary,
        'description': description,
        'requirements': requirements,
      };
}
