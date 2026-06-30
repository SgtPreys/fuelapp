class Station {
  final int? id;
  final String name;
  final String? location;
  final String? type;
  final String? additionalInfo;

  Station({
    this.id,
    required this.name,
    this.location,
    this.type,
    this.additionalInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'type': type,
      'additionalInfo': additionalInfo,
    };
  }

  factory Station.fromMap(Map<String, dynamic> map) {
    return Station(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      type: map['type'],
      additionalInfo: map['additionalInfo'],
    );
  }
}