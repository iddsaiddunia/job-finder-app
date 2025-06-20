class EmployerProfile {
  String email;
  String companyName;
  String validationInfo;
  String phone;
  String website;
  String address;
  String industry;
  String companySize;
  String description;

  EmployerProfile({
    required this.email,
    required this.companyName,
    required this.validationInfo,
    this.phone = '',
    this.website = '',
    this.address = '',
    this.industry = '',
    this.companySize = '',
    this.description = '',
  });

  factory EmployerProfile.fromJson(Map<String, dynamic> json) {
    return EmployerProfile(
      email: json['email'] ?? '',
      companyName: json['company_name'] ?? '',
      validationInfo: json['validation_info'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      address: json['address'] ?? '',
      industry: json['industry'] ?? '',
      companySize: json['company_size'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'company_name': companyName,
        'validation_info': validationInfo,
        'phone': phone,
        'website': website,
        'address': address,
        'industry': industry,
        'company_size': companySize,
        'description': description,
      };
}
