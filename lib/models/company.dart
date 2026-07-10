class Company {
  final int? id;
  final String name;
  final String? location;
  final String? contactPerson;
  final String? email;
  final String? telephone;
  final String? website;
  final String? imagePath;
  final String? additionalInfo;

  Company({
    this.id,
    required this.name,
    this.location,
    this.contactPerson,
    this.email,
    this.telephone,
    this.website,
    this.imagePath,
    this.additionalInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'contactPerson': contactPerson,
      'email': email,
      'telephone': telephone,
      'website': website,
      'imagePath': imagePath,
      'additionalInfo': additionalInfo,
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      contactPerson: map['contactPerson'],
      email: map['email'],
      telephone: map['telephone'],
      website: map['website'],
      imagePath: map['imagePath'],
      additionalInfo: map['additionalInfo'],
    );
  }
}