class Station {
  final int? id;
  final String name;
  final String? location;
  final String? contactPerson;
  final String? email;
  final String? telephone;
  final String? website;
  final String? type;
  final String? imagePath;
  final String? additionalInfo;
  final int? isVisible; // NEW: Visibility field

  Station({
    this.id,
    required this.name,
    this.location,
    this.contactPerson,
    this.email,
    this.telephone,
    this.website,
    this.type,
    this.imagePath,
    this.additionalInfo,
    this.isVisible = 1, // NEW: Visibility field
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
      'type': type,
      'imagePath': imagePath,
      'additionalInfo': additionalInfo,
      'isVisible': isVisible, // NEW: Visibility field
    };
  }

  factory Station.fromMap(Map<String, dynamic> map) {
    return Station(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      contactPerson: map['contactPerson'],
      email: map['email'],
      telephone: map['telephone'],
      website: map['website'],
      type: map['type'],
      imagePath: map['imagePath'],
      additionalInfo: map['additionalInfo'],
      isVisible: map['isVisible'] ?? 1, // NEW: Visibility field
    );
  }
}