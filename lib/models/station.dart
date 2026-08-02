class Station {
  final int? id;
  final String name;
  final String? location;
  final String? type;
  final String? imagePath;
  final String? additionalInfo;
  final int? isVisible; // NEW: Visibility field

  Station({
    this.id,
    required this.name,
    this.location,
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
      type: map['type'],
      imagePath: map['imagePath'],
      additionalInfo: map['additionalInfo'],
      isVisible: map['isVisible'] ?? 1, // NEW: Visibility field
    );
  }
}